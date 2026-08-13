-- ============================================================
-- MTNC ADAPTER - QBCORE
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
    if not QBCore then return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0 } end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then
        return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0 }
    end
    local j = p.PlayerData.job
    return {
        name = j.name or 'unemployed',
        label = j.label or 'Arbejdsloes',
        grade = j.grade and (j.grade.level or j.grade) or 0,
        gradeLabel = j.grade and (j.grade.name or j.gradeLabel) or 'Borger',
        duty = j.onduty or false,
        salary = j.payment or 0
    }
end

function FrameworkAdapter.GetJobs(src)
    local primary = FrameworkAdapter.GetPrimaryJob(src)
    local list = { primary }

    if not QBCore then return list end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData then return list end

    -- Check if metadata multijob exists (standard modern QBCore)
    if p.PlayerData.metadata and p.PlayerData.metadata['multijob'] and type(p.PlayerData.metadata['multijob']) == 'table' then
        for jobName, jobData in pairs(p.PlayerData.metadata['multijob']) do
            if jobName ~= primary.name then
                table.insert(list, {
                    name = jobName,
                    label = jobData.label or jobName,
                    grade = jobData.grade or 0,
                    gradeLabel = jobData.gradeLabel or 'Medarbejder',
                    duty = false,
                    salary = jobData.salary or 0
                })
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
