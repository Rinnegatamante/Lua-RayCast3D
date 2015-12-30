-------------------------------------------------
-- Ray-Casting Algorithm Tech-Demo for lpp-3ds --
-------------------------------------------------

-- Load RayCast3D Engine
dofile(System.currentDirectory().."/raycast3d.lua")

-- Map Details
wall_height = 64
tile_size = 64
map_width = 7
map_height = 6
map = {
	0,0,0,0,0,0,0,
	0,1,1,1,1,1,0,
	0,1,1,1,1,1,0,
	0,1,1,1,1,1,0,
	0,1,1,1,1,1,0,
	0,0,0,0,0,0,0
}

-- Player Speed
pl_speed = 5
cam_speed = 50

-- Setting up RayCast3D Engine
RayCast3D.setResolution(400, 240)
RayCast3D.setViewsize(60)
RayCast3D.setAccuracy(3)
RayCast3D.loadMap(map, map_width, map_height, tile_size, wall_height)
RayCast3D.spawnPlayer(227, 193, 300)

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
	if Controls.check(pad,KEY_DDOWN) then
		RayCast3D.movePlayer(BACK, pl_speed)
	end
	if Controls.check(pad,KEY_START) then
		error("So you want to restart?")
	end
	oldpad = pad
	
	-- Printing player info on the bottom screen
	Screen.debugPrint(0,0,"RayCast3D Engine v.0.1",0xFFFF00FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,15,"Tech Demo",0xFFFF00FF,BOTTOM_SCREEN)
	player = RayCast3D.getPlayer()
	Screen.debugPrint(0,60,"X: " .. player.x,0xFF0000FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,75,"Y: " .. player.y,0xFF0000FF,BOTTOM_SCREEN)
	Screen.debugPrint(0,90,"Angle: " .. player.angle,0xFF0000FF,BOTTOM_SCREEN)
	Screen.flip()
	Screen.waitVblankStart()
end