--[[
 This file is part of:
   ______            _____           _   ___________ 
   | ___ \          /  __ \         | | |____ |  _  \
   | |_/ /__ _ _   _| /  \/ __ _ ___| |_    / / | | |
   |    // _` | | | | |    / _` / __| __|   \ \ | | |
   | |\ \ (_| | |_| | \__/\ (_| \__ \ |_.___/ / |/ / 
   \_| \_\__,_|\__, |\____/\__,_|___/\__\____/|___/  
               __/ |                                
              |___/            by Rinnegatamante

 Lua Game Engine made to create 3D games using Ray-Casting
 algorithm.
]]--

-- Movements globals
LEFT = 0
RIGHT = 1
FORWARD = 2
BACK = 3

-- Screen Globals (Default: TOP_SCREEN size)
local vwidth = 400 -- Pixels
local vheight = 240 -- Pixels
local viewsize = 60 -- Degrees

-- Map Globals
local wall_height = 64
local tile_size = 64
local tile_shift = 6
local map_width = 1
local map_height = 1
local map = { 
	0 
}

-- Player Globals
local pl_x = 0
local pl_y = 0
local pl_angle = 0


-- Angles Globals (DON'T EDIT)
local ANGLE60 = vwidth
local ANGLE30 = ANGLE60 >> 1
local ANGLE15 = ANGLE30 >> 1
local ANGLE5 = math.ceil(ANGLE30 / 6)
local ANGLE10 = ANGLE5 << 1
local ANGLE0 = 0
local ANGLE90 = ANGLE30 * 3
local ANGLE180 = ANGLE90 << 1
local ANGLE270 = ANGLE90 * 3
local ANGLE360 = ANGLE180 << 1

-- PreCalculated Trigonometric Tables (DON'T EDIT)
local sintable = {}
local sintable2 = {}
local costable = {}
local costable2 = {}
local tantable = {}
local tantable2 = {}
local fishtable = {}
local xsteptable = {}
local ysteptable = {}

-- Internal Globals (DON'T EDIT)
local ycenter = vheight >> 1
local dist_proj =  (vwidth >> 1) / math.tan(math.rad(viewsize >> 1))
local accuracy = 2
local floors = true
local sky = false
RayCast3D = {}

-- Internal Functions (DON'T EDIT)
local function arc2rad(val)
	return (val*math.pi)/ANGLE180
end
local function rad2arc(val)
	return (val*ANGLE180)/math.pi
end
local function WallRender(x,y,stride,top_wall,wh)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall,y+top_wall+wh,0xFF0000FF)
end
local function WallFloorRender(x,y,stride,top_wall,wh)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall,y+top_wall+wh,0xFF0000FF)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall+wh,vheight,0xFFFFFFFF)
end
local function WallSkyRender(x,y,stride,top_wall,wh)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall,y+top_wall+wh,0xFF0000FF)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall,0,0xFFFF00FF)
end
local function WallFloorSkyRender(x,y,stride,top_wall,wh)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall,y+top_wall+wh,0xFF0000FF)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall+wh,vheight,0xFFFFFFFF)
	Graphics.fillRect(x+stride,x+stride+accuracy,y+top_wall,0,0xFFFF00FF)
end
local function ResetAngles()
	ANGLE60 = vwidth
	ANGLE30 = ANGLE60 >> 1
	ANGLE15 = ANGLE30 >> 1
	ANGLE5 = math.ceil(ANGLE30 / 6)
	ANGLE10 = ANGLE5 << 1
	ANGLE0 = 0
	ANGLE90 = ANGLE30 * 3
	ANGLE180 = ANGLE90 << 1
	ANGLE270 = ANGLE90 * 3
	ANGLE360 = ANGLE180 << 1
	i = 0
	sintable = {}
	sintable2 = {}
	costable = {}
	costable2 = {}
	tantable = {}
	tantable2 = {}
	fishtable = {}
	xsteptable = {}
	ysteptable = {}
	while i <= ANGLE360 do
		v = arc2rad(i) + 0.0001 -- avoid asymptotics values
		sintable[i] = math.sin(v)
		sintable2[i] = (1.0/(sintable[i]))
		costable[i] = math.cos(v)
		costable2[i] = (1.0/(costable[i]))
		tantable[i] = sintable[i] / costable[i]
		tantable2[i] = (1.0/(tantable[i]))
		if (i >= ANGLE90 and i < ANGLE270) then
			xsteptable[i] = 0.0 - math.abs(tile_size / tantable[i])
		else
			xsteptable[i] = math.abs(tile_size / tantable[i])
		end
		if (i >= ANGLE0 and i < ANGLE180) then
			ysteptable[i] = math.abs(tile_size * tantable[i])
		else
			ysteptable[i] = 0.0 - math.abs(tile_size * tantable[i])
		end
		i = i + 1
	end
	i = -ANGLE30
	while i <= ANGLE30 do
		v = arc2rad(i)
		fishtable[i+ANGLE30] =  1.0 / math.cos(v)
		i = i + 1
	end
