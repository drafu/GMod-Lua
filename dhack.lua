-- Thanks to Ubi, Schwarz, LRED and GOBJIuH for help --
-- Made by Drafu --

include("vec2.lua") -- Easier target finding. WIP

local ply = LocalPlayer()
local DHack = {}
DHack.Bone = {}
DHack.Bone.Head = "ValveBiped.Bip01_Head1"
local scrw_center = ScrW()/2
local scrh_center = ScrH()/2
local vec2_screen = vec2(scrw_center, scrh_center)

DHack.GetAll = {}

render.SetBlend(0.2)

surface.CreateFont("Trebuchet19", {font="TabLarge", size=12, weight=600})

hook.Add("Think", "DHackGetAllUpdate", function()
	for _, o in pairs(player.GetAll()) do 
	   if o == ply then continue end
	   DHack.GetAll[_] = o
	
	table.sort(DHack.GetAll, function(a,b)
		a, b = a or b, b or a
		local vec2_apos = vec2(a:GetPos():ToScreen().x, a:GetPos():ToScreen().y)
		local vec2_bpos = vec2(b:GetPos():ToScreen().x, b:GetPos():ToScreen().y)
		return vec2_apos - vec2_screen < vec2_bpos - vec2_screen end)
end)
	
local function IsVisible(ent)
	local tracer = {}
	if(ply:GetShootPos() ~= nil and IsValid(ent)) then
		tracer.start = ply:GetShootPos()
		tracer.endpos = ent:GetBonePosition(ent:LookupBone(DHack.Bone.Head))
		tracer.filter = { ply, ent }
		tracer.mask = MASK_SHOT
		local trace = util.TraceLine( tracer )
		if trace.Fraction >= 1 then return true 
		else return false end
	end
end

hook.Add("Move", "DHackAim", function()
	if ply:KeyDown(IN_ATTACK2) then
		for k,v in pairs(DHack.GetAll) do	
			if(IsVisible(v)) then
				local head = v:LookupBone(DHack.Bone.Head)
				local headpos,targetheadang = v:GetBonePosition(head)
				ply:SetEyeAngles((headpos - ply:GetShootPos()):Angle()) -- We still need a good velocity fix
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
			-- as long as we see halo of weapon, it may be useless
		end
	end
end)

hook.Add("HUDPaint", "DHackGlow", function()
		
	for k,v in pairs(DHack.GetAll) do
		if(v:GetPos():Distance(ply:GetPos()) < 5000) then
			halo.Add({v}, team.GetColor(v:Team()), 1, 1, 5, true, true)
		end
	end
		
	for k,v in pairs(ents.GetAll()) do
		if v:GetPos():Distance(ply:GetPos()) < 16000 then
			if
				string.find(v:GetClass(), "weapon") or
				string.find(v:GetClass(), "gun") and 
				not string.find(v:GetClass(), "phys")
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
				string.find(v:GetClass(), "darkrp") or 
				string.find(v:GetClass(), "sent") or
				string.find(v:GetClass(), "print")
			then
				halo.Add({v}, Color(0,255,0), 1, 1, 5, true, true)
				draw.DrawText(v:GetClass(), "Trebuchet19", v:GetPos():ToScreen().x, v:GetPos():ToScreen().y, Color(0,255,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
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
