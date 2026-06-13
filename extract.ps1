$logPath = "C:\Users\emrej\.gemini\antigravity\brain\6e89f0ec-7881-4fd7-a0cb-48e3dd6dcc1b\.system_generated\logs\transcript_full.jsonl"
$htmlPath = "C:\Users\emrej\Desktop\ZHuB-Website\api\index.html"

$lastUserInput = ""
Get-Content $logPath -ReadCount 1000 | ForEach-Object {
    foreach ($line in $_) {
        if ($line -match '"type":"USER_INPUT"') {
            $lastUserInput = $line
        }
    }
}

if ($lastUserInput -eq "") { Write-Host "No input found"; exit 1 }

$jsonObj = $lastUserInput | ConvertFrom-Json
$content = $jsonObj.content

# Strip any <USER_REQUEST> tags if they exist
$content = $content -replace "(?s)<USER_REQUEST>.*?</USER_REQUEST>", { $_.Value.Substring(14, $_.Value.Length - 29) }
$content = $content -replace "<USER_REQUEST>", ""
$content = $content -replace "</USER_REQUEST>", ""
$content = $content -replace "(?s)<ADDITIONAL_METADATA>.*?</ADDITIONAL_METADATA>", ""

$content = $content.Trim()

Write-Host "Script length extracted: $($content.Length)"

$htmlContent = Get-Content $htmlPath -Raw
$pattern = "(?s)<!-- \[ZHUB_DATA_START\].*?\[ZHUB_DATA_END\] -->"
$htmlContent = $htmlContent -replace $pattern, ""
$newBlock = "<!-- [ZHUB_DATA_START]`n$content`n[ZHUB_DATA_END] -->`n"
$htmlContent = $htmlContent.Replace("</body>", "$newBlock</body>")

[IO.File]::WriteAllText($htmlPath, $htmlContent)
Write-Host "Done!"
