from pydantic import BaseModel
from typing import List, Optional

# --- SCORE ---
class ScoreRequest(BaseModel):
    """
    Defines the structure of the incoming request to the /score endpoint.
    """
    scenario_id: str
    user_reply: str
    locale: str # e.g., "en" or "ne"

class Score(BaseModel):
    """
    A single scoring criterion and its result.
    """
    criterion: str
    score: int
    rationale: str

class ScoreResponse(BaseModel):
    """
    Defines the structure of the JSON response from the /score endpoint.
    """
    scores: List[Score]
    suggested_rewrite: str
    safety_flags: List[str]

# --- SCENARIO GENERATION ---
class ScenarioRequest(BaseModel):
    """
    Defines the optional input for generating a scenario.
    The user might suggest a topic.
    """
    topic: Optional[str] = None
    gentle_mode: bool = False

class ScenarioResponse(BaseModel):
    """
    Defines the structure of a dynamically generated scenario.
    """
    scenario_id: str
    context: str
    hate_speech_comment: str
    character_persona: str

# --- NEW: Telemetry Models ---
class TelemetryData(BaseModel):
    """
    Defines the structure for anonymous, aggregated metrics
    to measure learning and safety.
    """
    scenario_id: str
    rubric_score_gain: int # e.g., (final_score - initial_score)
    session_duration_seconds: int
    was_skipped: bool
    was_flagged_distressing: bool
    gentle_mode_active: bool

class LearnRequest(BaseModel):
    """
    Defines the incoming request for a lesson.
    """
    topic: str

class LearnResponse(BaseModel):
    """
    Defines the structured lesson content returned by the AI.
    """
    title: str
    content: List[str] 
    example: str

class QuizQuestion(BaseModel):
    """ Defines the structure for a single multiple-choice question. """
    question_text: str
    options: List[str]  # A list of 4 possible answers
    correct_answer_index: int # The index (0-3) of the correct answer in the options list

class QuizResponse(BaseModel):
    """ Defines the structure for the entire quiz. """
    questions: List[QuizQuestion]

class QuizRequest(BaseModel):
    """ Defines the incoming request for a quiz. """
    topic: str

class GameItemResponse(BaseModel):
    """
    Defines the structure for a single item in the deepfake game.
    """
    content: str  # The text snippet for the user to evaluate
    is_real: bool # The correct answer (True if real, False if AI-generated)
    explanation: str # A short sentence explaining why it's real or fake

class UpdateScoreRequest(BaseModel):
    user_id: str
    username: str
    xp_gained: int