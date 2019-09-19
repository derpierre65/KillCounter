local maxRows = 22

local function stringSplit(inputstr, sep)
    local t = {}

    if (sep == nil) then
        return t
    end

    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function GetItemCount(type)
    if (KillCounterCharDB.kills == nil or KillCounterCharDB.kills[type] == nil) then
        return 0
    end
    local i = 0
    for k, v in pairs(KillCounterCharDB.kills[type]) do
        i = i + 1
    end
    return i
end

local function GetLastKill(time)
    if (time == nil) then
        return "Unbekannt"
    end

    local difference = GetTime() - time
    if (difference < 60) then
        if (difference <= 1) then
            return "vor einer Sekunde"
        else
            return "vor " .. math.floor(difference) .. " Sekunden"
        end
    elseif difference < 3600 then
        local minutes = math.floor(difference / 60)
        if (minutes <= 1) then
            return "vor einer Minute"
        else
            return "vor " .. minutes .. " Minuten"
        end
    elseif difference < 86400 then
        local hours = math.floor(difference / 3600)
        if (hours <= 1) then
            return "vor einer Stunde"
        else
            return "vor " .. hours .. " Stunden"
        end
    else
        local days = math.floor(difference / 86400)
        if (days <= 1) then
            return "vor einem Tag"
        else
            return "vor " .. days .. " Tage"
        end
    end
end

function KillCounterListFrameSortOption_SetValue(newValue)
    UIDropDownMenu_SetSelectedID(KillCounterListFrameSortOption, newValue:GetID());
    KillCounterCharDB.options.sort = newValue:GetID()
    if KillCounterListFrame:IsVisible() then
        KillCounter_Update()
    end
end

local function KillCounter_SortMenu(frame, level, menuList)
    local sorts = {
        "Name aufsteigend", -- 1
        "Name absteigend", -- 2
        "Kills aufsteigend", -- 3
        "Kills absteigend", -- 4
        "Letzter Kill aufsteigend", -- 5
        "Letzter Kill absteigend" -- 6
    }

    for k, v in pairs(sorts) do
        local info = UIDropDownMenu_CreateInfo()
        info.func = KillCounterListFrameSortOption_SetValue
        info.text = v
        UIDropDownMenu_AddButton(info)
    end
end

function KillCounter_OnLoad()
    KillCounterRow1:SetNormalFontObject("GameFontNormal")
    KillCounterRow1:SetNormalTexture("")
    KillCounterRow1:Show()
    KillCounterRow1Text:SetText("Name")
    KillCounterRow1Kills:SetText("Kills")
    KillCounterRow1Level:SetText("Letzter Kill")

    -- tab menu
    PanelTemplates_SetNumTabs(KillCounterListFrame, 2);
    PanelTemplates_SetTab(KillCounterListFrame, 1)

    -- dropdown
    UIDropDownMenu_Initialize(KillCounterListFrameSortOption, KillCounter_SortMenu)
    UIDropDownMenu_SetWidth(KillCounterListFrameSortOption, 150)

    -- blizzmove
    if (movableFramesLoD ~= nil and BlizzMove ~= nil) then
        movableFramesLoD['KillCounter'] = function()
            BlizzMove:SetMoveHandle(KillCounterListFrame)
        end
    end

    -- add kill counter frame to special frames (close with escape)
    tinsert(UISpecialFrames, "KillCounterListFrame")

    -- kill counter frame
    KillCounterListFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    KillCounterListFrame:RegisterEvent('ADDON_LOADED')
    KillCounterListFrame:SetScript('OnEvent', function(self, event, arg1, ...)
        if (event == "ADDON_LOADED" and arg1 == "KillCounter") then
            if (KillCounterCharDB == nil) then
                KillCounterCharDB = {
                    options = {
                        sort = 4
                    },
                    kills = {}
                }
            end

            UIDropDownMenu_SetSelectedID(KillCounterListFrameSortOption, KillCounterCharDB.options.sort);
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local timestamp, event, hideCaster, s_guid, s_name, s_flags, s_raidflags, d_guid, d_name, d_flags, d_raidflags = CombatLogGetCurrentEventInfo()
            if event == "PARTY_KILL" then
                local x = stringSplit(d_guid, "-")

                local playerid = x[table.getn(x) - 1]
                local type = string.lower(x[1])

                if (type == "pet") then
                    return
                end

                if (type == "player") then
                    playerid = x[table.getn(x)];
                end

                if (KillCounterCharDB.kills[type] == nil) then
                    KillCounterCharDB.kills[type] = {}
                end
                if (KillCounterCharDB.kills[type][playerid] == nil) then
                    KillCounterCharDB.kills[type][playerid] = {
                        name = d_name,
                        kills = 0
                    }
                end

--                if (type ~= "player" and type ~= "creature" and type ~= "pet") then
--                    message("neuer type '" .. type .. "', bitte bescheid geben :)")
--                end

                KillCounterCharDB.kills[type][playerid].last = GetTime()
                KillCounterCharDB.kills[type][playerid].kills = KillCounterCharDB.kills[type][playerid].kills + 1
                KillCounter_Update()
            end
        end
    end)

    -- commands
    SLASH_KillCounter1 = "/kills"
    SlashCmdList["KillCounter"] = function()
        if (not GameMenuFrame:IsVisible()) then
            if (KillCounterListFrame:IsVisible()) then
                KillCounterListFrame:Hide()
            else
                KillCounterListFrame:Show()
            end
        end
    end
