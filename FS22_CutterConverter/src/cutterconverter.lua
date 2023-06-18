--
-- Main
--
-- Main class for initialize the cutter converter.
--
-- Copyright (c) Peppie84, 2023
--

---Mission00 is loading
---@param mission table (Mission00)
local function preload(mission)
    print("Cutter convert preload")

    local conversionFactor = 1
    local windrowConversionFactor = 0

    -- Convert WINTER_WHEAT to WHEAT
    local winterWheatFruitTypeDesc  = g_fruitTypeManager:getFruitTypeByName('WINTER_WHEAT')
    local wheatFillTypeDesc         = g_fillTypeManager:getFillTypeByName('WHEAT')
    local winterWheatConverterIndex = g_fruitTypeManager:addFruitTypeConverter('WINTERWHEAT_CONVERTER', true)
    g_fruitTypeManager:addFruitTypeConversion(winterWheatConverterIndex, winterWheatFruitTypeDesc.index, wheatFillTypeDesc.index, conversionFactor, windrowConversionFactor)

    -- Convert WINTER_BARLEY to BARLEY
    local winterBarleyFruitTypeDesc = g_fruitTypeManager:getFruitTypeByName('WINTER_BARLEY')
    local barleyFillTypeDesc        = g_fillTypeManager:getFillTypeByName('BARLEY')
    local winterBarleyConverterIndex = g_fruitTypeManager:addFruitTypeConverter('WINTERBARLEY_CONVERTER', true)
    g_fruitTypeManager:addFruitTypeConversion(winterBarleyConverterIndex, winterBarleyFruitTypeDesc.index, barleyFillTypeDesc.index, conversionFactor, windrowConversionFactor)
end

---Cutter.onLoad
---@param self table (cutter)
---@param savegame table
local function onLoad(self, savegame)
    local spec = self.spec_cutter
    local data = g_fruitTypeManager:getConverterDataByName('WINTERWHEAT_CONVERTER')

    if data ~= nil then
        for input, converter in pairs(data) do
            spec.fruitTypeConverters[input] = converter
        end
    end

    data = g_fruitTypeManager:getConverterDataByName('WINTERBARLEY_CONVERTER')

    if data ~= nil then
        for input, converter in pairs(data) do
            spec.fruitTypeConverters[input] = converter
        end
    end
end

---init()
local function init()
    Mission00.load = Utils.prependedFunction(Mission00.load, preload)
    Cutter.onLoad = Utils.appendedFunction(Cutter.onLoad, onLoad)
end

init()
