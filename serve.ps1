# Local HTTP server for landscape-portfolio
# Run: powershell -ExecutionPolicy Bypass -File serve.ps1
# Stop: Ctrl+C

$port = 8080
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try { $listener.Start() }
catch {
    Write-Host "Port $port busy. Trying 5500..." -ForegroundColor Yellow
    $port = 5500
    $listener.Prefixes.Clear()
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
}

Write-Host ""
Write-Host "  Server running:  " -NoNewline
Write-Host "http://localhost:$port/" -ForegroundColor Cyan
Write-Host "  Serving folder:  $root" -ForegroundColor DarkGray
Write-Host "  Press Ctrl+C to stop" -ForegroundColor DarkGray
Write-Host ""

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response
        $path = [System.Uri]::UnescapeDataString($req.Url.LocalPath)
        if ($path -eq "/") { $path = "/index.html" }
        $filePath = Join-Path $root $path.TrimStart('/')

        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = switch ($ext) {
                '.html' { 'text/html; charset=utf-8' }
                '.htm'  { 'text/html; charset=utf-8' }
                '.css'  { 'text/css; charset=utf-8' }
                '.js'   { 'application/javascript; charset=utf-8' }
                '.json' { 'application/json; charset=utf-8' }
                '.jpg'  { 'image/jpeg' }
                '.jpeg' { 'image/jpeg' }
                '.png'  { 'image/png' }
                '.gif'  { 'image/gif' }
                '.svg'  { 'image/svg+xml' }
                '.webp' { 'image/webp' }
                '.ico'  { 'image/x-icon' }
                '.woff' { 'font/woff' }
                '.woff2'{ 'font/woff2' }
                default { 'application/octet-stream' }
            }
            $res.ContentType = $mime
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
            Write-Host "  200  " -NoNewline -ForegroundColor Green
            Write-Host $path
        } else {
            $res.StatusCode = 404
            $msg = [Text.Encoding]::UTF8.GetBytes("Not Found: $path")
            $res.OutputStream.Write($msg, 0, $msg.Length)
            Write-Host "  404  " -NoNewline -ForegroundColor Red
            Write-Host $path
        }
        $res.Close()
    } catch {
        Write-Host "  ERR  $($_.Exception.Message)" -ForegroundColor Red
    }
}
