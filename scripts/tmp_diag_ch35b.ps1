param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$content = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
Write-Output ("len=" + $content.Length)
Write-Output ("slice2000_2100=[" + $content.Substring(2000, 100) + "]")
$idxTail = $content.IndexOf("信息差的边界外")
Write-Output ("tailIdx=" + $idxTail)
$idxStart = $content.IndexOf("她下楼扔垃圾")
Write-Output ("startIdx=" + $idxStart)
$idxAuthor = $content.IndexOf("## 作者有话说")
Write-Output ("authorIdx=" + $idxAuthor)
$lines = $content -split "`n"
Write-Output ("lineCount=" + $lines.Count)
Write-Output ("line130=[" + $lines[129].Substring(0, [Math]::Min(30, $lines[129].Length)) + "]")
Write-Output ("line132=[" + $lines[131].Substring(0, [Math]::Min(30, $lines[131].Length)) + "]")
