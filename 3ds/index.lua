-------------------------------------------------
-- Ray-Casting Algorithm Tech-Demo for lpp-3ds --
-------------------------------------------------

-- Load RayCast3D Engine
dofile(System.currentDirectory().."/raycast3d.lua")

-- Map Details
wall_height = 64
tile_size = 64
map_width = 15
map_height = 6
W = Graphics.loadImage(System.currentDirectory().."/wall.png")
I = Graphics.loadImage(System.currentDirectory().."/wall2.png")
map = {
	W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,
	W,0,W,0,0,0,W,0,0,W,I,I,I,I,I,
	W,0,W,W,W,0,0,0,0,W,I,0,0,0,I,
	W,0,0,0,0,0,0,0,0,0,0,0,0,0,I,
	W,0,0,0,W,0,0,0,0,W,I,0,0,0,I,
	W,W,W,W,W,W,W,W,W,W,I,I,I,I,I
}

-- Player Speed
pl_speed = 5
cam_speed = 50

-- Setting up RayCast3D Engine
RayCast3D.setResolution(400, 240)
RayCast3D.setViewsize(60)
RayCast3D.loadMap(map, map_width, map_height, tile_size, wall_height)
RayCast3D.spawnPlayer(80, 80, 90)

-- Set accuracy depending on console
System.setCpuSpeed(804)
if System.getCpuSpeed() == 804 then
	RayCast3D.setAccuracy(1)
else
	RayCast3D.setAccuracy(3)
end

-- Set 3D variable
is3D = false

-- Using an image as skybox
RayCast3D.enableFloor(false)
RayCast3D.setFloorColor(Color.new(29,14,7))
skybox = Graphics.loadImage(System.currentDirectory().."/skybox.png")

-- Enabling shading and using it
RayCast3D.useShading(true)
RayCast3D.setDepth(300)

Graphics.init()
while true do

	-- Screen purging
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	
	-- Rendering scene
	if is3D then
		Graphics.initBlend(TOP_SCREEN,LEFT_EYE)
		Graphics.drawImage(0,0,skybox)
		RayCast3D.renderLeftScene(0,0)
		Graphics.termBlend()
		Graphics.initBlend(TOP_SCREEN,RIGHT_EYE)
		Graphics.drawImage(0,0,skybox)
		RayCast3D.renderRightScene(0,0)
		Graphics.termBlend()
	else
		Graphics.initBlend(TOP_SCREEN)
		Graphics.drawImage(0,0,skybox)
		RayCast3D.renderScene(0,0)
		Graphics.termBlend()
	end
	
	-- Getting current watched cell
	pl = RayCast3D.getPlayer()
	cell = RayCast3D.shoot(pl.x, pl.y, pl.angle)
	
	-- Rendering minimap
	Graphics.initBlend(BOTTOM_SCREEN)
	RayCast3D.renderMap(10, 80, 15)
	Graphics.fillRect(10 + cell.x * 15, 10 + cell.x * 15+15, 80 + cell.y * 15, 80 + cell.y * 15+15, Color.new(255,0,0, 100))
	Graphics.termBlend()
	
	-- Player and camera movements
	pad = Controls.read()
	if Controls.check(pad, KEY_DLEFT) then
		RayCast3D.rotateCamera(LEFT, cam_speed)
	end
	if Controls.check(pad, KEY_DRIGHT) then
		RayCast3D.rotateCamera(RIGHT, cam_speed)
	end
	if Controls.check(pad,KEY_DUP) then
		RayCast3D.movePlayer(FORWARD, pl_speed)
	end
	if Controls.check(pad,KEY_X) then
		RayCast3D.rotateCamera(FORWARD, cam_speed)
	end
	if Controls.check(pad,KEY_B) then
		RayCast3D.rotateCamera(BACK, cam_speed)
	end
	if Controls.check(pad,KEY_DDOWN) then
		RayCast3D.movePlayer(BACK, pl_speed)
	end
	if Controls.check(pad,KEY_START) then
		Graphics.freeImage(W)
		Graphics.freeImage(I)
		Graphics.freeImage(skybox)
		Graphics.term()
		System.exit()
	end
	if Controls.check(pad, KEY_L) then
		RayCast3D.movePlayer(LEFT, pl_speed)
	end
	if Controls.check(pad, KEY_R) then
		RayCast3D.movePlayer(RIGHT, pl_speed)
	end
	if Controls.check(pad, KEY_SELECT) and not Controls.check(oldpad, KEY_SELECT) then
	
		-- Change 3D setting and accuracy to prevent huge framedrops
		is3D = not is3D
		if is3D then
			Screen.enable3D()
			if System.getCpuSpeed() == 804 then
				RayCast3D.setAccuracy(2)
			else
				RayCast3D.setAccuracy(5)
			end
		else
			Screen.disable3D()
			if System.getCpuSpeed() == 804 then
				RayCast3D.setAccuracy(1)
			else
				RayCast3D.setAccuracy(3)
			end
		end
		
	end
	
	-- Screenshots
	if Controls.check(pad, KEY_Y) and not Controls.check(oldpad, KEY_Y) then
		dd,d,m,y = System.getDate()
		h,m,s = System.getTime()
		scr_name = "raycast3d_"..d.."_"..m.."_"..h.."_"..m.."_"..s..".jpg"
		System.takeScreenshot("/"..scr_name, true)
	end
	
	oldpad = pad
	
	-- Printing player info on the bottom screen
	Screen.debugPrint(0,0,"RayCast3D Engine v.0.2",0xFFFF00FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,15,"Tech Demo",0xFFFF00FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,60,"Minimap:",0xFF0000FF,BOTTOM_SCREEN)
	player = RayCast3D.getPlayer()
	Screen.debugPrint(0,210,"X: " .. player.x .. " | " .. "Y: " .. player.y,0xFF0000FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,225,"Angle: " .. player.angle,0xFF0000FF,BOTTOM_SCREEN)
	Screen.flip()
	Screen.waitVblankStart()
end