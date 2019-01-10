-- Initialize the gamemode!

include( "shared.lua" )
include( "player.lua" )

AddCSLuaFile( "cl_earlyfunctions.lua" )
AddCSLuaFile( "cl_killicons.lua" )
AddCSLuaFile( "cl_language.lua" )
AddCSLuaFile( "cl_materials.lua" )
AddCSLuaFile( "cl_music.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )


-- ConVars
local useCSSHands = CreateConVar( "ov_sv_survivor_css_hands", 1, FCVAR_ARCHIVE, "Hands will be forced as CS:S hands for survivors." )
local enablePlayerRadar = CreateConVar( "ov_sv_enable_player_radar", 1, FCVAR_NOTIFY, "Players can see the radar." )
local enablePlayerRanking = CreateConVar( "ov_sv_enable_player_ranking", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Announce player ranks during the game." )
local enableMysteryWeapons = CreateConVar( "ov_sv_survivor_mystery_weapons", 0, FCVAR_NOTIFY, "Survivors get their weapons when the round begins instead of on spawn." )


-- Called when the game is initialized
function GM:Initialize()

	-- Player weapon loadout
	weaponLoadout = {}

	-- Network Strings
	util.AddNetworkString( "UpdateRoundState" )
	util.AddNetworkString( "UpdateRoundNumber" )
	util.AddNetworkString( "UpdateRoundTime" )
	util.AddNetworkString( "UpdateMaxRounds" )
	util.AddNetworkString( "UpdateMinimumPlayers" )
	util.AddNetworkString( "UpdatePreventEnraged" )
	util.AddNetworkString( "UpdatePlayerRadar" )
	util.AddNetworkString( "UpdatePlayerRanking" )
	util.AddNetworkString( "ClientsideInfect" )
	util.AddNetworkString( "ClientInitializedMusic" )
	util.AddNetworkString( "SetRoundMusic" )
	util.AddNetworkString( "SendInformationText" )
	util.AddNetworkString( "SendDamageValue" )

	-- Set the default deploy speed to 1
	game.ConsoleCommand( "sv_defaultdeployspeed 1\n" )

	-- Set alltalk to 1
	game.ConsoleCommand( "sv_alltalk 1\n" )

	-- ConCommands
	concommand.Add( "invwep", function( ply, cmd, args, argstring )
	
		if ( IsValid( ply ) && ply:Alive() && ply:IsSurvivor() ) then
		
			ply:SelectWeapon( argstring )
		
		end
	
	end )

end


-- Can players hear another player using voice
function GM:PlayerCanHearPlayersVoice( listener, talker )

	return true

end


-- Client has sent us information that they want to infect someone
function ClientsideInfect( len, ply )

	if ( !IsRoundState( ROUNDSTATE_INROUND ) && !IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then return; end

	local target_ply = net.ReadEntity()
	if ( IsValid( ply ) && ply:Alive() && ply:IsInfected() && ply:GetInfectionStatus() && IsValid( target_ply ) && target_ply:IsPlayer() && target_ply:Alive() && target_ply:IsSurvivor() ) then
	
		-- Is the player visible (validate check)
		if ( ply:Visible( target_ply ) ) then
		
			target_ply:InfectPlayer( ply )
		
		end
	
	end

end
net.Receive( "ClientsideInfect", ClientsideInfect )


-- Client has initialized
function ClientInitializedMusic( len, ply )

	if ( !IsRoundState( ROUNDSTATE_ENDROUND ) && IsValid( ply ) ) then
	
		SetRoundMusic( ROUNDMUSIC_STOP, ply )
	
		if ( IsRoundState( ROUNDSTATE_WAITING ) ) then
		
			SetRoundMusic( ROUNDMUSIC_WFP, ply )
		
		elseif ( IsRoundState( ROUNDSTATE_PREROUND ) ) then
		
			SetRoundMusic( ROUNDMUSIC_PREROUND, ply )
		
		elseif ( IsRoundState( ROUNDSTATE_INROUND ) ) then
		
			SetRoundMusic( ROUNDMUSIC_INROUND, ply )
		
		elseif ( IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then
		
			SetRoundMusic( ROUNDMUSIC_LASTSURVIVOR, ply )
		
		end
	
	end

end
net.Receive( "ClientInitializedMusic", ClientInitializedMusic )


-- Global function to set music
function SetRoundMusic( int, ply )

	-- Make sure it is a number
	if ( !isnumber( int ) ) then return; end

	-- Send to a specific player instead
	if ( IsValid( ply ) && ply:IsPlayer() ) then
	
		net.Start( "SetRoundMusic" )
			net.WriteInt( int, 4 )
		net.Send( ply )
	
		return
	
	end

	net.Start( "SetRoundMusic" )
		net.WriteInt( int, 4 )
	net.Broadcast()

end


-- Called every tick
local playerInFirstPlace = Player( 0 )
local playerInSecondPlace = Player( 0 )
local playerInThirdPlace = Player( 0 )
function GM:Think()

	-- Infected cannot infect players instantly when they spawn
	if ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) || IsRoundState( ROUNDSTATE_ENDROUND ) ) then
	
		for _, ply in ipairs( team.GetPlayers( TEAM_INFECTED ) ) do
		
			if ( IsValid( ply ) && ply:Alive() && !ply:GetInfectionStatus() && ( ply.timeInfectionStatus < CurTime() ) ) then
				
				ply:SetInfectionStatus( true )
				
			end
		
		end
	
	end

	-- Player adrenaline status needs to run out eventually
	if ( IsRoundState( ROUNDSTATE_PREROUND ) || IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) || IsRoundState( ROUNDSTATE_ENDROUND ) ) then
	
		for _, ply in ipairs( team.GetPlayers( TEAM_SURVIVOR ) ) do
		
			if ( IsValid( ply ) && ply:GetAdrenalineStatus() && ( ply.timeAdrenalineStatus < CurTime() ) ) then
			
				ply:SetAdrenalineStatus( false )
			
			end
		
		end
	
	end

	-- Enraged players must be cancelled
	if ( !GetPreventEnraged() && ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_ENDROUND ) ) && ( team.NumPlayers( TEAM_INFECTED ) > 1 ) ) then
	
		for _, ply in ipairs( team.GetPlayers( TEAM_INFECTED ) ) do
		
			if ( IsValid( ply ) && ply:GetEnragedStatus() ) then
			
				ply:SetEnragedStatus( false )
			
			end
		
		end
	
		SetPreventEnraged( true )
	
	end

	-- Last survivor engaged
	if ( IsRoundState( ROUNDSTATE_INROUND ) && !IsRoundState( ROUNDSTATE_LASTSURVIVOR ) && ( team.NumPlayers( TEAM_SURVIVOR ) <= 1 ) ) then
	
		for _, ply in ipairs( team.GetPlayers( TEAM_SURVIVOR ) ) do
		
			if ( IsValid( ply ) && ply:Alive() ) then
			
				SetRoundState( ROUNDSTATE_LASTSURVIVOR )
			
				SetRoundMusic( ROUNDMUSIC_STOP )
			
				net.Start( "SendInformationText" )
					net.WriteString( string.upper( ply:Nick() ).." IS THE LAST SURVIVOR" )
					net.WriteColor( Color( 255, 255, 255 ) )
					net.WriteInt( 5, 4 )
				net.Broadcast()
			
				SetRoundMusic( ROUNDMUSIC_LASTSURVIVOR )
				BroadcastLua( "surface.PlaySound( \"openvirus/vo/ov_vo_lastchance.wav\" )" )
			
			end
		
		end
	
	end

	-- Select a random person to be infected
	if ( ( player.GetCount() > 1 ) && ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) && ( team.NumPlayers( TEAM_INFECTED ) < 1 ) ) then
	
		for _, ply in ipairs( team.GetPlayers( TEAM_SURVIVOR ) ) do
		
			if ( ( team.NumPlayers( TEAM_INFECTED ) < 1 ) && IsValid( ply ) ) then
			
				if ( math.random( 1, team.NumPlayers( TEAM_SURVIVOR ) ) == ( team.NumPlayers( TEAM_SURVIVOR ) ) ) then
				
					BroadcastLua( "surface.PlaySound( \"openvirus/effects/ov_stinger.wav\" )" )
					ply:InfectPlayer()
				
				end
			
			end
		
		end
	
	end

	-- Display players in the lead
	if ( IsPlayerRankingEnabled() && IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then
	
		if ( playerInFirstPlace != self:GetRankingPlayer( 1 ) ) then
		
			playerInFirstPlace = self:GetRankingPlayer( 1 )
		
			if ( IsValid( playerInFirstPlace ) ) then
			
				-- Publicly display ranking
				net.Start( "SendInformationText" )
					net.WriteString( string.upper( playerInFirstPlace:Nick() ).." IS IN FIRST PLACE!" )
					net.WriteColor( Color( 200, 200, 200 ) )
					net.WriteInt( 6, 4 )
				net.Broadcast()
			
			end
		
		end
	
		if ( playerInSecondPlace != self:GetRankingPlayer( 2 ) ) then
		
			playerInSecondPlace = self:GetRankingPlayer( 2 )
		
			if ( IsValid( playerInSecondPlace ) ) then
			
				-- Publicly display ranking
				net.Start( "SendInformationText" )
					net.WriteString( string.upper( playerInSecondPlace:Nick() ).." IS IN SECOND PLACE!" )
					net.WriteColor( Color( 200, 200, 200 ) )
					net.WriteInt( 6, 4 )
				net.Broadcast()
			
			end
		
		end
	
		if ( playerInThirdPlace != self:GetRankingPlayer( 3 ) ) then
		
			playerInThirdPlace = self:GetRankingPlayer( 3 )
		
			if ( IsValid( playerInThirdPlace ) ) then
			
				-- Publicly display ranking
				net.Start( "SendInformationText" )
					net.WriteString( string.upper( playerInThirdPlace:Nick() ).." IS IN THIRD PLACE!" )
					net.WriteColor( Color( 200, 200, 200 ) )
					net.WriteInt( 6, 4 )
				net.Broadcast()
			
			end
		
		end
	
	end

end


-- Called when an entity takes damage
function GM:EntityTakeDamage( ent, info )

	-- Infected blood effects
	if ( IsValid( ent ) && ent:IsPlayer() && ent:Alive() && ent:IsInfected() ) then
	
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin( info:GetDamagePosition() )
		util.Effect( "infectedblood", bloodeffect )
	
	end

end


-- Called when the player is hurt
function GM:PlayerHurt( ply, attacker, health, dmg )

	-- Send damage values to the client
	if ( IsValid( attacker ) && attacker:IsPlayer() && ( attacker:Health() > 0 ) && attacker:IsSurvivor() ) then
	
		net.Start( "SendDamageValue" )
			net.WriteInt( dmg, 16 )
			net.WriteVector( ply:LocalToWorld( ply:OBBCenter() + Vector( 0, 0, 32 ) ) )
		net.Send( attacker )
	
		attacker:SendLua( "surface.PlaySound( \"buttons/blip1.wav\" )" )
	
	end

	-- Infected health is shown briefly
	if ( IsValid( ply ) && ply:Alive() && ( ply:Team() == TEAM_INFECTED ) ) then
	
		ply:SetNWInt( "InfectedLastHurt", CurTime() + 4 )
	
	end

end


-- 4 players or over this should begin
function GM:BeginWaitingSession()

	-- Round Time
	SetRoundTime( 15 )

end


-- The PreRound moment before we start the actual game
function GM:BeginPreRound()

	-- Stop the music
	SetRoundMusic( ROUNDMUSIC_STOP )

	-- Add to the round number
	SetRoundNumber( GetRoundNumber() + 1 )

	-- Set up a new set of weapons for players
	weaponLoadout = {
		"weapon_ov_m3",
		"weapon_ov_pistol",
		"weapon_ov_flak",
		"weapon_ov_dualpistol",
		"weapon_ov_laserpistol",
		"weapon_ov_silencedpistol",
		"weapon_ov_p90",
		"weapon_ov_laserrifle",
		"weapon_ov_xm1014",
		"weapon_ov_mp5",
		"weapon_ov_smg1",
		"weapon_ov_sniper",
		"weapon_ov_slam",
		"weapon_ov_adrenaline"
	}

	-- List primary weapons
	local weaponLoadoutPrimary = {
		"weapon_ov_pistol",
		"weapon_ov_dualpistol",
		"weapon_ov_laserpistol",
		"weapon_ov_silencedpistol"
	}

	-- List secondary weapons
	local weaponLoadoutSecondary = {
		"weapon_ov_p90",
		"weapon_ov_laserrifle",
		"weapon_ov_mp5",
		"weapon_ov_smg1"
	}

	-- List shotgun weapons
	local weaponLoadoutShotguns = {
		"weapon_ov_m3",
		"weapon_ov_xm1014"
	}

	-- Remove some primary weapons
	for removenum = 1, ( #weaponLoadoutPrimary - 2 ) do
	
		local removeSelected = table.Random( weaponLoadoutPrimary )
		table.RemoveByValue( weaponLoadout, removeSelected )
		table.RemoveByValue( weaponLoadoutPrimary, removeSelected )
	
	end

	-- Remove some secondary weapons
	for removenum = 1, ( #weaponLoadoutSecondary - math.random( 1, 2 ) ) do
	
		local removeSelected = table.Random( weaponLoadoutSecondary )
		table.RemoveByValue( weaponLoadout, removeSelected )
		table.RemoveByValue( weaponLoadoutSecondary, removeSelected )
	
	end

	-- Remove some shotguns
	for removenum = 1, ( #weaponLoadoutShotguns - math.random( 0, 1 ) ) do
	
		local removeSelected = table.Random( weaponLoadoutShotguns )
		table.RemoveByValue( weaponLoadout, removeSelected )
		table.RemoveByValue( weaponLoadoutShotguns, removeSelected )
	
	end

	-- Randomly replace the laser rifle with a hybrid version
	if ( table.HasValue( weaponLoadout, "weapon_ov_laserrifle" ) && ( math.random( 1, 4 ) >= 4 ) ) then
	
		table.RemoveByValue( weaponLoadout, "weapon_ov_laserrifle" )
		table.insert( weaponLoadout, "weapon_ov_laserriflehybrid" )
	
	end

	-- Only give the Flak gun occasionally
	if ( math.random( 1, 6 ) > 1 ) then
	
		table.RemoveByValue( weaponLoadout, "weapon_ov_flak" )
	
	end

	-- Give the sniper rifle randomly and when we do not have the Flak gun
	if ( table.HasValue( weaponLoadout, "weapon_ov_flak" ) || ( math.random( 1, 8 ) > 1 ) ) then
	
		table.RemoveByValue( weaponLoadout, "weapon_ov_sniper" )
	
	end

	-- Here we will clean up the map
	game.CleanUpMap()

	-- Set round state
	SetRoundState( ROUNDSTATE_PREROUND )

	-- Reset player ranking
	playerInFirstPlace = Player( 0 )
	playerInSecondPlace = Player( 0 )
	playerInThirdPlace = Player( 0 )

	-- Set prevent enraged to false
	SetPreventEnraged( false )

	-- Set round time
	SetRoundTime( math.random( 20, 25 ) )

	-- Close Scoreboard for players
	BroadcastLua( "GAMEMODE:ScoreboardHide()" )

	-- Respawn all players
	for _, ply in ipairs( player.GetAll() ) do
	
		ply:Freeze( false )
	
		ply:SetTeam( TEAM_SURVIVOR )
		ply:SetColor( Color( 255, 255, 255 ) )
		ply:SetEnragedStatus( false )
		ply:SetInfectionStatus( false )
		ply:SetAdrenalineStatus( false )
		ply:SetNWFloat( "SurvivorTimeSurvived", 0 )
	
		ply:SetFrags( 0 )
		ply:SetDeaths( 0 )
	
		ply:RemoveAllItems()
	
		ply:Spawn()
	
	end

	-- Indicate that the infection is about to spread
	net.Start( "SendInformationText" )
		net.WriteString( "THE INFECTION IS ABOUT TO SPREAD" )
		net.WriteColor( Color( 255, 255, 255 ) )
		net.WriteInt( 5, 4 )
	net.Broadcast()

	-- Indicate that this is the last round
	if ( GetRoundNumber() >= GetMaxRounds() ) then
	
		net.Start( "SendInformationText" )
			net.WriteString( "THIS IS THE LAST ROUND" )
			net.WriteColor( Color( 255, 255, 255 ) )
			net.WriteInt( 5, 4 )
		net.Broadcast()
	
	end

	-- Start some music
	SetRoundMusic( ROUNDMUSIC_PREROUND )

end


-- Begin the main Round
function GM:BeginMainRound()

	-- Do not begin the main round if we are below minimum player requirement
	if ( player.GetCount() < GetMinimumPlayers() ) then
	
		SetRoundTime( 1 )
		return
	
	end

	-- Stop music
	SetRoundMusic( ROUNDMUSIC_STOP )

	-- Give weapons to players in mystery weapons mode
	if ( enableMysteryWeapons:GetBool() ) then
	
		for _, ply in ipairs( player.GetAll() ) do
		
			if ( IsValid( ply ) && ply:Alive() && ply:IsSurvivor() ) then
			
				hook.Call( "PlayerLoadout", GAMEMODE, ply )
			
			end
		
		end
	
	end

	-- Set round state
	SetRoundState( ROUNDSTATE_INROUND )

	-- Set round time
	SetRoundTime( GAME_ROUND_TIME )

	-- Start some music
	SetRoundMusic( ROUNDMUSIC_INROUND )

	-- Update server settings
	SetPlayerRadar( enablePlayerRadar:GetBool() )
	SetPlayerRanking( enablePlayerRanking:GetBool() )

	-- Allow for events to happen after the round has started
	hook.Call( "PostBeginMainRound", GAMEMODE )

end


-- End the main Round
function GM:EndMainRound()

	-- Stop music
	SetRoundMusic( ROUNDMUSIC_STOP )

	-- Set this on all players
	for _, ply in pairs( player.GetAll() ) do
	
		ply:Freeze( true )
		if ( ply:GetAdrenalineStatus() ) then ply:SetAdrenalineStatus( false ) end
	
	end

	-- Set round state
	SetRoundState( ROUNDSTATE_ENDROUND )

	-- Set round time
	SetRoundTime( 15 )

	if ( team.NumPlayers( TEAM_SURVIVOR ) > 0 ) then -- Survivors win
	
		net.Start( "SendInformationText" )
			net.WriteString( "THE SURVIVORS WIN" )
			net.WriteColor( Color( 255, 255, 255 ) )
			net.WriteInt( 5, 4 )
		net.Broadcast()
	
		SetRoundMusic( ROUNDMUSIC_SURVIVORSWIN )
		BroadcastLua( "surface.PlaySound( \"openvirus/vo/ov_vo_survivorswin.wav\" )" )
	
	else -- Infected win
	
		net.Start( "SendInformationText" )
			net.WriteString( "THE INFECTION HAS SPREAD" )
			net.WriteColor( Color( 255, 255, 255 ) )
			net.WriteInt( 5, 4 )
		net.Broadcast()
	
		SetRoundMusic( ROUNDMUSIC_INFECTEDWIN )
		BroadcastLua( "surface.PlaySound( \"openvirus/vo/ov_vo_infectedwin.wav\" )" )
	
	end

	-- Reached the max amount of rounds
	if ( GetRoundNumber() >= GetMaxRounds() ) then
	
		-- Remove the RoundTimer
		if ( timer.Exists( "RoundTimer" ) ) then
		
			timer.Remove( "RoundTimer" )
		
		end
	
		timer.Simple( 20, function() LoadNextMap(); end )
	
	end

	-- Open Scoreboard for players
	timer.Simple( 2, function() BroadcastLua( "GAMEMODE:ScoreboardShow()" ); end )

	-- Allow for events to happen after the round has ended
	hook.Call( "PostEndMainRound", GAMEMODE )

end


-- Function used for loading the next map
function LoadNextMap()

	-- MapVote integration (thanks for the idea Wolvindra)
	if ( MapVote ) then
	
		MapVote.Start( nil, nil, nil, nil )
		return
	
	end

	-- Load up the next map
	game.LoadNextMap()

end


-- During this phase we check for players until we continue
function StartGameWhenReady()

	-- At 4 players or over we should start
	if ( player.GetCount() >= GetMinimumPlayers() ) then
	
		timer.Remove( "StartGameWhenReady" )
		hook.Call( "BeginWaitingSession", GAMEMODE )
	
	end

end
timer.Create( "StartGameWhenReady", 1, 0, StartGameWhenReady )


-- Show Help
function GM:ShowHelp( ply )

	ply:SendLua( "GAMEMODE:ShowHelp()" )

end
