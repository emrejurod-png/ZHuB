-- ZHuB Loader v3.0
-- Universal Script Entry Point (Stealth Mode)

local url = "https://emrejurod-png.github.io/ZHuB/api/index.html"
local success, result = pcall(function()
    return game:HttpGet(url)
end)

if success and result then
    -- Extract the hidden script from the 403 Unauthorized HTML page
    local s, e = result:find("%[ZHUB_DATA_START%]")
    local s2, e2 = result:find("%[ZHUB_DATA_END%]")
    local scriptContent = nil
    
    if s and e and s2 then
        scriptContent = result:sub(e + 1, s2 - 1)
    end
    
    if scriptContent then
        local func, err = loadstring(scriptContent)
        if func then
            func()
        else
            warn("[ZHuB] Syntax error in core: ", err)
        end
    else
        warn("[ZHuB] Could not extract script from secure endpoint. Ensure you are authorized.")
    end
else
    warn("[ZHuB] Failed to connect to secure server.")
end