end

function KillCounter_Update()
    local activeTab = PanelTemplates_GetSelectedTab(KillCounterListFrame)
    local type;
    if (activeTab == 1) then
        type = "player"
    elseif (activeTab == 2) then
        type = "creature"
    end

    FauxScrollFrame_Update(KillCounterListScrollBar, GetItemCount(type) + 1, maxRows, 16); -- 100 = entries

    local scrollOffset = FauxScrollFrame_GetOffset(KillCounterListScrollBar)
    local list = {}
    local allKills = 0;
    if (KillCounterCharDB ~= nil and KillCounterCharDB.kills ~= nil and KillCounterCharDB.kills[type] ~= nil) then
        local tmpTable = {}
        for k, v in pairs(KillCounterCharDB.kills[type]) do
            table.insert(tmpTable, v)
            allKills = allKills + v.kills
        end

        table.sort(tmpTable, function(a, b)
            if (KillCounterCharDB.options.sort == 1) then
                return a.name < b.name
            elseif (KillCounterCharDB.options.sort == 2) then
                return a.name > b.name
            elseif (KillCounterCharDB.options.sort == 3) then
                return a.kills < b.kills
            elseif (KillCounterCharDB.options.sort == 4) then
                return a.kills > b.kills
            elseif (KillCounterCharDB.options.sort == 5) then
                return a.last < b.last
            elseif (KillCounterCharDB.options.sort == 6) then
                return a.last > b.last
            end
            return a.name > b.name
        end)

        local i = 0
        for k, v in pairs(tmpTable) do
            if (i >= scrollOffset) then
                table.insert(list, {
                    first = v.name,
                    second = v.kills,
                    third = v.last
                });
            end
            if (i == scrollOffset + (maxRows-1)) then
                break
            end
            i = i + 1
        end
    end

    KillCounterListFrameTitle:SetText("Kills (" .. allKills .. ")")

    for i = 2, maxRows do
        local btn = _G['KillCounterRow' .. i];
        local playername = _G['KillCounterRow' .. i .. 'Text']
        local killCount = _G['KillCounterRow' .. i .. 'Kills']
        local playerLevel = _G['KillCounterRow' .. i .. 'Level']

        btn:SetNormalFontObject("GameFontNormal")
        btn:SetNormalTexture("")
        playername:SetTextColor(1, 1, 1)
        killCount:SetTextColor(1, 1, 1)
        playerLevel:SetTextColor(1, 1, 1)

        local row = list[i - 1]
        if (row ~= nil) then
            btn:Show()
            playername:SetText(row.first)
            killCount:SetText(row.second)
            playerLevel:SetText(GetLastKill(row.third))
        else
            btn:Hide()
        end
    end
    --    DEFAULT_CHAT_FRAME:AddMessage("We're at " .. FauxScrollFrame_GetOffset(KillCounterListScrollBar));
end