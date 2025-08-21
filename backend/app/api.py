import os
import json
import uuid
from fastapi import APIRouter, HTTPException, Depends
from .models import ScoreRequest, ScoreResponse, ScenarioRequest, ScenarioResponse, TelemetryData, LearnRequest, LearnResponse, QuizRequest, QuizResponse, GameItemResponse, UpdateScoreRequest
import google.generativeai as genai
from dotenv import load_dotenv
from .database import SessionLocal, Leaderboard
from sqlalchemy.orm import Session

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

# --- NEW: PROMPT ENGINEERING for Lesson Generation ---
SYSTEM_PROMPT_LESSON = """
You are an expert educator and content creator for "Netra," an app that teaches Media and Information Literacy (MIL) to a young, tech-savvy audience (ages 16-25).
Your task is to generate a short, clear, and highly engaging lesson on a specific MIL topic. The tone should be friendly, encouraging, and easy to understand. Use simple analogies where possible.

You MUST respond ONLY with a valid JSON object that follows this exact structure:
{
  "title": "<A catchy and clear title for the lesson>",
  "content": [
    "<Paragraph 1: A simple introduction explaining what the topic is and why it matters.>",
    "<Paragraph 2: A core explanation with more detail or a key concept.>",
    "<Paragraph 3: A concluding thought or a piece of actionable advice.>"
  ],
  "example": "<A short, concrete example of the topic in a real-world online scenario.>"
}
"""

# --- NEW: PROMPT ENGINEERING for Quiz Generation ---
SYSTEM_PROMPT_QUIZ = """
You are a master quiz creator for "Netra," an app that teaches Media and Information Literacy (MIL) to a young audience.
Your task is to generate a short, 3-question multiple-choice quiz based on a specific MIL topic.
The questions must be clear, relevant to the topic, and test the user's understanding.
Provide 4 plausible options for each question, with one clear correct answer.

You MUST respond ONLY with a valid JSON object that follows this exact structure:
{
  "questions": [
    {
      "question_text": "<The first question>",
      "options": [
        "<Option A>",
        "<Option B>",
        "<Option C>",
        "<Option D>"
      ],
      "correct_answer_index": <The index of the correct answer (0, 1, 2, or 3)>
    },
    {
      "question_text": "<The second question>",
      "options": ["<A>", "<B>", "<C>", "<D>"],
      "correct_answer_index": <0, 1, 2, or 3>
    },
    {
      "question_text": "<The third question>",
      "options": ["<A>", "<B>", "<C>", "<D>"],
      "correct_answer_index": <0, 1, 2, or 3>
    }
  ]
}
"""

# --- PROMPT ENGINEERING for Game Item Generation ---
SYSTEM_PROMPT_GAME_ITEM = """
You are a content designer for a game within the "Netra" app. The game is called "Real or Fake?".
Your task is to generate a single game item. You must FIRST randomly decide to either:
A) Write a short, plausible-sounding but completely FAKE news headline or a short, fake paragraph on a common topic (e.g., science, tech, history).
B) Write a short, FACTUAL news headline or a short, factual paragraph summarizing a well-known, real event.

After generating the content, you must provide a boolean `is_real` and a short, helpful `explanation` for why the content is real or fake. The explanation is the most important part for teaching the user.

You MUST respond ONLY with a valid JSON object that follows this exact structure:
{
  "content": "<The text snippet you generated>",
  "is_real": <true_or_false>,
  "explanation": "<A concise explanation. e.g., 'This is fake because this event never happened.' or 'This is real; it refers to the moon landing in 1969.'>"
}
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

@router.post("/generate_lesson", response_model=LearnResponse)
async def generate_lesson(request: LearnRequest):
    """
    Generates a personalized educational lesson on a given MIL topic.
    """
    try:
        full_prompt = f"{SYSTEM_PROMPT_LESSON}\n\nPlease generate a lesson on the topic of: '{request.topic}'."

        response = await model.generate_content_async(full_prompt)
        cleaned_response_text = response.text.strip().replace("```json", "").replace("```", "").strip()
        ai_output = json.loads(cleaned_response_text)
        
        return LearnResponse(**ai_output)
    except Exception as e:
        print(f"An unexpected error occurred during lesson generation: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during lesson generation.")  
    
@router.post("/generate_quiz", response_model=QuizResponse)
async def generate_quiz(request: QuizRequest):
    """
    Generates a 3-question quiz on a given MIL topic.
    """
    try:
        full_prompt = f"{SYSTEM_PROMPT_QUIZ}\n\nPlease generate a quiz on the topic of: '{request.topic}'."
        response = await model.generate_content_async(full_prompt)
        cleaned_response_text = response.text.strip().replace("```json", "").replace("```", "").strip()
        ai_output = json.loads(cleaned_response_text)
        return QuizResponse(**ai_output)
    except Exception as e:
        print(f"An unexpected error occurred during quiz generation: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during quiz generation.")
    
@router.get("/generate_game_item", response_model=GameItemResponse)
async def generate_game_item():
    """
    Generates a single "Real or Fake?" game item (text-based).
    """
    try:
        # We use the same prompt every time and let the AI handle the randomization.
        response = await model.generate_content_async(SYSTEM_PROMPT_GAME_ITEM)
        cleaned_response_text = response.text.strip().replace("```json", "").replace("```", "").strip()
        ai_output = json.loads(cleaned_response_text)
        return GameItemResponse(**ai_output)
    except Exception as e:
        print(f"An unexpected error occurred during game item generation: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during game item generation.")
    

# Dependency to get a DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/update_score")
def update_score(request: UpdateScoreRequest, db: Session = Depends(get_db)):
    """
    Updates a user's total XP. Creates the user if they don't exist.
    """
    user = db.query(Leaderboard).filter(Leaderboard.user_id == request.user_id).first()
    if user:
        user.total_xp += request.xp_gained
    else:
        new_user = Leaderboard(
            user_id=request.user_id,
            username=request.username,
            total_xp=request.xp_gained
        )
        db.add(new_user)
    db.commit()
    return {"status": "success"}

@router.get("/leaderboard")
def get_leaderboard(db: Session = Depends(get_db)):
    """
    Returns the top 50 users sorted by total_xp.
    """
    leaderboard = db.query(Leaderboard).order_by(Leaderboard.total_xp.desc()).limit(50).all()
    return leaderboard

@router.get("/ping")
def ping():
    """ A simple endpoint to verify the API is running and to wake it up. """
    return {"status": "alive"}