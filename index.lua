-------------------------------------------------
-- Ray-Casting Algorithm Tech-Demo for lpp-3ds --
-------------------------------------------------

-- Load RayCast3D Engine
dofile(System.currentDirectory().."/raycast3d.lua")

-- Map Details
wall_height = 32
tile_size = 64
map_width = 7
map_height = 6
W = Graphics.loadImage(System.currentDirectory().."/wall.png")
map = {
	W,W,W,W,W,W,W,
	W,0,0,0,0,0,W,
	W,0,W,W,W,0,W,
	W,0,0,W,0,0,W,
	W,0,0,W,W,0,W,
	W,W,W,W,W,W,W
}

-- Player Speed
pl_speed = 5
cam_speed = 50

-- Setting up RayCast3D Engine
RayCast3D.setResolution(400, 240)
RayCast3D.setViewsize(60)
RayCast3D.loadMap(map, map_width, map_height, tile_size, wall_height)
RayCast3D.spawnPlayer(80, 80, 300)
RayCast3D.enableSky(true)

-- Set accuracy depending on console
System.setCpuSpeed(804)
if System.getCpuSpeed() == 804 then
	RayCast3D.setAccuracy(1)
else
	RayCast3D.setAccuracy(3)
end

-- Setting floor and sky colors
ceil_c = Color.new(83, 69, 59, 255)
floor_c = Color.new(25, 17, 15, 255)
RayCast3D.setSkyColor(ceil_c)
RayCast3D.setFloorColor(floor_c)

Graphics.init()
while true do

	-- Screen purging
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	
	-- Rendering scene
	Graphics.initBlend(TOP_SCREEN)
	RayCast3D.renderScene(0,0)
	Graphics.termBlend()
	
	-- Rendering minimap
	Graphics.initBlend(BOTTOM_SCREEN)
	RayCast3D.renderMap(50, 120, 15)
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
		Graphics.term()
		System.exit()
	end
	if Controls.check(pad, KEY_L) then
		RayCast3D.movePlayer(LEFT, pl_speed)
	end
	if Controls.check(pad, KEY_R) then
		RayCast3D.movePlayer(RIGHT, pl_speed)
	end
	oldpad = pad
	
	-- Printing player info on the bottom screen
	Screen.debugPrint(0,0,"RayCast3D Engine v.0.2",0xFFFF00FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,15,"Tech Demo",0xFFFF00FF,BOTTOM_SCREEN)
	player = RayCast3D.getPlayer()
	Screen.debugPrint(0,60,"X: " .. player.x,0xFF0000FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,75,"Y: " .. player.y,0xFF0000FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,90,"Angle: " .. player.angle,0xFF0000FF,BOTTOM_SCREEN)
	Screen.flip()
	Screen.waitVblankStart()
end