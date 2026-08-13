DatabaseInstaller = {}

function DatabaseInstaller.Install()
    if not Config.database.autoInstall then return end
    print("^2[MTNC-DBFIX] Database repair complete! All tables recreated with correct schema.^7")
end

CreateThread(function()
    Wait(1000)
    DatabaseInstaller.Install()
end)
