--
-- Main
--
-- Main class for initialize the WinterX converters.
--
-- Copyright (c) Peppie84, 2023
-- https://github.com/Peppie84/FS22_CutterConverter
--
local cutterConverterData = {
    WINTERWHEAT_CONVERTER = {
        FROM_FRUIT = 'WINTER_WHEAT',
        TO_FRUIT = 'WHEAT',
        CONVERSION_FACTOR = 1.2
    },
    WINTERBARLEY_CONVERTER = {
        FROM_FRUIT = 'WINTER_BARLEY',
        TO_FRUIT = 'BARLEY',
        CONVERSION_FACTOR = 1.4
    }
}

local cutterConverterConstants = {
    CONVERTER_IS_BASE_TYPE = false
}

---Mission00 is loading
---@param mission table (Mission00)
local function preload(mission)
    local windrowConversionFactor = 0

    for cutterConverterName, cutterConverterDesc in pairs(cutterConverterData) do
        -- Convert FROM_FRUIT to TO_FRUIT
        local fromFruitTypeDesc   = g_fruitTypeManager:getFruitTypeByName(cutterConverterDesc.FROM_FRUIT)
        local toFruitFillTypeDesc = g_fillTypeManager:getFillTypeByName(cutterConverterDesc.TO_FRUIT)

        local converterIndex = g_fruitTypeManager:addFruitTypeConverter(
            cutterConverterName,
            cutterConverterConstants.CONVERTER_IS_BASE_TYPE
        )

        g_fruitTypeManager:addFruitTypeConversion(
            converterIndex,
            fromFruitTypeDesc.index,
            toFruitFillTypeDesc.index,
            cutterConverterDesc.CONVERSION_FACTOR,
            windrowConversionFactor
        )
    end
end

---Cutter.onLoad
---@param self table (cutter)
---@param savegame table
local function onLoad(self, savegame)
    local spec = self.spec_cutter
    local data = nil

    for cutterConverterName, _ in pairs(cutterConverterData) do
        data = g_fruitTypeManager:getConverterDataByName(cutterConverterName)

        if data ~= nil then
            for input, converter in pairs(data) do
                spec.fruitTypeConverters[input] = converter
            end
        end
    end
end

---init()
local function init()
    Mission00.load = Utils.prependedFunction(Mission00.load, preload)
    Cutter.onLoad = Utils.appendedFunction(Cutter.onLoad, onLoad)
end

init()
