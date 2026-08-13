-- ============================================================
-- MTNC ADAPTER — QBCORE
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

local QBCore = nil
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

function FrameworkAdapter.IsQBCore()
    return QBCore ~= nil
end

function FrameworkAdapter.GetPlayer(src)
    if not QBCore then return nil end
    return QBCore.Functions.GetPlayer(src)
end

function FrameworkAdapter.GetCharacterName(src)
    if not QBCore then return GetPlayerName(src) end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.charinfo then return GetPlayerName(src) end
    return (p.PlayerData.charinfo.firstname or '') .. ' ' .. (p.PlayerData.charinfo.lastname or '')
end

function FrameworkAdapter.GetPrimaryJob(src)
    if not QBCore then return { name = 'unemployed', label = 'Arbejdsløs', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0 } end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then
        return { name = 'unemployed', label = 'Arbejdsløs', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0 }
    end
    local j = p.PlayerData.job
    return {
        name = j.name or 'unemployed',
        label = j.label or 'Arbejdsløs',
        grade = j.grade and (j.grade.level or j.grade) or 0,
        gradeLabel = j.grade and (j.grade.name or j.gradeLabel) or 'Borger',
        duty = j.onduty or false,
        salary = j.payment or 0
    }
end

function FrameworkAdapter.GetJobs(src)
    local primary = FrameworkAdapter.GetPrimaryJob(src)
    local list = { primary }

    -- Support ps-multijob / qb-multijob if database or export exists
    if QBCore then
        local p = QBCore.Functions.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.citizenid then
            local cid = p.PlayerData.citizenid
            local extra = MySQL.query.await('SELECT * FROM user_jobs WHERE citizenid = ?', { cid }) or {}
            for _, row in ipairs(extra) do
                if row.job ~= primary.name then
                    table.insert(list, {
                        name = row.job,
                        label = row.job_label or row.job,
                        grade = row.grade or 0,
                        gradeLabel = row.grade_label or 'Medarbejder',
                        duty = false,
                        salary = row.salary or 0
                    })
                end
            end
        end
    end

    return list
end

function FrameworkAdapter.SetDuty(src, state)
    if not QBCore then return false end
    local p = QBCore.Functions.GetPlayer(src)
    if not p then return false end
    p.Functions.SetJobDuty(state)
    return true
end

function FrameworkAdapter.SwitchJob(src, jobName, grade)
    if not QBCore then return false end
    local p = QBCore.Functions.GetPlayer(src)
    if not p then return false end
    p.Functions.SetJob(jobName, grade or 0)
    return true
end
