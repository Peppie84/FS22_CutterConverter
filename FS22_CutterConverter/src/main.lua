--
-- Main
--
-- Main class for initialize the cutter converter.
--
-- Copyright (c) Peppie84, 2023
--

---@type string directory of the mod.
local modDirectory = g_currentModDirectory or ''

source(modDirectory .. 'src/cutterconverter.lua')

---Mission00 is loading
---@param mission table (Mission00)
local function preload(mission)
    print("Cutter convert preload")
    -- Convert WINTER_WHEAT to WHEAT
    local winterWheatFruitTypeDesc = g_fruitTypeManager:getFruitTypeByName('WINTER_WHEAT')
    winterWheatFruitTypeDesc.convertTo = 'WHEAT'

    -- Convert WINTER_BARLEY to BARLEY
    local winterBarleyFruitTypeDesc = g_fruitTypeManager:getFruitTypeByName('WINTER_BARLEY')
    winterBarleyFruitTypeDesc.convertTo = 'BARLEY'
end

---init()
local function init()
    Cutter.processCutterArea = Utils.overwrittenFunction(Cutter.processCutterArea, CutterConverter.inj_processCutterArea)
    Mission00.load = Utils.prependedFunction(Mission00.load, preload)
end

init()
