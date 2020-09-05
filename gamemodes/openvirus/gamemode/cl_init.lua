-- Initialize the gamemode!

include( "cl_earlyfunctions.lua" )
include( "cl_killicons.lua" )
include( "cl_materials.lua" )
include( "cl_music.lua" )
include( "cl_scoreboard.lua" )

include( "shared.lua" )


-- ConVars
local enableScreenspaceEffects = CreateClientConVar( "ov_cl_screenspace_effects", 1, true, false )
local enableSoundDSPEffects = CreateClientConVar( "ov_cl_sound_dsp_effects", 1, true, false )
local enableGeigerCounter = CreateClientConVar( "ov_cl_geigercounter", 1, true, false )
local enableCameraRoll = CreateClientConVar( "ov_cl_camera_roll", 1, true, false )
local enableInfectedBlood = CreateClientConVar( "ov_cl_infected_blood", 1, true, false )


-- Called when the game is initialized
function GM:Initialize()

	-- Create this directory if it does not exist
	if ( !file.Exists( "openvirus", "DATA" ) ) then
	
		file.CreateDir( "openvirus" )
	
	end

	-- Create this directory if it does not exist
	if ( !file.Exists( "openvirus/client", "DATA" ) ) then
	
		file.CreateDir( "openvirus/client" )
	
	end

	-- Automatic help menu for first time
	if ( !file.Exists( "openvirus/client/seen_help_menu.txt", "DATA" ) ) then
	
		file.Write( "openvirus/client/seen_help_menu.txt", "Delete me if you want the help menu to appear automatically again." )
		hook.Call( "ShowHelp", GAMEMODE )
	
	end

	-- Hide scoreboard
	GAMEMODE.ShowScoreboard = false

end


-- Called after entities are created
function GM:InitPostEntity()

	-- Run this console command
	RunConsoleCommand( "r_radiosity", "4" )

	-- Seperate function for initializing sounds
	hook.Call( "InitializeSounds", GAMEMODE )

	-- Seperate function for initializing VGUI
	hook.Call( "InitializeVGUI", GAMEMODE )

end


-- Initialize the sounds and music
function GM:InitializeSounds()

	-- Allows music to loop
	hook.Call( "SetupMusicLooping", GAMEMODE )

	-- Waiting For Players music
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/wfp/", ROUNDMUSIC_WFP, "wav" )
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/wfp/", ROUNDMUSIC_WFP, "mp3" )

	-- PreRound music
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/pround/", ROUNDMUSIC_PREROUND, "wav" )
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/pround/", ROUNDMUSIC_PREROUND, "mp3" )

	-- Round music
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/inround/", ROUNDMUSIC_INROUND, "wav" )
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/inround/", ROUNDMUSIC_INROUND, "mp3" )

	-- Last Survivor music
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/laststanding/", ROUNDMUSIC_LASTSURVIVOR, "wav" )
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/laststanding/", ROUNDMUSIC_LASTSURVIVOR, "mp3" )

	-- Infected Win music
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/infected_win/", ROUNDMUSIC_INFECTEDWIN, "wav" )
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/infected_win/", ROUNDMUSIC_INFECTEDWIN, "mp3" )

	-- Survivors Win music
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/survivors_win/", ROUNDMUSIC_SURVIVORSWIN, "wav" )
	hook.Call( "AddMusicPath", GAMEMODE, "openvirus/music/survivors_win/", ROUNDMUSIC_SURVIVORSWIN, "mp3" )

	-- Call after we initialize the sounds
	hook.Call( "PostInitSounds", GAMEMODE )

	-- Send to the server we have initialized music
	net.Start( "ClientInitializedMusic" )
	net.SendToServer()

end


