local ffi = require("ffi")
local shaders = require("shaders")

function dump(table, depthlimit, depth)
    depth = depth or 0
    depthlimit = depthlimit or 0
    if depth > depthlimit then return end
    local indent = "" .. string.rep("\t", depth)
    for k, v in pairs(table) do
        if type(v) ~= "table" then
            print(indent .. k, v)
        else
            print(indent .. k)
            dump(v, depthlimit, depth + 1)
        end
    end
end

local lov3 = {}

ffi.cdef[[
    typedef struct { float x, y; } vec2;
    typedef struct { float x, y, z; } vec3;
    typedef struct { float x, y, z, w; } vec4;
]]

function lov3.isNum(v) return type(v) == "number" end
function lov3.lerp(a, b, t) return a + (b - a) * t end

------------------------------vec2------------------------------

function lov3.cross2(x1,y1,x2,y2) return y2*x1 - y1*x2 end
function lov3.dot2(x1,y1,x2,y2) return x1*x2 + y1*y2 end
function lov3.mag2(x,y) return math.sqrt(x*x + y*y) end
function lov3.scale2(s, x, y) return x*s, y*s end
function lov3.lerp2(x1, y1, x2, y2, t) return x1 + (x2 - x1) * t, y1 + (y2 - y1) * t end

vec2 = {}

function vec2.__call(t, x, y) return ffi.new("vec2", x or 0.0, y or 0.0) end
function vec2.__index(t, k) return rawget(vec2, k) end
function vec2.__eq(a, b) return a.x == b.x and a.y == b.y end
function vec2.__add(a, b) return vec2(a.x + b.x, a.y + b.y) end
function vec2.__sub(a, b) return vec2(a.x - b.x, a.y - b.y) end
function vec2.__mul(a, b) local isNum = lov3.isNum local an, bn = isNum(a) and a, isNum(b) and b
    return vec2((an or a.x) * (bn or b.x), (an or a.y) * (bn or b.y)) end
function vec2.__div(a, b) local isNum = lov3.isNum local an, bn = isNum(a) and a, isNum(b) and b
    return vec2((an or a.x) / (bn or b.x), (an or a.y) / (bn or b.y)) end
function vec2.__unm(v) return vec2(-v.x, -v.y) end
function vec2.__len(v) return lov3.mag2(v.x, v.y) end
function vec2.__lt(a,b) return #a < #b end
function vec2.__le(a,b) return #a <= #b end
function vec2.__tostring(v) return v.x .. " " .. v.y end
function vec2.one() return vec2(1.0, 1.0) end
function vec2.right() return vec2(1.0, 0.0) end
function vec2.left() return vec2(-1.0, 0.0) end
function vec2.up() return vec2(0.0, 1.0) end
function vec2.down() return vec2(0.0, -1.0) end
function vec2.cross(a, b) return vec2(lov3.cross2(a.x, a.y, b.x, b.y)) end
function vec2.dot(a, b) return lov3.dot2(a.x, a.y, b.x, b.y) end
function vec2:set(x, y) self.x, self.y = x, y end
function vec2:hash() return self.x*258494 + self.y*1934663 + (self.x + self.y)*65836589 end
function vec2:normalise() return vec2(self.x, self.y) / #self end
function vec2:table() return {self.x, self.y} end
function vec2:decay() return self.x, self.y end
setmetatable(vec2, vec2)
ffi.metatype("vec2", vec2)

------------------------------vec3------------------------------

function lov3.cross3(x1,y1,z1,x2,y2,z2) return y1*z2 - z1*y2, z1*x2 - x1*z2, y2*x1 - y1*x2 end
function lov3.dot3(x1,y1,z1,x2,y2,z2) return x1*x2 + y1*y2 + z1*z2 end
function lov3.mag3(x,y,z) return math.sqrt(x*x + y*y + z*z) end
function lov3.scale3(s, x, y, z) return x*s, y*s, z*s end
function lov3.lerp3(x1, y1, z1, x2, y2, z2, t) return x1 + (x2 - x1) * t, y1 + (y2 - y1) * t, z1 + (z2 - z1) * t end


vec3 = {}

function vec3.__call(t, x, y, z) return ffi.new("vec3", x or 0.0, y or 0.0, z or 0.0) end
function vec3.__index(t, k) return rawget(vec3, k) end
function vec3.__eq(a, b) return a.x == b.x and a.y == b.y and a.z == b.z end
function vec3.__add(a, b) return vec3(a.x + b.x, a.y + b.y, a.z + b.z) end
function vec3.__sub(a, b) return vec3(a.x - b.x, a.y - b.y, a.z - b.z) end
function vec3.__mul(a, b) local isNum = lov3.isNum local an, bn = isNum(a) and a, isNum(b) and b
    return vec3((an or a.x) * (bn or b.x), (an or a.y) * (bn or b.y), (an or a.z) * (bn or b.z)) end
function vec3.__div(a, b) local isNum = lov3.isNum local an, bn = isNum(a) and a, isNum(b) and b
    return vec3((an or a.x) / (bn or b.x), (an or a.y) / (bn or b.y), (an or a.z) / (bn or b.z)) end
function vec3.__unm(v) return vec3(-v.x, -v.y, -v.z) end
function vec3.__len(v) return lov3.mag3(v.x, v.y, v.z) end
function vec3.__lt(a,b) return #a < #b end
function vec3.__le(a,b) return #a <= #b end
function vec3.__tostring(v) return v.x .. " " .. v.y .. " " .. v.z end
function vec3.one() return vec3(1.0, 1.0, 1.0) end
function vec3.right() return vec3(1.0, 0.0, 0.0) end
function vec3.left() return vec3(-1.0, 0.0, 0.0) end
function vec3.up() return vec3(0.0, 1.0, 0.0) end
function vec3.down() return vec3(0.0, -1.0, 0.0) end
function vec3.forward() return vec3(0.0, 0.0, 1.0) end
function vec3.backward() return vec3(0.0, 0.0, -1.0) end
function vec3.cross(a, b) return vec3(lov3.cross3(a.x, a.y, a.z, b.x, b.y, b.z)) end
function vec3.dot(a, b) return lov3.dot3(a.x, a.y, a.z, b.x, b.y, b.z) end
function vec3.lerp(a, b, t) return vec3(lov3.lerp3(a.x, a.y, a.z, b.x, b.y, b.z, t)) end
function vec3:set(x, y, z) self.x, self.y, self.z = x, y, z end
function vec3:hash() return self.x*258494 + self.y*1934663 + self.z*834927919 + (self.x + self.y + self.z)*65836589 end
function vec3:normalise() return vec3(self.x, self.y, self.z) / #self end
function vec3:table() return {self.x, self.y, self.z} end
function vec3:decay() return self.x, self.y, self.z end
setmetatable(vec3, vec3)
ffi.metatype("vec3", vec3)

------------------------------vec4------------------------------

function lov3.dot4(x1,y1,z1,w1,x2,y2,z2,w2) return x1*x2 + y1*y2 + z1*z2 + w1*w2 end
function lov3.mag4(x,y,z,w) return math.sqrt(x*x + y*y + z*z + w*w) end
--function lov3.cross4(x1,y1,z1,w1,x2,y2,z2,w2) ...
function lov3.scale4(s, x, y, z, w) return x*s, y*s, z*s, w*s end

vec4 = {}

function vec4.__call(t, x, y, z, w) return ffi.new("vec4", x or 0.0, y or 0.0, z or 0.0, w or 0.0) end
function vec4.__index(t, k) return rawget(vec4, k) end
function vec4.__eq(a, b) return a.x == b.x and a.y == b.y and a.z == b.z  and a.w == b.w end
function vec4.__add(a, b) return vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w) end
function vec4.__sub(a, b) return vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w) end
function vec4.__mul(a, b) local isNum = lov3.isNum local an, bn = isNum(a) and a, isNum(b) and b
    return vec4((an or a.x) * (bn or b.x), (an or a.y) * (bn or b.y), (an or a.z) * (bn or b.z), (an or a.w) * (bn or b.w)) end
function vec4.__div(a, b) local isNum = lov3.isNum local an, bn = isNum(a) and a, isNum(b) and b
    return vec4((an or a.x) / (bn or b.x), (an or a.y) / (bn or b.y), (an or a.z) / (bn or b.z), (an or a.w) / (bn or b.w)) end
function vec4.__unm(v) return vec4(-v.x, -v.y, -v.z, -v.w) end
function vec4.__len(v) return lov3.mag4(v.x, v.y, v.z, v.w) end
function vec4.__lt(a,b) return #a < #b end
function vec4.__le(a,b) return #a <= #b end
function vec4.__tostring(v) return v.x .. " " .. v.y .. " " .. v.z .. " " .. v.w end
function vec4.one() return vec4(1.0, 1.0, 1.0, 1.0) end
function vec4.right() return vec4(1.0, 0.0, 0.0, 0.0) end
function vec4.left() return vec4(-1.0, 0.0, 0.0, 0.0) end
function vec4.up() return vec4(0.0, 1.0, 0.0, 0.0) end
function vec4.down() return vec4(0.0, -1.0, 0.0, 0.0) end
function vec4.forward() return vec4(0.0, 0.0, 1.0, 0.0) end
function vec4.backward() return vec4(0.0, 0.0, -1.0, 0.0) end
function vec4.ana() return vec4(0.0, 0.0, 0.0, 1.0) end
function vec4.kata() return vec4(0.0, 0.0, 0.0, -1.0) end
--function vec4.cross(a, b) return vec4(lov3.cross4(a.x, a.y, a.z, a.w, b.x, b.y, b.z, b.w)) end
function vec4.dot(a, b) return lov3.dot4(a.x, a.y, a.z, a.w, b.x, b.y, b.z, b.w) end
function vec4:set(x, y, z, w) self.x, self.y, self.z, self.w = x, y, z, w end
function vec4:hash() return self.x*258494 + self.y*1934663 + self.z*834927919 + self.w*193867475 + (self.x + self.y + self.z + self.w)*65836589 end
function vec4:normalise() return vec4(self.x, self.y, self.z, self.w) / #self end
function vec4:table() return {self.x, self.y, self.z, self.w} end
function vec4:decay() return self.x, self.y, self.z, self.w end
setmetatable(vec4, vec4)
ffi.metatype("vec4", vec4)

-------------------------------Helpers-----------------------------

function lov3.identityMat4()
    return
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
end
function lov3.translationMat4(vec3)
    return
        1, 0, 0, vec3.x,
        0, 1, 0, vec3.y,
        0, 0, 1, vec3.z,
        0, 0, 0,      1
end
function lov3.scaleMat4(vec3)
    return
        vec3.x, 0, 0, 0,
        0, vec3.y, 0, 0,
        0, 0, vec3.z, 0,
        0,   0,    0, 1
end
function lov3.rotationMat4(vec3)
local sin = math.sin
local cos = math.cos
local x, y, z = vec3.x, vec3.y, vec3.z
-- this is in z - y - x order...?
local sx, sy, sz, cx, cy, cz = sin(x), sin(y), sin(z), cos(x), cos(y), cos(z)
    return
        cz*cy, cz*sy*sx-sz*cx, cz*sy*cx+sz*sx, 0,
        sz*cy, sz*sy*sx+cz*cx, sz*sy*cx-cz*sx, 0,
          -sy,          cy*sx,          cy*cx, 0,
            0,              0,              0, 1
