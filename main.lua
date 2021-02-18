
dofile("timeAndSpace.lua")
dofile("habitatCone.lua")
dofile("queue.lua")

-- a habitat is a vector of cells
habitatDensity = function(habitat, self)
    local sum = 0

    if self then sum = -1 end -- ignore the agent itself

    forEachElement(habitat, function(_, cell)
        sum = sum + #cell:getAgents()
    end)

    return sum / #habitat
end

habitatBurning = function(habitat)
    local burning = false
    forEachElement(habitat, function(_, cell)
        if cell:burning() == 1 then
            burning = true
        end
    end)

    return burning
end

Mouse = Agent{
    -- verifica se o habitat esta cheio
    fullHabitat = function(self, habitat)
        if habitat == nil then
            return habitatDensity(self.habitat, true) > self.density
        end

        return habitatDensity(habitat) > self.density
    end,
    -- move the agent to a random cell within its habitat
    moveWithinHabitat = function(self)
        local newCell = Random(clone(self.habitat)):sample()

        if newCell:isEmpty() then
            self:move(newCell)
        end
    end,
    validHabitat = function(self, cell)
        return belong(cell.state, self.validHabitats)
    end,
    habitatGrade = function(self, habitat)
        local grade = 0

        forEachElement(habitat, function(_, cell)
            if self:validHabitat(cell) then
                grade = grade + self[cell.state]
            end
        end)

        return grade
    end,
    newHabitat = function(self)
        self.habitat = {}
    end,
    addHabitat = function(self, cell)
        if type(cell) ~= "Cell" then
            error("wrong cell, got "..type(cell))
        end

        table.insert(self.habitat, cell)
    end,
    checkCone = function(self)
        local candidates = habitatCone(self:getCell(), 2)
        local best_candidates = {}
        local best_grade = self:habitatGrade(self.habitat)
        local newCell

        if self:fullHabitat() then -- se o habitat atual esta cheio qualquer lugar eh melhor
            best_grade = 0
        end

        forEachElement(candidates, function(_, habitat) -- verifica dentro do cone
            if habitatBurning(habitat) then return end -- at least one cell burning
            if self:fullHabitat(habitat) then return end -- more than allowed density

            local grade = self:habitatGrade(habitat)

            if grade > best_grade then
                best_candidates = {habitat}
                best_grade = grade
            elseif grade == best_grade then
                table.insert(best_candidates, habitat)
            end
        end)

        if #best_candidates > 1 then
            newCell = Random(best_candidates):sample()[1]
        elseif #best_candidates == 1 then
            newCell = best_candidates[1][1]
        end

        if newCell then -- compute the new habitat
            self:move(newCell)
            self:buildHabitat(newCell)
        end
    end,
    buildHabitat = function(self, cell)
        self:move(cell)
        local addedToQueue = {}

        queue:clean()
        queue:push(cell)
        addedToQueue[cell] = true

        local missing = self.lifearea - 1

        while missing > 0 and queue:length() > 0 do
            local candidates = {}

            for _ = 1, queue:length() do
                local newcell = queue:pop()

                if self:validHabitat(newcell) then
                    table.insert(candidates, newcell)

                    forEachNeighbor(newcell, function(neigh)
                        if not addedToQueue[neigh] then
                            addedToQueue[neigh] = true
                            queue:push(neigh)
                        end
                    end)
                end
            end

            if #candidates <= missing then
                forEachElement(candidates, function(_, value)
                    self:addHabitat(value)
                end)

                missing = missing - #candidates
            else -- #candidates > missing
                while missing > 0 do
                    local pos = Random{min = 1, max = #candidates, step = 1}:sample()

                    self:addHabitat(candidates[pos])
                    table.remove(candidates, pos)
                    missing = missing - 1
                end
            end
        end
    end,
    execute = function(self)
        self:checkCone()
        self:moveWithinHabitat()
        self:lifeCycle()
    end,
    procreate = function(self)
        local new_mouse = self:reproduce()
        new_mouse:newHabitat()
        new_mouse:addHabitat(puppy:getCell())
    end,
    lifeCycle = function(self)
        self.Age = self.Age + 1

        -- reproductiveAge = 10, betweenoffspring = 4 => 10, 14, 18, 22, etc.
        if self.sex == "female" and not self:fullHabitat() and (self.Age >= self.ReproductiveAge) then
            -- se o habitat estiver cheio na epoca da reproducao ela vai perder a janela de reproducao
            if (self.Age - self.ReproductiveAge) % self.BetweenOffspring == 0 then -- a cada ReproductiveAge dias
                for _ = 1, self.Offspring do
                    self:procreate()
                end

                local prob = self.Offspring % 1 -- 4.2 => 4 mouses + 20% of change of one more mouse

                if Random{p = prob}:sample() then
                    self:procreate()
                end
            end
        end

        if self.Age > self.LifeExpectance then
            self:die()
        elseif self:getCell():burning() == 1 and Random{p = self.BurningProbability}:sample() then
            self:die()
        end
    end
}

animal1 = Mouse{
    Offspring = 6,
    ReproductiveAge = 226,
    BurningProbability = 0.8,
    BetweenOffspring = 90,
    LifeExpectance = 472,
    sex = Random {"male", "female"},
    Age = 0,
    forest = 4.00,
    savanna = 3.00,
    grasslands = 2.00,
    crop =	1.00,
    pasture = 2.00,
    OtherNonVegetatedArea = 0,
    ForestPlantation = 2.00,
    Water = 0.00,
    MosaicAgriculturePasture = 2.00,
    Wetland	= 1.00,
    Rockyoutcrop = 2.00,
    Others = 0.00,
    density = 0.21, -- número de indivíduos por célula
    lifearea = 33, -- pode ser o tamanho do cone para onde ele mora
    perceptualRange = 3, -- número de células onde ele enxerga. No caso, 3 células de distância
    validHabitats =  {"forest"},
}

animal2 = Mouse{
    Offspring = 4.22,
    ReproductiveAge = 131.50,
    BetweenOffspring = 107.00,
    LifeExpectance = 720.00,
    sex = Random {"male", "female"},
    Age = 0,
    forest = 4,
    savanna = 3.00,
    grasslands = 1.00,
    crop =	1.00,
    pasture = 1.00,
    OtherNonVegetatedArea = 0,
    ForestPlantation = 1.00,
    Water = 0.00,
    MosaicAgriculturePasture = 1.00,
    Wetland	= 1.00,
    Rockyoutcrop = 1.00,
    Others = 0.00,
    density = 0.26, -- indivíduos por célula
    lifearea = 2, -- pode ser o tamanho do cone para onde ele mora
    perceptualRange = 1, -- número de células onde ele enxerga. No caso, 3 células de distância
    validHabitats = {"forest", "savanna"},
}

animal3 = Mouse{
    Offspring = 3.53,
    ReproductiveAge = 115,
    BetweenOffspring = 70.75,
    LifeExpectance = 415.26,
    sex = Random {"male", "female"},
    Age = 0,
    forest = 3,
    savanna = 4,
    grasslands = 4,
    crop =	2,
    pasture = 3,
    OtherNonVegetatedArea = 0,
    ForestPlantation = 1.00,
    Water = 0.00,
    MosaicAgriculturePasture = 2.00,
    Wetland	= 1.00,
    Rockyoutcrop = 3.00,
    Others = 0.00,
    density = 0.61, -- indivíduos por célula
    lifearea = 2, -- pode ser o tamanho do cone para onde ele mora
    perceptualRange = 1, -- número de células onde ele enxerga. No caso, 3 células de distância
    validHabitats = {"savanna", "grasslands"},
}

animal4 = Mouse{
    Offspring = 3.75,
    ReproductiveAge = 115,
    BetweenOffspring = 25,
    LifeExpectance = 587,
    sex = Random {"male", "female"},
    Age = 0,
    forest = 4,
    savanna = 3.00,
    grasslands = 1.00,
    crop =	1.00,
    pasture = 1.00,
    OtherNonVegetatedArea = 0,
    ForestPlantation = 2.00,
    Water = 4.00,
    MosaicAgriculturePasture = 1.00,
    Wetland	= 1.00,
    Rockyoutcrop = 1.00,
    Others = 0.00,
    density = 0.26, -- indivíduos por célula
    lifearea = 3, -- pode ser o tamanho do cone para onde ele mora
    perceptualRange = 2, -- número de células onde ele enxerga. No caso, 3 células de distância
    validHabitats = {"forest"},
}

soc1 = Society{instance = animal1, quantity = 1000}
soc2 = Society{instance = animal2, quantity = 1000}
soc3 = Society{instance = animal3, quantity = 1000}
soc4 = Society{instance = animal4, quantity = 1000}

env = Environment{soc1, soc2, soc3, soc4, cs}
env:createPlacement{} -- colocando a sociedade dentro do espaço

-- the initial habitat of an agent is the cell it belongs
-- from the first step on it will be the cone it moved to
forEachCell(cs, function(cell)
    local agent = cell:getAgent()

    if agent then
        agent:newHabitat()
        agent:addHabitat(cell)
    end
end)

-- this is the simulation
-- do not use Timer as time representation is more complex
currentTime = now:get()

--[[
map = Map{
    target = cs,
    select = "state",
	value = {"forest", "savanna", "grasslands", "pasture"},
    --value = {3, 4, 12, 15}, --"4", "12", "15", "19", "21", "33"}, -- forest, savanna, grasslands, pasture, annual and perenial crop, Mosaic of Agriculture and Pasture,River, Lake and Ocean
    color = {"green","yellow", "orange", "red"}
}

map2 = Map{
    target = cs,
    select = "burning",
	value = {0,1},
    color = {"white","red"}
}

map2 = Map{
    target = soc1,
    background = map2
}
--]]

