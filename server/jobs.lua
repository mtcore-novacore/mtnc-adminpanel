-- ============================================================
-- MTNC JOB / MULTIJOB SYSTEM
-- ============================================================
Jobs = Jobs or {}

RegisterNetEvent('mtnc:server:getJobs', function()
    local src = source
    if not Security.RateLimit(src) then return end

    local primary = FrameworkAdapter.GetPrimaryJob(src)
    local allJobs = FrameworkAdapter.GetJobs(src)

    TriggerClientEvent('mtnc:client:receiveJobs', src, {
        primary = primary,
        jobs = allJobs
    })
end)

RegisterNetEvent('mtnc:server:toggleDuty', function()
    local src = source
    if not Security.RateLimit(src) then return end

    local primary = FrameworkAdapter.GetPrimaryJob(src)
    local newDuty = not primary.duty
    local success = FrameworkAdapter.SetDuty(src, newDuty)

    if success then
        Audit.Log('JOB_DUTY_TOGGLE', src, src, { duty = newDuty })
        TriggerClientEvent('mtnc:client:receiveJobs', src, {
            primary = FrameworkAdapter.GetPrimaryJob(src),
            jobs = FrameworkAdapter.GetJobs(src)
        })
    end
end)

RegisterNetEvent('mtnc:server:switchJob', function(jobName, grade)
    local src = source
    if not Security.RateLimit(src) then return end

    -- Server-side validation of owned jobs
    local userJobs = FrameworkAdapter.GetJobs(src)
    local ownsJob = false
    for _, j in ipairs(userJobs) do
        if j.name == jobName then
            ownsJob = true
            break
        end
    end

    if ownsJob then
        FrameworkAdapter.SwitchJob(src, jobName, grade or 0)
        Audit.Log('JOB_SWITCH', src, src, { job = jobName, grade = grade })
        TriggerClientEvent('mtnc:client:receiveJobs', src, {
            primary = FrameworkAdapter.GetPrimaryJob(src),
            jobs = FrameworkAdapter.GetJobs(src)
        })
    end
end)
