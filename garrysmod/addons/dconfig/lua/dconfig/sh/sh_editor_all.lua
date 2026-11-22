
function DCONFIG2.AddAllowedSearch(editor)
    DCONFIG2.Editor.AddOption(editor, {
        name = "Allowed Jobs Lookup",
        description = "Select Jobs That Have Access - ( Some Hardcoded Jobs May be Missing )",
        nokey = true,
        key = "allowed_lookup",
        type="searchlist",
        searchList = {
            isSorted = true, 
            isSelected = function(job, selectedOptions)
                if not job.jobvar then return false end
    
                return selectedOptions[job.jobvar]
            end,
            getSelected = function(body, editorOptions)
                local selected = DCONFIG2.ConvertStrToLookupTbl(editorOptions.allowed.textEntry:GetValue())
                return selected
            end,
            getList = function(body, selectedOptions)
                return DCONFIG2.SortSelectedTable(RPExtraTeams, selectedOptions, function(val)
                    return val.jobvar or ""
                end)
            end,
            isSearchFound = function(searchStr, className, job)
                if not job then return false end
                
                local jobVar = job.jobvar or ""
                local jobStrings = job.name .. " " .. jobVar .. " " .. job.command
                return string.find(string.lower(jobStrings), searchStr)
            end,
            getModel = function(job)
                return type(job.model) == "string" and job.model or job.model[1]
            end,
            getTitleLabel = function(key, job)
                return job.name
            end,
            getSubLabel = function(key, job)
                local jobVar = job.jobvar or "Unknown Job Variable"
                return jobVar
            end,
            click = function(job, body, panel, editorOptions, data)
                local jobVar = job.jobvar
                if not jobVar then
                    DCONFIG2.ShowPopup("DConfig was unable to find this job's variable. You must manually type it in or move the job into jobs.lua", "dconfig/close.png", 5, true)
                    return
                end 
                if not panel.selectedOptions[jobVar] then
                    local curVal = editorOptions.allowed.textEntry:GetValue()
                    local newVal = ""
                    if string.len(curVal) > 0 then
                        newVal = curVal .. ", " .. jobVar
                    else
                        newVal = jobVar
                    end
                    panel.selectedOptions[jobVar] = true
                    editorOptions.allowed.textEntry:SetValue(newVal)
                else
                    panel.selectedOptions[jobVar] = nil
                    local str = ""
                    for k,v in pairs(panel.selectedOptions) do
                        if string.len(str) <= 0 then
                            str = k
                        else
                            str = str .. ", " .. k
                        end
                    end
                    editorOptions.allowed.textEntry:SetValue(str)
                end
            end,
        },
    })
end

function DCONFIG2.AddUpdateInfo(editor)
    DCONFIG2.Editor.AddOption(editor, {
        name = "Info",
        description = "Information related to this data entry.",
        key = "info",
        type = "info",
        nokey = true,
        getlist = function(contentData)
            if not DCONFIG2.IngameConfig.display_update_info then return end

            if contentData then
                if not contentData.updateTime then return end
    
                local timeStamp = contentData.updateTime
                local timeString = "Unknown"
                if timeStamp then
                    timeString = os.date( "%H:%M:%S - %m/%d/%Y" , timeStamp )
                end
                local updateBy = contentData.updateBy and contentData.updateBy or "Unknown"
                updateBy = updateBy .. " - " .. (contentData.updateByID or "Unknown Steam ID")
                return {
                    {title = "Last Time Updated", value = timeString},
                    {title = "Updated By", value = updateBy},
                }
            end
        end, 
        postbuild = function(body, panel, editorOptions, data)
            //PrintTable(editorOptions)
        end
    })
end