from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Initialize client only if API key is available
client = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY and OPENAI_API_KEY != "your_openai_api_key_here" else None

def ask_openai(prompt):
    if not client:
        return "OpenAI API key not configured. Please set OPENAI_API_KEY in your .env file."
    
    try:
        resp = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
        )
        return resp.choices[0].message.content
    except Exception as e:
        return f"Error calling OpenAI: {str(e)}"
