local lov3 = require("lov3")

local game = {}

function game.toClosestCell(position)
    local floor = math.floor
    return vec3(floor(position.x), floor(position.y), floor(position.z)) + vec3.one()/2
end

return game