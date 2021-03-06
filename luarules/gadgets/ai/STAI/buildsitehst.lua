
local DebugEnabledPlans = false
local DebugEnabledDraw = false


local function EchoDebugPlans(inStr)
	if DebugEnabledPlans then
		game:SendToConsole("BuildSiteHST Plans: " .. inStr)
	end
end

BuildSiteHST = class(Module)

function BuildSiteHST:Name()
	return "BuildSiteHST"
end

function BuildSiteHST:internalName()
	return "buildsitehst"
end

BuildSiteHST.DebugEnabled = false

function BuildSiteHST:Init()
	self.debugPlotDrawn = {}
	local mapSize = self.map:MapDimensions()
	self.ai.maxElmosX = mapSize.x * 8
	self.ai.maxElmosZ = mapSize.z * 8
	self.ai.maxElmosDiag = math.sqrt(self.ai.maxElmosX^2 + self.ai.maxElmosZ^2)
	self.ai.lvl1Mexes = 1 -- this way mexupgrading doesn't revert to taskqueuing before it has a chance to find mexes to upgrade
	self.resurrectionRepair = {}
	self.dontBuildRects = {}
	self.plans = {}
	self.constructing = {}
	-- self.history = {}
	self:DontBuildOnMetalOrGeoSpots()
end

function BuildSiteHST:GetFacing(p)
	local x = p.x
	local z = p.z
	if math.abs(Game.mapSizeX - 2*x) > math.abs(Game.mapSizeZ - 2*z) then
		if (2*x>Game.mapSizeX) then
			facing=3
		else
			facing=1
		end
	else
		if (2*z>Game.mapSizeZ) then
			facing=2
		else
			facing=0
		end
	end
	return facing
end

function BuildSiteHST:PlansOverlap(position, unitName)
	local rect = { position = position, unitName = unitName }
	self:CalculateRect(rect)
	for i, plan in pairs(self.plans) do
		if self.ai.tool:RectsOverlap(rect, plan) then
			return true
		end
	end
	return false
end

-- keeps amphibious/hover cons from zigzagging from the water to the land too far
function BuildSiteHST:LandWaterFilter(pos, unitTypeToBuild, builder)
	local builderName = builder:Name()
	local mtype = self.ai.armyhst.unitTable[builderName].mtype
	if mtype ~= "amp" and  mtype ~= "hov" and not self.ai.armyhst.commanderList[builderName] then
		-- don't bother with units that aren't amphibious
		return true
	end
	local unitName = unitTypeToBuild:Name()
	if self.ai.armyhst.unitTable[unitName].extractsMetal > 0 or self.ai.armyhst.unitTable[unitName].buildOptions then
		-- leave mexes and factories alone
		return true
	end
	-- where is the con?
	local builderPos = builder:GetPosition()
	local water = self.ai.maphst:MobilityNetworkHere("shp", builderPos)
	-- is this a land or a water unit we're building?
	local waterBuildOrder = self.ai.armyhst.unitTable[unitName].needsWater
	-- if this is a movement from land to water or water to land, check the self.ai.tool:distance
	if water then self:EchoDebug(builderName .. " is in water") else self:EchoDebug(builderName .. " is on land") end
	if waterBuildOrder then self:EchoDebug(unitName .. " would be in water") else self:EchoDebug(unitName .. " would be on land") end
	if (water and not waterBuildOrder) or (not water and waterBuildOrder) then
		self:EchoDebug("builder would traverse the shore to build " .. unitName)
		local dist = self.ai.tool:Distance(pos, builderPos)
		if dist > 250 then
			self:EchoDebug("build too far away from shore to build " .. unitName)
			return false
		else
			return true
		end
	else
		return true
	end
end

