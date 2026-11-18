-- Forever compatibility helpers; scoped to this addon only.
local _, FC = ...
FC = FC or {}
FC.GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
FC.IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
FC.LoadAddOn = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
function FC.OpenOptions(name)
    if InCombatLockdown() then
        print("Devilconfig: 전투가 끝난 뒤 설정창을 열어 주세요.")
        return false
    end
    local dialog = LibStub and LibStub("AceConfigDialog-3.0", true)
    if dialog then
        dialog:Open(name)
        return true
    end
    print("Devilconfig: 설정창 라이브러리를 불러오지 못했습니다.")
    return false
end
function FC.Gradient(texture, orientation, r,g,b,a, r2,g2,b2,a2)
    if texture.SetGradientAlpha then
        texture:SetGradientAlpha(orientation,r,g,b,a,r2,g2,b2,a2)
    else
        texture:SetGradient(orientation,CreateColor(r,g,b,a),CreateColor(r2,g2,b2,a2))
    end
end
function FC.MinResize(frame,w,h)
    if frame.SetMinResize then frame:SetMinResize(w,h)
    else frame:SetResizeBounds(w,h) end
end
function FC.Resolution()
    if GetPhysicalScreenSize then
        local w,h = GetPhysicalScreenSize()
        if w and h then return string.format("%dx%d",w,h) end
    end
    return string.format("%dx%d",GetScreenWidth(),GetScreenHeight())
end
