local ply = LocalPlayer()
local DHack = {}
DHack.FOV = 90
DHack.Dist = 64000
DHack.Bone = "ValveBiped.Bip01_Head1"
DHack.AimEnabled = 1

surface.CreateFont("Trebuchet19", {font="TabLarge", size=12, weight=600})

DHack.GetAll = player.GetAll()

local function SortGetAll()
	for k, ply1 in pairs(DHack.GetAll) do
		if ply1 == ply then table.remove(DHack.GetAll,k) continue end
		
		for k,ply2 in pairs(DHack.GetAll) do
  			dist1 = ply1:GetPos():Distance(ply:GetPos())
  			dist2 = ply2:GetPos():Distance(ply:GetPos())
   			if dist1 > dist2 then
    			ply1, ply2 = ply2, ply1
			end
		end
	end
end

hook.Add("Think", "DHackRefreshTable", function()
	DHack.GetAll = player.GetAll()
	SortGetAll()
end)
	
local function IsValidModel(ent)
	if(ent:LookupBone("ValveBiped.Bip01_Head1") ~= nil and ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1")) ~= nil) then return true
	else return false end
end

local function IsVisible(ent)
	local tracer = {}
	if(ply:GetShootPos() ~= nil and IsValid(ent)) then
		tracer.start = ply:GetShootPos()
		if IsValidModel(ent) then
			tracer.endpos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
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
	if(DHack.AimEnabled == 1 and ply:KeyDown(IN_ATTACK2)) then
		for k,v in pairs(DHack.GetAll) do
			if(IsVisible(v)) then
				if(IsValidModel(v)) then
					local head = v:LookupBone("ValveBiped.Bip01_Head1")
					local headpos,targetheadang = v:GetBonePosition(head)
					ply:SetEyeAngles((headpos - ply:GetShootPos()):Angle())
				else
					ply:SetEyeAngles((v:GetPos() + Vector(0,0,50) - ply:GetShootPos()):Angle())
				end
			end
		end
	end
end)

hook.Add("HUDPaint", "DHackESP", function()
	for k,v in pairs(DHack.GetAll) do
		if(v:GetPos():Distance(ply:GetPos()) < 2500) then
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

hook.Add("HUDPaint", "DHackChams", function()
	for k,v in pairs(player.GetAll()) do
			cam.Start3D(EyePos(), EyeAngles())
				/*v:SetMaterial("models/debug/debugwhite")
				v:SetColor(Color(20, 71, 244, 255))
				render.MaterialOverride("models/debug/debugwhite")
				render.SuppressEngineLighting( false )
				render.SetColorModulation( 0, 1, 0 )*/
				render.SetBlend( 0.2 )
				--v:DrawModel()
				/*if GetConVarNumber("dead_chams_wire") >= 1 then
					v:SetMaterial("models/wireframe")
					render.MaterialOverride("models/wireframe")
					v:DrawModel()
				end*/
			cam.End3D()
	end
end)

hook.Add("HUDPaint", "DHackGlowPly", function()
	for k,v in pairs(player.GetAll()) do
			halo.Add({v}, team.GetColor(v:Team()), 1, 1, 5, true, true)
	end
end)

hook.Add("HUDPaint", "DHackGlowEnts", function()
	for k,v in pairs(ents.GetAll()) do
		if(string.find(v:GetClass(), "weapon_")) then
			halo.Add({v}, Color(255,0,0), 1, 1, 5, true, true)
			/*cam.Start3D(EyePos(), EyeAngles())
				v:DrawModel()
			cam.End3D()*/
		end
	end
end)

hook.Add("HUDPaint", "DHackGlowDarkRP", function()
	for k,v in pairs(ents.GetAll()) do
		if(
			string.find(v:GetClass(), "food") or
			string.find(v:GetClass(), "drug") or 
			--string.find(v:GetClass(), "gun") or
			string.find(v:GetClass(), "melon") or 
			string.find(v:GetClass(), "money") or
			string.find(v:GetClass(), "spawned") or 
			string.find(v:GetClass(), "microwave") or
			v:GetModel() == "models/props/cs_assault/money.mdl" or
			string.find(v:GetClass(), "darkrp_") or 
			string.find(v:GetClass(), "sent_")
		) then
			halo.Add({v}, Color(0,255,0), 1, 1, 5, true, true)
			/*cam.Start3D(EyePos(), EyeAngles())
				v:DrawModel()
			cam.End3D()*/
		end
	end
end)

hook.Add("HUDPaint", "DHackXHair", function()
	--if(IsValid(ply:GetEyeTrace().Entity) ) then
		--surface.SetDrawColor(team.GetColor(ply:GetEyeTrace().Entity:Team()))
	--else
		surface.SetDrawColor(Color(255,255,255,255))
	--end
	surface.DrawRect(ScrW()/2-1, ScrH()/2-4, 2, 2, 0)
	surface.DrawRect(ScrW()/2-4, ScrH()/2-1, 2, 2, 0)
	surface.DrawRect(ScrW()/2-1, ScrH()/2+2, 2, 2, 0)
	surface.DrawRect(ScrW()/2+2, ScrH()/2-1, 2, 2, 0)
end)
