DB = {}

function DB.Query(query, params, cb)
    if exports.oxmysql then
        exports.oxmysql:query(query, params, cb)
    end
end

function DB.Single(query, params, cb)
    if exports.oxmysql then
        exports.oxmysql:single(query, params, cb)
    end
end
