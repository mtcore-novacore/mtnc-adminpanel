-- ============================================================
-- MTNC REPORT SYSTEM
-- ============================================================
Reports = Reports or {}

local ticketList = {}

RegisterNetEvent('mtnc:server:createReport', function(data)
    local src = source
    if not Security.RateLimit(src) then return end

    local reportId = #ticketList + 1
    local rep = {
        id = reportId,
        authorSrc = src,
        authorName = FrameworkAdapter.GetCharacterName(src),
        targetId = data.targetId or 'N/A',
        category = data.category or 'Spiller Report',
        reason = data.reason or 'Ingen årsag',
        status = 'OPEN',
        claimedBy = nil,
        time = os.date('%H:%M')
    }

    table.insert(ticketList, 1, rep)
    TriggerClientEvent('mtnc:client:toast', src, '🟢 Din report #' .. reportId .. ' er modtaget!', 'success')
    Audit.Log('REPORT_CREATED', src, nil, { id = reportId, reason = rep.reason })
end)

RegisterNetEvent('mtnc:server:getReports', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.reports.manage') then return end
    TriggerClientEvent('mtnc:client:receiveReports', src, ticketList)
end)

RegisterNetEvent('mtnc:server:actionReport', function(reportId, action)
    local src = source
    if not Permissions.HasPermission(src, 'admin.reports.manage') then return end

    for _, r in ipairs(ticketList) do
        if r.id == reportId then
            if action == 'claim' then
                r.claimedBy = GetPlayerName(src)
                r.status = 'CLAIMED'
            elseif action == 'close' then
                r.status = 'CLOSED'
            end
            Audit.Log('REPORT_ACTION', src, r.authorSrc, { id = reportId, action = action })
            break
        end
    end

    TriggerClientEvent('mtnc:client:receiveReports', src, ticketList)
end)