function BuildSiteHST:CheckBuildPos(pos, unitTypeToBuild, builder, originalPosition)
	-- make sure it's on the map
	local mapSize = self.ai.map:MapDimensions()
	local maxElmosX = mapSize.x * 8
	local maxElmosZ = mapSize.z * 8
	if pos ~= nil then
		if self.ai.armyhst.unitTable[unitTypeToBuild:Name()].buildOptions then
			-- don't build factories too close to south map edge because they face south
			-- Spring.Echo(pos.x, pos.z, maxElmosX, maxElmosZ)
			if (pos.x <= 0) or (pos.x > maxElmosX) or (pos.z <= 0) or (pos.z > maxElmosZ - 240) then
				self:EchoDebug("bad position: " .. pos.x .. ", " .. pos.z)
				return nil
			end
		else
			if (pos.x <= 0) or (pos.x > maxElmosX) or (pos.z <= 0) or (pos.z > maxElmosZ) then
				self:EchoDebug("bad position: " .. pos.x .. ", " .. pos.z)
				return nil
			end
		end
	end
	-- sanity check: is it REALLY possible to build here?
	if pos ~= nil then
		local s = self.ai.map:CanBuildHere(unitTypeToBuild, pos)
		if not s then
			self:EchoDebug("cannot build " .. unitTypeToBuild:Name() .. " here: " .. pos.x .. ", " .. pos.z)
			return nil
		end
	end
	local rect
	if pos ~= nil then
		rect = {position = pos, unitName = unitTypeToBuild:Name()}
		self:CalculateRect(rect)
	end
	-- is it too far away from an amphibious constructor?
	if pos ~= nil then
		local lw = self:LandWaterFilter(pos, unitTypeToBuild, builder)
		if not lw then
			return nil
		end
	end
	-- don't build where you shouldn't (metal spots, geo spots, factory lanes)
	if pos ~= nil then
		for i, dont in pairs(self.dontBuildRects) do
			if self.ai.tool:RectsOverlap(rect, dont) then
				pos = nil
				break
			end
		end
	end
	-- don't build on top of current build orders
	if pos ~= nil then
		for i, plan in pairs(self.plans) do
			if self.ai.tool:RectsOverlap(rect, plan) then
				return nil
			end
		end
	end
	-- don't build where the builder can't go
	if pos ~= nil then
		if not self.ai.maphst:UnitCanGoHere(builder, pos) then
			self:EchoDebug(builder:Name() .. " can't go there: " .. pos.x .. "," .. pos.z)
			return nil
		end
	end
	if pos ~= nil then
		local uname = unitTypeToBuild:Name()
		if self.ai.armyhst.nanoTurretList[uname] then
			-- don't build nanos too far away from factory
			local dist = self.ai.tool:Distance(originalPosition, pos)
			self:EchoDebug("nano self.ai.tool:distance: " .. dist)
			if dist > 390 then
				self:EchoDebug("nano too far from factory")
				return nil
			end
		elseif self.ai.armyhst.bigPlasmaList[uname] or self.ai.armyhst.littlePlasmaList[uname] or self.ai.armyhst.nukeList[uname] then
			-- don't build bombarding units outside of bombard positions
			local b = self.ai.targethst:IsBombardPosition(pos, uname)
			if not b then
				self:EchoDebug("bombard not in bombard position")
				return nil
			end
		end
	end
	return pos
end

function BuildSiteHST:GetBuildSpacing(unitTypeToBuild)
	local spacing = 1
	local name = unitTypeToBuild:Name()
	if self.ai.armyhst.Eco1[name] then spacing = 2 end--TODO removing this sistem
	if self.ai.armyhst.unitTable[name].isWeapon then spacing = 8 end
	if self.ai.armyhst.unitTable[name].bigExplosion then spacing = 20 end
	if self.ai.armyhst.unitTable[name].buildOptions then spacing = 4 end
	return spacing
end

function BuildSiteHST:ClosestBuildSpot(builder, position, unitTypeToBuild, minimumDistance, attemptNumber, buildDistance, maximumDistance)
	maximumDistance = maximumDistance or 400
	-- return self:ClosestBuildSpotInSpiral(builder, unitTypeToBuild, position)
	if attemptNumber == nil then self:EchoDebug("looking for build spot for " .. builder:Name() .. " to build " .. unitTypeToBuild:Name()) end
	local minDistance = minimumDistance or self:GetBuildSpacing(unitTypeToBuild)
	buildDistance = buildDistance or 100
	local function validFunction(pos)
		local vpos = self:CheckBuildPos(pos, unitTypeToBuild, builder, position)
		-- Spring.Echo(pos.x, pos.y, pos.z, unitTypeToBuild:Name(), builder:Name(), position.x, position.y, position.z, vpos)
		return vpos
	end
	return self.map:FindClosestBuildSite(unitTypeToBuild, position, maximumDistance, minDistance, validFunction)
end

