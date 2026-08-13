Bridge = {}

function Bridge.Init()
    local fw = Framework.Detect()
    print(("^2[MTNC] ⚡ Framework Bridge aktiv: %s^7"):format(fw))

    if fw == "QBCORE" then
        QBCoreBridge.Init()
    elseif fw == "QBOX" then
        QBoxBridge.Init()
    elseif fw == "ESX" then
        ESXBridge.Init()
    elseif fw == "VRP" then
        VRPBridge.Init()
    else
        StandaloneBridge.Init()
    end
end

CreateThread(function()
    Wait(500)
    Bridge.Init()
end)