-- Called every frame
local infectedFlameMaterial = MATERIAL_INFECTED_FLAME_FRAMES[ 1 ]
local infectedFlameFrame = 0
local infectedFlameFrameUpdate = 0
function GM:Think()

	-- Update infected flame frames
	if ( infectedFlameFrameUpdate < CurTime() ) then
	
		infectedFlameFrameUpdate = CurTime() + 0.075
		if ( infectedFlameFrame >= #MATERIAL_INFECTED_FLAME_FRAMES ) then
		
			infectedFlameFrame = 1
			infectedFlameMaterial = MATERIAL_INFECTED_FLAME_FRAMES[ 1 ]
		
		else
		
			infectedFlameFrame = infectedFlameFrame + 1
			infectedFlameMaterial = MATERIAL_INFECTED_FLAME_FRAMES[ infectedFlameFrame ]
		
		end
	
	end

	-- Geiger Counter
	if ( enableGeigerCounter:GetBool() && ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) ) then
	
		if ( IsValid( LocalPlayer() ) && LocalPlayer():Alive() && !LocalPlayer():IsSpectating() ) then
		
			for _, ent in ipairs( ents.FindInSphere( LocalPlayer():GetPos(), 1024 ) ) do
			
				if ( IsValid( ent ) && ( ent:IsPlayer() && ent:Alive() && ( ent:Team() != LocalPlayer():Team() ) ) && ( !ent.geigerCounterCooldown || ( ent.geigerCounterCooldown < CurTime() ) ) ) then
				
					ent.geigerCounterCooldown = CurTime() + ( ent:GetPos():Distance( LocalPlayer():GetPos() ) / 1024 )
				
					if ( ent:GetPos():Distance( LocalPlayer():GetPos() ) <= 256 ) then
					
						surface.PlaySound( "player/geiger3.wav" )
					
					else
					
						surface.PlaySound( "player/geiger"..math.random( 1, 2 )..".wav" )
					
					end
				
				end
			
			end
		
		end
	
	end

end


-- Called each tick
local countdownText = {}
local countdownTimerStored = 0
local informationText = {}
function GM:Tick()

	-- Check for players around us to infect
	if ( IsValid( LocalPlayer() ) && LocalPlayer():Alive() && LocalPlayer():IsInfected() && LocalPlayer():GetInfectionStatus() ) then
	
		local traceData = { start = LocalPlayer():GetPos(), endpos = LocalPlayer():GetPos(), filter = team.GetPlayers( TEAM_INFECTED ) }
		local trace = util.TraceEntity( traceData, LocalPlayer() )
	
		if ( trace.Hit ) then
		
			local ent = trace.Entity
			if ( IsValid( ent ) && ent:IsPlayer() && ent:Alive() && ent:IsSurvivor() ) then
			
				net.Start( "ClientsideInfect" )
					net.WriteEntity( ent )
				net.SendToServer()
			
			end
		
		end
	
	end

	-- Lerp calculation for Countdown Text and avoid frame stuff
	for k, v in pairs( countdownText ) do
	
		local xAdd = math.Clamp( ( ( v.time - CurTime() ) - ( v.timeSet - 0.5 ) ) / 0.5, 0, 1 ) * ScrW()
		local xMinus = ( ( 0.5 - math.Clamp( v.time - CurTime(), 0, 0.5 ) ) / 0.5 ) * ScrW()
	
		v.x = ( ScrW() / 2 ) + xAdd - xMinus
		if ( v.lerp ) then
		
			v.x = ( v.x * 0.1 ) + ( v.lerp.x * 0.9 )
		
		end
		v.lerp = v.lerp || {}
		v.lerp.x = v.x
	
	end

	-- Lerp calculation for Information Text and avoid frame stuff
	for k, v in pairs( informationText ) do
	
		local xAdd = math.Clamp( ( ( v.time - CurTime() ) - ( v.timeSet - 0.5 ) ) / 0.5, 0, 1 ) * ScrW()
		local xMinus = ( ( 0.5 - math.Clamp( v.time - CurTime(), 0, 0.5 ) ) / 0.5 ) * ScrW()
	
		v.x = ( ScrW() / 2 ) + xAdd - xMinus
		v.y = ( ScrH() / 2 ) + 60 + ( 40 * k )
		if ( v.lerp ) then
		
			v.x = ( v.x * 0.15 ) + ( v.lerp.x * 0.85 )
			v.y = ( v.y * 0.3 ) + ( v.lerp.y * 0.7 )
		
		end
		v.lerp = v.lerp || {}
		v.lerp.x = v.x
		v.lerp.y = v.y
	
	end

	-- Manage the timer countdown here
	if ( ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) && IsRoundTimeActive() ) then
	
		local countdownTimerRounded = math.Round( GetCurrentRoundTime() )
		local countdownTimerText = {}
	
		if ( ( countdownTimerRounded == 15 ) && ( countdownTimerRounded != countdownTimerStored ) ) then
		
			countdownTimerStored = countdownTimerRounded
		
			countdownTimerText = {}
			countdownTimerText.text = "15 SECONDS LEFT"
			countdownTimerText.color = Color( 255, 0, 0 )
			countdownTimerText.time = CurTime() + 4
			countdownTimerText.timeSet = 4
		
			table.insert( countdownText, countdownTimerText )
			surface.PlaySound( "buttons/bell1.wav" )
		
		elseif ( ( ( countdownTimerRounded > 0 ) && ( countdownTimerRounded <= 5 ) ) && ( countdownTimerRounded != countdownTimerStored ) ) then
		
			countdownTimerStored = countdownTimerRounded
		
			countdownTimerText = {}
			countdownTimerText.text = countdownTimerRounded
			countdownTimerText.color = Color( 255, 255, 255 )
			countdownTimerText.time = CurTime() + 1.5
			countdownTimerText.timeSet = 1.5
		
			table.insert( countdownText, countdownTimerText )
			surface.PlaySound( "buttons/bell1.wav" )
		
		end
	
	end

