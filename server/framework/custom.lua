--[[
  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC AdminPanel — server/framework/custom.lua
  ÅBEN CUSTOM FRAMEWORK ADAPTER (Kan frit redigeres af serverejere)
--]]

local CustomAdapter = {}

--- Initialiserer custom framework
function CustomAdapter.Init()
    -- Tilføj check for dit eget framework her
    -- Returner true hvis dit framework er aktivt
    return false
end

--- Henter spiller objekt
---@param src number Spiller ID (source)
function CustomAdapter.GetPlayer(src)
    -- Returner dit custom player objekt her
    return nil
end

--- Henter spillerens gruppe / rank
---@param src number
function CustomAdapter.GetGroup(src)
    return "user"
end

--- Henter spillerens job informationer
---@param src number
function CustomAdapter.GetJob(src)
    return {
        name = "unemployed",
        label = "Arbejdsløs",
        grade = 0,
        grade_name = "Ingen"
    }
end

--- Henter spillerens pengebeholdning
---@param src number
---@param mtype string "cash" eller "bank"
function CustomAdapter.GetMoney(src, mtype)
    return 0
end

--- Tilføjer penge til spilleren
---@param src number
---@param mtype string "cash" eller "bank"
---@param amount number Beløb
function CustomAdapter.AddMoney(src, mtype, amount)
    -- Tilføj dit eget penge-kald her
    return true
end

--- Fjerner penge fra spilleren
---@param src number
---@param mtype string "cash" eller "bank"
---@param amount number Beløb
function CustomAdapter.RemoveMoney(src, mtype, amount)
    -- Fjern penge her
    return true
end

--- Genopliver spilleren (Revive)
---@param src number
function CustomAdapter.Revive(src)
    -- Trigger dit eget custom revive event (f.eks. ambulance:revive)
    TriggerClientEvent("mtnc:client:customRevive", src)
end

--- Giver fuldt helbred (Heal)
---@param src number
function CustomAdapter.Heal(src)
    TriggerClientEvent("mtnc:client:customHeal", src)
end

_G.MTNC_Custom_Server = CustomAdapter
