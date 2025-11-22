# Create Baybayin dataset folders

$base_dir = "sulatin_dataset"
if (-not (Test-Path $base_dir)) { New-Item -ItemType Directory -Name $base_dir | Out-Null }

$characters = @(
    # Consonants alone
    "k", "p", "t", "n", "d", "b", "m", "l", "g", "ng", "s", "h", "w", "y", "r",
    
    # Vowels
    "a", "e", "i", "o", "u",
    
    # With 'a' vowel
    "ka", "pa", "ta", "na", "da", "ba", "ma", "la", "ga", "nga", "sa", "ha", "wa", "ya", "ra",
    
    # With 'e' vowel
    "ke", "pe", "te", "ne", "de", "be", "me", "le", "ge", "nge", "se", "he", "we", "ye", "re",
    
    # With 'u' vowel
    "ku", "pu", "tu", "nu", "du", "bu", "mu", "lu", "gu", "ngu", "su", "hu", "wu", "yu", "ru"
)

foreach ($char in $characters) {
    $folder_path = Join-Path $base_dir $char
    if (-not (Test-Path $folder_path)) {
        New-Item -ItemType Directory -Path $folder_path | Out-Null
        Write-Host "Created: $folder_path"
    } else {
        Write-Host "Already exists: $folder_path"
    }
}

Write-Host "`nDone! Created $(($characters | Measure-Object).Count) character folders in $base_dir"