end


-- Called after the player think function
function GM:PlayerPostThink( ply )

	-- Dynamic light
	if ( IsValid( ply ) && ply:Alive() && ply:IsInfected() && ply:GetInfectionStatus() ) then
	
		infectedLight = DynamicLight( ply:EntIndex() )
		if ( infectedLight ) then
		
			infectedLight.brightness = 1
			infectedLight.decay = 500
			infectedLight.dietime = CurTime() + 2
			infectedLight.pos = ply:GetBonePosition( ply:LookupBone( "ValveBiped.Bip01_Spine2" ) || 0 )
			infectedLight.size = 128
			infectedLight.r = ply:GetColor().r
			infectedLight.g = ply:GetColor().g
			infectedLight.b = ply:GetColor().b
		
		end
	
	end

end


-- Get some information text
function SendInformationText( len )

	local infoText = {}
	infoText.text = net.ReadString()
	infoText.color = net.ReadColor()

	local timeAdd = net.ReadInt( 4 ) + 1
	infoText.time = CurTime() + timeAdd
	infoText.timeSet = timeAdd

	table.insert( informationText, infoText )

end
net.Receive( "SendInformationText", SendInformationText )


-- Get damage values and put them on the screen
local damageValues = {}
function SendDamageValue( len )

	local damageValue = {}
	damageValue.dmg = net.ReadInt( 16 )
	damageValue.pos = net.ReadVector()
	damageValue.time = CurTime() + 3
	damageValue.timeSet = 3

	table.insert( damageValues, damageValue )

end
net.Receive( "SendDamageValue", SendDamageValue )


-- Called when a HUD element wants to be drawn
function VirusHUDShouldDraw( hud )

	-- Block these HUDs
	local block_huds = { CHudHealth = true, CHudBattery = true, CHudAmmo = true, CHudSecondaryAmmo = true }

	if ( block_huds[ hud ] ) then
	
		return false
	
	end

	-- Hide the crosshair for thirdperson
	if ( IsValid( LocalPlayer() ) && LocalPlayer():ShouldDrawLocalPlayer() && ( hud == "CHudCrosshair" ) ) then
	
		return false
	
	end

end
hook.Add( "HUDShouldDraw", "VirusHUDShouldDraw", VirusHUDShouldDraw )


