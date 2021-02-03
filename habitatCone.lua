-- compute a set of habitats from the cone using neighbor cells and a radius
habitatCone = function(cell, radius)
    local result = {}
    radius = radius - 1
    local x = cell.x
    local y = cell.y

    local zero_table = function() return {} end
    local whatToDo = function(habitat, mcell)
        table.insert(habitat, mcell)
    end

    --local cs = cell.parent
	local mcell
    local y_1 = cs:get(x, y - 1)
    local habitat

    if y_1 then
        habitat = zero_table()

        for dx = 0, radius do
            local my = y - dx - 1
            for mdx = -dx, dx do
                mcell = cs:get(x + mdx, my)

                if mcell then whatToDo(habitat, mcell) end
            end
        end

        table.insert(result, habitat)
    end

    ---------------------------------------
    y_1 = cs:get(x, y + 1)

    if y_1 then
        habitat = zero_table()
        for dx = 0, radius do
            local my = y + dx + 1
            for mdx = -dx, dx do
                mcell = cs:get(x + mdx, my)

                if mcell then whatToDo(habitat, mcell) end
            end
        end

        table.insert(result, habitat)
    end
    ---------------------------------------
    local x_1 = cs:get(x - 1, y)

    if x_1 then
        habitat = zero_table()
        for dy = 0, radius do
            local mx = x - dy - 1
            for mdy = -dy, dy do
                mcell = cs:get(mx, y + mdy)

                if mcell then whatToDo(habitat, mcell) end
            end
        end

        table.insert(result, habitat)
    end

    x_1 = cs:get(x + 1, y)

    if x_1 then
        habitat = zero_table()

        for dy = 0, radius do
            local mx = x + dy + 1
            for mdy = -dy, dy do
                mcell = cs:get(mx, y + mdy)

                if mcell then whatToDo(habitat, mcell) end
            end
        end

        table.insert(result, habitat)
    end
--==============================================================
-- DIAGONAL
    y_1 = cs:get(x - 1, y - 1)

    if y_1 then
        habitat = zero_table()

        if y_1 then whatToDo(habitat, y_1) end
        if radius == 1 then
            mcell = cs:get(x - 2, y - 2)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x - 2, y - 1)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x - 1, y - 2)
            if mcell then whatToDo(habitat, mcell) end
        end

        table.insert(result, habitat)
    end

    y_1 = cs:get(x + 1, y + 1)

    if y_1 then
        habitat = zero_table()

        if y_1 then whatToDo(habitat, y_1) end
        if radius == 1 then
            mcell = cs:get(x + 2, y + 2)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x + 2, y + 1)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x + 1, y + 2)
            if mcell then whatToDo(habitat, mcell) end
        end

        table.insert(result, habitat)
    end

    y_1 = cs:get(x + 1, y - 1)

    if y_1 then
        habitat = zero_table()

        if y_1 then whatToDo(habitat, y_1) end
        if radius == 1 then
            mcell = cs:get(x + 2, y - 2)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x + 2, y - 1)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x + 1, y - 2)
            if mcell then whatToDo(habitat, mcell) end
        end

        table.insert(result, habitat)
    end

    y_1 = cs:get(x - 1, y + 1)

    if y_1 then
        habitat = zero_table()

        if y_1 then whatToDo(habitat, y_1) end
        if radius == 1 then
            mcell = cs:get(x - 2, y + 2)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x - 2, y + 1)
            if mcell then whatToDo(habitat, mcell) end

            mcell = cs:get(x - 1, y + 2)
            if mcell then whatToDo(habitat, mcell) end
        end

        table.insert(result, habitat)
    end

    return result
end

--[[

cs = CellularSpace{xdim = 10}
cs:createNeighborhood{}

cell = cs:sample()
print(cell.x.."  "..cell.y)
print("=========================")
cone = habitatCone(cell, 2)

forEachElement(cone, function(idx, set)
    print(idx)
    forEachElement(set, function(_, mcell)
        print(mcell.x.."  "..mcell.y)
    end)
end)

--]]