quantityByClass = File("quantity-by-class.csv")
quantityByCoverage = File("quantity-by-coverage.csv")

quantityByClass:writeLine({"s1", "s2", "s3", "s4", "total"}, ";")
quantityByCoverage:writeLine({"forest", "grasslands", "pasture", "savanna", "total"}, ";")

writeByClass = function()
   quantityByClass:writeLine({#soc1, #soc2, #soc3, #soc4, #soc1 + #soc2 + #soc3 + #soc4}, ";")
end

writeByCoverage = function()
    sum = {forest = 0, grasslands = 0, pasture = 0, savanna = 0}

    forEachCell(cs, function(cell)
        if sum[cell.state] == nil then return end
        if cell:getAgent() == nil then return end

        sum[cell.state] = sum[cell.state] + 1
    end)

    quantityByCoverage:writeLine({sum.forest, sum.grasslands, sum.pasture, sum.savanna,
                                  sum.forest + sum.grasslands + sum.pasture + sum.savanna}, ";")
end

writeByCoverage()
writeByClass()

while currentTime < 19990301 do --20181231 do -- final time
    print(currentTime)
    currentTime = now:get()
    if updateLandCover(currentTime) then
--        map: update()
    end
    if updateBurning(currentTime) then
--        map2:update()
    end
    soc1:execute()
    soc2:execute()
    soc3:execute()
    soc4:execute()
    now:nextday()
    writeByClass()
    writeByCoverage()
end