-- HUDPaint
local weaponSelectionName = ""
local weaponSelectionNameTime = 0
function GM:HUDPaint()

	-- ///
	-- The HUD stuff is not final and will possibly be changed in the future
	-- ///

	-- If cl_drawhud is 0 or we are spectator
	if ( !GetConVar( "cl_drawhud" ):GetBool() ) then return; end

	-- Draw a text for WFP session
	if ( IsRoundState( ROUNDSTATE_WAITING ) ) then
	
		local alpha = ( math.cos( CurTime() ) / 1 ) * 255
		if ( alpha < 0 ) then alpha = alpha * -1; end
	
		draw.SimpleTextOutlined( "WAITING FOR PLAYERS", "DermaLarge", ScrW() / 2, ScrH() / 1.5, Color( 255, 255, 255, alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, alpha ) )
	
	end

	-- Damage values
	for k, v in pairs( damageValues ) do
	
		local addZ = 32 - ( ( ( v.time - CurTime() ) / v.timeSet ) * 32 )
		local alpha = ( math.Clamp( v.time - CurTime(), 0, 0.5 ) / 0.5 ) * 255
		draw.SimpleTextOutlined( tostring( "-"..v.dmg ), "Trebuchet18", v.pos:ToScreen().x, ( v.pos + Vector( 0, 0, addZ ) ):ToScreen().y, Color( 255, 255, 255, alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, alpha ) )
	
		if ( v.time < CurTime() ) then
		
			table.remove( damageValues, k )
		
		end
	
	end

	-- Weapon Selection
	if ( IsValid( LocalPlayer() ) && LocalPlayer():Alive() && LocalPlayer():IsSurvivor() && ( weaponSelectionNameTime > CurTime() ) ) then
	
		local alpha = math.Clamp( weaponSelectionNameTime - CurTime(), 0, 1 ) * 255
		draw.SimpleTextOutlined( "#"..weaponSelectionName, "TargetID", ScrW() / 2, ScrH() / 2 - 60, Color( 255, 255, 255, alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, alpha ) )
	
	end

	-- Countdown Text
	for k, v in pairs( countdownText ) do
	
		-- Lerp stuff
		v.x = v.x || ( ScrW() / 2 )
	
		-- Draw text
		local alphaAdd = math.Clamp( ( ( v.time - CurTime() ) - ( v.timeSet - 0.5 ) ) / 0.5, 0, 1 ) * 255
		local alphaMinus = ( ( 0.5 - math.Clamp( v.time - CurTime(), 0, 0.5 ) ) / 0.5 ) * 255
		draw.SimpleTextOutlined( v.text, "DermaLarge", v.x, ScrH() / 2 + 60, Color( v.color.r, v.color.g, v.color.b, v.color.a - alphaAdd - alphaMinus ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, v.color.a - alphaAdd - alphaMinus ) )
	
		-- Delete when time is up
		if ( v.time < CurTime() ) then
		
			table.remove( countdownText, k )
		
		end
	
	end

	-- Information Text
	for k, v in pairs( informationText ) do
	
		-- Lerp stuff
		v.x = v.x || ( ScrW() / 2 )
		v.y = v.y || ( ( ScrH() / 2 ) + 60 + ( 40 * k ) )
	
		-- Draw text
		local alphaAdd = math.Clamp( ( ( v.time - CurTime() ) - ( v.timeSet - 0.5 ) ) / 0.5, 0, 1 ) * 255
		local alphaMinus = ( ( 0.5 - math.Clamp( v.time - CurTime(), 0, 0.5 ) ) / 0.5 ) * 255
		draw.SimpleTextOutlined( v.text, "CloseCaption_Normal", v.x, v.y, Color( v.color.r, v.color.g, v.color.b, v.color.a - alphaAdd - alphaMinus ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, v.color.a - alphaAdd - alphaMinus ) )
	
		-- Delete when time is up
		if ( v.time < CurTime() ) then
		
			table.remove( informationText, k )
		
		end
	
	end

	-- Ammo Counter
	if ( IsValid( LocalPlayer() ) && LocalPlayer():Alive() && IsValid( LocalPlayer():GetActiveWeapon() ) && ( LocalPlayer():Team() == TEAM_SURVIVOR ) ) then
	
		local ammocounter_primaryclip = LocalPlayer():GetActiveWeapon():Clip1().." /"
		if ( LocalPlayer():GetActiveWeapon():Clip1() < 0 ) then ammocounter_primaryclip = "" end
		local ammocounter_primarycount = ""
		if ( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() > 0 ) then ammocounter_primarycount = " "..LocalPlayer():GetAmmoCount( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() ).." " end
		local ammocounter_secondarycount = ""
		if ( LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType() > 0 ) then ammocounter_secondarycount = "| "..LocalPlayer():GetAmmoCount( LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType() ) end
	
		draw.SimpleTextOutlined( ammocounter_primaryclip..ammocounter_primarycount..ammocounter_secondarycount, "DermaLarge", ScrW() - 15, ScrH() - 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color( 0, 0, 0, 255 ) )
	
	end

	-- Paint death notices
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )

end


-- Called when a player sends a message
function VirusOnPlayerChat( ply )

	if ( IsValid( ply ) ) then chat.PlaySound() end

end
hook.Add( "OnPlayerChat", "VirusOnPlayerChat", VirusOnPlayerChat )


