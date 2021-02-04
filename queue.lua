
queue = {
    clean = function(self)
      self.first = 0
      self.last = 0
      self.values = {}
    end,
    length = function(self)
        return self.last - self.first
    end,
    push = function (self, value)
      self.last = self.last + 1
      self.values[self.last] = value
    end,
    pop = function(self)
        self.first = self.first + 1
        return self.values[self.first]
    end
}

--[[
queue:clean()
queue:push(3)
queue:push(7)
print(queue:length())
print(queue:pop())
print(queue:length())
queue:push(5)
print(queue:pop())
print(queue:length())
print(queue:pop())
print(queue:length())
--]]


--[[
t = {}

table.insert(t, 2)
table.insert(t, 3)
table.insert(t, 1)
table.insert(t, 0)

print(t)

table.remove(t, 2)
print(t)

--]]