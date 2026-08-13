-- World Module Handler
RegisterNetEvent("mtnc:setWeather", function(weather)
    print(("^2[MTNC-WORLD] Weather set to: %s^7"):format(weather))
end)

RegisterNetEvent("mtnc:setTime", function(hour, minute)
    print(("^2[MTNC-WORLD] Time set to: %02d:%02d^7"):format(hour, minute))
end)
