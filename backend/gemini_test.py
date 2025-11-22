# Simple test to list available models and try a generation
from pathlib import Path
from dotenv import load_dotenv
import os, traceback

# ensure .env is loaded from backend directory
HERE = Path(__file__).parent
load_dotenv(dotenv_path=HERE / ".env")

try:
    import google.generativeai as genai
except Exception as e:
    print("ERROR: google.generativeai import failed:", e)
    raise SystemExit(1)

# configure using environment variable
KEY = os.getenv("GOOGLE_API_KEY")
if not KEY:
    print("ERROR: GOOGLE_API_KEY not set in environment/.env")
    raise SystemExit(1)

genai.configure(api_key=KEY)
print("INFO: genai configured")

# list models
print("\n== Listing available models ==")
try:
    models = genai.list_models()  # SDK call to list models
    # models may be an iterable of model objects; print relevant info
    for m in models:
        # attempt to show common attributes
        name = getattr(m, "name", None) or getattr(m, "model", None) or str(m)
        print("-", name)
except Exception as e:
    print("ERROR listing models:", e)
    traceback.print_exc()

# Try a short generation with an environment-specified model or the first 'bison' or 'gemini' model
model_env = os.getenv("GOOGLE_MODEL")  # optional override
candidate_model = model_env
if not candidate_model:
    # attempt to pick one from the model list above heuristically
    try:
        models = list(genai.list_models())
        names = [getattr(m, "name", None) or getattr(m, "model", None) or str(m) for m in models]
        # prefer gemini, then bison, then chat-bison, else first
        for prefer in ("gemini", "bison", "chat"):
            for n in names:
                if n and prefer in n.lower():
                    candidate_model = n
                    break
            if candidate_model:
                break
        if not candidate_model and names:
            candidate_model = names[0]
    except Exception:
        candidate_model = None

print("\nSelected model for test:", candidate_model)

if candidate_model:
    prompt = "Magbigay ng isang maikling (2 pangungusap) pagpapakilala tungkol sa jeepney sa Filipino."
    print("\n== Trying a generation using model:", candidate_model)
    try:
        resp = genai.generate_text(model=candidate_model, prompt=prompt, max_output_tokens=200)
        # try common response shapes
        if hasattr(resp, "text") and resp.text:
            print(resp.text)
        else:
            candidates = getattr(resp, "candidates", None)
            if candidates and len(candidates) > 0:
                first = candidates[0]
                print(getattr(first, "output", getattr(first, "content", getattr(first, "text", str(first)))))
            else:
                print("Raw response:", resp)
    except Exception as e:
        print("Generation error:", e)
        traceback.print_exc()
else:
    print("No model selected; cannot run generation test.")