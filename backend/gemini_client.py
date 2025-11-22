import os
from pathlib import Path
from dotenv import load_dotenv
import traceback

# Try to import the Google Generative AI SDK
try:
    import google.generativeai as genai
except Exception as e:
    genai = None
    print(f"DEBUG: google.generativeai import failed: {e}")

# Load .env from backend folder (safe for local dev)
BACKEND_DIR = Path(__file__).parent
ENV_FILE = BACKEND_DIR / ".env"
load_dotenv(dotenv_path=ENV_FILE)

def _configure_client():
    if genai is None:
        return False, "google.generativeai SDK not installed"
    key = os.getenv("GOOGLE_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not key:
        return False, "GOOGLE_API_KEY not set in environment"
    try:
        genai.configure(api_key=key)
        return True, "configured"
    except Exception as e:
        return False, f"error configuring SDK: {e}"

def _list_models():
    try:
        models = list(genai.list_models())
        names = [getattr(m, "name", None) or getattr(m, "model", None) or str(m) for m in models]
        return True, names
    except Exception as e:
        return False, str(e)

def ask_gemini(prompt: str, max_output_tokens: int = 512) -> str:
    """
    Ask Google Generative AI (Gemini) for a response in Filipino.
    Uses environment variable GOOGLE_MODEL to choose model if set.
    """
    try:
        client_ready, reason = _configure_client()
        if not client_ready:
            msg = f"Google Generative AI API key not configured. Reason: {reason}"
            print("DEBUG:", msg)
            return "Google Generative AI API key not configured. Please set GOOGLE_API_KEY in your .env file."

        # system instruction to prefer Filipino
        system_instruction = (
            "You are a helpful assistant that speaks only in Filipino (Tagalog). "
            "Always respond clearly and naturally in Filipino. If the user asks in English, respond in Filipino. "
            "Be friendly, educational, and culturally aware."
        )
        full_prompt = f"{system_instruction}\n\nUser: {prompt}\nAssistant:"

        # model selection strategy:
        env_model = os.getenv("GOOGLE_MODEL")
        model_candidates = []
        if env_model:
            model_candidates.append(env_model)

        # app-level fallbacks (common example model IDs). Keep these but they may not exist in your project.
        model_candidates += [
            "models/gemini-1.5-mini",
            "models/gemini-1.5",
            "models/text-bison-001",
            "models/chat-bison-001",
            "models/text-bison-002",
        ]

        last_exception = None
        for model in model_candidates:
            try:
                print(f"DEBUG: Trying model {model}")
                resp = genai.generate_text(model=model, prompt=full_prompt, max_output_tokens=max_output_tokens)
                # parse common response shapes
                if hasattr(resp, "text") and resp.text:
                    return resp.text
                candidates = getattr(resp, "candidates", None)
                if candidates and len(candidates) > 0:
                    first = candidates[0]
                    if hasattr(first, "output") and first.output:
                        return first.output
                    if hasattr(first, "content") and first.content:
                        return first.content
                    if hasattr(first, "text") and first.text:
                        return first.text
                return str(resp)
            except Exception as e:
                last_exception = e
                # If it's a NotFound (404) or permission, print and continue to try other candidates
                print(f"DEBUG: model {model} failed: {e}")
                continue

        # Try listing models and pick one heuristically
        ok, result = _list_models()
        if ok:
            names = result
            # try to pick one we think will work
            pick = None
            for prefer in ("gemini", "bison", "chat"):
                for n in names:
                    if n and prefer in n.lower():
                        pick = n
                        break
                if pick:
                    break
            if not pick and names:
                pick = names[0]
            if pick:
                try:
                    print(f"DEBUG: Falling back to available model {pick}")
                    resp = genai.generate_text(model=pick, prompt=full_prompt, max_output_tokens=max_output_tokens)
                    if hasattr(resp, "text") and resp.text:
                        return resp.text
                    candidates = getattr(resp, "candidates", None)
                    if candidates and len(candidates) > 0:
                        first = candidates[0]
                        return getattr(first, "output", getattr(first, "content", getattr(first, "text", str(first))))
                    return str(resp)
                except Exception as e:
                    print(f"DEBUG: fallback model {pick} failed: {e}")
                    return f"Error: model {pick} failed: {e}"
            else:
                return f"Error: no models available in your project. Models list: {names}"
        else:
            return f"Error: all candidate models failed. Last exception: {last_exception}. Also failed to list models: {result}"
    except Exception as e:
        print("❌ DEBUG: ask_gemini unexpected error:", e)
        return f"Error calling Gemini: {e}"