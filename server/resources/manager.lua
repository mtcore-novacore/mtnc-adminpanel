ResourcesManager = {}

function ResourcesManager.GetAll()
    local resources = {}
    for i = 0, GetNumResources() - 1 do
        local name = GetResourceByFindIndex(i)
        if name then
            table.insert(resources, {
                name = name,
                state = GetResourceState(name)
            })
        end
    end
    return resources
end
