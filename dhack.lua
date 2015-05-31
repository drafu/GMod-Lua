-- Thanks to Ubi, Schwarz, LRED and GOBJIuH for help --
-- Made by Drafu --

include("vec2.lua")

local ply = LocalPlayer()
local DHack = {}
DHack.Bone = {}
DHack.Bone.Head = "ValveBiped.Bip01_Head1"
local scrw_center = ScrW()/2
local scrh_center = ScrH()/2
DHack.GetAll = {}

surface.CreateFont("Trebuchet19", {font="TabLarge", size=12, weight=600})

for _, o in pairs(player.GetAll()) do 
   if o == ply then continue end
   DHack.GetAll[_] = o
end

local I = 0
table.sort(DHack.GetAll, function(a,b)
	a, b = a or b, b or a
	local a_pos, b_pos = a:GetPos():ToScreen(), b:GetPos():ToScreen()
	return (scrw_center - a_pos.x)^2 + (scrh_center - a_pos.y)^2 < (scrw_center - b_pos.x)^2 + (scrh_center - b_pos.y)^2
end)

local function IsValidModel(ent)
	if(ent:LookupBone(DHack.Bone.Head) ~= nil and ent:GetBonePosition(ent:LookupBone(DHack.Bone.Head)) ~= nil) then return true
	else return false end
end

local function IsVisible(ent)
	local tracer = {}
	if(ply:GetShootPos() ~= nil and IsValid(ent)) then
		tracer.start = ply:GetShootPos()
		if IsValidModel(ent) then
			tracer.endpos = ent:GetBonePosition(ent:LookupBone(DHack.Bone.Head))
		else
			tracer.endpos = ent:GetPos()
		end
		tracer.filter = { ply, ent }
		tracer.mask = MASK_SHOT
		local trace = util.TraceLine( tracer )
		if trace.Fraction >= 1 then return true 
		else return false end
	end
end

hook.Add("Move", "DHackAim", function()
	if(ply:KeyDown(IN_ATTACK2)) then
		for k,v in pairs(DHack.GetAll) do
			if(IsVisible(v)) then
				if(IsValidModel(v)) then
					local head = v:LookupBone(DHack.Bone.Head)
					local headpos,targetheadang = v:GetBonePosition(head)
					ply:SetEyeAngles((headpos + ((v:GetVelocity() * 0.00672724)-(ply:GetVelocity()*0.0087775)) - ply:GetShootPos()):Angle())
				else
					ply:SetEyeAngles((v:GetPos() + Vector(0,0,50) - ply:GetShootPos()):Angle())
				end
			end
		end
	end
end)

hook.Add("HUDPaint", "DHackESP", function()
	for k,v in pairs(DHack.GetAll) do
		if(v:GetPos():Distance(ply:GetPos()) < 100000) then
			local ESP = v:EyePos():ToScreen()
			draw.DrawText(v:Name(), "Trebuchet19", ESP.x, ESP.y -46, team.GetColor(v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.DrawText("Team: "..team.GetName(v:Team()), "Trebuchet19", ESP.x, ESP.y -23, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.DrawText("Health: " .. v:Health(), "Trebuchet19", ESP.x, ESP.y -34, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			if(v:GetActiveWeapon():IsValid()) then
				draw.DrawText("Weapon: " .. v:GetActiveWeapon():GetClass(), "Trebuchet19", ESP.x, ESP.y -12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			end
		end
	end
end)

--[[ DOES THIS PART NEED A HOOK OR JUST FINE ONCE? ]]--
hook.Add("RenderScreenspaceEffects", "DHackChams", function()
	for k,v in pairs(DHack.GetAll) do
			cam.Start3D(EyePos(), EyeAngles())
				render.SetBlend( 0.2 )
			cam.End3D()
	end
end)
--[[ ############################################# ]]--

hook.Add("HUDPaint", "DHackGlow", function()
		
	for k,v in pairs(DHack.GetAll) do
		if(v:GetPos():Distance(ply:GetPos()) < 5000) then
			halo.Add({v}, team.GetColor(v:Team()), 1, 1, 5, true, true)
		end
	end
		
	for k,v in pairs(ents.GetAll()) do
		if v:GetPos():Distance(ply:GetPos()) < 2500 then
			if
				string.find(v:GetClass(), "weapon") or 
				string.find(v:GetClass(), "gun")
			then
				halo.Add({v}, Color(255,0,0), 1, 1, 5, true, true)
			end
			if
				string.find(v:GetClass(), "food") or
				string.find(v:GetClass(), "drug") or 
				string.find(v:GetClass(), "melon") or 
				string.find(v:GetClass(), "money") or
				string.find(v:GetClass(), "spawned") or 
				string.find(v:GetClass(), "microwave") or
				v:GetModel() == "models/props/cs_assault/money.mdl" or
				string.find(v:GetClass(), "darkrp_") or 
				string.find(v:GetClass(), "sent_")
			then
				halo.Add({v}, Color(0,255,0), 1, 1, 5, true, true)
			end
		end
	end

end)
hook.Add("HUDPaint", "DHackXHair", function()
	--if(IsValid(ply:GetEyeTrace().Entity) ) then
		--surface.SetDrawColor(team.GetColor(ply:GetEyeTrace().Entity:Team()))
	--else
		surface.SetDrawColor(Color(255,255,255,255))
	--end
	surface.DrawRect(scrw_center-1, scrh_center-4, 2, 2, 0)
	surface.DrawRect(scrw_center-4, scrh_center-1, 2, 2, 0)
	surface.DrawRect(scrw_center-1, scrh_center+2, 2, 2, 0)
	surface.DrawRect(scrw_center+2, scrh_center-1, 2, 2, 0)
end)
