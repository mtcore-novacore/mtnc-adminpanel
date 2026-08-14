-- ============================================================
-- MTNC ADAPTER - QBCORE (LIVE QBCore.Shared.Jobs SALARY LOOKUP)
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

local function GetQBCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

local QBCore = GetQBCore()

function FrameworkAdapter.IsQBCore()
    QBCore = QBCore or GetQBCore()
    return QBCore ~= nil
end

function FrameworkAdapter.GetPlayer(src)
    QBCore = QBCore or GetQBCore()
    if not QBCore then return nil end
    return QBCore.Functions.GetPlayer(src)
end

function FrameworkAdapter.GetCharacterName(src)
    QBCore = QBCore or GetQBCore()
    if not QBCore then return GetPlayerName(src) end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.charinfo then return GetPlayerName(src) end
    return (p.PlayerData.charinfo.firstname or '') .. ' ' .. (p.PlayerData.charinfo.lastname or '')
end

function FrameworkAdapter.GetJobSalary(jobName, gradeLevel)
    QBCore = QBCore or GetQBCore()
    if not QBCore or not QBCore.Shared or not QBCore.Shared.Jobs then return 0 end
    local jobData = QBCore.Shared.Jobs[jobName]
    if not jobData or not jobData.grades then return 0 end

    local gKeyStr = tostring(gradeLevel or 0)
    local gKeyNum = tonumber(gradeLevel or 0)

    local gradeData = jobData.grades[gKeyStr] or (gKeyNum and jobData.grades[gKeyNum]) or jobData.grades[0] or jobData.grades['0']
    if gradeData and gradeData.payment then
        return tonumber(gradeData.payment) or 0
    end
    return 0
end

function FrameworkAdapter.GetPrimaryJob(src)
    QBCore = QBCore or GetQBCore()
    if not QBCore then return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0, isBoss = false } end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then
        return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0, isBoss = false }
    end
    local j = p.PlayerData.job
    local jobName = j.name or 'unemployed'
    local gradeLevel = j.grade and (j.grade.level or j.grade) or 0
    
    local salary = tonumber(j.payment) or 0
    if salary == 0 then
        salary = FrameworkAdapter.GetJobSalary(jobName, gradeLevel)
    end

    local isBoss = (j.isboss == true)
    if not isBoss and j.grade then
        if type(j.grade) == 'table' and j.grade.isboss then
            isBoss = true
        elseif type(j.grade) == 'table' and j.grade.name and (string.lower(j.grade.name) == 'boss' or string.lower(j.grade.name) == 'ledelse' or string.lower(j.grade.name) == 'direktør' or string.lower(j.grade.name) == 'chef') then
            isBoss = true
        end
    end

    return {
        name = jobName,
        label = j.label or jobName,
        grade = gradeLevel,
        gradeLabel = j.grade and (j.grade.name or j.gradeLabel) or 'Borger',
        duty = j.onduty or false,
        salary = salary,
        isBoss = isBoss
    }
end

function FrameworkAdapter.GetJobs(src)
    local primary = FrameworkAdapter.GetPrimaryJob(src)
    local list = { primary }

    QBCore = QBCore or GetQBCore()
    if not QBCore then return list end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData then return list end

    -- Check metadata multijob
    if p.PlayerData.metadata and p.PlayerData.metadata['multijob'] and type(p.PlayerData.metadata['multijob']) == 'table' then
        for jobName, jobData in pairs(p.PlayerData.metadata['multijob']) do
            if jobName ~= primary.name then
                local gradeLvl = jobData.grade or (jobData.grade and jobData.grade.level) or 0
                local salary = tonumber(jobData.salary or jobData.payment) or 0
                if salary == 0 then
                    salary = FrameworkAdapter.GetJobSalary(jobName, gradeLvl)
                end

                table.insert(list, {
                    name = jobName,
                    label = jobData.label or jobName,
                    grade = gradeLvl,
                    gradeLabel = jobData.gradeLabel or (jobData.grade and jobData.grade.name) or 'Medarbejder',
                    duty = false,
                    salary = salary
                })
            end
        end
    end

    return list
end

function FrameworkAdapter.SetDuty(src, state)
    QBCore = QBCore or GetQBCore()
    if not QBCore then return false end
    local p = QBCore.Functions.GetPlayer(src)
    if not p then return false end
    p.Functions.SetJobDuty(state)
    return true
end

function FrameworkAdapter.SwitchJob(src, jobName, grade)
    QBCore = QBCore or GetQBCore()
    if not QBCore then return false end
    local p = QBCore.Functions.GetPlayer(src)
    if not p then return false end
    p.Functions.SetJob(jobName, grade or 0)
    return true
end
