-- Forever compatibility helpers; scoped to this addon only.
local _, FC = ...
FC = FC or {}
FC.GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
FC.IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
FC.LoadAddOn = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
function FC.OpenOptions(name)
    local dialog = LibStub and LibStub("AceConfigDialog-3.0", true)
    local id = dialog and dialog.BlizOptionsIDMap and dialog.BlizOptionsIDMap[name]
    if Settings and Settings.OpenToCategory and id then
        Settings.OpenToCategory(id)
    elseif dialog then
        dialog:Open(name)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(name)
    end
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
