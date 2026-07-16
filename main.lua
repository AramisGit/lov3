io.stdout:setvbuf('no')

local lov3 = require("lov3")
local game = require("game")

local IS_PAUSED = false
local TIME = 0
local SHOW_SAVE_DIALOG = false
local loadScenePath, saveScenePath = "test_scene_b.entity", "test_scene_b.entity"
local scene, yaw, block_a, camera, red_light, green_light, blue_light, player, block_b, pitch
local PI = math.pi

local leftMouseDown = false
local mouseDownX, mouseDownY = 0, 0
local deltaTheta, deltaGamma = 0, 0
local targetTheta, targetGamma = 0, 0
local targetPos, origPos = vec3(), vec3()
local isMoving = false
local moveFactor = 0
local bounds = transform3.new({position = vec3(0, 8, 0), scale = vec3(8,8,8)})

function love.load()
	love.graphics.setNewFont(18)

	scene = lov3.loadEntity(loadScenePath, true)

	player = lov3.findEntity("player")
	yaw = lov3.findEntity("yaw")
	pitch = lov3.findEntity("pitch")
	camera = lov3.findEntity("camera")
	block_a = lov3.findEntity("block_a")
	block_b = lov3.findEntity("block_b")
	red_light = lov3.findEntity("red_light")
	green_light = lov3.findEntity("green_light")
	blue_light = lov3.findEntity("blue_light")

	targetPos = player and player.transform3.position
	origPos = player and player.transform3.position
	targetTheta = yaw and yaw.transform3.rotation.y or 0
end

local function translate(dt)
	if not isMoving then
		return
	end

	local reach = (bounds.position - targetPos)

	if math.abs(reach.x) > bounds.scale.x or math.abs(reach.y) > bounds.scale.y or math.abs(reach.z) > bounds.scale.z then
		isMoving = false
		return
	end

	moveFactor = moveFactor + dt * 7
	player.transform3:setPosition(vec3.lerp(origPos, targetPos, moveFactor))
	if moveFactor > 1 then
		player.transform3:setPosition(targetPos)
		isMoving = false
	end
end

local function rotate(dt)
	if leftMouseDown then
		deltaTheta = (mouseDownX - love.mouse.getX())/love.graphics.getWidth() * 2
		deltaGamma = (mouseDownY - love.mouse.getY())/love.graphics.getHeight() * 2
		yaw.transform3:setRotation(yaw.transform3.rotation.x, targetTheta + deltaTheta, yaw.transform3.rotation.z)
		pitch.transform3:setRotation(targetGamma + deltaGamma, pitch.transform3.rotation.y, pitch.transform3.rotation.z)
	else
		yaw.transform3:setRotation(yaw.transform3.rotation.x, lov3.lerp(yaw.transform3.rotation.y, targetTheta, 0.02), yaw.transform3.rotation.z)
		pitch.transform3:setRotation(lov3.lerp(pitch.transform3.rotation.x, targetGamma, 0.02), pitch.transform3.rotation.y, pitch.transform3.rotation.z)
	end
end

function love.update (dt)

	rotate(dt)
	translate(dt)

	if IS_PAUSED then
		return
	end

	TIME = TIME + dt
end



function love.draw()
	lov3.render()
	love.graphics.print("FPS: " .. love.timer.getFPS() .. "\t" .. "DC: " .. love.graphics.getStats().drawcalls)

	if SHOW_SAVE_DIALOG then
		love.graphics.print(table.concat({"Saved \"", scene.name, "\" to \"", saveScenePath, "\""}), 0, love.graphics.getHeight()-28, 0)
		if TIME - SAVE_TIME > 2 then
			SHOW_SAVE_DIALOG = false
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if button == 1 then
		leftMouseDown = true
		mouseDownX, mouseDownY = x, y
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased (x, y, button, istouch, presses)
	if button == 1 then
		leftMouseDown = false
	end
end