-- Called after when rendering opaque renderables
function GM:PostPlayerDraw( ply )

	-- Begin 3D TargetID
	if ( IsValid( ply ) && ply:Alive() && ( ply:IsSurvivor() || ply:IsInfected() ) && ( ply:GetPos():Distance( LocalPlayer():GetPos() ) <= 512 ) && ply:IsLineOfSightClear( LocalPlayer() ) && ( ply != LocalPlayer() ) ) then
	
		cam.Start3D2D( ply:GetPos(), Angle( 0, LocalPlayer():EyeAngles().y - 90, 90 ), 0.25 )
		
			local alpha = 255 - ( math.Clamp( ply:GetPos():Distance( LocalPlayer():GetPos() ) / 412, 0, 1 ) * 255 )
			draw.SimpleText( ply:Name(), "DermaLarge", 80, -210, Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
			local playerName = "WAITING"
			if ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then
			
				if ( ply:IsSurvivor() ) then
				
					playerName = ""
				
				elseif ( ply:IsInfected() ) then
				
					playerName = "INFECTED"
				
				end
			
			end
		
			draw.SimpleText( playerName, "Trebuchet24", 80, -180, Color( 127.5, 127.5, 127.5, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
		cam.End3D2D()
	
	end

	-- Infected flame
	if ( IsValid( ply ) && ply:Alive() && ply:GetInfectionStatus() ) then
	
		cam.Start3D2D( ply:GetPos(), Angle( 0, EyeAngles().y - 90, 90 ), 0.5 )
		
			local red, green, blue = 180, 255, 0
			if ( ply:GetEnragedStatus() ) then
			
				red, green, blue = 255, 255, 255
			
			end
		
			surface.SetDrawColor( red, green, blue, 255 )
			surface.SetMaterial( infectedFlameMaterial )
			surface.DrawTexturedRect( -50, -292, 100, 300 )
		
		cam.End3D2D()
	
	end

	-- Infected player health
	if ( IsValid( LocalPlayer() ) && IsValid( ply ) && ( LocalPlayer() == ply ) ) then
	
		if ( LocalPlayer():Alive() && LocalPlayer():IsInfected() && ( LocalPlayer():GetNWInt( "InfectedLastHurt", 0 ) > CurTime() ) ) then
		
			cam.Start3D2D( LocalPlayer():GetPos(), Angle( 0, LocalPlayer():EyeAngles().y - 270, 90 ), 0.25 )
			
				local playerHealthBar = ( LocalPlayer():Health() / LocalPlayer():GetMaxHealth() ) * 198
				local colorAlpha = math.Clamp( ( LocalPlayer():GetNWInt( "InfectedLastHurt", 0 ) - CurTime() ) / 0.5, 0, 1 ) * 200
				surface.SetDrawColor( 0, 0, 0, colorAlpha )
				surface.DrawRect( 80, -250, 16, 200 )
				surface.SetDrawColor( 255, 127.5, 0, colorAlpha )
				surface.DrawRect( 81, -249 + ( 198 - playerHealthBar ), 14, playerHealthBar )
			
			cam.End3D2D()
		
		end
	
	end

end


-- Called when the player view is calculated
function GM:CalcView( ply, origin, angles, fov, znear, zfar )

	local Vehicle = ply:GetVehicle()
	local Weapon = ply:GetActiveWeapon()

	local view = {}
	view.origin = origin
	view.angles = angles
	view.fov = fov
	view.znear = znear
	view.zfar = zfar
	view.drawviewer = false

	if ( IsValid( Vehicle ) ) then return hook.Run( "CalcVehicleView", Vehicle, ply, view ); end

	if ( drive.CalcView( ply, view ) ) then return view; end

	player_manager.RunClass( ply, "CalcView", view )

	-- Give the active weapon a go at changing the viewmodel position
	if ( IsValid( Weapon ) ) then

		local func = Weapon.CalcView
		if ( func ) then
		
			view.origin, view.angles, view.fov = func( Weapon, ply, origin * 1, angles * 1, fov )
		
		end

	end

	-- Infected thirdperson
	if ( IsValid( ply ) && ply:Alive() && ( ply:IsInfected() || IsRoundState( ROUNDSTATE_WAITING ) ) ) then
	
		local tracepos = {}
		tracepos.start = origin
		tracepos.endpos = origin - ( ply:GetAimVector() * 128 ) + Vector( 0, 0, 16 )
		tracepos.filter = player.GetAll()
		tracepos.mins = Vector( -4, -4, -4 )
		tracepos.maxs = Vector( 4, 4, 4 )
	
		local tracepos = util.TraceHull( tracepos )
	
		view.origin = tracepos.HitPos
		view.angles = angles
		view.fov = fov
		view.znear = znear
		view.zfar = zfar
		view.drawviewer = true
	
	end

	-- Survivor firstperson
	if ( enableCameraRoll:GetBool() && IsValid( ply ) && ply:Alive() && ply:IsOnGround() && ply:IsSurvivor() && !view.drawviewer ) then
	
		view.origin = origin
		view.angles = Angle( angles.p, angles.y, angles.r + ( ply:EyeAngles():Right():Dot( ply:GetVelocity() ) / ply:GetMaxSpeed() ) * 6 )
		view.fov = fov
		view.znear = znear
		view.zfar = zfar
		view.drawviewer = false
	
	end

	return view

end


-- Called when a key is pressed
function GM:PlayerBindPress( ply, key, pressed )

	-- Adrenaline shortcut
	if ( ply:HasWeapon( "weapon_ov_adrenaline" ) && ( key == "+menu_context" ) ) then
	
		local plyWeapon = ply:GetWeapon( "weapon_ov_adrenaline" )
		
		ply:ConCommand( "invwep "..plyWeapon:GetClass() )
	
		weaponSelectionName = plyWeapon:GetClass()
		weaponSelectionNameTime = CurTime() + 2
	
		surface.PlaySound( "common/wpn_hudoff.wav" )
	
	end

	-- Switch to the last weapon used
	if ( key == "+menu" ) then
	
		ply:ConCommand( "lastinv" )
	
	end

	return false

end


-- Render Screenspace Effects
function GM:RenderScreenspaceEffects()

	if ( enableScreenspaceEffects:GetBool() ) then
	
		-- Last Survivor
		if ( ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) && IsValid( LocalPlayer() ) && LocalPlayer():Alive() && LocalPlayer():IsSurvivor() && ( team.NumPlayers( TEAM_SURVIVOR ) <= 1 ) ) then
		
			DrawBloom( 0.75, 2, 9, 9, 1, 1, 1, 1, 1 )
		
		end

		-- Adrenaline effect
		if ( IsValid( LocalPlayer() ) && LocalPlayer():Alive() && LocalPlayer():IsSurvivor() && LocalPlayer():GetAdrenalineStatus() ) then
		
			DrawMotionBlur( 0.25, 0.75, 0.01 )
			DrawSharpen( 1.1, 1.1 )
			DrawToyTown( 1.1, ScrH() / 2 )
		
		end
	
		-- Preparing for the next round
		if ( IsRoundState( ROUNDSTATE_ENDROUND ) ) then
		
			if ( IsRoundTimeActive() ) then
			
				local colour = math.Clamp( GetCurrentRoundTime() / 15, 0, 1 )
				DrawColorModify( { [ "$pp_colour_contrast" ] = 1, [ "$pp_colour_colour" ] = colour } )
			
			else
			
				DrawColorModify( { [ "$pp_colour_contrast" ] = 1, [ "$pp_colour_colour" ] = 0 } )
			
			end
		
		end
	
	end

end


-- Emitted sounds
function GM:EntityEmitSound( data )

	-- Adrenaline effect
	if ( ( data.Entity != game.GetWorld() ) && enableSoundDSPEffects:GetBool() && IsValid( LocalPlayer() ) && LocalPlayer():Alive() && LocalPlayer():IsSurvivor() && LocalPlayer():GetAdrenalineStatus() ) then
	
		data.DSP = 58
		return true
	
	end

end


-- Basic Help VGUI
function GM:ShowHelp()

	local helpframe = vgui.Create( "DFrame" )
	helpframe:SetSize( 640, 480 )
	helpframe:SetDraggable( false )
	helpframe:SetBackgroundBlur( true )
	helpframe:SetTitle( "Help" )

	local helppanel = vgui.Create( "DPanel", helpframe )
	helppanel:Dock( FILL )

	local helplabel = vgui.Create( "DLabel", helppanel )
	helplabel:SetPos( 2, 2 )
	helplabel:SetColor( Color( 0, 0, 0, 255 ) )
	helplabel:SetText( "How to play open Virus:\n\nThe gamemode is essentially zombie survival but with fast-paced rounds.\nSurvivors must survive the entire round (typically 90 seconds) in order to win.\nInfected must spread the virus to all survivors within the given time in order to win.\n\nPlayers CANNOT use basic movement keys such as crouching, jumping or zooming.\nSurvivors can use C to quick-switch to adrenaline.\nSurvivors should work as a team.\nInfected must be aware of SLAMs.\nInfected must run into players to infect them." )
	helplabel:SizeToContents()

	local helplabel_size_x, helplabel_size_y = helplabel:GetSize()
	helpframe:SetSize( helplabel_size_x + 4, helplabel_size_y + 40 )
	helpframe:Center()
	helpframe:MakePopup()

end