-- deprecated --]]
-- function BuildSiteHST:ClosestBuildSpotInSpiral(builder, unitTypeToBuild, position, dist, segmentSize, direction, i)
-- 	local pos = nil
-- 	if dist == nil then
-- 		local ut = self.ai.armyhst.unitTable[unitTypeToBuild:Name()]
-- 		dist = math.max(ut.xsize, ut.zsize) * 8
-- 		-- dist = 64
-- 	end
-- 	if segmentSize == nil then segmentSize = 1 end
-- 	if direction == nil then direction = 1 end
-- 	if i == nil then i = 0 end
-- 	-- have to set it this way, otherwise both just point to the same set of data, and originalPosition doesn't stay the same
-- 	local searchPos = api.Position()
-- 	searchPos.x = position.x + 0
-- 	searchPos.y = position.y + 0
-- 	searchPos.z = position.z + 0
--
-- 	self:EchoDebug("new spiral search")
-- 	while segmentSize < 8 do
-- 		-- self:EchoDebug(i .. " " .. direction .. " " .. segmentSize .. " : " .. math.ceil(position.x) .. " " .. math.ceil(position.z))
-- 		if direction == 1 then
-- 			searchPos.x = searchPos.x + dist
-- 		elseif direction == 2 then
-- 			searchPos.z = searchPos.z + dist
-- 		elseif direction == 3 then
-- 			searchPos.x = searchPos.x - dist
-- 		elseif direction == 4 then
-- 			searchPos.z = searchPos.z - dist
-- 		end
-- 		pos = self:CheckBuildPos(searchPos, unitTypeToBuild, builder, position)
-- 		if pos ~= nil then break end
-- 		i = i + 1
-- 		if i == segmentSize then
-- 			i = 0
-- 			direction = direction + 1
-- 			if direction == 3 then
-- 				segmentSize = segmentSize + 1
-- 			elseif direction == 5 then
-- 				segmentSize = segmentSize + 1
-- 				direction = 1
-- 			end
-- 		end
-- 	end
--
-- 	return pos
-- end


function BuildSiteHST:ClosestHighestLevelFactory(builderPos, maxDist)
	if not builderPos then return end
	local minDist = maxDist
	local maxLevel = self.ai.maxFactoryLevel
	self:EchoDebug(maxLevel .. " max factory level")
	local factorybhvr
	if self.ai.factoriesAtLevel[maxLevel] ~= nil then
		for i, factory in pairs(self.ai.factoriesAtLevel[maxLevel]) do
			if not self.ai.outmodedFactoryID[factory.id] then
				local dist = self.ai.tool:Distance(builderPos, factory.position)
				if dist < minDist then
					minDist = dist
					factorybhvr = factory
				end
			end
		end
	end
	if factorybhvr then

		local factoryPos = factorybhvr.position
		local newpos = api.Position()
		newpos.x = factoryPos.x
		newpos.z = factoryPos.z
		newpos.y = factoryPos.y
		return newpos, factorybhvr.unit:Internal()
	else
		return
	end
end

function BuildSiteHST:DontBuildRectangle(x1, z1, x2, z2, unitID)
	x1 = math.ceil(x1)
	z1 = math.ceil(z1)
	x2 = math.ceil(x2)
	z2 = math.ceil(z2)
	table.insert(self.dontBuildRects, {x1 = x1, z1 = z1, x2 = x2, z2 = z2, unitID = unitID})
end

-- handle deaths
function BuildSiteHST:DoBuildRectangleByUnitID(unitID)
	for i = #self.dontBuildRects, 1, -1 do
		local rect = self.dontBuildRects[i]
		if rect.unitID == unitID then
			table.remove(self.dontBuildRects, i)
		end
	end
	self:PlotAllDebug()
end

function BuildSiteHST:DontBuildOnMetalOrGeoSpots()
	local spots = self.ai.scoutSpots["air"][1]
	for i, p in pairs(spots) do
		self:DontBuildRectangle(p.x-40, p.z-40, p.x+40, p.z+40)
	end
	self:PlotAllDebug()

end

