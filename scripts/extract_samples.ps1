# Extract sample chapters from 南小华《贵人》(深圳，夜色迷人)
# Encoding: GBK (CodePage 936)
# Usage: Create the directory structure first, then run this script

$sourceFile = $args[0]  # Path to the source text file
$outDir = $args[1]      # Output directory for chapter files

# Read with GBK encoding
$bytes = [System.IO.File]::ReadAllBytes($sourceFile)
$text = [System.Text.Encoding]::GetEncoding(936).GetString($bytes)
$lines = $text -split "`r`n|`n"

# Find all chapter start lines
$chStarts = @()
for ($i = 7; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^第(\d{3})章') {
        $chStarts += @{ Ch = [int]$matches[1]; Line = $i }
    }
}

# Target chapters
$targets = @(1..30) + @(100, 200, 300, 400, 500, 600)

$extracted = 0
for ($j = 0; $j -lt $chStarts.Count; $j++) {
    $ch = $chStarts[$j].Ch
    if ($ch -in $targets) {
        $startLine = $chStarts[$j].Line
        $endLine = if ($j + 1 -lt $chStarts.Count) { $chStarts[$j + 1].Line - 1 } else { $lines.Count - 1 }
        $content = $lines[$startLine..$endLine]
        $filename = Join-Path $outDir ("Ch{0:D3}.txt" -f $ch)
        $content -join "`r`n" | Out-File $filename -Encoding utf8
        $extracted++
    }
}

Write-Host ("找到章节: {0}" -f $chStarts.Count)
Write-Host ("提取章节: {0}" -f $extracted)
Get-ChildItem $outDir -Name | Sort-Object | ForEach-Object { Write-Host $_ }
