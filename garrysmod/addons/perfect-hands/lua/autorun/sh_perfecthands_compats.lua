if CLIENT then
    local function isPlayingAnim()
        return LocalPlayer().mvp_phands_animation_playing
    end

    -- VManip compatibility
    -- (https://steamcommunity.com/workshop/filedetails/?id=2155366756)
    hook.Add("VManipPrePlayAnim", "mvp_perfecthands", function() if isPlayingAnim() then return false end end)

    -- Gmod Legs 3 compatibility
    -- (https://steamcommunity.com/sharedfiles/filedetails/?id=112806637)
    hook.Add("ShouldDisableLegs", "mvp_perfecthands", function() if isPlayingAnim() then return true end end)

    -- PAC3 compatibility
    -- (https://steamcommunity.com/workshop/filedetails/?id=104691717)
    hook.Add("pac_Initialized", "mvp.perfecthands.PAC3", function()
        if not pac then return end
        local oldResetBones = pac.ResetBones

        function pac.ResetBones(ent)
            if ent.mvp_phands_animation_playing == true then return end
            oldResetBones(ent)
        end
    end)

    -- Shmovment compatibility
    -- (https://steamcommunity.com/workshop/filedetails/?id=2737702541)
    local ShmovmentConvar = GetConVar("cl_luc_headbob")
    if (ShmovmentConvar) then
        local oldShmovment = ShmovmentConvar:GetBool()
        hook.Add("mvp.phands.CameraCreated", "mvp.perfecthands.ShmovmentCompat", function()
            oldShmovment = ShmovmentConvar:GetBool()
            ShmovmentConvar:SetBool(false) -- Disable headbob when camera is created
        end)

        hook.Add("mvp.phands.CameraDestroyed", "mvp.perfecthands.ShmovmentCompat", function()
            ShmovmentConvar:SetBool(oldShmovment) -- Restore headbob when camera is destroyed, if it was enabled before
        end)
    end
end