end
function lov3.createTranslationTransform(vec3) return love.math.newTransform():setMatrix(lov3.translationMat4(vec3)) end
function lov3.createScaleTransform(vec3) return love.math.newTransform():setMatrix(lov3.scaleMat4(vec3)) end
function lov3.createRotationTransform(vec3) return love.math.newTransform():setMatrix(lov3.rotationMat4(vec3)) end
function lov3.perspectiveMat4(fovY, aspectRatio, front, back)
    local DEG2RAD = math.acos(-1.0) / 180
    local tangent = math.tan(fovY/2 * DEG2RAD) -- tangent of half fovY
    local top = front * tangent                -- half height of near plane
    local right = top * aspectRatio            -- half width of near plane
    return
    front/right, 0, 0, 0,
    0, front/top, 0, 0,
    0, 0, -(back + front) / (back - front), -1,
    0, 0, -(2 * back * front) / (back - front), 0
end
function lov3.orthoMat4(left, right, bottom, top, near, far)
    local r_l = right - left
    local t_b = top - bottom
    local f_n = far - near
    local tx = -(right + left) / r_l
    local ty = -(top + bottom) / t_b
    local tz = -(far + near) / f_n
    return 
    2 / r_l, 0, 0, tx,
    0, 2 / t_b, 0, ty,
    0, 0, -2/ f_n, tz,
    0,    0,    0,  1
end
function lov3.getPositionVector(transform)
    local _, _, _, m03, _, _, _, m13, _, _, _, m23 = transform:getMatrix()
    return m03, m13, m23
end
function lov3.getRotationVector(transform)
    local atan2 = math.atan2
    local m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23 = transform:getMatrix()

    -- normalise basis vectors
    sx, sy, sz = lov3.getScaleVector(transform)

    m00, m01, m02 = m00/sx, m01/sy, m02/sz
    m10, m11, m12 = m10/sx, m11/sy, m12/sz
    m20, m21, m22 = m20/sx, m21/sy, m22/sz

    if (m20 == 1 or m20 == -1) then -- gimbal lock
        return 180, 90, atan2(m01, m11) -- this needs work
    else
        return atan2(m21, m22), atan2(-m20, math.sqrt(m21*m21 + m22*m22)), atan2(m10, m00)
    end
end
function lov3.getScaleVector(transform)
    local m00, m01, m02, _, m10, m11, m12, _, m20, m21, m22 = transform:getMatrix()
    return lov3.mag3(m00, m10, m20), lov3.mag3(m01, m11, m21), lov3.mag3(m02, m12, m22)
end

----------------------------------Colour----------------------------------

--- Although I'd prefer colour as a c-union ( .r, .g, .b, .a) to vec4, I've left it as a table to more comfortably interop with love2d.
--- This is subject to change.

colour = {}
function colour.new(r,g,b,a)
    return setmetatable({r or 1.0, g or 1.0, b or 1.0, a or 1.0}, Colour_meta)
end
function colour.white() return colour.new(1,1,1,1) end
function colour.black() return colour.new(0,0,0,1) end
function colour.red() return colour.new(1,0,0,1) end
function colour.green() return colour.new(0,1,0,1) end
function colour.blue() return colour.new(0,0,1,1) end
function colour.yellow() return colour.new(1,1,0,1) end
function colour.magenta() return colour.new(1,0,1,1) end
function colour.cyan() return colour.new(0,1,1,1) end
function colour.clear() return colour.new(0,0,0,0) end
function colour:setRGBA(r,g,b,a) self[1], self[2], self[3], self[4] = r or 1.0, g or 1.0, b or 1.0, a or 1.0 return self end
function colour:setHSVA(h,s,v,a)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    self[1], self[2], self[3], self[4] = r, g, b, a or 1.0
    return self
end
Colour_meta = {
    __index = colour,
    __eq = function(a, b)
        return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
    end,
    __tostring = function(v)
        return string.format("#%02X%02X%02X%02X", v[1] * 255, v[2] * 255, v[3] * 255, v[4] * 255)
    end
}

----------------------------Transform3--------------------------

transform3 = {}

---@alias transform3 transform3

---@return transform3
function transform3.new(contents)
    local self = setmetatable({
        -- This is intended to be Read-Only. Use transform3:setPosition() to set this value. Or transform3:getWorldPosition() for the world coordinates.
        position = contents and contents.position or vec3(),
        -- This is intended to be Read-Only. Use transform3:setRotation() to set this value. Or transform3:getWorldRotation() for the world euler angles.
        rotation = contents and contents.rotation or vec3(),
        -- This is intended to be Read-Only. Use transform3:setScale() to set this value. Or transform3:getWorldScale() for the world scale.
        scale = (contents and type(contents.scale) == "number" and vec3.one() * contents.scale) or (contents and contents.scale or vec3.one()),
        -- This is intended to be Read-Only.
        transform = love.math.newTransform(),
        -- This is intended to be Read-Only. Use transform3:setParent() to set this value.
        parent = nil,
        -- This is intended to be Read-Only.
        children = {},
    }, Transform3_meta)
    return self:recalculateTransform()
end
-- Returns the local T*R*S transform
function transform3:getLocalTransform()
    return lov3.createTranslationTransform(self.position):apply(lov3.createRotationTransform(self.rotation)):apply(lov3.createScaleTransform(self.scale))
end
-- Multiplies the reference transform (usually the parent) with the local transform
---@return transform3
function transform3:recalculateTransform(reference)
    local referenceTransform = reference or (self.parent and self.parent.transform:clone() or love.math.newTransform())
    self.transform = referenceTransform * self:getLocalTransform()
    for i=1, #self.children do
        self.children[i]:recalculateTransform()
    end
    return self
end
function transform3:getWorldPosition() return lov3.getPositionVector(self.transform) end
function transform3:getWorldRotation() return lov3.getRotationVector(self.transform) end
function transform3:getWorldScale() return lov3.getScaleVector(self.transform) end
function transform3:setPosition(...)
    local args = {...}
    if #args == 1 and type(args[1]) == "cdata" then -- vec3
        self.position = args[1]
    elseif #args == 3 then
        self.position.x, self.position.y, self.position.z = args[1], args[2], args[3]
    else
        error("Invalid arguments.")
    end

    return self:recalculateTransform()
end
function transform3:setRotation(...)
    local args = {...}
    if #args == 1 and type(args[1]) == "cdata" then -- vec3
        self.rotation = args[1]
    elseif #args == 3 then
        self.rotation.x, self.rotation.y, self.rotation.z = args[1], args[2], args[3]
    else
        error("Invalid arguments.")
    end
    return self:recalculateTransform()
end
function transform3:setScale(...)
    local args = {...}
    if #args == 1 and type(args[1]) == "cdata" then -- vec3
        self.scale = args[1]
    elseif #args == 3 then
        self.scale.x, self.scale.y, self.scale.z = args[1], args[2], args[3]
    else
        error("Invalid arguments.")
    end
    return self:recalculateTransform()
end
function transform3:translate(...)
    local args = {...}
    if #args == 1 and type(args[1]) == "cdata" then -- vec3
        return self:setPosition(self.position + args[1])
    elseif #args == 3 then
        return self:setPosition(self.position.x + args[1], self.position.y + args[2], self.position.z + args[3])
    end
    error("Invalid arguments.")
end
function transform3:rotate (...)
    local args = {...}
    if #args == 1 and type(args[1]) == "cdata" then -- vec3
        return self:setRotation(self.rotation + args[1])
    elseif #args == 3 then
        return self:setRotation(self.rotation.x + args[1], self.rotation.y + args[2], self.rotation.z + args[3])
    end
    error("Invalid arguments.")
