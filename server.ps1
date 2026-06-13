$port = 8080
$root = "C:\Users\emrej\Desktop\ZHuB-Website"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "ZHuB Web Server running on port $port..."
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $req = $context.Request
        $res = $context.Response
        
        $path = $req.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        $fullPath = Join-Path $root $path
        
        if (Test-Path $fullPath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            
            # Set content types
            if ($path.EndsWith(".html")) { $res.ContentType = "text/html" }
            elseif ($path.EndsWith(".css")) { $res.ContentType = "text/css" }
            elseif ($path.EndsWith(".js")) { $res.ContentType = "application/javascript" }
            elseif ($path.EndsWith(".lua")) { $res.ContentType = "text/plain" }
            
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
            $res.StatusCode = 200
        } else {
            $res.StatusCode = 404
        }
        $res.Close()
    }
} finally {
    $listener.Stop()
}
