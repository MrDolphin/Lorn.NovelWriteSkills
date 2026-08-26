param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
Write-Output ("totalLen=" + $content.Length)
$full = [regex]::Matches($content, '[\p{IsCJKUnifiedIdeographs}]').Count
Write-Output ("fullCJK=" + $full)
$idx = $content.IndexOf("## 作者有话说")
Write-Output ("authorIdx=" + $idx)
if ($idx -ge 0) {
    $body = $content.Substring(0, $idx)
    Write-Output ("bodyLen=" + $body.Length)
    $n = [regex]::Matches($body, '[\p{IsCJKUnifiedIdeographs}]').Count
    Write-Output ("bodyCJK=" + $n)
    $stripped = [regex]::Replace($body, '(?m)^#+\s.*$', '')
    Write-Output ("strippedLen=" + $stripped.Length)
    $n2 = [regex]::Matches($stripped, '[\p{IsCJKUnifiedIdeographs}]').Count
    Write-Output ("strippedCJK=" + $n2)
}