function BuildSiteHST:unitNearCheck(utype,pos,range)
	if type(range) ~= 'number' then
		range = self.ai.armyhst.unitTable[utype:Name()][range]
	end
	--local target = Spring.GetUnitsInCylinder(p.x,p.z,range,self.game:GetTeamID())
	local unitsNear = self.game:getUnitsInCylinder(pos, range)
	if not unitsNear  then return false end
	for idx, typeDef in pairs(unitsNear) do
		local unitName = self.game:GetUnitByID(typeDef):Name()
		if utype:Name() == unitName  then
			self:EchoDebug(utype:Name() .. ' block by ' .. tostring(unitName))
			return true
		end
	end
	return false
end

function BuildSiteHST:searchPosNearThing(utype,builder,thing,range,spaceEquals,minDist)
	self:EchoDebug(thing)
	local pos = builder:GetPosition()
	local builderName = builder:Name()
	if not range then
		range = self.ai.armyhst.unitTable[builderName].losRadius
		if type(spaceEquals) == 'string' then
			range = self.ai.armyhst.unitTable[builderName][spaceEquals]
		elseif type(spaceEquals) == 'number' then
			range = spaceEquals
		end
	end
	local unitsNear = self.game:getUnitsInCylinder(pos, range)
	if not unitsNear then return nil end
	for idx, typeDef in pairs(unitsNear) do
		local unitNear = self.game:GetUnitByID(typeDef)
		local unitNearName = unitNear:Name()
		self:EchoDebug('around there ', unitNearName)
		local tg = self.ai.armyhst.unitTable[unitNearName][thing]
		if tg then
			self:EchoDebug()
			local tgPos = unitNear:GetPosition()
			if  spaceEquals then
				if not self:unitNearCheck(utype,tgPos,spaceEquals)then
					self:EchoDebug('no same unit near: pass')
					local p = self.ai.buildsitehst:ClosestBuildSpot(builder, tgPos, utype , minDist, nil, nil, self.ai.armyhst.unitTable[builderName].losRadius)
					self:EchoDebug('is ok')
					if p then return p end
				else
					self:EchoDebug('same unit near: skip')
				end
			else
				local p = self.ai.buildsitehst:ClosestBuildSpot(builder, tgPos, utype , minDist, nil, nil, self.ai.armyhst.unitTable[builderName].losRadius)
				if p then return p end
			end
		end
	end
	return nil
end

function BuildSiteHST:searchPosInList(list,utype, builder, spaceEquals,minDist)
	if spaceEquals and self:unitNearCheck(utype,builder:GetPosition(),spaceEquals) then return nil end
	if list and #list > 0 then
		for index, pos in pairs(list) do
			if self.ai.tool:Distance(pos,builder:GetPosition()) < self.ai.armyhst.unitTable[builder:Name()].losRadius then
				if not spaceEquals or not self:unitNearCheck(utype,pos,spaceEquals)then
					local p = self.ai.buildsitehst:ClosestBuildSpot(builder, pos, utype , minDist, nil, nil, self.ai.armyhst.unitTable[utype:Name()][spaceEquals])
					if p then return p end
				end
			end
		end
	end

	return nil
end


