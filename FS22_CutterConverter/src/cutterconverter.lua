---
-- Cutter Converter
--
-- This table will be used to overwrite processCutterArea to convert one fruit to another
-- with the new value 'convertTo' on the fruitType.
--
-- Copyright (c) Peppie84, 2023
--
CutterConverter = {}

---Cutter.processCutterArea
function CutterConverter.inj_processCutterArea(self, superFunc, workArea, dt)
    local spec = self.spec_cutter

	if spec.workAreaParameters.combineVehicle ~= nil then
		local xs, _, zs = getWorldTranslation(workArea.start)
		local xw, _, zw = getWorldTranslation(workArea.width)
		local xh, _, zh = getWorldTranslation(workArea.height)
		local lastRealArea = 0
		local lastThreshedArea = 0
		local lastArea = 0
		local fieldGroundSystem = g_currentMission.fieldGroundSystem

		for _, fruitTypeIndex in ipairs(spec.workAreaParameters.fruitTypesToUse) do
			local fruitTypeDesc = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
			local chopperValue = fieldGroundSystem:getChopperTypeValue(fruitTypeDesc.chopperTypeIndex)
			local realArea, area, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, beeYieldBonusPerc, growthState, _, terrainDetailPixelsSum = FSDensityMapUtil.cutFruitArea(fruitTypeIndex, xs, zs, xw, zw, xh, zh, true, spec.allowsForageGrowthState, chopperValue)

			if realArea > 0 then
				if self.isServer then

                    if fruitTypeDesc.convertTo ~= nil then
                        local convertFruitType = g_fruitTypeManager:getFruitTypeByName(fruitTypeDesc.convertTo:upper())
                        if convertFruitType ~= nil then
                            fruitTypeIndex = convertFruitType.index
                            fruitTypeDesc = convertFruitType
						else
							print("ERROR: Fuit '".. fruitTypeDesc.convertTo:upper() .."' not found to convert from '" .. fruitTypeDesc.name:upper() .. "'")
                        end
                    end

					if growthState ~= spec.currentGrowthState then
						spec.currentGrowthStateTimer = spec.currentGrowthStateTimer + dt

						if spec.currentGrowthStateTimer > 500 or spec.currentGrowthStateTime + 1000 < g_time then
							spec.currentGrowthState = growthState
							spec.currentGrowthStateTimer = 0
						end
					else
						spec.currentGrowthStateTimer = 0
						spec.currentGrowthStateTime = g_time
					end

					if fruitTypeIndex ~= spec.currentInputFruitType then
						spec.currentInputFruitType = fruitTypeIndex
						spec.currentOutputFillType = g_fruitTypeManager:getFillTypeIndexByFruitTypeIndex(spec.currentInputFruitType)

						if spec.fruitTypeConverters[spec.currentInputFruitType] ~= nil then
							spec.currentOutputFillType = spec.fruitTypeConverters[spec.currentInputFruitType].fillTypeIndex
							spec.currentConversionFactor = spec.fruitTypeConverters[spec.currentInputFruitType].conversionFactor
						end

						local cutHeight = g_fruitTypeManager:getCutHeightByFruitTypeIndex(fruitTypeIndex, spec.allowsForageGrowthState)

						self:setCutterCutHeight(cutHeight)
					end

					self:setTestAreaRequirements(fruitTypeIndex, nil, spec.allowsForageGrowthState)

					if terrainDetailPixelsSum > 0 then
						spec.currentInputFruitTypeAI = fruitTypeIndex
					end

					spec.currentInputFillType = g_fruitTypeManager:getFillTypeIndexByFruitTypeIndex(fruitTypeIndex)
					spec.useWindrow = false
				end

				local multiplier = g_currentMission:getHarvestScaleMultiplier(fruitTypeIndex, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, beeYieldBonusPerc)
				lastRealArea = realArea * multiplier
				lastThreshedArea = realArea
				lastArea = area
				spec.workAreaParameters.lastFruitType = fruitTypeIndex
				spec.workAreaParameters.lastChopperValue = chopperValue

				break
			end
		end

		if lastArea > 0 then
			if workArea.chopperAreaIndex ~= nil and spec.workAreaParameters.lastChopperValue ~= nil then
				local chopperWorkArea = self:getWorkAreaByIndex(workArea.chopperAreaIndex)

				if chopperWorkArea ~= nil then
					xs, _, zs = getWorldTranslation(chopperWorkArea.start)
					xw, _, zw = getWorldTranslation(chopperWorkArea.width)
					xh, _, zh = getWorldTranslation(chopperWorkArea.height)

					FSDensityMapUtil.setGroundTypeLayerArea(xs, zs, xw, zw, xh, zh, spec.workAreaParameters.lastChopperValue)
				else
					workArea.chopperAreaIndex = nil

					Logging.xmlWarning(self.xmlFile, "Invalid chopperAreaIndex '%d' for workArea '%d'!", workArea.chopperAreaIndex, workArea.index)
				end
			end

			spec.stoneLastState = FSDensityMapUtil.getStoneArea(xs, zs, xw, zw, xh, zh)
			spec.isWorking = true
		end

		spec.workAreaParameters.lastRealArea = spec.workAreaParameters.lastRealArea + lastRealArea
		spec.workAreaParameters.lastThreshedArea = spec.workAreaParameters.lastThreshedArea + lastThreshedArea
		spec.workAreaParameters.lastStatsArea = spec.workAreaParameters.lastStatsArea + lastThreshedArea
		spec.workAreaParameters.lastArea = spec.workAreaParameters.lastArea + lastArea
	end

	return spec.workAreaParameters.lastRealArea, spec.workAreaParameters.lastArea
end
