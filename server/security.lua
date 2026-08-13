-- ============================================================
-- MTNC SECURITY & RATE LIMITING
-- ============================================================
Security = Security or {}

local requestCounts = {}

function Security.RateLimit(src, limit, windowSeconds)
    local now = os.time()
    if not requestCounts[src] then requestCounts[src] = {} end
    
    local valid = {}
    for _, t in ipairs(requestCounts[src]) do
        if (now - t) < (windowSeconds or 5) then
            table.insert(valid, t)
        end
    end
    table.insert(valid, now)
    requestCounts[src] = valid

    return #valid <= (limit or 15)
end

AddEventHandler('playerDropped', function()
    local src = source
    requestCounts[src] = nil
end)