end
local function ResetProjections()
	dist_proj =  (vwidth >> 1) / math.tan(math.rad(viewsize >> 1))
end
local function ResetEngine()
	ResetAngles()
	ResetProjections()
	ycenter = vheight >> 1
end

--[[setResolution: Sets renderer resolution]]--
function RayCast3D.setResolution(w, h)

	-- Change screen resolution
	vwidth = w
	vheight = h
	
	-- Reset engine with new values
	ResetEngine()
	
end

--[[setViewsize: Sets FOV]]--
function RayCast3D.setViewsize(angle)
	viewsize = angle
	ResetProjections()
end

--[[renderScene: Render viewport scene using GPU]]--
function RayCast3D.renderScene(x, y)
	if floors then
		if sky then
			RenderRay = WallFloorSkyRender
		else
			RenderRay = WallFloorRender
		end
	else
		if sky then
			RenderRay = WallSkyRender
		else
			RenderRay = WallRender
		end
	end
	castArc = pl_angle - ANGLE30
	if castArc < 0 then
		castArc = ANGLE360 + castArc
	end
	stride = 0
	while stride < vwidth do
		if (castArc > ANGLE0 and castArc < ANGLE180) then
			hgrid = ((pl_y >> tile_shift) << tile_shift) + tile_size
			dist_next_hgrid = tile_size
			xtmp = tantable2[castArc]*(hgrid-pl_y)
			xinter = xtmp + pl_x
		else
			hgrid = ((pl_y >> tile_shift) << tile_shift)
			dist_next_hgrid = 0 - tile_size
			xtmp = tantable2[castArc]*(hgrid-pl_y)
			xinter = xtmp + pl_x
			hgrid = hgrid - 1
		end
		if (castArc == ANGLE0 or castArc == ANGLE180) then -- Prevent asymptotics values
			dist_hgrid_hit = math.huge
		else
			dist_next_xinter = xsteptable[castArc]
			while true do
				xgrid_index = math.ceil(xinter) >> tile_shift
				ygrid_index = hgrid >> tile_shift
				if (xgrid_index >= map_width or ygrid_index >= map_height or xgrid_index < 0 or ygrid_index < 0) then
					dist_hgrid_hit = math.huge
					break
				elseif (map[ygrid_index*map_width+xgrid_index+1] ~= 1) then
					dist_hgrid_hit = (xinter - pl_x) * costable2[castArc]
					break
				else
					xinter = xinter + dist_next_xinter
					hgrid = hgrid + dist_next_hgrid
				end
			end
		end
		if castArc < ANGLE90 or castArc > ANGLE270 then
			vgrid = tile_size + ((pl_x >> tile_shift) << tile_shift)
			dist_next_vgrid = tile_size
			ytmp = tantable[castArc]*(vgrid - pl_x)
			yinter = ytmp + pl_y
		else
			vgrid = (pl_x >> tile_shift) << tile_shift
			dist_next_vgrid = 0 - tile_size
			ytmp = tantable[castArc]*(vgrid-pl_x)
			yinter = ytmp + pl_y
			vgrid = vgrid - 1
		end
		if (castArc == ANGLE90 or castArc == ANGLE270) then
			dist_vgrid_hit = math.huge
		else
			dist_next_yinter = ysteptable[castArc]
			while true do
				xgrid_index = vgrid >> tile_shift
				ygrid_index = math.ceil(yinter) >> tile_shift
				if (xgrid_index >= map_width or ygrid_index >= map_height or xgrid_index < 0 or ygrid_index < 0) then
					dist_vgrid_hit = math.huge
					break
				elseif (map[ygrid_index*map_width+xgrid_index+1] ~= 1) then
					dist_vgrid_hit = (yinter-pl_y)*sintable2[castArc]
					break
				else
					yinter = yinter + dist_next_yinter
					vgrid = vgrid + dist_next_vgrid
				end
			end
		end
		if (dist_hgrid_hit < dist_vgrid_hit) then
			dist = dist_hgrid_hit
		else
			dist = dist_vgrid_hit
		end
		dist = dist / fishtable[stride]
		wh = math.ceil(wall_height * (dist_proj / dist))
		bot_wall = ycenter + math.ceil(wh * 0.5)
		top_wall = vheight-bot_wall
		if (bot_wall >= vheight) then
			bot_wall = vheight - 1
		end
		RenderRay(x,y,stride,top_wall,wh)
		stride = stride + accuracy
		castArc = castArc + accuracy
		if castArc >= ANGLE360 then
			castArc = castArc - ANGLE360
		end
	end
