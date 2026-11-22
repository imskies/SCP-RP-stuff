if CLIENT then
    net.Receive("DeepSCPDestroyDoor", function()
        local prop_dynamic = net.ReadEntity()
        local pos          = net.ReadVector()
        local ang          = net.ReadAngle()

        if IsValid(prop_dynamic) then
            local effect = EffectData()
            effect:SetOrigin(pos)
            effect:SetAngles(ang)
            util.Effect("cball_explode", effect)
        end
    end)
end
