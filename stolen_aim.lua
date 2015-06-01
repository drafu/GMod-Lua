/*
	cunt [STEAM_0:0:40143824 | 63.141.253.124:27005]
	hake/aimbot.lua (10932 bytes)
*/
/*
====================
Name: aimbot.lua
Purpose: Aimbot?
====================
*/

--[ ConVars ]--
CreateConVar( "aim_auto", 1 )
CreateConVar( "aim_friendly", 1 )
CreateConVar( "aim_ignoreadmins", 0 )
CreateConVar( "aim_ignorefriends", 1 )
CreateConVar( "aim_ignoretraitors", 0 )
CreateConVar( "aim_ignoreinnocents", 0 )
CreateConVar( "aim_prediction", 1 )
CreateConVar( "aim_spawnprotection", 1 )
CreateConVar( "aim_obbcenter", 0 )
CreateConVar( "aim_fov", 360 )
CreateConVar( "aim_offset", 0 )
CreateConVar( "aim_anti", 0 )
CreateConVar( "aim_nospread", 1 )
CreateConVar( "aim_holdtarget", 0 )
CreateConVar( "aim_noshake", 1 )
CreateConVar( "aim_ignorebots", 1 )

require( "nyx" )
_nyx.Init()

function SetViewAngles( cmd, ang )
	return R.CUserCmd.SetViewAngles( cmd, ang )
end

function GetWeaponVector( value, typ )
local s = ( -value )      
	if ( typ == true ) then
		s = ( -value )
	elseif ( typ == false ) then
		s = ( value )
	else
		s = ( value )
	end
	return Vector( s, s, s )
end
 
function GetCone( wep )
	if !IsValid( wep ) then return 0 end
	
	if HL2Cones[ wep:GetClass() ] then return HL2Cones[ wep:GetClass() ] end
	if NormalCones[ wep.Base ] then return wep.Cone or wep.Primary.Cone or 0 end
	if CustomCones[ wep.Base ] then return CustomCones[ wep.Base ]( wep ) end
	
	local Cone = wep.Cone
	
	if !Cone then
		Cone = wep.Primary and wep.Primary.Cone or 0
	end
	
	return Cone
end

NormalCones 			= {
	[ "weapon_cs_base" ]	= true,
	[ "weapon_sh_base" ] 	= true,
	[ "weapon_zs_base" ] 	= true,
}

HL2Cones 				= {
	[ "weapon_pistol" ] 	= Vector( 0.0100, 0.0100, 0.0100 ),
	[ "weapon_smg1" ] 		= GetWeaponVector( 0.04362, true, true ),
	[ "weapon_ar2" ]		= Vector( 0.02618, 0.02618, 0.02618 ),
	[ "weapon_shotgun" ]	= Vector( 0.08716, 0.08716, 0.08716 ),
}

CustomCones 			= {
	[ "weapon_sh_base" ]	= function( wep )
								local Cone = wep.Primary.Cone
								local Recoil = WeaponRecoil[ wep:GetClass() ]
								local IsSniper = wep.Sniper and 2 or 1								
								local Stance = wep.Owner:IsOnGround() and wep.Owner:Crouching() and 10
								or !wep.Sprinting and wep.Owner:IsOnGround() and 15
								or wep.Walking and wep.Owner:IsOnGround() and 20
								or !wep.Owner:IsOnGround() and 25
								or wep.Primary.Ammo == "buckshot" and 0
									
								local WepType = wep.Sniper and 8
								or wep.SMG and 2
								or wep.Pistol and 2
								or wep.Primary.Ammo == "buckshot" and 0
								or 1.6								
								local Shotgun = wep.Primary.Ammo == "buckshot" and wep.Primary.Cone or 0			
								if wep:GetIronsights() then
									return Cone
								else
									return Cone * Recoil * Stance * WepType + Shotgun
								end
							end,
	[ "weapon_zs_base" ] = function( wep )
								local Cone = wep.Cone or wep.Primary.Cone or 0		
								if LocalPlayer():GetVelocity():Length() > 20 then
									return wep.ConeMoving
								end									
								if LocalPlayer():Crouching() then
									return wep.ConeCrouching
								end		
								return Cone
							end,
}


