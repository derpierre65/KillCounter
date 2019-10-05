local _, KillCounter = ...
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

local function KillCounter_formatTime(time)
    if (time == nil) then
        return KillCounter.L["Unknown"]
    end

    local seconds = math.floor(GetServerTime() - time)
    if (seconds < 0) then
        return KillCounter.L["Unknown"]
    end

    if (seconds < 60) then
        if (seconds <= 1) then
            return KillCounter.L["timeFormatSeconds_singular"]
        else
            return string.format(KillCounter.L["timeFormatSeconds_plural"], seconds)
        end
    elseif seconds < 3600 then
        local minutes = math.floor(seconds / 60)
        if (minutes <= 1) then
            return KillCounter.L["timeFormatMinutes_singular"]
        else
            return string.format(KillCounter.L["timeFormatMinutes_plural"], minutes)
        end
    elseif seconds < 86400 then
        local hours = math.floor(seconds / 3600)
        if (hours <= 1) then
            return KillCounter.L["timeFormatHours_singular"]
        else
            return string.format(KillCounter.L["timeFormatHours_plural"], hours)
        end
    else
        local days = math.floor(seconds / 86400)
        if (days <= 1) then
            return KillCounter.L["timeFormatDays_singular"]
        else
            return string.format(KillCounter.L["timeFormatDays_plural"], days)
        end
    end
end

local function KillCounter_SortMenu(frame, level, menuList)
    local sorts = {
        KillCounter.L["SortFilter1"],
        KillCounter.L["SortFilter2"],
        KillCounter.L["SortFilter3"],
        KillCounter.L["SortFilter4"],
        KillCounter.L["SortFilter5"],
        KillCounter.L["SortFilter6"]
    }

    for _, v in pairs(sorts) do
        local info = UIDropDownMenu_CreateInfo()
        info.func = KillCounterListFrameSortOption_SetValue
        info.text = v
        UIDropDownMenu_AddButton(info)
    end
end

local function KillCounter_GetGUIDType(guid)
    local x = stringSplit(guid, "-")

    local id = x[table.getn(x) - 1]
    local type = string.lower(x[1])

    if (type == "pet") then
        return
    end

    if (type == "player") then
        id = x[table.getn(x)];
    end

    return type, id;
end

function KillCounter_OpenTooltip(frame, tooltip)
    GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT");
    GameTooltip:SetText(KillCounter.L[tooltip], nil, nil, nil, nil, 1);
end

function KillCounterListFrameSortOption_SetValue(newValue)
    UIDropDownMenu_SetSelectedID(KillCounterListFrameSortOption, newValue:GetID());
    KillCounterCharDB.options.sort = newValue:GetID()
    if KillCounterListFrame:IsVisible() then
        KillCounter_Update()
    end
end

function KillCounter_OnLoad()
    KillCounterRow1:SetNormalFontObject("GameFontNormal")
    KillCounterRow1:SetNormalTexture("")
    KillCounterRow1:Show()
    KillCounterRow1Text:SetText(KillCounter.L["Name"])
    KillCounterRow1Kills:SetText(KillCounter.L["Kills"])
    KillCounterRow1Level:SetText(KillCounter.L["LastKill"])

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
    KillCounterListFrame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
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

            KillCounterListFrameTab1:SetText(KillCounter.L["ListFrameTab1"])
            KillCounterListFrameTab2:SetText(KillCounter.L["ListFrameTab2"])
            KillCounterListFrameTitle:SetText(KillCounter.L["Kills"])

            UIDropDownMenu_SetSelectedID(KillCounterListFrameSortOption, KillCounterCharDB.options.sort);

            -- todo remove later
            if (KillCounterCharDB ~= nil and KillCounterCharDB.kills ~= nil) then
                for _, type in pairs({ "creature", "player" }) do
                    for _, v in pairs(KillCounterCharDB.kills[type]) do
                        if (v.last < 1568929168) then
                            v.last = 1568929168
                        end
                    end
                end
            end
        elseif event == "UPDATE_MOUSEOVER_UNIT" and UnitExists('mouseover') then
            local type, id = KillCounter_GetGUIDType(UnitGUID("mouseover"));
            if (KillCounterCharDB.kills ~= nil and KillCounterCharDB.kills[type] ~= nil and KillCounterCharDB.kills[type][id] ~= nil) then
                GameTooltip:AddLine(KillCounter.L["Kills"] .. ": " .. KillCounterCharDB.kills[type][id].kills);
                GameTooltip:AddLine(KillCounter.L["LastKill"] .. " " .. KillCounter_formatTime(KillCounterCharDB.kills[type][id].last));
                GameTooltip:Show()
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local timestamp, event, hideCaster, s_guid, s_name, s_flags, s_raidflags, d_guid, d_name, d_flags, d_raidflags = CombatLogGetCurrentEventInfo()
            if event == "PARTY_KILL" then
                local type, id = KillCounter_GetGUIDType(d_guid);
                if (type == nil or id == nil) then
                    return
                end

                if (KillCounterCharDB.kills[type] == nil) then
                    KillCounterCharDB.kills[type] = {}
                end
                if (KillCounterCharDB.kills[type][id] == nil) then
                    KillCounterCharDB.kills[type][id] = {
                        name = d_name,
                        kills = 0
                    }
                end

                KillCounterCharDB.kills[type][id].last = GetServerTime()
                KillCounterCharDB.kills[type][id].kills = KillCounterCharDB.kills[type][id].kills + 1
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
    elseif (activeTab == 3) then
        type = "deaths"
    end

    FauxScrollFrame_Update(KillCounterListScrollBar, GetItemCount(type) + 1, maxRows, 16); -- 100 = entries

    local scrollOffset = FauxScrollFrame_GetOffset(KillCounterListScrollBar)
    local list = {}
    local allKills = 0;
    if (KillCounterCharDB ~= nil and KillCounterCharDB.kills ~= nil and KillCounterCharDB.kills[type] ~= nil) then
        local tmpTable = {}
        for _, v in pairs(KillCounterCharDB.kills[type]) do
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
            if (i == scrollOffset + (maxRows - 1)) then
                break
            end
            i = i + 1
        end
    end

    KillCounterListFrameTitle:SetText(KillCounter.L["Kills"] .. " (" .. allKills .. ")")

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
            playerLevel:SetText(KillCounter_formatTime(row.third))
        else
            btn:Hide()
        end
    end
end