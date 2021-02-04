
dofile("timeAndSpace.lua")
dofile("habitatCone.lua")

-- a habitat is a set of cells

habitatDensity = function(habitat)
    local sum = 0
    forEachElement(habitat, function(_, cell)
        sum = sum + #cell:getAgents()
    end)

    return sum / #habitat
end

habitatBurning = function(habitat)
    local burning = false
    forEachElement(habitat, function(_, cell)
        if cell:burning() then
            burning = true
        end
    end)

    return burning
end

Mouse = Agent{
    -- verifica se o habitat esta cheio
    fullHabitat = function(self, habitat)
        if habitat == nil then habitat = self.habitat end

        return habitatDensity(habitat) > self.density
    end,
    -- move the agent to a random cell within its habitat
    moveWithinHabitat = function(self)
        local newCell = Random(clone(self.habitat)):sample()

        if newCell:isEmpty() then
            self:move(newCell)
        end
    end,
    habitatGrade = function(self, habitat)
        local grade = 0

        forEachElement(habitat, function(_, cell)
            grade = grade + self[cell.state]
            -- cell.state == "forest" and self.forest == 5 => grade = grade + 5
        end)

        return grade
    end,
    checkCone = function(self)
        local candidates = habitatCone(self:getCell(), 2)
        local best_candidates = {}
        local best_grade = self:habitatGrade(self.habitat)
        local newCell

        if self:fullHabitat() then -- se o habitat atual esta cheio qualquer lugar eh melhor
            best_grade = math.inf
        end

        forEachElement(candidates, function(_, habitat) -- verifica dentro do cone
            if habitatBurning(habitat) then return end -- at least one cell burning
            if self:fullHabitat(habitat) then return end -- more than allowed density

            local grade = agent:habitatGrade(habitat)

            if grade > best_grade then
                best_candidates = {habitat}
                best_grade = grade
            elseif grade == current_grade then
                table.insert(best_candidates, habitat)
            end
        end)

        if #best_candidates > 1 then
            newCell = Random(best_candidates):sample()
        elseif #best_candidates == 1 then
            newCell = best_candidates[1]
        end

        if newCell then -- compute the new habitat
            self:move(newCell)
            self:buildHabitat(newCell)
        end

        if #valid_candidates == 0 then return end

        -- think on a way of selecting the new habitat
        new_habitat = valid_candidates[1].habitat

        self.habitat = new_habitat
    end,
    execute = function(self)
        self:checkCone()
        self:moveWithinHabitat()
        self:lifeCycle()
    end,
    lifeCycle = function(self)
        self.Age = self.Age + 1

        -- reproductiveAge = 10, betweenoffspring = 4 => 10, 14, 18, 22, etc.
        if self.sex == "female" and not self:fullHabitat() and (self.Age >= self.ReproductiveAge) then
            -- se o habitat estiver cheio na epoca da reproducao ela vai perder a janela de reproducao
            if (self.Age - self.ReproductiveAge) % self.betweenOffspring == 0 then -- a cada ReproductiveAge dias
                for _ = 1, self.Offspring do
                    local puppy = self:reproduce()
                    puppy.habitat = {puppy:getCell()}
                end
            end
        end

        if self.Age > self.LifeExpectance then
            self:die()
        elseif self:getCell().burning() == 1 and Random{p = self.BurningProbability}:sample() then
            self:die()
        end
    end
}

animal1 = Mouse{
    Offspring = 6,
    ReproductiveAge = 226,
    BurningProbability = 0.8,
    BetweenOffsprings = 90,
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
    habitat =  {"forest"},
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
    habitat = {"forest", "savanna"},
}

animal3 = Mouse{
    Offspring = 3.53,
    ReproductiveAge = 115,
    Offspring = 70.75,
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
    habitat = {"savanna", "grasslands"},
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
    habitat = {"forest"},
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

    if agent then agent.habitat = {cell} end
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

while currentTime < 20181231 do -- final time
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
end