function PredictSpread( cmd, ang )
local w = LocalPlayer():GetActiveWeapon()
local vecCone, valCone = Vector( 0, 0, 0 )
	if ( w && w:IsValid() && ( type( w.Initialize ) == "function" ) ) then
		valCone = GetCone( w )                    
		if ( type( valCone ) == "number" ) then
			vecCone = Vector( -valCone, -valCone, -valCone )                      
		elseif ( type( valCone ) == "Vector" ) then
			vecCone = valCone * -1     
		elseif bit.band( cmd:GetButtons(), IN_SPEED ) or bit.band( cmd:GetButtons(), IN_JUMP ) then
			vecCone = valCone + (cone * 2 )                        
		end
	else
		if ( w:IsValid() ) then
			local class = w:GetClass()
			if ( CustomCones[ class ] ) then
				vecCone = CustomCones[ class ]
			elseif ( HL2Cones[ class ] ) then
				vecCone = HL2Cones[ class ]
			end
		end
	end
return ( _nyx.RemoveSpread( cmd, ang, vecCone ) ):Angle()
end

FireBulletCone = Vector( 0, 0, 0 )
R.Entity.FireBullets = Detour( R.Entity.FireBullets, function( ent, shot )
	FireBulletCone = shot.Spread
	return Detours[ R.Entity.FireBullets ]( ent, shot )
end )

function GetTarget()
local target
if target == nil then 
	target = LocalPlayer() 
else 
	target = target 
end
local ply = LocalPlayer()
local angA, angB = 0
local x, y = ScrW(), ScrH()
local distance = math.huge
	for k, e in pairs( player.GetAll() ) do
		if ( e != LocalPlayer() && e:Alive() && IsVisible( e ) && ValidTarget( e ) && InFov( e ) ) then
		
			local ePos, oldPos, myAngV = e:EyePos():ToScreen(), target:EyePos():ToScreen(), ply:GetAngles()
			local thedist = e:GetPos():DistToSqr( LocalPlayer():GetPos() )
			
			angA = math.Dist( x / 2, y / 2, oldPos.x, oldPos.y )
			angB = math.Dist( x / 2, y / 2, ePos.x, ePos.y )
			
			if (thedist < distance) then
				distance = thedist;
				target = e;
			end	
			
		end
	end
return target
end


function GetPos( ent )
local Eyes = ent:LookupAttachment( "eyes" )
local Pos
	if ( GetVar( "aim_obbcenter" ) == 1 or ent:EyeAngles().p < -89 ) then -- anti anti aim
		Pos = ent:LocalToWorld( ent:OBBCenter() )	
	elseif Eyes ~= 0 then
		Eyes = ent:GetAttachment( Eyes )
		if ( Eyes && Eyes.Pos ) then
			Pos = Eyes.Pos, Eyes.Ang
		end
	else
		Pos = ent:LookupBone( "ValveBiped.Bip01_Head1" )
	end
return Pos
end

function Prediction( pos , pl )
	if IsValid( pl ) and type( pl:GetVelocity() ) == "Vector" and pl.GetPos and type( pl:GetPos() ) == "Vector" then
		local distance = LocalPlayer():GetPos():Distance( pl:GetPos() )
		local weapon = ( LocalPlayer().GetActiveWeapon and ( IsValid( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon():GetClass() ) )	
		if weapon and Prediction[ weapon ] then
			local time = distance / Prediction[ weapon ]
			return pos + pl:GetVelocity() * time
		end
	end
	return pos
end

function  IsVisible( e )
	local trace = util.TraceLine( {
		start = LocalPlayer():GetShootPos(),
		endpos = GetPos( e ),
		filter = { LocalPlayer(), e },
		mask = MASK_SHOT + CONTENTS_WINDOW
	} )
	if (( trace.Fraction >= 0.99 )) then return true end
	return false
end

function InFov( e )
	if( GetVar( "aim_fov" ) != 360 ) then
		local lpang = LocalPlayer():GetAngles()
		local ang = ( e:GetPos() - LocalPlayer():EyePos() ):Angle()
		local ady = math.abs( math.NormalizeAngle( lpang.y - ang.y ) )
		local adp = math.abs( math.NormalizeAngle( lpang.p - ang.p ) )
		if( ady > GetVar( "aim_fov" ) || adp > GetVar( "aim_fov" ) ) then return false end
	end
	return true
end

function ValidTarget( e )
	local ply = LocalPlayer()
	if ( !IsValid( e ) ) then return false end
	if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() ) || e == ply ) then return false end
	if ( e:IsPlayer() && e:InVehicle() ) then return false end
	if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
	if ( e:IsNPC() ) then return false end
	if ( GetVar( "aim_ignorebots" ) == 1 && e:IsBot() ) then return false end
	if ( !InFov( e ) ) then return false end
	if ( e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	if string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) then return false end
	if ( GetVar( "aim_friendly" ) == 0 && e:Team() == LocalPlayer():Team()) then return false end 	
	if ( GetVar( "aim_ignoreadmins" ) == 1 && IsAdmin( e ) ) then return false end	
	if ( GetVar( "aim_spawnprotection" ) == 1 && e:GetColor( r, g, b, a ).a < 255 or LocalPlayer():GetColor( r, g, b, a ).a < 255 ) then return false end
	if ( GetVar( "aim_ignorefriends" ) == 1 && e:GetFriendStatus() == "friend" ) then return false end
	if ( IsTTT() && GetVar( "aim_ignoreinnocents" ) == 1 && !table.HasValue( Traitors, e:Nick() ) ) then return false end
	if ( IsTTT() && IsTraitor( e ) && GetVar( "aim_ignoretraitors" ) == 1 ) then return false end
	return true
