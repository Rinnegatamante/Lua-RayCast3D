-------------------------------------------------
-- Ray-Casting Algorithm Tech-Demo for lpp-3ds --
-------------------------------------------------

-- Load RayCast3D Engine
dofile("app0:/raycast3d.lua")

-- Map Details
wall_height = 64
tile_size = 64
map_width = 15
map_height = 6
acc = 3
W = Graphics.loadImage("app0:/wall.png")
I = Graphics.loadImage("app0:/wall2.png")
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
RayCast3D.setResolution(960, 544)
RayCast3D.setViewsize(60)
RayCast3D.loadMap(map, map_width, map_height, tile_size, wall_height)
RayCast3D.spawnPlayer(80, 80, 90)

-- Set accuracy depending on console
System.setCpuSpeed(444)
RayCast3D.setAccuracy(acc)

-- Set 3D variable
is3D = false

-- Using an image as skybox
RayCast3D.enableFloor(false)
RayCast3D.setFloorColor(Color.new(29,14,7))
skybox = Graphics.loadImage("app0:/skybox.png")

-- Enabling shading and using it
RayCast3D.useShading(true)
RayCast3D.setDepth(300)

while true do
	
	-- Rendering scene
	Graphics.initBlend()
	Screen.clear()
	Graphics.drawImage(0,0,skybox)
	RayCast3D.renderScene(0,0)
	Graphics.termBlend()
	
	-- Player and camera movements
	pad = Controls.read()
	if Controls.check(pad, SCE_CTRL_LEFT) then
		RayCast3D.rotateCamera(LEFT, cam_speed)
	end
	if Controls.check(pad, SCE_CTRL_RIGHT) then
		RayCast3D.rotateCamera(RIGHT, cam_speed)
	end
	if Controls.check(pad, SCE_CTRL_UP) then
		RayCast3D.movePlayer(FORWARD, pl_speed)
	end
	if Controls.check(pad, SCE_CTRL_TRIANGLE) then
		RayCast3D.rotateCamera(FORWARD, cam_speed)
	end
	if Controls.check(pad, SCE_CTRL_CROSS) then
		RayCast3D.rotateCamera(BACK, cam_speed)
	end
	if Controls.check(pad, SCE_CTRL_DOWN) then
		RayCast3D.movePlayer(BACK, pl_speed)
	end
	if Controls.check(pad,SCE_CTRL_START) then
		Graphics.freeImage(W)
		Graphics.freeImage(I)
		Graphics.freeImage(skybox)
		System.exit()
	end
	if Controls.check(pad, SCE_CTRL_LTRIGGER) then
		RayCast3D.movePlayer(LEFT, pl_speed)
	end
	if Controls.check(pad, SCE_CTRL_RTRIGGER) then
		RayCast3D.movePlayer(RIGHT, pl_speed)
	end
	if Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT) then
	
		-- Change accuracy 
		acc=acc+1
		if acc > 8 then
			acc = 1
		end
		RayCast3D.setAccuracy(acc)
		
	end
	
	oldpad = pad
	
	Screen.flip()

end