function BuildSiteHST:BuildNearNano(builder, utype)
	self:EchoDebug("looking for spot near nano hotspots")
	local nanoHots = self.ai.nanohst:GetHotSpots()
	if nanoHots then
		self:EchoDebug("got " .. #nanoHots .. " nano hotspots")
		local hotRadius = self.ai.nanohst:HotBuildRadius()
		for i = 1, #nanoHots do
			local hotPos = nanoHots[i]
			-- find somewhere within hotspot
			local p = self:ClosestBuildSpot(builder, hotPos, utype, 10, nil, nil, hotRadius)
			if p then
				self:EchoDebug('found Position for near nano hotspot at: ' .. hotPos.x ..' ' ..hotPos.z)
				return p
			end
		end
	end
	return self:BuildNearLastNano(builder, utype)

end

function BuildSiteHST:BuildNearLastNano(builder, utype)
	self:EchoDebug("looking for spot near last nano")
	local p = nil
	if self.ai.lastNanoBuild then
		self:EchoDebug('found position near last nano')
		-- find somewhere at most 400 away
		p = self:ClosestBuildSpot(builder, self.ai.lastNanoBuild, utype, 30, nil, nil, 400)
	end
	return p
end

function BuildSiteHST:UnitCreated(unit)
	local unitName = unit:Name()
	local position = unit:GetPosition()
	local unitID = unit:ID()
	local planned = false
	for i = #self.plans, 1, -1 do
		local plan = self.plans[i]
		if plan.unitName == unitName and self.ai.tool:PositionWithinRect(position, plan) then
			if plan.resurrect then
				-- so that BootBST will hold it in place while it gets repaired
				self:EchoDebug("resurrection of " .. unitName .. " begun")
				self.resurrectionRepair[unitID] = plan.behaviour
			else
				self:EchoDebug(plan.behaviour.name .. " began constructing " .. unitName)
				if self.ai.armyhst.unitTable[unitName].isBuilding or self.ai.armyhst.nanoTurretList[unitName] then
					-- so that oversized factory lane rectangles will overlap with existing buildings
					self:DontBuildRectangle(plan.x1, plan.z1, plan.x2, plan.z2, unitID)
					self.ai.turtlehst:PlanCreated(plan, unitID)
				end
				-- tell the builder behaviour that construction has begun
				plan.behaviour:ConstructionBegun(unitID, plan.unitName, plan.position)
				-- pass on to the table of what we're actually building
				plan.frame = self.game:Frame()
				self.constructing[unitID] = plan
				table.remove(self.plans, i)
			end
			planned = true
			break
		end
	end
	if not planned and (self.ai.armyhst.unitTable[unitName].isBuilding or self.ai.armyhst.nanoTurretList[unitName]) then
		-- for when we're restarting the AI, or other contingency
		-- game:SendToConsole("unplanned building creation " .. unitName .. " " .. unitID .. " " .. position.x .. ", " .. position.z)
		local rect = { position = position, unitName = unitName }
		self:CalculateRect(rect)
		self:DontBuildRectangle(rect.x1, rect.z1, rect.x2, rect.z2, unitID)
		self.ai.turtlehst:NewUnit(unitName, position, unitID)
	end
	self:PlotAllDebug()
end

-- prevents duplication of expensive buildings and building more than one factory at once
-- true means there's a duplicate, false means there isn't
function BuildSiteHST:CheckForDuplicates(unitName)
	if unitName == nil then return true end
	if unitName == self.ai.armyhst.DummyUnitName then return true end
	local utable = self.ai.armyhst.unitTable[unitName]
	local isFactory = utable.isBuilding and utable.buildOptions
	local isExpensive = utable.metalCost > 300
	if not isFactory and not isExpensive then return false end
	EchoDebugPlans("looking for duplicate plan for " .. unitName)
	for i, plan in pairs(self.plans) do
		local thisIsFactory = self.ai.armyhst.unitTable[plan.unitName].isBuilding and self.ai.armyhst.unitTable[plan.unitName].buildOptions
		if isFactory and thisIsFactory then return true end
		if isExpensive and plan.unitName == unitName then return true end
	end
	EchoDebugPlans("looking for duplicate construction for " .. unitName)
	for unitID, construct in pairs(self.constructing) do
		if isExpensive and construct.unitName == unitName then
			self:EchoDebug('there is already one of this')
			return true
		end
	end
	return false
end

function BuildSiteHST:MyUnitBuilt(unit)
	local unitID = unit:ID()
	local done = self.constructing[unitID]
	if done then
		EchoDebugPlans(done.behaviour.name .. " " .. done.behaviour.id ..  " completed " .. done.unitName .. " " .. unitID)
		done.behaviour:ConstructionComplete()
		done.frame = self.game:Frame()
		-- table.insert(self.history, done)
		self.constructing[unitID] = nil
	end
end

function BuildSiteHST:UnitDead(unit)
	local unitID = unit:ID()
	local construct = self.constructing[unitID]
	if construct then
		construct.behaviour:ConstructionComplete()
		self.constructing[unitID] = nil
	end
	self:DoBuildRectangleByUnitID(unitID)
end

function BuildSiteHST:CalculateRect(rect)
	local unitName = rect.unitName
	if self.ai.armyhst.factoryExitSides[unitName] ~= nil and self.ai.armyhst.factoryExitSides[unitName] ~= 0 then
		self:CalculateFactoryLane(rect)
		return
	end
	local position = rect.position
	local outX = self.ai.armyhst.unitTable[unitName].xsize * 4
	local outZ = self.ai.armyhst.unitTable[unitName].zsize * 4
	rect.x1 = position.x - outX
	rect.z1 = position.z - outZ
	rect.x2 = position.x + outX
	rect.z2 = position.z + outZ
end

function BuildSiteHST:CalculateFactoryLane(rect)
	local unitName = rect.unitName
	local position = rect.position
	local outX = self.ai.armyhst.unitTable[unitName].xsize * 4
	local outZ = self.ai.armyhst.unitTable[unitName].zsize * 4
	local tall = outZ * 10
	local facing = self:GetFacing(position)
	if facing == 0 then
		rect.x1 = position.x - outX
		rect.x2 = position.x + outX
		rect.z1 = position.z - outZ
		rect.z2 = position.z + tall
	elseif facing == 2 then
		rect.x1 = position.x - outX
		rect.x2 = position.x + outX
		rect.z1 = position.z - tall
		rect.z2 = position.z + outZ
	elseif facing == 1 then
		rect.x1 = position.x - outX
		rect.x2 = position.x + tall
		rect.z1 = position.z - outZ
		rect.z2 = position.z + outZ
	elseif facing == 3 then
		rect.x1 = position.x - tall
		rect.x2 = position.x + outX
		rect.z1 = position.z - outZ
		rect.z2 = position.z + outZ
	end
end

function BuildSiteHST:NewPlan(unitName, position, behaviour, resurrect)
	if resurrect then
		EchoDebugPlans("new plan to resurrect " .. unitName .. " at " .. position.x .. ", " .. position.z)
	else
		EchoDebugPlans(behaviour.name .. " plans to build " .. unitName .. " at " .. position.x .. ", " .. position.z)
	end
	local plan = {unitName = unitName, position = position, behaviour = behaviour, resurrect = resurrect}
	self:CalculateRect(plan)
	if self.ai.armyhst.unitTable[unitName].isBuilding or self.ai.armyhst.nanoTurretList[unitName] then
		self.ai.turtlehst:NewUnit(unitName, position, plan)
	end
	table.insert(self.plans, plan)
	self:PlotAllDebug()
end

function BuildSiteHST:ClearMyPlans(behaviour)
	for i = #self.plans, 1, -1 do
		local plan = self.plans[i]
		if plan.behaviour == behaviour then
			if not plan.resurrect and (self.ai.armyhst.unitTable[plan.unitName].isBuilding or self.ai.armyhst.nanoTurretList[unitName]) then
				self.ai.turtlehst:PlanCancelled(plan)
			end
			table.remove(self.plans, i)
		end
	end
	self:PlotAllDebug()
end

function BuildSiteHST:ClearMyConstruction(behaviour)
	for unitID, construct in pairs(self.constructing) do
		if construct.behaviour == behaviour then
			self.constructing[unitID] = nil
		end
	end
	self:PlotAllDebug()
end

function BuildSiteHST:RemoveResurrectionRepairedBy(unitID)
	self.resurrectionRepair[unitID] = nil
end

function BuildSiteHST:ResurrectionRepairedBy(unitID)
	return self.resurrectionRepair[unitID]
end

function BuildSiteHST:PlotRectDebug(rect)
	if DebugEnabledDraw and not rect.drawn then
		local label
		local color
		if rect.unitName then
			color = {0, 1, 0} -- plan
		else
			color = {1, 0, 0} -- don't build here
		end
		local pos1 = {x=rect.x1, y=0, z=rect.z1}
		local pos2 = {x=rect.x2, y=0, z=rect.z2}
		local id = self.map:DrawRectangle(pos1, pos2, color)
		rect.drawn = color
		self.debugPlotDrawn[#self.debugPlotDrawn+1] = rect
	end
end

function BuildSiteHST:PlotAllDebug()
	if DebugEnabledDraw then
		local isThere = {}
		for i, plan in pairs(self.plans) do
			self:PlotRectDebug(plan)
			isThere[plan] = true
		end
		for i, rect in pairs(self.dontBuildRects) do
			self:PlotRectDebug(rect)
			isThere[rect] = true
		end
		for i = #self.debugPlotDrawn, 1, -1 do
			local rect = self.debugPlotDrawn[i]
			if not isThere[rect] then
				local pos1 = {x=rect.x1, y=0, z=rect.z1}
				local pos2 = {x=rect.x2, y=0, z=rect.z2}
				self.map:EraseRectangle(pos1, pos2, rect.drawn)
				table.remove(self.debugPlotDrawn, i)
			end
		end
	end
end