function love.keypressed (key, scancode, isrepeat)
	if key == "space" then IS_PAUSED = not IS_PAUSED end
	if key == "v" then lov3.IS_SHADOW_DEBUG = not lov3.IS_SHADOW_DEBUG end
	if key == "l" then lov3.SKIP_SHADOWS = not lov3.SKIP_SHADOWS end
	if key == "p" then lov3.SKIP_POST_PROCESSING = not lov3.SKIP_POST_PROCESSING end
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen()) end
	if key == "escape" then love.event.quit() end

	if key == "s" and love.keyboard.isDown("lctrl", "rctrl") then
		if lov3.saveEntityTo(scene, saveScenePath) then
			SHOW_SAVE_DIALOG = true
			SAVE_TIME = TIME
		end
		lov3.saveEntityTo(green_light, "test_green_light.entity")
	end

	if key == "0" then
		player.transform3:removeChild(2)
		player.transform3:setPosition(block_a.transform3:getWorldPosition())
		block_a.transform3:setParent(player.transform3)
		targetPos = vec3(player.transform3:getWorldPosition())
	end

	if key == "9" then
		player.transform3:removeChild(2)
		player.transform3:setPosition(block_b.transform3:getWorldPosition())
		block_b.transform3:setParent(player.transform3)
		targetPos = vec3(player.transform3:getWorldPosition())
	end

	if key == "1" then
		player.transform3:removeChild(2)
		player.transform3:setPosition(red_light.transform3:getWorldPosition())
		red_light.transform3:setParent(player.transform3)
		targetPos = vec3(player.transform3:getWorldPosition())
	end

	if key == "2" then
		player.transform3:removeChild(2)
		player.transform3:setPosition(green_light.transform3:getWorldPosition())
		green_light.transform3:setParent(player.transform3)
		targetPos = vec3(player.transform3:getWorldPosition())
	end

	if key == "3" then
		player.transform3:removeChild(2)
		player.transform3:setPosition(blue_light.transform3:getWorldPosition())
		blue_light.transform3:setParent(player.transform3)
		targetPos = vec3(player.transform3:getWorldPosition())
	end

	--translation
	local worldPos = vec3(player.transform3:getWorldPosition())

	if key == "w" and not isMoving then

		targetPos = game.toClosestCell(worldPos - yaw.transform3:getBasisZ())
		origPos = game.toClosestCell(worldPos)
		moveFactor = 0
		isMoving = true
	end
	if key == "s" and not isMoving and not love.keyboard.isDown("lctrl", "rctrl") then
		targetPos = game.toClosestCell(worldPos + yaw.transform3:getBasisZ())
		origPos = game.toClosestCell(worldPos)
		moveFactor = 0
		isMoving = true
	end
	if key == "a" and not isMoving then
		targetPos = game.toClosestCell(worldPos - yaw.transform3:getBasisX())
		origPos = game.toClosestCell(worldPos)
		moveFactor = 0
		isMoving = true
	end
	if key == "d" and not isMoving then
		targetPos = game.toClosestCell(worldPos + yaw.transform3:getBasisX())
		origPos = game.toClosestCell(worldPos)
		moveFactor = 0
		isMoving = true
	end
	if key == "down" and not isMoving then
		targetPos = game.toClosestCell(worldPos - yaw.transform3:getBasisY())
		origPos = game.toClosestCell(worldPos)
		moveFactor = 0
		isMoving = true
	end
	if key == "up" and not isMoving then
		targetPos = game.toClosestCell(worldPos + yaw.transform3:getBasisY())
		origPos = game.toClosestCell(worldPos)
		moveFactor = 0
		isMoving = true
	end

	-- rotation
	if key == "left" or key == "kp4" then
		targetTheta = targetTheta + PI/2
	end
	if key == "right" or key == "kp6" then
		targetTheta = targetTheta - PI/2
	end
end

function love.resize(w, h)
	lov3.resizeCamera3(camera.camera3, w, h)
end

function love.quit()
end