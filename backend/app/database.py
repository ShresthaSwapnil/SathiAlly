# backend/app/database.py
from sqlalchemy import create_engine, Column, String, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = os.getenv("DATABASE_URL") # We will set this in Render

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Define our Leaderboard table structure
class Leaderboard(Base):
    __tablename__ = "leaderboard"
    user_id = Column(String, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    total_xp = Column(Integer, default=0)

# Create the table in the database if it doesn't exist
def create_db_and_tables():
    Base.metadata.create_all(bind=engine)