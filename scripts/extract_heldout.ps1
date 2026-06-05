$sourceFile = $args[0]; $outDir = $args[1]; $targets = $args[2] -split ','
$bytes = [System.IO.File]::ReadAllBytes($sourceFile)
$txt = [System.Text.Encoding]::GetEncoding(936).GetString($bytes)
$lines = $txt -split "`r`n|`n"
$chStarts = @{}
for($i=7;$i -lt $lines.Count;$i++){ if($lines[$i] -match '^第(\d{3})章'){ $chStarts[[int]$matches[1]]=$i } }
New-Item -ItemType Directory -Force $outDir | Out-Null
$keys = ($chStarts.Keys | Sort-Object)
for($j=0;$j -lt $keys.Count;$j++){
    $ch = $keys[$j]
    if($ch -in ($targets|%{[int]$_})){
        $s=$chStarts[$ch]; $e=if($j+1 -lt $keys.Count){$chStarts[$keys[$j+1]]-1}else{$lines.Count-1}
        $c=$lines[$s..$e]; $c -join "`r`n" | Out-File (Join-Path $outDir "Ch$('{0:D3}' -f $ch).txt") -Encoding utf8
    }
}
Get-ChildItem $outDir -Name | Sort | % { Write-Host $_ }