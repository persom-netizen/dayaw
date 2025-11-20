import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from openai import OpenAI

# Get the backend directory path
BACKEND_DIR = Path(__file__).parent
ENV_FILE = BACKEND_DIR / ".env"

print(f"DEBUG: Looking for .env at: {ENV_FILE}")
print(f"DEBUG: .env exists: {ENV_FILE.exists()}")

# Load environment variables from .env file
load_dotenv(dotenv_path=ENV_FILE)

# Get API key from environment
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

print(f"DEBUG: OPENAI_API_KEY value: {OPENAI_API_KEY}")
if OPENAI_API_KEY:
    print(f"DEBUG: OPENAI_API_KEY loaded: {OPENAI_API_KEY[:20]}...")
else:
    print("DEBUG: OPENAI_API_KEY is NOT SET")

# Initialize client only if API key is available
client = None
if OPENAI_API_KEY and OPENAI_API_KEY != "your_openai_api_key_here":
    try:
        client = OpenAI(api_key=OPENAI_API_KEY)
        print("✅ DEBUG: OpenAI client initialized successfully")
    except Exception as e:
        print(f"❌ DEBUG: Error initializing OpenAI client: {e}")
else:
    print("❌ DEBUG: OPENAI_API_KEY is not set or is a placeholder")

def ask_openai(prompt):
    """
    Ask OpenAI a question, with response in Filipino.
    """
    if not client:
        error_msg = "OpenAI API key not configured. Please set OPENAI_API_KEY in your .env file."
        print(f"❌ ERROR: {error_msg}")
        return error_msg
    
    try:
        # Add Filipino language instruction to the prompt
        system_message = """You are a helpful assistant that speaks only in Filipino (Tagalog). 
        Always respond in clear, natural Filipino. If the user asks in English, respond in Filipino.
        Be friendly, educational, and culturally aware."""
        
        resp = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_message},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
        )
        return resp.choices[0].message.content
    except Exception as e:
        print(f"❌ DEBUG: OpenAI API error: {e}")
        return f"Error calling OpenAI: {str(e)}"   