end
---@param newParentOrNil transform3 | nil
---@return transform3
function transform3:setParent(newParentOrNil, keepGlobalPosition)

    keepGlobalPosition = keepGlobalPosition == nil and true or keepGlobalPosition

    if newParentOrNil then
        if keepGlobalPosition then
            local newLocal = newParentOrNil.transform:inverse() * self.transform
            self.position, self.rotation, self.scale = vec3(lov3.getPositionVector(newLocal)), vec3(lov3.getRotationVector(newLocal)), vec3(lov3.getScaleVector(newLocal))
        end
        if self.parent then
            for t=1, #self.parent.children do
                if self.parent.children[t] == self then
                    table.remove(self.parent.children, t)
                end
            end
        end
        self.parent = newParentOrNil
        newParentOrNil.children[#newParentOrNil.children+1] = self
        return self:recalculateTransform()
    else
        if keepGlobalPosition then
            self.position, self.rotation, self.scale = vec3(self:getWorldPosition()), vec3(self:getWorldRotation()), vec3(self:getWorldScale())
        end
        if self.parent then
            for t=1, #self.parent.children do
                if self.parent.children[t] == self then
                    table.remove(self.parent.children, t)
                end
            end
        end
        self.parent = lov3.rootEntity and lov3.rootEntity.transform3 or nil
        if self.parent then self.parent.children[#self.parent.children+1] = self end
        return self:recalculateTransform()
    end
end
-- Returns the removed child transform3
function transform3:removeChild(transform3OrIndex)
    if lov3.isNum(transform3OrIndex) then
        return table.remove(self.children, transform3OrIndex):setParent(nil)
    else
        for t=1, #self.children do
            if self.children[t] == transform3OrIndex then
                return table.remove(self.children, t):setParent(nil)
            end
        end
    end
end
-- Returns the list of removed child transform3s
function transform3:removeChildren()
    local removedChildren = {}
    for i=1, #self.children do
        removedChildren[#removedChildren+1] = table.remove(self.children, i):setParent(nil)
    end
    return removedChildren
end
function transform3:getBasisX()
    local matrix = {self.transform:getMatrix()}
    return vec3(matrix[1], matrix[5], matrix[9])
end
function transform3:getBasisY()
    local matrix = {self.transform:getMatrix()}
    return vec3(matrix[2], matrix[6], matrix[10])
end
function transform3:getBasisZ()
    local matrix = {self.transform:getMatrix()}
    return vec3(matrix[3], matrix[7], matrix[11])
end
-- Transforms a given point from local to global coordinates and returns the results in the form x, y, z
function transform3:transformPoint(vec3)
    return lov3.getPositionVector(self.transform:clone():apply(lov3.createTranslationTransform(vec3)))
end
-- Transforms a given point from global to local coordinates and returns the results in the form x, y, z
function transform3:inverseTransformPoint(vec3)
    return lov3.getPositionVector(self.transform:inverse():apply(lov3.createTranslationTransform(vec3)))
end
function transform3:reset()
    self = transform3.new()
end
Transform3_meta = {
    __index = transform3,
    -- __tostring = function(v)
    --     local a1,a2,a3,a4,b1,b2,b3,b4,c1,c2,c3,c4,d1,d2,d3,d4 = v.transform:getMatrix()
    --     local sub = string.sub
    --     local out =  sub(a1, 1, 6) .. "\t" .. sub(a2, 1, 6) .. "\t" .. sub(a3, 1, 6) .. "\t" .. sub(a4, 1, 6) .. "\n"
    --     out = out .. sub(b1, 1, 6) .. "\t" .. sub(b2, 1, 6) .. "\t" .. sub(b3, 1, 6) .. "\t" .. sub(b4, 1, 6) .. "\n"
    --     out = out .. sub(c1, 1, 6) .. "\t" .. sub(c2, 1, 6) .. "\t" .. sub(c3, 1, 6) .. "\t" .. sub(c4, 1, 6) .. "\n"
    --     out = out .. sub(d1, 1, 6) .. "\t" .. sub(d2, 1, 6) .. "\t" .. sub(d3, 1, 6) .. "\t" .. sub(d4, 1, 6) .. "\n"
    --     return out
    -- end
}

---------------------------------- Light3 ------------------------------------

light3 = {}

---@alias light3 light3

---@return light3
function light3.new(contents)
    return {
        useShadows = contents and contents.useShadows or true,
        lightType = contents and contents.lightType or "point",
        attenuation = contents and contents.attenuation or 20,
        intensity = contents and contents.intensity or 1,
        colour = contents and contents.colour or colour.white()
    }
end

---------------------------------- Renderer3 ------------------------------------

renderer3 = {}

---@alias renderer3 renderer3

---@return renderer3
function renderer3.new(contents)
    return {
        unlit = contents and contents.unlit or false,
        emissive = contents and contents.emissive or false,
        hasShadows = contents and contents.hasShadows or false,
        transparent = contents and contents.transparent or false,
        colour = contents and contents.colour or colour.white()
    }
end

---------------------------------- Camera3 --------------------------------------

camera3 = {}

---@alias camera3 camera3

---@return camera3
function camera3.new(contents)
    return {
        projection = love.math.newTransform():setMatrix(lov3.perspectiveMat4(30, 1, 1, 100)),
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight(),
        canvas = love.graphics.newCanvas(),
        depthStencilCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), {format = "depth24stencil8"}),
        emissiveCanvas = love.graphics.newCanvas(),
    }
end

---------------------------------- Modeling ----------------------------------

lov3.primitives = {
    quad = {
        verts = { vec3(-0.500000, 0.000000, -0.500000), vec3(-0.500000, 0.000000, 0.500000), vec3(0.500000, 0.000000, -0.500000), vec3(0.500000, 0.000000, 0.500000), },
        uvs = { {0,0}, {0,1}, {1,0}, {1,1}, },
        normals = { vec3.up() },
        tris = { {{1, 1, 1}, {2, 2, 1}, {3, 3, 1}}, {{4, 4, 1}, {3, 3, 1}, {2, 2, 1}}}
    },
    plane = {
        verts = { vec3(-0.500000, 0.000000, -0.500000), vec3(-0.500000, 0.000000, 0.500000), vec3(0.500000, 0.000000, -0.500000), vec3(0.500000, 0.000000, 0.500000), },
        uvs = { {0,0}, {0,1}, {1,0}, {1,1}, },
        normals = { vec3.up(), vec3.down(), },
        tris = { {{1, 1, 1}, {2, 2, 1}, {3, 3, 1}}, {{4, 4, 1}, {3, 3, 1}, {2, 2, 1}}, {{1, 1, 2}, {3, 3, 2}, {2, 2, 2}}, {{4, 4, 2}, {2, 2, 2}, {3, 3, 2}}, },
    },
    tetrahedron = {
        verts = { vec3( 0.0000,  0.6666,  0.0000), vec3( 0.0000, -0.3333, -0.6666), vec3( 0.5774, -0.3333,  0.3333), vec3(-0.5774, -0.3333,  0.3333), },
        uvs = { {0.5,0}, {0,1}, {1,1} },
        normals = { vec3(-0.8215,  0.3163, -0.4744), vec3( 0.0000,  0.3163,  0.9487), vec3( 0.8215,  0.3163, -0.4744), vec3( 0.0000, -1.0000,  0.0000), },
        tris = { {{1, 1, 1}, {2, 2, 1}, {4, 3, 1}}, {{1, 1, 2}, {4, 2, 2}, {3, 3, 2}}, {{1, 1, 3}, {3, 2, 3}, {2, 3, 3}}, {{3, 1, 4}, {4, 2, 4}, {2, 3, 4}}, },
    },
    cube = {
        verts = {
            vec3(-0.5, -0.5,  0.5), vec3(-0.5,  0.5,  0.5), vec3( 0.5,  0.5,  0.5), vec3( 0.5, -0.5,  0.5),
            vec3(-0.5, -0.5, -0.5), vec3(-0.5,  0.5, -0.5), vec3( 0.5,  0.5, -0.5), vec3( 0.5, -0.5, -0.5),
        },
        uvs = { {0,1}, {1,0}, {0,0}, {1,1} },
        normals = { vec3.forward(), vec3.down(), vec3.left(), vec3.right(), vec3.up(), vec3.backward(), },
        tris = {
            {{1, 1, 1}, {3, 2, 1}, {2, 3, 1}}, {{1, 1, 1}, {4, 4, 1}, {3, 2, 1}}, {{5, 1, 2}, {4, 2, 2}, {1, 3, 2}}, {{5, 1, 2}, {8, 4, 2}, {4, 2, 2}},
            {{5, 1, 3}, {2, 2, 3}, {6, 3, 3}}, {{5, 1, 3}, {1, 4, 3}, {2, 2, 3}}, {{4, 1, 4}, {7, 2, 4}, {3, 3, 4}}, {{4, 1, 4}, {8, 4, 4}, {7, 2, 4}},
            {{2, 1, 5}, {7, 2, 5}, {6, 3, 5}}, {{2, 1, 5}, {3, 4, 5}, {7, 2, 5}}, {{8, 1, 6}, {6, 2, 6}, {7, 3, 6}}, {{8, 1, 6}, {5, 4, 6}, {6, 2, 6}},
        },
    },
    icosahedron  = {
        verts = {
            vec3(0.000000, -0.5257310, 0.8506510), vec3(0.8506510, 0.000000, 0.5257310), vec3(0.8506510, 0.000000, -0.5257310), vec3(-0.8506510, 0.000000, -0.5257310),
            vec3(-0.8506510, 0.000000, 0.5257310), vec3(-0.5257310, 0.8506510, 0.000000), vec3(0.5257310, 0.8506510, 0.000000), vec3(0.5257310, -0.8506510, 0.000000),
            vec3(-0.5257310, -0.8506510, 0.000000), vec3(0.000000, -0.5257310, -0.8506510), vec3(0.000000, 0.5257310, -0.8506510), vec3(0.000000, 0.5257310, 0.8506510),
        },
        uvs = { {0,1}, {1,0}, {0,0}, {1,1} },
        normals = {
            vec3(0.934172, 0.356822, 0.000000), vec3(0.934172, -0.356822, 0.000000), vec3(-0.934172, 0.356822, 0.000000), vec3(-0.934172, -0.356822, 0.000000),
            vec3(0.000000, 0.934172, 0.356822), vec3(0.000000, 0.934172, -0.356822), vec3(0.356822, 0.000000, -0.934172), vec3(-0.356822, 0.000000, -0.934172),
            vec3(0.000000, -0.934172, -0.356822), vec3(0.000000, -0.934172, 0.356822), vec3(0.356822, 0.000000, 0.934172), vec3(-0.356822, 0.000000, 0.934172),
            vec3(0.577350, 0.577350, -0.577350), vec3(0.577350, 0.577350, 0.577350), vec3(-0.577350, 0.577350, -0.577350), vec3(-0.577350, 0.577350, 0.577350),
            vec3(0.577350, -0.577350, -0.577350), vec3(0.577350, -0.577350, 0.577350), vec3(-0.577350, -0.577350, -0.577350), vec3(-0.577350, -0.577350, 0.577350),
        },
        tris = {
            {{ 2, 1,  1}, { 3, 2,  1}, { 7, 3,  1}}, {{ 2, 1,  2}, { 8, 2,  2}, { 3, 3,  2}}, {{ 4, 1,  3}, { 5, 2,  3}, { 6, 3,  3}}, 
            {{ 5, 1,  4}, { 4, 2,  4}, { 9, 3,  4}}, {{ 7, 1,  5}, { 6, 2,  5}, {12, 3,  5}}, {{ 6, 1,  6}, { 7, 2,  6}, {11, 3,  6}}, 
            {{10, 1,  7}, {11, 2,  7}, { 3, 3,  7}}, {{11, 1,  8}, {10, 2,  8}, { 4, 3,  8}}, {{ 8, 1,  9}, { 9, 2,  9}, {10, 3,  9}}, 
            {{ 9, 1, 10}, { 8, 2, 10}, { 1, 3, 10}}, {{12, 1, 11}, { 1, 2, 11}, { 2, 3, 11}}, {{ 1, 1, 12}, {12, 2, 12}, { 5, 3, 12}},
            {{ 7, 1, 13}, { 3, 2, 13}, {11, 3, 13}}, {{ 2, 1, 14}, { 7, 2, 14}, {12, 3, 14}}, {{ 4, 1, 15}, { 6, 2, 15}, {11, 3, 15}}, 
            {{ 6, 1, 16}, { 5, 2, 16}, {12, 3, 16}}, {{ 3, 1, 17}, { 8, 2, 17}, {10, 3, 17}}, {{ 8, 1, 18}, { 2, 2, 18}, { 1, 3, 18}},
            {{ 4, 1, 19}, {10, 2, 19}, { 9, 3, 19}}, {{ 5, 1, 20}, { 9, 2, 20}, { 1, 3, 20}},
        },
    },
    -- This is a rather low-poly sphere.
    sphere = {
        verts = {
            vec3( 0.0000,  0.5000,  0.0000), vec3( 0.2500,  0.4330,  0.0000), vec3( 0.4330,  0.2500,  0.0000), vec3( 0.5000,  0.0000,  0.0000),
            vec3( 0.4330, -0.2500,  0.0000), vec3( 0.2500, -0.4330,  0.0000), vec3( 0.0000, -0.5000,  0.0000), vec3( 0.1250,  0.4330,  0.2165),
            vec3( 0.2165,  0.2500,  0.3750), vec3( 0.2500,  0.0000,  0.4330), vec3( 0.2165, -0.2500,  0.3750), vec3( 0.1250, -0.4330,  0.2165),
            vec3(-0.1250,  0.4330,  0.2165), vec3(-0.2165,  0.2500,  0.3750), vec3(-0.2500,  0.0000,  0.4330), vec3(-0.2165, -0.2500,  0.3750),
            vec3(-0.1250, -0.4330,  0.2165), vec3(-0.2500,  0.4330,  0.0000), vec3(-0.4330,  0.2500,  0.0000), vec3(-0.5000,  0.0000,  0.0000),
            vec3(-0.4330, -0.2500,  0.0000), vec3(-0.2500, -0.4330,  0.0000), vec3(-0.1250,  0.4330, -0.2165), vec3(-0.2165,  0.2500, -0.3750),
            vec3(-0.2500,  0.0000, -0.4330), vec3(-0.2165, -0.2500, -0.3750), vec3(-0.1250, -0.4330, -0.2165), vec3( 0.1250,  0.4330, -0.2165),
            vec3( 0.2165,  0.2500, -0.3750), vec3( 0.2500,  0.0000, -0.4330), vec3( 0.2165, -0.2500, -0.3750), vec3( 0.1250, -0.4330, -0.2165),
        },
        uvs = {
            {0.000000, 0.000000}, {0.166667, 0.166667}, {0.000000, 0.166667}, {0.166667, 0.333333}, {0.000000, 0.333333}, {0.166667, 0.500000},
            {0.000000, 0.500000}, {0.166667, 0.666667}, {0.000000, 0.666667}, {0.166667, 0.833333}, {0.000000, 0.833333}, {0.166667, 1.000000},
            {0.166667, 0.000000}, {0.333333, 0.166667}, {0.333333, 0.333333}, {0.333333, 0.500000}, {0.333333, 0.666667}, {0.333333, 0.833333}, 
            {0.333333, 1.000000}, {0.333333, 0.000000}, {0.500000, 0.166667}, {0.500000, 0.333333}, {0.500000, 0.500000}, {0.500000, 0.666667},
            {0.500000, 0.833333}, {0.500000, 1.000000}, {0.500000, 0.000000}, {0.666667, 0.166667}, {0.666667, 0.333333}, {0.666667, 0.500000}, 
            {0.666667, 0.666667}, {0.666667, 0.833333}, {0.666667, 1.000000}, {0.666667, 0.000000}, {0.833333, 0.166667}, {0.833333, 0.333333},
            {0.833333, 0.500000}, {0.833333, 0.666667}, {0.833333, 0.833333}, {0.833333, 1.000000}, {0.833333, 0.000000}, {1.000000, 0.166667}, 
            {1.000000, 0.333333}, {1.000000, 0.500000}, {1.000000, 0.666667}, {1.000000, 0.833333}, {1.000000, 1.000000},
        },
        normals = { -- Intended to be Phong-shaded.
            vec3( 0.0000,  1.0000,  0.0000), vec3( 0.5000,  0.8660,  0.0000), vec3( 0.8660,  0.5000,  0.0000), vec3( 1.0000,  0.0000,  0.0000),
            vec3( 0.8660, -0.5000,  0.0000), vec3( 0.5000, -0.8660,  0.0000), vec3( 0.0000, -1.0000,  0.0000), vec3( 0.2500,  0.8660,  0.4330),
            vec3( 0.4330,  0.5000,  0.7500), vec3( 0.5000,  0.0000,  0.8660), vec3( 0.4330, -0.5000,  0.7500), vec3( 0.2500, -0.8660,  0.4330),
            vec3(-0.2500,  0.8660,  0.4330), vec3(-0.4330,  0.5000,  0.7500), vec3(-0.5000,  0.0000,  0.8660), vec3(-0.4330, -0.5000,  0.7500),
            vec3(-0.2500, -0.8660,  0.4330), vec3(-0.5000,  0.8660,  0.0000), vec3(-0.8660,  0.5000,  0.0000), vec3(-1.0000,  0.0000,  0.0000),
            vec3(-0.8660, -0.5000,  0.0000), vec3(-0.5000, -0.8660,  0.0000), vec3(-0.2500,  0.8660, -0.4330), vec3(-0.4330,  0.5000, -0.7500),
            vec3(-0.5000,  0.0000, -0.8660), vec3(-0.4330, -0.5000, -0.7500), vec3(-0.2500, -0.8660, -0.4330), vec3( 0.2500,  0.8660, -0.4330),
            vec3( 0.4330,  0.5000, -0.7500), vec3( 0.5000,  0.0000, -0.8660), vec3( 0.4330, -0.5000, -0.7500), vec3( 0.2500, -0.8660, -0.4330),        
        },
        tris = {
            {{ 1,  1,  1}, { 8,  2,  8}, { 2,  3,  2}}, {{ 2,  3,  2}, { 8,  2,  8}, { 9,  4,  9}}, {{ 2,  3,  2}, { 9,  4,  9}, { 3,  5,  3}},
            {{ 3,  5,  3}, { 9,  4,  9}, {10,  6, 10}}, {{ 3,  5,  3}, {10,  6, 10}, { 4,  7,  4}}, {{ 4,  7,  4}, {10,  6, 10}, {11,  8, 11}}, 
            {{ 4,  7,  4}, {11,  8, 11}, { 5,  9,  5}}, {{ 5,  9,  5}, {11,  8, 11}, {12, 10, 12}}, {{ 5,  9,  5}, {12, 10, 12}, { 6, 11,  6}},
            {{ 6, 11,  6}, {12, 10, 12}, { 7, 12,  7}}, {{ 1, 13,  1}, {13, 14, 13}, { 8,  2,  8}}, {{ 8,  2,  8}, {13, 14, 13}, {14, 15, 14}},
            {{ 8,  2,  8}, {14, 15, 14}, { 9,  4,  9}}, {{ 9,  4,  9}, {14, 15, 14}, {15, 16, 15}}, {{ 9,  4,  9}, {15, 16, 15}, {10,  6, 10}}, 
            {{10,  6, 10}, {15, 16, 15}, {16, 17, 16}}, {{10,  6, 10}, {16, 17, 16}, {11,  8, 11}}, {{11,  8, 11}, {16, 17, 16}, {17, 18, 17}}, 
            {{11,  8, 11}, {17, 18, 17}, {12, 10, 12}}, {{12, 10, 12}, {17, 18, 17}, { 7, 19,  7}}, {{ 1, 20,  1}, {18, 21, 18}, {13, 14, 13}},                                             
            {{13, 14, 13}, {18, 21, 18}, {19, 22, 19}}, {{13, 14, 13}, {19, 22, 19}, {14, 15, 14}}, {{14, 15, 14}, {19, 22, 19}, {20, 23, 20}},
            {{14, 15, 14}, {20, 23, 20}, {15, 16, 15}}, {{15, 16, 15}, {20, 23, 20}, {21, 24, 21}}, {{15, 16, 15}, {21, 24, 21}, {16, 17, 16}},
            {{16, 17, 16}, {21, 24, 21}, {22, 25, 22}}, {{16, 17, 16}, {22, 25, 22}, {17, 18, 17}}, {{17, 18, 17}, {22, 25, 22}, { 7, 26,  7}},                                             
            {{ 1, 27,  1}, {23, 28, 23}, {18, 21, 18}}, {{18, 21, 18}, {23, 28, 23}, {24, 29, 24}}, {{18, 21, 18}, {24, 29, 24}, {19, 22, 19}},
            {{19, 22, 19}, {24, 29, 24}, {25, 30, 25}}, {{19, 22, 19}, {25, 30, 25}, {20, 23, 20}}, {{20, 23, 20}, {25, 30, 25}, {26, 31, 26}}, 
            {{20, 23, 20}, {26, 31, 26}, {21, 24, 21}}, {{21, 24, 21}, {26, 31, 26}, {27, 32, 27}}, {{21, 24, 21}, {27, 32, 27}, {22, 25, 22}}, 
            {{22, 25, 22}, {27, 32, 27}, { 7, 33,  7}}, {{ 1, 34,  1}, {28, 35, 28}, {23, 28, 23}}, {{23, 28, 23}, {28, 35, 28}, {29, 36, 29}}, 
            {{23, 28, 23}, {29, 36, 29}, {24, 29, 24}}, {{24, 29, 24}, {29, 36, 29}, {30, 37, 30}}, {{24, 29, 24}, {30, 37, 30}, {25, 30, 25}},
            {{25, 30, 25}, {30, 37, 30}, {31, 38, 31}}, {{25, 30, 25}, {31, 38, 31}, {26, 31, 26}}, {{26, 31, 26}, {31, 38, 31}, {32, 39, 32}}, 
            {{26, 31, 26}, {32, 39, 32}, {27, 32, 27}}, {{27, 32, 27}, {32, 39, 32}, { 7, 40,  7}}, {{ 1, 41,  1}, { 2, 42,  2}, {28, 35, 28}},                                            
            {{28, 35, 28}, { 2, 42,  2}, { 3, 43,  3}}, {{28, 35, 28}, { 3, 43,  3}, {29, 36, 29}}, {{29, 36, 29}, { 3, 43,  3}, { 4, 44,  4}}, 
            {{29, 36, 29}, { 4, 44,  4}, {30, 37, 30}}, {{30, 37, 30}, { 4, 44,  4}, { 5, 45,  5}}, {{30, 37, 30}, { 5, 45,  5}, {31, 38, 31}},
            {{31, 38, 31}, { 5, 45,  5}, { 6, 46,  6}}, {{31, 38, 31}, { 6, 46,  6}, {32, 39, 32}}, {{32, 39, 32}, { 6, 46,  6}, { 7, 47,  7}},                                            
        }
    }
}

---@return verts, tris, uvs, norms
function lov3.parseOBJ(objString)
    local input = objString
    local verts, tris, uvs, norms = {}, {}, {}, {}

    -- Make sure to sub out any .obj comments (start with "#") lines
    input = string.gsub(input, "#(.-)\n", "")

    -- vertices
    for vx, vy, vz in string.gmatch(input, "v%s+(%-?%d+%.?%d*)%s+(%-?%d+%.?%d*)%s+(%-?%d+%.?%d*)") do
        if vx then
            verts[#verts + 1] = vec3(tonumber(vx), tonumber(vy), tonumber(vz))
        end
        --print("v ", vx, vy-4, vz)
    end
    -- uv mappings
    for u, v in string.gmatch(input, "vt%s+(%-?%d+%.?%d*)%s+(%-?%d+%.?%d*)") do
        if u then
            uvs[#uvs + 1] = {tonumber(u), tonumber(v)}
        end
    end
    -- normals
    for nx, ny, nz in string.gmatch(input, "vn%s+(%-?%d+%.?%d*)%s+(%-?%d+%.?%d*)%s+(%-?%d+%.?%d*)") do
        if nx then
            norms[#norms + 1] = vec3(tonumber(nx), tonumber(ny), tonumber(nz))
        end
    end
    -- tris (faces)
    for face in string.gmatch(input, "f%s+(.-)\n") do
        local tri = {}
        tris[#tris + 1] = tri
        for v, vt, vn in string.gmatch(face, "(%d+)/?(%d*)/?(%d*)") do
            if(#tri == 3) then -- If we found more than 3 points, its a "quad" obj f line, so we need another tri
                tris[#tris + 1] = {tris[#tris][1], tris[#tris][3], {tonumber(v), tonumber(vt), tonumber(vn)} }
            else
                tri[#tri + 1] = {tonumber(v), tonumber(vt), tonumber(vn)}
            end
        end
    end
    return verts, tris, uvs, norms
end

---------------------------------- Entities ----------------------------------

--[[
    This "entity" system is relying on lua's tables, which are, at least for the "hashed-part" of lua tables (which we're using as 
    the entities), linked lists. These are not contigous in memory. When we're iterating through the entities-with-component tables
    (which should use the "array-part" and ARE contiguous in memory), it wont be very cache-friendly when accessing properties of 
    the "components" themselves (e.g. the transform3).
    
    We're operating on the assumption of not having thousands of entities per scene. If we want that many entities, this approach 
    will probably fall over. And to not fall over, we'll probably have to either create a single contiguous array of flat c-structs 
    with type flags (by "flat" I mean we flatten the components we have defined into a single "mega" struct), or go full "ecs"-driven
    and designate c-structs for each component to "compose" our entities, but still ofcourse create contiguous arrays where we iterate
    through them seperately.
    
    This is probably my least favourite part of this entire implementation, and we may consider an entire refactoring of this system, 
    or even removing it entirely, and relying on the implementer to do what they see fit. This would mean our renderer must then accept
    separate array/lists of camera positions, light positions, meshes, etc.
]]

lov3.entities = {}
lov3.renderableEntities = {}
lov3.lightEntities = {}
lov3.cameraEntities = {}
lov3.rootEntity = nil

-- This is a 16 byte string, which is trusting lua's reference manual claim "Lua is 8-bit clean: strings can contain any 8-bit value, including embedded zeros ('\0')"
function lov3.newUUID()
    return (string.gsub("xxxxxxxxxxxxxxxx", '[x]', function (c) return string.char(love.math.random(0, 255)) end))
end

function lov3.createEntity(contents)
    if contents.id then
        error("This entity already has an ID defined.")
    end

    local newEntity = contents

    newEntity.id = lov3.newUUID()
    lov3.entities[newEntity.id] = newEntity

    for _, component in pairs(contents) do
        if type(component) == "table" then
            component.entity = newEntity
        end
    end

    if newEntity.mesh3 and newEntity.renderer3 then
        lov3.renderableEntities[#lov3.renderableEntities+1] = newEntity
        lov3.addShadowMesh(newEntity)
    end
    if newEntity.light3 then
        lov3.lightEntities[#lov3.lightEntities+1] = newEntity
    end
    if newEntity.camera3 then
        lov3.cameraEntities[#lov3.cameraEntities+1] = newEntity
    end
    return newEntity
end

function lov3.setRootEntity(entity)
    lov3.rootEntity = entity
end

function lov3.findEntity(name)
    for _, v in pairs(lov3.entities) do
        if v.name == name then
            return v
        end
    end
    return nil
end

function lov3.clearEntities()
    lov3.entities = {}
    lov3.renderableEntities, lov3.lightEntities, lov3.cameraEntities = {}, {}, {}
end

function lov3.deleteEntity(id)
    lov3.entities[id] = nil
end

-------------------------------- Shadow Volumes -------------------------------

--[[
    The idea is that for our shadowing technique, we want to do shadow volumes. This is opposed to the standard shadowing method of 
    shadow-mapping.

    The basic premise is that for each light we want producing shadows, and each object in our scene we want shadowed, we'll be 
    producing a "volume" that describes the 3D region where the light will not reach. It exact terms, we'll be generating geometry
    that describes the "umbra" of the occluding body with respect to the particular light source.
    
    To achieve this we'll need a regular buffer, a depth buffer, and a stencil buffer.
    
    We'll initially render the objects of our scene to the regular buffer as if no lights existed, (i.e. everything is "shadowed"), then 
    we'll render the shadow volumes produced from the objects lit by our first light to the depth and stencil buffers, and broadly speaking, 
    use the interaction of these two buffers to 'slice' out a version of our regular buffer that is 'allowed' to be lit, then render our objects
    in that "sliced" regular buffer, lit accordingly. Then we'll move onto the next light, additively blending the results, light by light, 
    until all the lights in our scene have made their contribution.

    Now how do we generate a shadow volume? Well, it'll basically look like the object itself, extruded in the direction away from 
    the light. This extrusion will occur at the edges of the object that form it's silhouette. Our objects are made of triangles, 
    so our silhouette will be the set of edges that are shared by both a "lit" triangle, and an "unlit" triangle. And we can figure that 
    out by checking the normal of each triangle against the light's direction.

    We've hopefully included some basic primitives in this project. I'll use the cube as an example. A cube has 6 faces, 8 corners. 
    Now those faces are squares, which our GPU doesn't know how to draw. It only knows triangles, so we have to draw 2 for each square.
    So that's 12 triangles. And with each triangle having 3 points, our mesh will have 36 vertices.

    For silhouette determination, we care about the edges of our mesh, so those 12 triangles also have 3 edges each, so that's also 36 edges. 
    But, if we're studious, we'll recognise that any particular edge belongs to both of the 2 triangles it joins, so, when we boil it down, 
    we only have 18 "unique" edges, where, for any particular edge made of points (a, b), there is an identical edge made of points (b, a). 
    Their commutative. We'll be taking advantage of this when we determine our silhouette.

    Now, as an aside, you might whisper, "Hey! Big guy! Cubes only have 12 edges!" This is true... if you know what a square is! Remember, the
    GPU is a triangle-based lifeform. And so with each square face being made of 2 triangles, there's an additional 6 invisible "edges" which 
    diagonally join those 2 triangles on each face. These "edges" that aren't quite edges might actually cause us some headaches later. We'll
    probably have to figure out a way to exclude them...

    Anyway, we basically have 2 options here:
        1. We pack all that information into love2d's mesh vertex buffer, which will probably contain the original objects vertices, 
            and a bunch more to account for whatever possible "extrusion" we could be generating. Then over in shader-land, use the 
            information to actually move the vertices where we want them. This'll mean a pretty big mesh, as we'll need to account for any
            possible extrusion, and each vertex needs to know a fair amount of context about the edge determination as a whole. This might be
            possible, but thats alot of information. Although, the GPU wouldn't blink an eye at performing these calculations. We could even 
            investigate writing a geomtery shader for this purpose. But that's a whole other kettle of fish.
        2. Keep the mesh smaller, or even seperate the regular mesh and the 'shadow-mesh', and do it back here in CPU-land, and use 
            the FFI library to talk to Lua's big brother C, and manipulate some memory-contiguous vertex buffers so the CPU doesn't blink 
            too much of an eye either.

    I've gone with option 2.

    Firstly, we're going to wrap a 3D-ified love:mesh (we've added a z-coord and a normal) into our own mesh container (which we might 
    call "mesh3", or something), where we'll keep an array of the vertex x,y,z positions (so we can do some fast copies, as we don't 
    have direct access to the love:mesh vertex buffer) and references to which edge they belong to (probably just use some indices), so 
    that when we're iterating through the buffer, we'll know that if we're at an edge described by (vertex[a], vertex[b]), we're also at 
    the edge (vertex[b], vertex[a]).

    A draw-back of keeping our own array of vertex positions is that this assumes the mesh vertices will stay exactly where they are 
    (in local space), for the lifetime of the mesh. If we deform our mesh, they won't, and our shadows won't align with their respective 
    object when it does so. The fix, ofcourse, is to not have our own vertex buffer (and rely on love2d's mesh.getVertex, which is a 
    little slower than I'd like) or, anytime we update our mesh's vertices, we update our vertex buffer too. We might be able to pre-empt 
    this behaviour with a flag like OpenGL's 'dynamic', and if it is 'dynamic', we use getVertex() instead'. Or something like that.
    What we really want ofcourse is direct access to the vert buffer, but as of love2D 11.5, we don't. We'll see.

    As for our edges, they shouldn't really change throughout the lifetime of our mesh, regardless of any deformations. This is good.

    Saying all this, I'm realising we could maybe ONLY keep our own internal buffer, and change that to our own desire, then set the love:mesh 
    as we change IT, essentially inverting the source of truth from love:mesh to our own buffer. That might be a way forward. We'll see!
]]

-- We'll create a new struct the same size bytes as vec4, but where we can 'hide' the edge index in the "w" value. We'll call it "edge".
ffi.cdef[[ typedef struct { float x, y, z; int32_t edge; } vec3edge; ]]

function lov3.buildMesh3(path, verts, tris, uvs, normals)

    -- We'll set up a love2d Mesh with as little information as required.
    local meshFormat = {{"VertexPosition", "float", 3}, {"VertexTexCoord", "float", 2}, {"VertexColor", "byte", 4}, {"VertexNormal", "float", 3}}
    local mesh = love.graphics.newMesh(meshFormat, #tris * 3, "triangles", "dynamic")
    local internal_buffer = ffi.new("vec3edge[?]", #tris * 3) -- Create a vertex array for our own use  (because we don't have direct access to love.mesh vert buffer)
    local edges = {} -- Create a table we'll fill with our edge determination.

    local count = 0
    -- tris = {{{v, uv, n}, {v, uv, n}, {v, uv, n}},...}
    for i=1, #tris do

        local tri = tris[i] -- tri = {{v, uv, n}, {v, uv, n}, {v, uv, n}}
        for v=1, 3 do

            local tri_vert = tri[v] -- tri_vert = {v, uv, n}
            local v_i, uv_i, n_i = unpack(tri_vert)

            local vertex = verts[v_i]
            local uv = uvs and uvs[uv_i] or {0, 0}
            local normal = normals and normals[n_i] or vec3.one() -- maybe compute here if we dont have them?
            local color = colour.white() -- maybe make this customizable?

            -- write to the mesh
            mesh:setVertex(
                count + 1,
                vertex.x, vertex.y, vertex.z,
                uv[1], uv[2],
                color[1], color[2], color[3], color[4],
                normal.x, normal.y, normal.z
            )

            -- write to our internal vert buffer
            local va = internal_buffer[count] -- zero based for c-arrays
            va.x, va.y, va.z = vertex.x, vertex.y, vertex.z

            -- determine our edges
            local avi, bvi = tri[v][1], tri[v%3 + 1][1] -- 'verts' indices of edge (a, b)
            local newEdge = true
            for e = 1, #edges do
                local edge = edges[e]
                if(edge and (avi == edge.a and bvi == edge.b) or (avi == edge.b and bvi == edge.a)) then
                    table.insert(edge.indices, count + 1) -- if our edge exists already, we'll just increase the size of the "indices" table.
                    if(#edge.indices > 2) then
                        va.edge = #edges -- If more than 2 verts share this edge, its a "bad" edge and we want to ignore it. This is discussed below.
                    else
                        va.edge = e - 1 -- otherwise, we just assign the index
                    end
                    newEdge = false
                    break
                end
            end
            if newEdge then
                table.insert(edges, {a = avi, b = bvi, indices = {count + 1}})
                va.edge = #edges - 1 -- If our edge doesn't exist yet, we assign the index of the newly added edge.
            end

            count = count + 1
        end
    end

    return {mesh = mesh, internal_buffer = internal_buffer, vert_count = count, edge_count = #edges, path = path}
end

function lov3.newQuadMesh3() local q = lov3.primitives.quad return lov3.buildMesh3("quad", q.verts, q.tris, q.uvs, q.normals) end
function lov3.newPlaneMesh3() local q = lov3.primitives.plane return lov3.buildMesh3("plane", q.verts, q.tris, q.uvs, q.normals) end
function lov3.newTetraMesh3() local t = lov3.primitives.tetrahedron return lov3.buildMesh3("tetrahedron", t.verts, t.tris, t.uvs, t.normals) end
function lov3.newCubeMesh3() local c = lov3.primitives.cube return lov3.buildMesh3("cube", c.verts, c.tris, c.uvs, c.normals) end
function lov3.newIcoMesh3() local i = lov3.primitives.icosahedron return lov3.buildMesh3("icosahedron", i.verts, i.tris, i.uvs, i.normals) end
function lov3.newSphereMesh3() local s = lov3.primitives.sphere return lov3.buildMesh3("sphere", s.verts, s.tris, s.uvs, s.normals) end

-- A helper to load our primitives...
function lov3.createPrimitive(primitiveName)
    if primitiveName == "quad" then return lov3.newQuadMesh3()
    elseif primitiveName == "plane" then return lov3.newPlaneMesh3()
    elseif primitiveName == "tetrahedron" then return lov3.newTetraMesh3()
    elseif primitiveName == "cube" then return lov3.newCubeMesh3()
    elseif primitiveName == "icosahedron" then return lov3.newIcoMesh3()
    elseif primitiveName == "sphere" then return lov3.newSphereMesh3()
    else return nil end
end

-- A helper to calculate the normals of a 3D mesh from its triangles
function lov3.recalculateNormalsPerFace(mesh3)
    local vcount = mesh3.mesh:getVertexCount()
    local new_verts = {}
    local normal

    for i=1, vcount do
        local ax, ay, az, u, v, r, g, b, a = mesh3.mesh:getVertex(i)

        if (i-1)%3 == 0 then
            local bx,by,bz = mesh3.mesh:getVertex(i + 1)
            local cx,cy,cz = mesh3.mesh:getVertex(i + 2)

            local e1 = vec3(ax - bx, ay - by, az - bz)
            local e2 = vec3(ax - cx, ay - cy, az - cz)

            normal = vec3.normalise(vec3.cross(e1, e2))
        end

        local new_vert = {ax,ay,az,u,v,r,g,b,a,normal.x,normal.y,normal.z}
        table.insert(new_verts, new_vert)
    end

    mesh3.mesh:setVertices(new_verts)
    return mesh3
end

-- A helper to calculate the normals of a 3D mesh from its triangles, then average any three triangles and assign that to the vertex they share
function lov3.recalculateNormalsPerVertex(mesh3)
    local vcount = mesh3.mesh:getVertexCount()

    local vertsWithNewNormals = {}
    local hashedVertices = {}

    for i=1, vcount/3 do
        local ai = (i-1) * 3 + 1
        local bi, ci = ai + 1, ai + 2
        local ax, ay, az = mesh3.mesh:getVertex(ai)
        local bx, by, bz = mesh3.mesh:getVertex(bi)
        local cx, cy, cz = mesh3.mesh:getVertex(ci)
        local a, b, c = vec3(ax, ay, az), vec3(bx, by, bz), vec3(cx, cy, cz)
        local normal = vec3.normalise(vec3.cross(a - b, a - c))

        local ha = hashedVertices[a:hash()]
        if not ha then ha = normal else ha = ha + normal end
        hashedVertices[a:hash()] = ha

        local hb = hashedVertices[b:hash()]
        if not hb then hb = normal else hb = hb + normal end
        hashedVertices[b:hash()] = hb

        local hc = hashedVertices[c:hash()]
        if not hc then hc = normal else hc = hc + normal end
        hashedVertices[c:hash()] = hc
    end

    for i=1, vcount/3 do
        local ai = (i-1) * 3 + 1
        local bi, ci = ai + 1, ai + 2
        local ax, ay, az, au, av, ar, ag, ab, aa = mesh3.mesh:getVertex(ai)
        local bx, by, bz, bu, bv, br, bg, bb, ba = mesh3.mesh:getVertex(bi)
        local cx, cy, cz, cu, cv, cr, cg, cb, ca = mesh3.mesh:getVertex(ci)
        local a, b, c = vec3(ax, ay, az), vec3(bx, by, bz), vec3(cx, cy, cz)

        local ha = hashedVertices[a:hash()]
        local hb = hashedVertices[b:hash()]
        local hc = hashedVertices[c:hash()]

        local na, nb, nc = ha/3, hb/3, hc/3 -- we know any particular hashed vert has a magnitude of 3, so we can just divide by 3 to get the norm.

        local new_a = {ax, ay, az, au, av, ar, ag, ab, aa, na.x, na.y, na.z}
        local new_b = {bx, by, bz, bu, bv, br, bg, bb, ba, nb.x, nb.y, nb.z}
        local new_c = {cx, cy, cz, cu, cv, cr, cg, cb, ca, nc.x, nc.y, nc.z}

        table.insert(vertsWithNewNormals, new_a)
        table.insert(vertsWithNewNormals, new_b)
        table.insert(vertsWithNewNormals, new_c)
    end

    mesh3.mesh:setVertices(vertsWithNewNormals)
    return mesh3
end

-- A naive helper to check if a mesh has face normals (and not vertex normals).
function lov3.hasFaceNormals(mesh3)
    local _, _, _, _, _, _, _, _, _, anx, any, anz = mesh3.mesh:getVertex(1)
    local _, _, _, _, _, _, _, _, _, bnx, bny, bnz = mesh3.mesh:getVertex(2)
    local _, _, _, _, _, _, _, _, _, cnx, cny, cnz = mesh3.mesh:getVertex(3)
    return (anx == bnx and bnx == cnx) and (any == bny and bny == cny) and (anz == bnz and bnz == cnz)
end

function lov3.addShadowMesh(entity)
    if entity.renderer3.useSimpleShadows and lov3.hasFaceNormals(entity.mesh3) then -- We just force anything that has face normals to  
        entity.renderer3.useSimpleShadows = false                                   -- not use simple shadows, as they just won't work.
    end

    if entity.renderer3.hasShadows and not entity.renderer3.useSimpleShadows then
        local vcount = entity.mesh3.mesh:getVertexCount()
        local meshFormat = {{"VertexPosition", "float", 4}}
        local shadowVertCount = vcount * 3
        local shadowMesh = love.graphics.newMesh(meshFormat, shadowVertCount, "triangles", "dynamic") -- Assumes incoming meshes are marked as "triangles"
        --[[
            Now I know we said we didn't want to have big meshes. But it is the case that a tetrahedron or quad has 12 verts but require 18 and 24 
            "silhouette" verts respectively, so vcount * 3 should cover us in most cases, but realistically most shapes require less. A cube only needs 
            an additional v*count * 2, being 36 verts but only ever requiring 36 extrusion verts. A sphere requires even less than that. We should 
            probably determine an algorithm that finds minimum set of required verts for extrusion.. or even just a switch case? We'll see!
        ]]
        
        -- We need to tie the shadow mesh to the renderable object, not the mesh3 instance, otherwise we'll overwite any shadows that share the same mesh3 
        -- (this is presuming we eventually add some kind of batch instancing).
        entity.shadowMesh = shadowMesh

        -- We'll set the shadow_buffer as big as the shadow mesh, then add an extra set of bytes for edge-checking,
        -- and then one more, so we can assign any "bad" edges to it. This can stay in the mesh3 instance, as we'll only use them one at a time.
        -- If we end up multi-threading, that may change.
        entity.mesh3.shadow_buffer = love.data.newByteData((4 * 4 * shadowVertCount) + (shadowVertCount+ 1))
        entity.mesh3.edge_buffer_offset = shadowVertCount
    end
end

-- This function contains the hot loop for our shadowing. The more optimization, the better.
function lov3.updateShadowMesh(shadowMesh, objectMesh3, objTransform3, lightPos)

    -- Local declarations of our buffers
    local shadow_buffer = objectMesh3.shadow_buffer
    local vert_buf_ptr = objectMesh3.internal_buffer -- at this stage this is still cast as vec3edge*
    local edge_buffer_offset = objectMesh3.edge_buffer_offset
    local edge_count = objectMesh3.edge_count
    local vert_count = objectMesh3.vert_count

    -- Vars
    local tri_count = vert_count/3 -- Total tris
    local light_x, light_y, light_z = lightPos.x, lightPos.y, lightPos.z
    local im11, im12, im13, im14, im21, im22, im23, im24, im31, im32, im33, im34 = objTransform3.transform:inverse():getMatrix()
    local o_lx = im11*light_x + im12*light_y + im13*light_z + im14 -- Transform light position into object space.
    local o_ly = im21*light_x + im22*light_y + im23*light_z + im24
    local o_lz = im31*light_x + im32*light_y + im33*light_z + im34
    local vert_i = 0 -- The original vert index for the base mesh (our near and far cap geometry)
    local extrusion_i = 0 -- The offset vert index for the extrusion geometry.
    local s_buf_ptr = ffi.cast("vec4*", shadow_buffer:getFFIPointer())   -- Now we cast our buffer to our vec4 c-struct for writing to our shader,
    local e_buf_ptr = ffi.cast("uint8_t*", s_buf_ptr + edge_buffer_offset) -- and then we get the edge buffer we appended to the end of the shadow buffer

    ffi.copy(s_buf_ptr, vert_buf_ptr, vert_count * 4 * 4)                 -- copy our vertex data into the shadow buffer,
    ffi.fill(e_buf_ptr, edge_count, 0)                                    -- and clear our edge buffer to 0
    e_buf_ptr[edge_count] = 128                                           -- set our bad edge value as something far from 0, 1 or 255

    for tri_i=0, tri_count-1 do -- we're working with c-arrays, so we use zero indexing

        vert_i = tri_i * 3

        local a_ptr = s_buf_ptr + vert_i
        local b_ptr = s_buf_ptr + vert_i + 1
        local c_ptr = s_buf_ptr + vert_i + 2

        local ea_ptr = e_buf_ptr + vert_buf_ptr[vert_i].edge
        local eb_ptr = e_buf_ptr + vert_buf_ptr[vert_i + 1].edge
        local ec_ptr = e_buf_ptr + vert_buf_ptr[vert_i + 2].edge

        local ax, ay, az = a_ptr[0].x, a_ptr[0].y, a_ptr[0].z
        local bx, by, bz = b_ptr[0].x, b_ptr[0].y, b_ptr[0].z
        local cx, cy, cz = c_ptr[0].x, c_ptr[0].y, c_ptr[0].z

        -- Cross product of edges (a,b) and (a,c) to get our normal
        local nx = (ay - by) * (az - cz) - (az - bz) * (ay - cy)
        local ny = (az - bz) * (ax - cx) - (ax - bx) * (az - cz)
        local nz = (ay - cy) * (ax - bx) - (ay - by) * (ax - cx)

        -- Dot product of light_dir and normal to get "luminance"
        local lit = nx * (o_lx - ax) + ny * (o_ly - ay) + nz * (o_lz - az) >= 0

        -- Here we write the "w" value, which will indicate if it's the near cap (lit) or the far cap (unlit) of the shadow volume.
        -- The shader we implement will then multiply "w" by the light direction, forming the the near and far caps of the extrusion.

        a_ptr[0].w, b_ptr[0].w, c_ptr[0].w = lit and 0 or 1, lit and 0 or 1, lit and 0 or 1

        -- If it is lit, we'll increment the paritcular location in our edge buffer, and decrement for unlit. We're pretty confident it wont be a null_ptr, 
        -- but maybe we should check anyway, otherwise, when we dereference... SEGMENTATION FAULT!!!

        if lit then
            ea_ptr[0] = ea_ptr[0] + 1
            eb_ptr[0] = eb_ptr[0] + 1
            ec_ptr[0] = ec_ptr[0] + 1
        else
            ea_ptr[0] = ea_ptr[0] - 1
            eb_ptr[0] = eb_ptr[0] - 1
            ec_ptr[0] = ec_ptr[0] - 1
        end

        -- Then, if this triangle has any silhouette edges, it will eventually be incrmented/decremented back to 0, so we know its a silhouette!
        -- And then we write the quad that joins the near-cap-edge to its corresponding far-cap-edge.
        if ea_ptr[0] == 0 then

            -- Depending on if we are currently inside a lit or unlit triangle, the edge we've found is either (a, b) or (b, a)
            -- and so we need to wind the triangles correctly depending on this property.

            local v1 = s_buf_ptr + vert_count + extrusion_i
            local v2, v3, v4, v5, v6 = v1 + 1, v1 + 2, v1 + 3, v1 + 4, v1 + 5

            if lit then
                v1[0], v2[0], v3[0] = a_ptr[0], a_ptr[0], b_ptr[0]
                v1[0].w, v2[0].w, v3[0].w = 0, 1, 0
                v4[0], v5[0], v6[0] = b_ptr[0], a_ptr[0], b_ptr[0]
                v4[0].w, v5[0].w, v6[0].w = 0, 1, 1
            else
                v1[0], v2[0], v3[0] = a_ptr[0], b_ptr[0], a_ptr[0]
                v1[0].w, v2[0].w, v3[0].w = 0, 0, 1
                v4[0], v5[0], v6[0] = b_ptr[0], b_ptr[0], a_ptr[0]
                v4[0].w, v5[0].w, v6[0].w = 0, 1, 1
            end

            extrusion_i = extrusion_i + 6
        end

        if eb_ptr[0] == 0 then

            local v1 = s_buf_ptr + vert_count + extrusion_i
            local v2, v3, v4, v5, v6 = v1 + 1, v1 + 2, v1 + 3, v1 + 4, v1 + 5

            if lit then
                v1[0], v2[0], v3[0] = b_ptr[0], b_ptr[0], c_ptr[0]
                v1[0].w, v2[0].w, v3[0].w = 0, 1, 0    
                v4[0], v5[0], v6[0] = c_ptr[0], b_ptr[0], c_ptr[0]
                v4[0].w, v5[0].w, v6[0].w = 0, 1, 1
            else
                v1[0], v2[0], v3[0] = b_ptr[0], c_ptr[0], b_ptr[0]
                v1[0].w, v2[0].w, v3[0].w = 0, 0, 1
                v4[0], v5[0], v6[0] = c_ptr[0], c_ptr[0], b_ptr[0]
                v4[0].w, v5[0].w, v6[0].w = 0, 1, 1
            end

            extrusion_i = extrusion_i + 6
        end

        if ec_ptr[0] == 0 then

            local v1 = s_buf_ptr + vert_count + extrusion_i
            local v2, v3, v4, v5, v6 = v1 + 1, v1 + 2, v1 + 3, v1 + 4, v1 + 5

            if lit then
                v1[0], v2[0], v3[0] = c_ptr[0], c_ptr[0], a_ptr[0]
                v1[0].w, v2[0].w, v3[0].w = 0, 1, 0
                v4[0], v5[0], v6[0] = a_ptr[0], c_ptr[0], a_ptr[0]
                v4[0].w, v5[0].w, v6[0].w = 0, 1, 1
            else
                v1[0], v2[0], v3[0] = c_ptr[0], a_ptr[0], c_ptr[0]
                v1[0].w, v2[0].w, v3[0].w = 0, 0, 1
                v4[0], v5[0], v6[0] = a_ptr[0], a_ptr[0], c_ptr[0]
                v4[0].w, v5[0].w, v6[0].w = 0, 1, 1
            end

            extrusion_i = extrusion_i + 6
        end
    end

    shadowMesh:setVertices(shadow_buffer)
    shadowMesh:setDrawRange(1, vert_count + extrusion_i)
    return shadowMesh
end

-- A few notes...

    --[[ 
        At the start of the update shadow mesh loop, our per-mesh3 shadow buffer looks something like:

        BYTES > }------------------vertex_count-*-3-*-16-----------------{}-------vertex_count------{}------1------{
            
                [orig_geometry][.........reserved_extrusion_bytes........][current_edge_indices_at_0][bad_edge_spot]
                               ^                                          ^                          ^
                      vertex_count(*4x4)                        e_buf_offset(*4x4)        e_buf_offset + e_count(*1)

        and by the end of the loop we'll want something like:

                [caps_geometry][computed_silhouette + any_remaining_bytes][all_silhouette_edges_at_0][bad_edge_spot]

        and then set the patricular shadow_mesh in question just with:
        
                [caps_geometry][computed_silhouette]
    ]]

    --[[
        This implementation isn't particularly cache friendly. Once we hit a mesh of a certain size, our pointer for our edge 
        buffer is miles away from wherever we are in the vertex buffer, and so on every dereference (which happens in every
        iteration of our loop) we're going to cache-miss. We'll see just how this affects the result once we start introducing 
        lots of meshes into our scenes. It might be no big deal, or it might be the case we have to refactor our entire method to
        make it more cache friendly. Some optimization ideas are...

            (a) When we organise our vertices during mesh creation, we order the verts in edge-to-edge order, so we can determine if 
            we're a silhouette edge within a very small slice of memory, then move on to the next 'edge-pair'. This will mean our
            vertices are now out of "triangle order", and we'll have to set an additional "index-map" to tell openGL the order 
            to draw the vertices correctly. This will imply a refactor, which will probably involve a longer loop, or even multiple
            loops, to achieve cache locality. Cache is king ofcourse. A cache-miss-free loop could be hundreds of times faster. We'll see!!!

            (b) We leverage parallelization to either draw the seperate volumes in seperate threads, or within a particular volume's 
            loop we parallelize our edge determination. If we're going inside the loop, we'll need to refactor a little in order to achieve this.

            (c) Do (a) and (b)?
    ]]

    --[[
        Incrementing and decrementing a single value for any particular edge works great for 3D objects, where we know an
        edge will only be shared by exactly 2 triangles. For 2D objects in 3D (like a quad), it may so happen that an edge
        could correspond to 4 triangles (the two front facing and two back facing triangles of a quad may all share the same
        single middle diagonal "edge"). This "edge" will also be incremented exactly twice and decremented exactly twice in
        much the same fashion as a real edge would exactly once (as it corresponds to 2 lit triangles and 2 unlit triangles)
        but ofcourse we would not want to include it in the silhouette edge list, as it isn't really an edge.

        We'll need to figure out a solution to filter out these "bad" edges...
    ]]
    
    --[[
        I realise having a 'bad edge' value isn't really necessary, we could just as easily set edge indices we considered "bad" to
        any old number or ignore them completely. But that means we have to check. This is an extra branch, but also means we don't
        jump ahead to the end of the edge buffer. We'll profile and see whats worse, and the result will probably be what we implement above.
    ]]

    --[[
        Calculating the normal in the loop assumes the mesh might not have per-face normals, and might have per-vertex normals
        (usually on the more "curvy" models that are intended to be phong-shaded (i.e. spheres, toroids, etc.)). If it was
        garaunteed to have per-face normals, we could just grab nx, ny, nz from the first vertex (after embedding it into 
        our internal buffer ofcourse). It isn't garunteed to have per-face normals though. People render phong-shaded spheres 
        all the time. They love it. So, we explcitly calculate it here even though its only really applicable when the mesh 
        we're shadowing has normals that are inconsistent across the triangle.

        But! If it IS the case that we have per-vertex normals, we *may* be able to skip over this entire extrusion method, 
        and just use the original mesh for the shadow volumes, as normals being inconsistent throughout any particular triangle 
        of the mesh means, by that very same virtue, that when those triangles are around the silhouette, they will have one or two 
        vertices be lit and one or two unlit, and so, we could deform that silhouette-triangle in GPU-land in much the same 
        fashion as this extrusion does for edges, but without all the CPU-land computational overhead! This silhouette will not 
        be a "true" silhouette, and may suffer from some artefact-ing, but it will probably be close enough. And, it will probably
        be closer and closer enough as the mesh complexity (by which I mean triangle density) increases.

        So, if we have a model that is intended to be phong-shaded (i.e. has vertex-specific normals instead of face-specific),
        we could probably skip CPU-calculated shadow extrusions. We should probably mark it ahead of time with something like
        "[object_to_render].use_simple_shadows == true", rather than programatically testing to see if its intended to be
        phong-shaded ourselves, as the fact its not a "true" silhouette may not be satisfactory for every particular
        implementation. We'll see.

        We could also invert this criteria and calculate and assign vertex-specific normals to meshes we want using the more
        performant approach, but then that item will be phong-shaded. We may or may not want that.

        If we're using/loading .obj files, an easy way to check "per-face-normal"-ness of the model is if any particular face line's [v/vt/vn] 
        components has a difference in the "vn" throughout the line:

            f 238//18 250//18 251//211 239//201 -- This one is intended to be phong-shaded.
            f 4//2 3//2 7//2 8//2               -- This one isn't.

        This ofcourse will then be reflected in the 'tris' array we produce for the mesh. And then the mesh itself. I may still 
        write a little helper called something like 'hasFaceNormals(mesh)' just in case we *do* want to programatically check. 
        The method will probably just check the first triangle, and assume the rest of the mesh follows in suit...

        Now, if a mesh has a combination of face-specific normals and vertex-specific normals, this whole approach may break.
        We probably have to either:
            (a) Force the mesh to have only face-specific normals by recalculating the normals per face. This will remove the
                phong-shading aspect of the mesh, and it will use this shadowing method.
            (b) Force the mesh to have only vertex-specific normals by recalculating the normals per vertex. This will the make the
                mesh entirely phong-shaded, but we can use the more performant shadowing method.
            (c) Always calculate normals here, and then force the particular mesh in question to use CPU-based volume extrusions,
                regardless of it's normals type.
            (d) Split the mesh in 2, with one having all the tris that correspond to vertex-specific normals, and the other
                with the face-specific normals. Nah.
        
        Currently, we're going with option (c). With the "use_simple_shadows" caveat.
    ]]


--------------------- Render Pipeline -----------------------

-- Defaults...
lov3.SKIP_SHADOWS = false
lov3.SKIP_POST_PROCESSING = false
lov3.IS_SHADOW_DEBUG = false
lov3.blurShader = love.graphics.newShader(shaders.blur)
lov3.ambientShader = love.graphics.newShader(shaders.ambient)
lov3.emissiveShader = love.graphics.newShader(shaders.unlit)
lov3.unlitShader = love.graphics.newShader(shaders.unlit)
lov3.lightShader = love.graphics.newShader(shaders.specular_phong)
lov3.transparentShader = love.graphics.newShader(shaders.specular_phong)
lov3.shadowShader = love.graphics.newShader(shaders.shadow_volume)
lov3.shadowShaderSimple = love.graphics.newShader(shaders.shadow_volume_simple)
lov3.ambientLightIntensity = 0.0
lov3.tint = colour.white()

function lov3.render()

    for c=1, #lov3.cameraEntities do
        local camera, lights, objects = lov3.cameraEntities[c], lov3.lightEntities, lov3.renderableEntities
        local w, h = camera.camera3.width, camera.camera3.height

        love.graphics.setFrontFaceWinding("cw") -- TODO - Replace this with something more concrete. I suspect this is due to love's default ortho.

        -- Render Passes
    
        love.graphics.push("all")
    
        love.graphics.setCanvas({camera.camera3.canvas, depthstencil = camera.camera3.depthStencilCanvas})
        love.graphics.clear(0, 0, 0, 0, true, true)
        lov3.ambientPass(camera, objects, lov3.ambientShader, lov3.unlitShader)
        lov3.lightingPass(lights, camera, objects, lov3.lightShader, lov3.shadowShaderSimple, lov3.shadowShader)
        lov3.transparentPass(lights, camera, objects, lov3.transparentShader)

        love.graphics.setCanvas({camera.camera3.emissiveCanvas, depthstencil = camera.camera3.depthStencilCanvas})
        love.graphics.clear(0, 0, 0, 0, false, false)
        lov3.emissivePass(camera, objects, lov3.emissiveShader)
    
        love.graphics.pop()
        love.graphics.setCanvas()
    
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.draw(camera.camera3.canvas, 0, h, 0, w/camera.camera3.canvas:getWidth(), -h/camera.camera3.canvas:getHeight())
    
        -- Post Processes
        if(not lov3.SKIP_POST_PROCESSING) then
            love.graphics.setBlendMode("add", "premultiplied")
            love.graphics.setShader(lov3.blurShader)
            lov3.blurShader:send("size", {w,h})
            love.graphics.draw(camera.camera3.emissiveCanvas, 0, h, 0, w/camera.camera3.canvas:getWidth(), -h/camera.camera3.canvas:getHeight())
        end
        
        -- Reset on exit 
        love.graphics.setShader()
        love.graphics.setBlendMode("alpha", "alphamultiply")
    end
end

function lov3.drawMesh3(mesh3, transform3)
    local shader = love.graphics.getShader()
    if (shader and shader:hasUniform("inverse_model_matrix")) then
	    shader:send("inverse_model_matrix", {transform3.transform:inverse():getMatrix()})
    end
    love.graphics.draw(mesh3.mesh, transform3.transform)
end

function lov3.resizeCamera3(camera3, w, h)
    camera3.width, camera3.height = w, h
    camera3.canvas = love.graphics.newCanvas(w, h)
	camera3.emissiveCanvas = love.graphics.newCanvas(w,h)
	camera3.depthStencilCanvas = love.graphics.newCanvas(w, h, {format = "depth24stencil8"})
    camera3.projection:setMatrix(lov3.perspectiveMat4(30, w/h, 1, 100))
end

function lov3.ambientPass(camera, objects, ambientShader, unlitShader)

    ambientShader:send("view_matrix", {camera.transform3.transform:inverse():getMatrix()})
	ambientShader:send("projection_matrix", {camera.camera3.projection:getMatrix()})
	ambientShader:send("intensity", lov3.ambientLightIntensity)

    unlitShader:send("view_matrix", {camera.transform3.transform:inverse():getMatrix()})
	unlitShader:send("projection_matrix", {camera.camera3.projection:getMatrix()})

    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("lequal", true)

	for i=1, #objects do
        local object = objects[i]
        if not object.renderer3.transparent then
            if object.renderer3.unlit then
                unlitShader:send("colour", object.renderer3.colour or colour.white())
                love.graphics.setShader(unlitShader)
            else
                ambientShader:send("colour", object.renderer3.colour or colour.white())
                love.graphics.setShader(ambientShader)
            end
            lov3.drawMesh3(object.mesh3, object.transform3)
        end
	end
end

function lov3.emissivePass(camera, objects, emissiveShader)

    emissiveShader:send("view_matrix", {camera.transform3.transform:inverse():getMatrix()})
	emissiveShader:send("projection_matrix", {camera.camera3.projection:getMatrix()})

    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("lequal", true)
    love.graphics.setShader(emissiveShader)

	for i=1, #objects do
        local object = objects[i]
        if object.renderer3.emissive then
            emissiveShader:send("colour", object.renderer3.colour or colour.white())
            lov3.drawMesh3(object.mesh3, object.transform3)
        end
	end
end

function lov3.lightingPass(lights, camera, objects, lightShader, shadowVolumeSimpleShader, shadowVolumeShader)

    local setShader = love.graphics.setShader
    local setDepthMode = love.graphics.setDepthMode
    local setStencilTest = love.graphics.setStencilTest
    local setMeshCullMode = love.graphics.setMeshCullMode
    local setBlendMode = love.graphics.setBlendMode
    local setWireframe = love.graphics.setWireframe
    local stencil = love.graphics.stencil
    local shaderSend = lightShader.send
    local drawMesh3 = lov3.drawMesh3
    local setColor = love.graphics.setColor
    local updateShadowMesh = lov3.updateShadowMesh

    local viewMatrix = {camera.transform3.transform:inverse():getMatrix()}
    local projectionMatrix = {camera.camera3.projection:getMatrix()}

    shaderSend(lightShader, "view_matrix", viewMatrix)
    shaderSend(shadowVolumeShader, "view_matrix", viewMatrix)
    shaderSend(shadowVolumeSimpleShader, "view_matrix", viewMatrix)

    shaderSend(lightShader, "projection_matrix", projectionMatrix)
    shaderSend(shadowVolumeShader, "projection_matrix", projectionMatrix)
    shaderSend(shadowVolumeSimpleShader, "projection_matrix", projectionMatrix)

    local function drawShadowVolumes(light)

        local lightPosition = vec3(light.transform3:getWorldPosition())
        shaderSend(shadowVolumeShader, "light_position", lightPosition:table())
        shaderSend(shadowVolumeSimpleShader, "light_position", lightPosition:table())

        for i=1, #objects do
            local object = objects[i]

            if object.renderer3.hasShadows and not object.renderer3.transparent then

                if object.renderer3.useSimpleShadows then
                    shaderSend(shadowVolumeSimpleShader, "attenuation", light.light3.attenuation)
                    setShader(shadowVolumeSimpleShader)
                    drawMesh3(object.mesh3, object.transform3)
                else
                    shaderSend(shadowVolumeShader, "attenuation", light.light3.attenuation)
                    setShader(shadowVolumeShader)
                    updateShadowMesh(object.shadowMesh, object.mesh3, object.transform3, lightPosition)
                    drawMesh3({mesh = object.shadowMesh}, object.transform3)
                end
            end
        end
    end

    -- For each light in the scene...
    for l=1, #lights do
        local light = lights[l]

        -- Render shadows with current light
        if light.light3.useShadows and not lov3.SKIP_SHADOWS then

            if not lov3.IS_SHADOW_DEBUG then        
                -- setDepthMode("lequal", false) -- Default shadow volume rendering method
                -- stencil(function() setMeshCullMode("back") drawShadowVolumes(light) end, "increment", nil, true)
                -- stencil(function() setMeshCullMode("front") drawShadowVolumes(light) end, "decrement", nil, true)

                setDepthMode("greater", false) -- Carmack's Reverse (invert stencil depth func, and swap increment direction when culling)
                stencil(function() setMeshCullMode("front") drawShadowVolumes(light) end, "incrementwrap", nil, true)
                stencil(function() setMeshCullMode("back") drawShadowVolumes(light) end, "decrementwrap", nil, true)
    
                setStencilTest("equal", 0)
            else
                setDepthMode("lequal", false)
                setWireframe(true)
                setColor(light.light3.colour)
                drawShadowVolumes(light)
                setWireframe(false)
                setColor(lov3.tint:setRGBA())
            end
        end

        setBlendMode("add")  -- Set blend mode to add so we cumulatively light the scene

        -- Render objects with current light
        setMeshCullMode("back")
        setDepthMode("lequal", false)
        shaderSend(lightShader, "light_position", {light.transform3:getWorldPosition()})
        shaderSend(lightShader, "attenuation", light.light3.attenuation)
        shaderSend(lightShader, "ambient_intensity", 0); -- Remove the ambient component. We already rendered that. Now we're blending with it.
        shaderSend(lightShader, "intensity", light.light3.intensity - lov3.ambientLightIntensity);
        shaderSend(lightShader, "light_color", light.light3.colour or colour.white())
        setShader(lightShader)

        for o=1, #objects do
            local object = objects[o]
            if not object.renderer3.emissive and not object.renderer3.transparent then
                shaderSend(lightShader, "colour", object.renderer3.colour or colour.white())
                drawMesh3(object.mesh3, object.transform3)
            end
        end

        stencil(function() end, nil, nil, false) -- set keepvalues to false to clear the stencil buffer
    end

    setBlendMode("alpha") -- Reset the blend mode, just in case
end

function lov3.transparentPass(lights, camera, objects, transparentShader)

    transparentShader:send("ambient_intensity", lov3.ambientLightIntensity); -- Add back the ambient intensity. We skipped transparent meshes in the ambient step.
    transparentShader:send("view_matrix", {camera.transform3.transform:inverse():getMatrix()})
	transparentShader:send("projection_matrix", {camera.camera3.projection:getMatrix()})

    love.graphics.setMeshCullMode("back")

    for l=1, #lights do
        local light = lights[l]

        transparentShader:send("light_position", {light.transform3:getWorldPosition()})
        transparentShader:send("attenuation", light.light3.attenuation)
        transparentShader:send("intensity", light.light3.intensity)

        love.graphics.setDepthMode("lequal", false)
        love.graphics.setShader(transparentShader)

        for i=1, #objects do
            local object = objects[i]
            if object.renderer3.transparent then
                lov3.drawMesh3(object.mesh3, object.transform3)
            end
        end
    end
end

-------------------------------- Serialisation --------------------------------

function lov3.parseString(input)
    return string.match(input, "\"(.-)\"")
end

function lov3.parseBool(input)
    if string.match(input, "true") ~= nil then
        return true
    elseif string.match(input, "false") ~= nil then
        return false
    end
    return nil
end

function lov3.parseColour(input)
    local function hex(e) return e and tonumber(e, 16)/255 or nil end
    local r, g, b, a = string.match(input, "#(..)(..)(..)(..)")
    return hex(r) and colour.new(hex(r), hex(g), hex(b), hex(a)) or nil
end

function lov3.parseVec2(input)
    local tn = tonumber
    local x, y = string.match(input, "(.-)%s+(.+)")
    return (x and y) and vec2(tn(x), tn(y)) or nil
end

function lov3.parseVec3(input)
    local tn = tonumber
    local x, y, z = string.match(input, "(.-)%s+(.-)%s+(.+)")
    return (x and y and z) and vec3(tn(x), tn(y), tn(z)) or nil
end

function lov3.parseVec4(input)
    local tn = tonumber
    local x, y, z, w = string.match(input, "(.-)%s+(.-)%s+(.-)%s+(.+)")
    return (x and y and z and w) and vec4(tn(x), tn(y), tn(z), tn(w)) or nil
end

function lov3.parseValue(input)
    --input = string.match(input, "^%s*(.-)%s*$") -- trim
    local value = lov3.parseString(input)
    if not value then value = lov3.parseBool(input) end
    if not value then value = tonumber(input) end
    if not value then value = lov3.parseColour(input) end
    if not value then value = lov3.parseVec4(input) end
    if not value then value = lov3.parseVec3(input) end
    if not value then value = lov3.parseVec2(input) end
    if not value then return nil end
    --print(input, type(value), value)
    return value
end

function lov3.readEntityNode(inputString, depth, parentEntity)

    local parseValue = lov3.parseValue

    depth = depth or 0
    local indent = string.rep("\t", depth)
    local componentIndent = table.concat({"[^\t]", indent, "\t"})
    local entity = nil

    for entityString in string.gmatch(inputString, table.concat({indent, "entity(.-)\n", indent, ";"})) do

        local entityContents  = {}
        
        entityContents.name = parseValue(string.match(entityString, componentIndent .. "name%s+(.-)[\r\n]"))

        if string.match(entityString, componentIndent .. "transform3") then
            local componentContents = {}
            for propertyKey, property in string.gmatch(entityString, componentIndent .. "transform3%.(.-)%s+(.-)[\r\n]") do
                componentContents[propertyKey] = parseValue(property)
            end
            entityContents.transform3 = transform3.new(componentContents):setParent(parentEntity and parentEntity.transform3 or nil, false)
        end

        if string.match(entityString, componentIndent .. "camera3") then
            local componentContents = {}
            for propertyKey, property in string.gmatch(entityString, componentIndent .. "camera3%.(.-)%s+(.-)[\r\n]") do
                componentContents[propertyKey] = parseValue(property)
            end
            entityContents.camera3 = camera3.new(componentContents)
        end

        if string.match(entityString, componentIndent .. "mesh3") then
            local componentContents = {}
            for propertyKey, property in string.gmatch(entityString, componentIndent .. "mesh3%.(.-)%s+(.-)[\r\n]") do
                componentContents[propertyKey] = parseValue(property)
            end
            entityContents.mesh3 = lov3.createPrimitive(componentContents.path) or lov3.buildMesh3(componentContents.path, lov3.parseOBJ(love.filesystem.read(componentContents.path)))
        end

        if string.match(entityString, componentIndent .. "light3") then
            local componentContents = {}
            for propertyKey, property in string.gmatch(entityString, componentIndent .. "light3%.(.-)%s+(.-)[\r\n]") do
                componentContents[propertyKey] = parseValue(property)
            end
            entityContents.light3 = light3.new(componentContents)
        end

        if string.match(entityString, componentIndent .. "renderer3") then
            local componentContents = {}
            for propertyKey, property in string.gmatch(entityString, componentIndent .. "renderer3%.(.-)%s+(.-)[\r\n]") do
                componentContents[propertyKey] = parseValue(property)
            end
            entityContents.renderer3 = renderer3.new(componentContents)
        end

        entity = lov3.createEntity(entityContents)

        lov3.readEntityNode(entityString, depth + 1, entity)
    end

    return entity
end

function lov3.loadEntity(path, isRoot)
    local entity = lov3.readEntityNode((love.filesystem.read(path)))
    if isRoot then lov3.setRootEntity(entity) end
    return entity
end

function lov3.writeValue(value) -- we'll leverage most value's own tostring() overloads
    if type(value) == "string" then return table.concat({"\"", value, "\""}) end
    return tostring(value)
end

function lov3.writeEntityNode(entity, depth)

    local writeValue = lov3.writeValue

    depth = depth or 0
    local indent = string.rep("\t", depth)
    local componentIndent = indent .. "\t"

    local output = table.concat({indent, "entity\r\n"})

    for componentKey, component in pairs(entity) do
        if componentKey == "id" then goto continueEntity end -- skip id, we'll regenerate on load.
        if componentKey == "shadowMesh" then goto continueEntity end

        if type(component) ~= "table" then
            output = table.concat({output, componentIndent, componentKey, " ", writeValue(component), "\r\n"})
            goto continueEntity
        end

        for propertyKey, property in pairs(component) do
            if propertyKey == "entity" then goto continueComponent end
            if componentKey == "mesh3" and propertyKey ~= "path" then goto continueComponent end
            if componentKey == "transform3" and propertyKey == "transform" then goto continueComponent end
            if componentKey == "transform3" and propertyKey == "parent" then goto continueComponent end
            if componentKey == "transform3" and propertyKey == "children" then
                for i=1, #component.children do
                    output = table.concat({output, lov3.writeEntityNode(component.children[i].entity, depth + 1)})
                end
                goto continueComponent
            end

            output = table.concat({output, componentIndent, componentKey, ".", propertyKey, " ", writeValue(property), "\r\n"})
            ::continueComponent::
        end
        
        ::continueEntity::
    end

    return table.concat({output, indent, ";", "\r\n"})
end

function lov3.saveEntityTo(entity, path)
    return love.filesystem.write(path, lov3.writeEntityNode(entity))
end

return lov3