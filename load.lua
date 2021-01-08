
-- object that represents time
now = {
    year = 1999, -- initial year
    month = 1, -- initial month
    day = 1, -- initial day
    -- current time in the format YYYYMMDD
    get = function(self)
        local mymonth = tostring(self.month)
        if string.len(mymonth) == 1 then mymonth = "0"..mymonth end

        local myday = tostring(self.day)
        if string.len(myday) == 1 then myday = "0"..myday end

        return(tonumber(self.year..mymonth..myday))
    end,
    -- one more day
    -- it assumes each month has 30 days. more accurate solution can be implemented
    nextday = function(self)
        self.day = self.day + 1

        if self.day > 30 then
            self.day = 1
            self.month = self.month + 1

            if self.month > 12 then
                self.month = 1
                self.year = self.year + 1
            end
        end
    end
}

-- compute the days in the format YYYYDDMM when burning occurs
burningTimes = function()
    local result = {}
    forEachFile("Shapefile/Queimada", function(file)
        result[tonumber(file:name():sub(9, 16))] = true
    end)

    return result
end

burningTimes_ = burningTimes()

-- compute the days in the format YYYY0101 when land change updates occur
landChangeTimes = function()
    local result = {}
    forEachFile("Shapefile/Cells", function(file)
        if string.endswith(file:name(), "shp") then
            result[tonumber(file:name():sub(6, 9).."0101")] = true
        end
    end)

    return result
end

landChangeTimes_ = landChangeTimes()
burning_ = {}

-- each cell has a funcion named burning that returns if it is burning
-- if cell:burning() then ... end
cell = Cell{
    burning = function(self)
        if not burning_[self.x] then return false end
        return burning_[self.x][self.y]
    end
}

cs = CellularSpace{
    file = "Shapefile/Cells/Teste2000.shp",
    instance = cell
}

updateBurning = function(time)
    burning_ = {}

    if not burningTimes_[time] then return end

    print("updateBurning "..time)
    local file = "Shapefile/Queimada/Queimada"..time..".shp.csv"

    local data = File(file):read()

    for i = 1, #data do
        local col = data.col[i]
        if not burning_[col] then
            burning_[col] = {}
        end

        local row = data.row[i]
        burning_[col][row] = true
    end
end

updateLandCover = function(time)
    if not landChangeTimes_[time] then
        return
    end

    print("updateLandCover "..time)

    local file = "Shapefile/Teste"..string.sub(time, 1, 4)..".shp"
    local cs2 = CellularSpace{file = file}

    forEachCellPair(cs, cs2, function(c1, c2)
        c1.state = c2.state
    end)
end

-- this is the simulation
-- do not use Timer as time representation is more complex
currentTime = now:get()

while currentTime < 20101231 do -- final time
    currentTime = now:get()
    updateLandCover(currentTime)
    updateBurning(currentTime)
    now:nextday()
end
