-- Thanks to Ubi, Schwarz, LRED and GOBJIuH for help --
-- Made by Drafu --

include("vec2.lua") -- Easier target finding. WIP

local ply = LocalPlayer()

local bone 	= {}
bone[1]	= "ValveBiped.Bip01_Head1"
bone[2] = "ValveBiped.Bip01_Neck1"
bone[3] = "ValveBiped.Bip01_Spine1"
bone[4] = "ValveBiped.Bip01_Pelvis"

local screen = {}
screen.w_c		= ScrW()/2
screen.h_c		= ScrH()/2
screen.center	= vec2(screen.w_c, screen.h_c)

local tables	= {}
tables.plyrs	= {}
tables.ents		= {}

local target = {}
target.locked = nil
target.active = 0

surface.CreateFont("Pixel", {font="TabLarge", size=13, weight=600, shadow=true})

local function Vec2Length(a,b)
	return (a - b):length()
end

local function GetPlayers()
	local tbl = {}
	local plyrs = player.GetAll()
	for _, o in pairs(plyrs) do 
		if o == ply or not o:Alive() or not IsValid(o) or not o then continue end
		tbl[_] = o
	end
	return tbl
end

local function GetEnts()
	local tbl = {}
	local entities = ents.GetAll()
	for _, v in pairs(entities) do 
		if 
			not (
				string.find(v:GetClass(), "weapon") or 
				string.find(v:GetClass(), "gun") or
				string.find(v:GetClass(), "food") or
				string.find(v:GetClass(), "drug") or 
				string.find(v:GetClass(), "melon") or 
				string.find(v:GetClass(), "money") or
				string.find(v:GetClass(), "spawned") or 
				string.find(v:GetClass(), "microwave") or
				string.find(v:GetClass(), "darkrp") or 
				string.find(v:GetClass(), "sent") or
				string.find(v:GetClass(), "print"))
			or 	string.find(v:GetClass(), "phys")
		then continue end
		tbl[_] = v
	end
	return tbl
end

local function SortAngDist(tbl)
	table.sort(tbl, function(a,b)
		if IsValid(a) and IsValid(b) and a:Alive() and b:Alive() then
			local vec2_apos = vec2(a:GetPos():ToScreen().x, a:GetPos():ToScreen().y)
			local vec2_bpos = vec2(b:GetPos():ToScreen().x, b:GetPos():ToScreen().y)
			return Vec2Length(vec2_apos, screen.center) < Vec2Length(vec2_bpos, screen.center)
		end
	end)
end

local function IsVisible(tar, tracebone)
	local tracer = {}
	if ply:GetShootPos() ~= nil and IsValid(tar) then
		tracer.start = ply:GetShootPos()
		tracer.endpos = tar:GetBonePosition(tar:LookupBone(tracebone))
		tracer.filter = { ply, ent }
		tracer.mask = MASK_SHOT
		local trace = util.TraceLine( tracer )
		if trace.Fraction >= 1 then return true 
		else return false end
	end
end

local function IsInLOS(tar, tracebone)
	return ply:IsLineOfSightClear(tar:GetBonePosition(tar:LookupBone(tracebone)))
end

local function BestTarget(tbl)
	for _,tar in pairs(tbl) do
		for _, tarbone in pairs(bone) do
			if IsInLOS(tar, tarbone) then
				return tar, tarbone
			else continue end
		end
	end
end

local function OnThink()
	tables.plyrs = GetPlayers()	
	SortAngDist(tables.plyrs)
	tables.ents = GetEnts()
end

local function OnKeyPress(tar, key)
	if tar == ply and key == 2048 and BestTarget(tables.plyrs) ~= nil then
		target.locked, target.aimbone = BestTarget(tables.plyrs)
		target.active =  1
	end
end

local function OnKeyRelease(tar, key)
	if tar == ply and key == 2048 and target.locked ~= nil then
		target.active = 0
		target.locked = nil
	end
end

local function DrawXHair()
	local traceent = ply:GetEyeTrace().Entity
	if IsValid(ply:GetEyeTrace().Entity) then
		if traceent:IsPlayer() then
			surface.SetDrawColor(team.GetColor(traceent:Team()))
		else
			surface.SetDrawColor(100,255,0,255)
		end
	else
		surface.SetDrawColor(255,255,255,255)
	end
	surface.DrawRect(screen.center.x-1, screen.center.y-1,2,2)
	surface.DrawRect(screen.center.x-4, screen.center.y-4,2,2)
	surface.DrawRect(screen.center.x+2, screen.center.y-4,2,2)
	surface.DrawRect(screen.center.x-4, screen.center.y+2,2,2)
	surface.DrawRect(screen.center.x+2, screen.center.y+2,2,2)
end

local function DrawPlyESP(tbl, ents)
	for k,v in pairs(tbl) do 
		if IsValid(v) and v:GetPos():Distance(ply:GetPos()) < 2000 then
			halo.Add({v}, team.GetColor(v:Team()), 1, 1, 1, true, true)
		end
		local drawcolor = team.GetColor(v:Team())
		local drawbonepos = v:GetBonePosition(v:LookupBone(bone[3])):ToScreen()
		surface.SetDrawColor(drawcolor)
		surface.DrawRect(drawbonepos.x, drawbonepos.y, 3,3)
		if v:GetPos():Distance(ply:GetPos()) < 2000 then
			draw.DrawText(v:Name(), "Pixel", drawbonepos.x, drawbonepos.y+5, drawcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		if v:GetPos():Distance(ply:GetPos()) < 750 then
			draw.DrawText(v:Health().."%", "Pixel", drawbonepos.x, drawbonepos.y+17, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.DrawText(team.GetName(v:Team()), "Pixel", drawbonepos.x, drawbonepos.y+29, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if(v:GetActiveWeapon():IsValid()) then
				draw.DrawText(v:GetActiveWeapon():GetClass(), "Pixel", drawbonepos.x, drawbonepos.y+41, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end

	
	for k2,v2 in pairs(tables.ents) do
		if IsValid(v2) and v2:GetPos():Distance(ply:GetPos()) < 25000 then
			halo.Add({v2}, Color(100,255,100), 1, 1, 1, true, true)
			if not string.find(v2:GetClass(), "weapon") and v2:GetPos():Distance(ply:GetPos()) < 50000 then
				draw.DrawText(v2:GetClass(), "Pixel", v2:GetPos():ToScreen().x, v2:GetPos():ToScreen().y, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
		
end

local function OnPaint()
	DrawXHair()
	DrawPlyESP(tables.plyrs, tables.ents)
end

hook.Add("HUDPaint", "OnPaint", OnPaint)
hook.Add("Think", "OnThink", OnThink)
hook.Add("KeyPress", "OnKeyPress", OnKeyPress)
hook.Add("KeyRelease", "OnKeyRelease", OnKeyRelease)

hook.Add("Move", "Aim", function()
	if target.active == 1 then
		ply:SetEyeAngles((target.locked:GetBonePosition(target.locked:LookupBone(target.aimbone)) - ply:GetShootPos()):Angle())
	end
end)