end

function ShouldAim()
	if Aimon == 1 then
		return true
	else
		return false
	end
end

HasTarget = false
NoSpreadAngle = Angle( 0, 0, 0 )
function Aimbot( ucmd )

NoSpreadAngle = ucmd:GetViewAngles()
Target = GetTarget()
Angles = ucmd:GetViewAngles()

local ply = LocalPlayer()

	if ( ShouldAim() && Target != ply && Target != nil ) then
		local Aimspot
		HasTarget = true	
		if GetVar( "aim_prediction" ) == 1 then
			Aimspot = Prediction( GetPos( Target ) ) - Vector( 0, 0, GetVar( "aim_offset" ) )
			Aimspot = Aimspot + Target:GetVelocity() * ( 1 / 66 ) - LocalPlayer():GetVelocity() * ( 1 / 66 )
		else
			Aimspot = ( GetPos( Target ) ) - Vector( 0, 0, GetVar( "aim_offset" ) )
			Aimspot = Aimspot + Target:GetVelocity() / 50 - LocalPlayer():GetVelocity() / 50
		end
		
		Angles = ( Aimspot - LocalPlayer():GetShootPos() ):GetNormal():Angle()	
		
		if GetVar( "aim_noshake" ) == 1 then
			NoSpreadAngle = Angles
		else
			NoSpreadAngle = ucmd:GetViewAngles()
		end
		
		if GetVar( "aim_nospread" ) == 1 then
			Spread = PredictSpread( ucmd, Angle( Angles.p, Angles.y, 0 ) )
		else
			Spread = Angle( Angles.p, Angles.y, 0 )
		end
		
		Angles.p = math.NormalizeAngle( Angles.p )
		Angles.y = math.NormalizeAngle( Angles.y )
		
		if GetVar( "aim_anti" ) == 1 then
			ucmd:SetViewAngles( Angle( -Spread.p + 900, Spread.y + 180, 0 ) )
		else
			SetViewAngles( ucmd, Spread )
		end

		if GetVar( "aim_auto" ) == 1 then
			ucmd:SetButtons( bit.bor( ucmd:GetButtons(), IN_ATTACK ) ) 
		end			
	else
		HasTarget = false
	end
end

GAMEMODE = table.Copy( GAMEMODE )
function GAMEMODE:CalcView( ply, origin, angles, fov )
	local view = GAMEMODE.CalcView( self, ply, origin, angles, fov ) || {}
	view.angles = NoSpreadAngle
return view
end

-- Static anti-aim, go fuck yourself
function AntiAim( cmd, u )
ViewAngles = cmd:GetViewAngles()
	if ( GetVar( "aim_anti" ) == 1 && !LocalPlayer():KeyDown( IN_ATTACK ) && Target == nil ) then
		cmd:SetViewAngles( Angle( -181, cmd:GetViewAngles().y, 0 ) )
	end
end


--[ Commands ]--
AddCommand( "+hake", function() Aimon = 1 end )
AddCommand( "-hake", function() Aimon = 0 end )

--[ Hooks ]--
AddHook( "CreateMove", AntiAim )
AddHook( "CreateMove", Aimbot )
