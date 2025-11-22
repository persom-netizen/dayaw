# gemini_probe_all.ps1
# Run from C:\xampp\htdocs\DAYAW\backend
# Requires: .\.venv\Scripts\python.exe and gemini_test.py present in this folder.
# This script will iterate candidate models, run gemini_test.py with each model,
# capture logs to ./gemini_logs and produce summary.csv

$models = @(
  "models/embedding-gecko-001",
  "models/gemini-2.5-pro-preview-03-25",
  "models/gemini-2.5-flash",
  "models/gemini-2.5-pro-preview-05-06",
  "models/gemini-2.5-pro-preview-06-05",
  "models/gemini-2.5-pro",
  "models/gemini-2.0-flash-exp",
  "models/gemini-2.0-flash",
  "models/gemini-2.0-flash-001",
  "models/gemini-2.0-flash-exp-image-generation",
  "models/gemini-2.0-flash-lite-001",
  "models/gemini-2.0-flash-lite",
  "models/gemini-2.0-flash-lite-preview-02-05",
  "models/gemini-2.0-flash-lite-preview",
  "models/gemini-2.0-pro-exp",
  "models/gemini-2.0-pro-exp-02-05",
  "models/gemini-exp-1206",
  "models/gemini-2.0-flash-thinking-exp-01-21",
  "models/gemini-2.0-flash-thinking-exp",
  "models/gemini-2.0-flash-thinking-exp-1219",
  "models/gemini-2.5-flash-preview-tts",
  "models/gemini-2.5-pro-preview-tts",
  "models/learnlm-2.0-flash-experimental",
  "models/gemma-3-1b-it",
  "models/gemma-3-4b-it",
  "models/gemma-3-12b-it",
  "models/gemma-3-27b-it",
  "models/gemma-3n-e4b-it",
  "models/gemma-3n-e2b-it",
  "models/gemini-flash-latest",
  "models/gemini-flash-lite-latest",
  "models/gemini-pro-latest",
  "models/gemini-2.5-flash-lite",
  "models/gemini-2.5-flash-image-preview",
  "models/gemini-2.5-flash-image",
  "models/gemini-2.5-flash-preview-09-2025",
  "models/gemini-2.5-flash-lite-preview-09-2025",
  "models/gemini-3-pro-preview",
  "models/gemini-robotics-er-1.5-preview",
  "models/gemini-2.5-computer-use-preview-10-2025",
  "models/embedding-001",
  "models/text-embedding-004",
  "models/gemini-embedding-exp-03-07",
  "models/gemini-embedding-exp",
  "models/gemini-embedding-001",
  "models/aqa",
  "models/imagen-4.0-generate-preview-06-06",
  "models/imagen-4.0-ultra-generate-preview-06-06",
  "models/imagen-4.0-generate-001",
  "models/imagen-4.0-ultra-generate-001",
  "models/imagen-4.0-fast-generate-001",
  "models/veo-2.0-generate-001",
  "models/veo-3.0-generate-001",
  "models/veo-3.0-fast-generate-001",
  "models/veo-3.1-generate-preview",
  "models/veo-3.1-fast-generate-preview",
  "models/gemini-2.0-flash-live-001",
  "models/gemini-live-2.5-flash-preview",
  "models/gemini-2.5-flash-live-preview",
  "models/gemini-2.5-flash-native-audio-latest",
  "models/gemini-2.5-flash-native-audio-preview-09-2025"
)

$logDir = Join-Path -Path (Get-Location) -ChildPath "gemini_logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

$venvPython = ".\.venv\Scripts\python.exe"
$testScript = ".\gemini_test.py"
$summaryFile = Join-Path $logDir "summary.csv"
"model,result,logfile" | Out-File -FilePath $summaryFile -Encoding utf8

foreach ($model in $models) {
    Write-Host "=== Testing model: $model ===" -ForegroundColor Cyan
    $env:GOOGLE_MODEL = $model
    $safeName = ($model -replace "[\/:\s]","_")
    $logFile = Join-Path $logDir ("test_" + $safeName + ".log")
    & $venvPython $testScript *> $logFile
    $logText = ""
    if (Test-Path $logFile) { $logText = Get-Content $logFile -Raw -ErrorAction SilentlyContinue }
    if ($logText -match "SUCCESS:") {
        $result = "success"
    } elseif ($logText -match "Generation error: 404|NotFound") {
        $result = "404_not_found"
    } elseif ($logText -match "Google Generative AI API key not configured") {
        $result = "not_configured"
    } elseif ($logText -match "Generation error:") {
        $result = "failed"
    } else {
        $result = "unknown"
    }
    "$model,$result,$logFile" | Out-File -FilePath $summaryFile -Append -Encoding utf8
    Write-Host "Model $model -> $result (log: $logFile)" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 700
}

Write-Host "=== Done. Summary written to $summaryFile ===" -ForegroundColor Green