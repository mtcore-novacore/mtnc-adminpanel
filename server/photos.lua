-- ============================================================
-- MTNC PHOTO STORAGE & SECURITY
-- ============================================================
Photos = Photos or {}

local playerPhotos = {}

RegisterNetEvent('mtnc:server:savePhoto', function(data)
    local src = source
    if not Security.RateLimit(src) then return end
    if not data or not data.image then return end

    local photoId = string.format("IMG_%d_%d", src, os.time())
    local item = {
        id = photoId,
        owner = src,
        image = data.image,
        date = os.date('%d/%m/%Y %H:%M'),
        location = data.location or 'Los Santos'
    }

    if not playerPhotos[src] then playerPhotos[src] = {} end
    table.insert(playerPhotos[src], 1, item)

    TriggerClientEvent('mtnc:client:photoSaved', src, item)
end)

RegisterNetEvent('mtnc:server:getPhotos', function()
    local src = source
    local photos = playerPhotos[src] or {}
    TriggerClientEvent('mtnc:client:receivePhotos', src, photos)
end)
