# check_imports.py - run inside your CONDA environment to verify key binary imports
import sys

def try_import(name, alias=None):
    try:
        module = __import__(name)
        ver = getattr(module, "__version__", None)
        print(f"{name} import OK, version: {ver}")
        return True
    except ModuleNotFoundError:
        print(f"{name} not installed in this environment.")
        return False
    except Exception as e:
        print(f"{name} import error: {repr(e)}")
        return False

print("Python:", sys.version.splitlines()[0])
ok_numpy = try_import("numpy")
ok_cv2 = try_import("cv2")
ok_tf = try_import("tensorflow")

print("\nSummary:")
print(" - numpy:", "OK" if ok_numpy else "MISSING")
print(" - cv2   :", "OK" if ok_cv2 else "MISSING or error")
print(" - tf    :", "OK" if ok_tf else "MISSING or error")

if not ok_numpy:
    print("\nRecommendation: activate your conda env (or install numpy into your venv).")
    print("  If using conda (recommended), open Anaconda Prompt and run:")
    print("    conda activate dayaw")
    print("    python check_imports.py")
    print("  If using the current virtualenv (.venv), run:")
    print("    & .\\.venv\\Scripts\\Activate.ps1")
    print("    pip install numpy")
    print("Then re-run this script.")