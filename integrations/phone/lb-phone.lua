-- ============================================================
-- MTNC ADAPTER — LB PHONE OFFICIAL INTEGRATION
-- ============================================================
PhoneAdapter = PhoneAdapter or {}

local isLBPhone = GetResourceState('lb-phone') == 'started'

function PhoneAdapter.IsAvailable()
    return isLBPhone or GetResourceState('lb-phone') == 'started'
end

function PhoneAdapter.GetPhoneNumber(src)
    if GetResourceState('lb-phone') == 'started' then
        local num = exports['lb-phone']:GetEquippedPhoneNumber(src)
        if num then return num end
    end
    return nil
end

function PhoneAdapter.ResetPin(src, newPin)
    if GetResourceState('lb-phone') == 'started' then
        -- Official LB Phone PIN reset export / event handling
        local phone = PhoneAdapter.GetPhoneNumber(src)
        if phone then
            MySQL.update.await('UPDATE phone_phones SET pin = NULL WHERE phone_number = ?', { phone })
            return true
        end
    end
    return false
end
