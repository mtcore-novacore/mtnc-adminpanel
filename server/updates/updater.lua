Updater = {}

CreateThread(function()
    Wait(3000)
    GitHubUpdater.Check()
end)
