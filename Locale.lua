local _, KillCounter = ...
KillCounter.L = {}

KillCounter.L["Kills"] = "Kills"
KillCounter.L["Name"] = "Name"

if (GetLocale() == "deDE") then
    KillCounter.L["ListFrameTab1"] = "Spieler"
    KillCounter.L["ListFrameTab2"] = "Monster"
    --KillCounter.L["ListFrameTab3"] = "Tode"
    KillCounter.L["LastKill"] = "Letzter Kill"

    KillCounter.L["SortTooltip"] = "Sortierung"
    KillCounter.L["SortFilter1"] = "Name aufsteigend"
    KillCounter.L["SortFilter2"] = "Name absteigend"
    KillCounter.L["SortFilter3"] = "Kills aufsteigend"
    KillCounter.L["SortFilter4"] = "Kills absteigend"
    KillCounter.L["SortFilter5"] = "Letzter Kill aufsteigend"
    KillCounter.L["SortFilter6"] = "Letzter Kill absteigend"

    KillCounter.L["timeFormatSeconds_singular"] = "vor einer Sekunde"
    KillCounter.L["timeFormatMinutes_singular"] = "vor einer Minute"
    KillCounter.L["timeFormatHours_singular"] = "vor einer Stunde"
    KillCounter.L["timeFormatDays_singular"] = "vor einem Tag"
    KillCounter.L["timeFormatSeconds_plural"] = "vor %d Sekunden"
    KillCounter.L["timeFormatMinutes_plural"] = "vor %d Minuten"
    KillCounter.L["timeFormatHours_plural"] = "vor %d Stunden"
    KillCounter.L["timeFormatDays_plural"] = "vor %d Tage"

    KillCounter.L["Unknown"] = "Unbekannt"
else
    KillCounter.L["ListFrameTab1"] = "Players"
    KillCounter.L["ListFrameTab2"] = "Monsters"
    --KillCounter.L["ListFrameTab3"] = "Deaths"
    KillCounter.L["LastKill"] = "Last killed"

    KillCounter.L["SortTooltip"] = "Sorting"
    KillCounter.L["SortFilter1"] = "Name ascending"
    KillCounter.L["SortFilter2"] = "Name descending"
    KillCounter.L["SortFilter3"] = "Kills ascending"
    KillCounter.L["SortFilter4"] = "Kills descending"
    KillCounter.L["SortFilter5"] = "Last kill ascending"
    KillCounter.L["SortFilter6"] = "Last kill descending"

    KillCounter.L["timeFormatSeconds_singular"] = "a second ago"
    KillCounter.L["timeFormatMinutes_singular"] = " a minute ago"
    KillCounter.L["timeFormatHours_singular"] = " a hour ago"
    KillCounter.L["timeFormatDays_singular"] = " a day ago"
    KillCounter.L["timeFormatSeconds_plural"] = "%d seconds ago"
    KillCounter.L["timeFormatMinutes_plural"] = "%d minutes ago"
    KillCounter.L["timeFormatHours_plural"] = "%d hours ago"
    KillCounter.L["timeFormatDays_plural"] = "%d days ago"

    KillCounter.L["Unknown"] = "Unknown"
end