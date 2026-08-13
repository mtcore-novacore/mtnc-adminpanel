DatabaseConnection = {}

function DatabaseConnection.IsConnected()
    return GetResourceState('oxmysql') == 'started'
end