end

--[[renderMinimap: Render 2D map scene using GPU]]--
function RayCast3D.renderMap(x, y, width)
	u = 0
	while (u < map_width) do
		v = 0
		while (v < map_height) do
			if (map[v*map_width+u+1]==0) then
				color = 0xFF0000FF
			else
				color = 0xFFFFFFFF
			end
			xp = x + u * width
			yp = y + v * width
			Graphics.fillRect(xp, xp + width, yp, yp + width, color)
			v = v + 1
		end
		u = u + 1
	end
	xpp = x + (pl_x / tile_size) * width
	ypp = y + (pl_y / tile_size) * width
	Graphics.fillRect(xpp,xpp+2,ypp,ypp+2,0xFFFF00FF)
end

--[[enableFloors: Enable floors rendering]]--
function RayCast3D.enableFloors(val)
	floors = val
end

--[[enableSky: Enable sky rendering]]--
function RayCast3D.enableSky(val)
	floors = val
end

--[[spawnPlayer: Spawn player on the map]]--
function RayCast3D.spawnPlayer(x, y, angle)
	pl_x = x
	pl_y = y
	pl_angle = math.ceil(rad2arc(math.rad(angle)))
end

--[[getPlayer: Gets player status]]--
function RayCast3D.getPlayer()
	return {["x"] = pl_x, ["y"] = pl_y, ["angle"] = math.deg(arc2rad(pl_angle))}
end

--[[movePlayer: Moves player]]--
function RayCast3D.movePlayer(dir, speed)
	xmov = math.ceil(costable[pl_angle] * speed)
	ymov = math.ceil(sintable[pl_angle] * speed)
	if dir == FORWARD then
		pl_x = pl_x + xmov
		pl_y = pl_y + ymov
	elseif dir == BACK then
		pl_x = pl_x - xmov
		pl_y = pl_y - ymov
	end
end

--[[rotateCamera: Rotates camera]]--
function RayCast3D.rotateCamera(dir, speed)
	if dir == LEFT then
		pl_angle = pl_angle - speed
		if pl_angle < ANGLE0 then
			pl_angle = math.ceil(pl_angle + ANGLE360)
		end
	elseif dir == RIGHT then
		pl_angle = pl_angle + speed
		if pl_angle >= ANGLE360 then
			pl_angle = math.ceil(pl_angle - ANGLE360)
		end
	end
end

--[[loadMap: Loads a map in the engine]]--
function RayCast3D.loadMap(map_table, m_width, m_height, t_size, w_height)
	wall_height = w_height
	if t_size ~= tile_size then
		tile_size = t_size
		tmp = 2
		i = 1
		while tmp < tile_size do
			tmp = bit32.lshift(tmp, 1)
			i = i + 1
		end
		if tmp ~= tile_size then
			error("Map tile-size must be 2^n pixels.")
		end
		tile_shift = i
		ResetAngles()
	end
	map_width = m_width
	map_height = m_height
	map = map_table
end

--[[setAccuracy: Sets renderer accuracy]]--
function RayCast3D.setAccuracy(val)
	accuracy = val
end