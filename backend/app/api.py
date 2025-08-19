import os
import json
import uuid
from fastapi import APIRouter, HTTPException
from .models import ScoreRequest, ScoreResponse, ScenarioRequest, ScenarioResponse, TelemetryData
import google.generativeai as genai
from dotenv import load_dotenv

# --- SETUP ---

# Load environment variables from the .env file
load_dotenv()

# Configure the Gemini API client with the key from the environment
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError("No GOOGLE_API_KEY found. Please set it in your .env file.")

genai.configure(api_key=GOOGLE_API_KEY)

# Initialize the Gemini model
# We use gemini-1.5-flash as it's fast and cost-effective.
model = genai.GenerativeModel('gemini-1.5-flash')

# APIRouter allows us to organize endpoints
router = APIRouter()

# --- PROMPT ENGINEERING for Scoring  ---

# This is the core instruction for our AI coach.
# We tell it its role, the scoring rubric, and the exact JSON format to reply in.
SYSTEM_PROMPT_SCORING = """
You are an AI coach for Sathi Ally, a platform that trains youth to de-escalate online hate speech. 
Your task is to score a user's reply to a hostile online comment based on a clear rubric. 
You must provide a score (0-3), a concise rationale for each criterion, and a constructive, improved rewrite of the user's reply.

You MUST respond ONLY with a valid JSON object that follows this exact structure:
{
  "scores": [
    {"criterion": "De-escalation", "score": <0-3>, "rationale": "<Your rationale>"},
    {"criterion": "Accuracy and reframing", "score": <0-3>, "rationale": "<Your rationale>"},
    {"criterion": "Care for targets/bystanders", "score": <0-3>, "rationale": "<Your rationale>"},
    {"criterion": "Platform fit", "score": <0-3>, "rationale": "<Your rationale>"},
    {"criterion": "Self-protection", "score": <0-3>, "rationale": "<Your rationale>"}
  ],
  "suggested_rewrite": "<Your improved version of the user's reply>",
  "safety_flags": []
}

Analyze the following user reply and provide your assessment in the specified JSON format.
"""

# --- PROMPT ENGINEERING for Scenario Generation ---
SYSTEM_PROMPT_SCENARIO = """
You are a creative content designer for Sathi Ally, a training app against online hate speech.
Your task is to generate a single, realistic, and challenging online hate speech scenario.
The scenario must be self-contained and provide enough context for a user to respond to.
Avoid overly graphic content, but make the comment feel authentic and harmful.

You MUST respond ONLY with a valid JSON object that follows this exact structure:
{
  "context": "<A short, one-sentence description of the online setting. e.g., 'In the comments of a YouTube video reviewing a new movie...'>",
  "character_persona": "<A brief, one-sentence description of the person making the comment. e.g., 'A user who believes the movie is pushing a political agenda.'>",
  "hate_speech_comment": "<The specific toxic or harmful comment the user needs to respond to.>"
}

Do not include any other text, explanations, or markdown formatting around the JSON object.
"""

# --- API ENDPOINT ---

@router.post("/score", response_model=ScoreResponse)
async def score_reply(request: ScoreRequest):
    """
    This endpoint receives a user's reply and returns an AI-generated score and feedback.
    """
    try:
        # Combine the system prompt with the user's specific reply
        full_prompt = f"{SYSTEM_PROMPT_SCORING}\n\nUser Reply to analyze: \"{request.user_reply}\""

        # Call the Gemini API
        response = await model.generate_content_async(full_prompt)

        # The response text might have markdown backticks (```json ... ```) around the JSON.
        # We need to clean this to parse it correctly.
        cleaned_response_text = response.text.strip().replace("```json", "").replace("```", "").strip()

        # Convert the JSON string from the AI into a Python dictionary
        ai_output = json.loads(cleaned_response_text)

        # Validate the received data with our Pydantic model and return it
        return ScoreResponse(**ai_output)

    except json.JSONDecodeError:
        # This error happens if the AI's response isn't valid JSON
        print("Error: Failed to decode JSON from AI response.")
        print(f"AI Raw Response: {response.text}")
        raise HTTPException(status_code=500, detail="AI response was not in valid JSON format.")
    except Exception as e:
        # Handle other potential errors (e.g., API key issue, network problem)
        print(f"An unexpected error occurred: {e}")
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {str(e)}")
    
# --- SCENARIO GENERATION API ENDPOINT ---
@router.post("/generate_scenario", response_model=ScenarioResponse)
async def generate_scenario(request: ScenarioRequest):
    """
    Generates a unique hate speech scenario using the AI.
    An optional topic can be provided to guide the generation.
    """
    try:
        # Build the prompt, adding the topic if one was provided by the user
        prompt_addition = ""
        if request.topic:
            prompt_addition = f"\n\nPlease ensure the scenario is related to the topic of: '{request.topic}'."

        # If gentle_mode is true, add specific instructions to the AI
        if request.gentle_mode:
            prompt_addition += "\nIMPORTANT: Please generate a 'gentle mode' scenario. This means the comment should be a microaggression, subtly biased, or based on misinformation rather than direct, aggressive hate speech. The tone should be less confrontational."
        
        full_prompt = f"{SYSTEM_PROMPT_SCENARIO}{prompt_addition}"

        # Call the Gemini API
        response = await model.generate_content_async(full_prompt)
        
        # Clean and parse the JSON response
        cleaned_response_text = response.text.strip().replace("```json", "").replace("```", "").strip()
        ai_output = json.loads(cleaned_response_text)

        # Create the final response object, adding a unique ID
        return ScenarioResponse(
            scenario_id=str(uuid.uuid4()), # Generate a new unique ID for this scenario
            **ai_output
        )

    except json.JSONDecodeError:
        print(f"Error: Failed to decode JSON from AI scenario response. Raw: {response.text}")
        raise HTTPException(status_code=500, detail="AI response (scenario) was not in valid JSON format.")
    except Exception as e:
        print(f"An unexpected error occurred during scenario generation: {e}")
        raise HTTPException(status_code=500, detail=f"An internal error occurred during scenario generation: {str(e)}")
    
# --- NEW: TELEMETRY ENDPOINT ---
@router.post("/telemetry", status_code=202)
async def receive_telemetry(data: TelemetryData):
    """
    Receives anonymous, aggregated data about user sessions.
    This helps measure impact and improve the app.
    In a real app, this would be stored in a database for analysis.
    For the hackathon, we'll just print it to show the functionality.
    """
    print("--- 📈 TELEMETRY DATA RECEIVED 📈 ---")
    print(data.model_dump_json(indent=2))
    print("------------------------------------")
    
    # We return a 202 "Accepted" status because the client doesn't need to wait for
    # any processing to happen after sending the data.
    return {"status": "accepted"}