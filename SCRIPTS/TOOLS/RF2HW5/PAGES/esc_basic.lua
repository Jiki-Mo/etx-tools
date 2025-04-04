local template = assert(loadScript(radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field + indent
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

local flightMode = { 
    [0] = "Fixed Wing",
    "Heli Ext Governor",
    "Heli Governor",
    "Heli Governor Store",
}

local rotation = {
    [0] = "CW",
    "CCW",
}

local lipoCellCount = {
    [0] = "Auto Calculate",
    "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "11S", "12S", "13S", "14S",
}

local cutoffType = {
    [0] = "Soft Cutoff",
    "Hard Cutoff"
}

local cutoffVoltage = {
    [0] = "Disabled",
    "2.8", "2.9", "3.0", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8",
}

labels[#labels + 1] = { t = "ESC",                    x = x,                y = inc.y(lineSpacing) }
y = yMinLim - lineSpacing
labels[#labels + 1] = { t = "---",                    x = x + sp - indent,  y = inc.y(lineSpacing) }
y = yMinLim - lineSpacing
labels[#labels + 1] = { t = "---",                    x = x + sp * 1.9,     y = inc.y(lineSpacing) }

fields[#fields + 1] = { t = "Flight Mode",            x = x + indent, y = inc.y(lineSpacing * 2), sp = x + sp, min = 0, max = #flightMode, vals = { 64 }, table = flightMode }
fields[#fields + 1] = { t = "Rotation",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #rotation, vals = { 77 }, table = rotation }
fields[#fields + 1] = { t = "BEC Voltage",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 54, max = 84, vals = { 68 }, scale = 10 }

labels[#labels + 1] = { t = "Protection and Limits",  x = x,          y = inc.y(lineSpacing * 2) }
fields[#fields + 1] = { t = "Lipo Cell Count",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #lipoCellCount, vals = { 65 }, table = lipoCellCount }
fields[#fields + 1] = { t = "Volt Cutoff Type",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #cutoffType, vals = { 66 }, table = cutoffType }
fields[#fields + 1] = { t = "Cutoff Voltage",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #cutoffVoltage, vals = { 67 }, table = cutoffVoltage }

return {
    read        = 217, -- MSP_ESC_PARAMETERS
    write       = 218, -- MSP_SET_ESC_PARAMETERS
    eepromWrite = true,
    reboot      = false,
    title       = "Basic Setup",
    minBytes    = mspBytes,
    labels      = labels,
    fields      = fields,

    postLoad = function(self)
        -- esc type
        local l = self.labels[1]
        -- local type = getText(self, 33, 48)
        local name = getText(self, 49, 64)
        l.t = name

        -- HW ver
        l = self.labels[2]
        l.t = getText(self, 17, 32)

        -- FW ver
        l = self.labels[3]
        l.t = getText(self, 1, 16)

        -- BEC offset
        local f = self.fields[3]
        f.value = f.value + 5.4
    end,

    preSave = function (self)
        -- BEC offset
        local f = self.fields[3]
        setPageValue(self, 68, f.value * 10 - 54)
        return self.values
    end,
}
