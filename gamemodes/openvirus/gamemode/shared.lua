-- Initialize the gamemode!

AddCSLuaFile()

include( "player_class/player_virus.lua" )
include( "vgui/init.lua" )
include( "player_meta.lua" )
include( "sh_ammo.lua" )
include( "sh_variables.lua" )


-- Map Lua inclusion
if ( file.Exists( "openvirus/gamemode/map_lua/"..game.GetMap()..".lua", "LUA" ) ) then

	include( "map_lua/"..game.GetMap()..".lua" )

end


-- ConVars
local blockKeys = CreateConVar( "ov_shared_block_keys", 1, { FCVAR_NOTIFY, FCVAR_REPLICATED }, "Block certain movement keys for a better GMT/TU experience." )


-- Functions down here
-- Name, Author, Email and Website
GM.Name = "open Virus"
GM.Author = "daunknownfox2010"
GM.Email = "N/A"
GM.Website = "N/A"
GM.Version = 35


-- Some global stuff here
GM.SurvivorSpeed = 300
GM.SurvivorAdrenSpeed = 420
GM.InfectedHealth = 100
GM.InfectedEnrageHealth = 400
GM.InfectedSpeed = 360
GM.InfectedEnrageSpeed = 460
GM.InfectedModel = "models/player/corpse1.mdl"


-- Translate player activities
function VirusTranslateActivity( ply, act )

	-- Infected run
	if ( IsValid( ply ) && ply:Alive() && ( ply:Team() == TEAM_INFECTED ) && ( act == ACT_MP_RUN ) ) then
	
		return ACT_HL2MP_RUN_FAST
	
	end

end
hook.Add( "TranslateActivity", "VirusTranslateActivity", VirusTranslateActivity )


-- Should the player take damage
function GM:PlayerShouldTakeDamage( ply, attacker )

	-- Block damaging players
	if ( IsValid( ply ) && ply:IsSurvivor() && IsValid( attacker ) && ( attacker:GetClass() != "trigger_hurt" ) ) then
	
		return false
	
	end

	-- Players cannot kill teammates
	if ( IsValid( ply ) && IsValid( attacker ) && attacker:IsPlayer() && ( ply:Team() == attacker:Team() ) ) then
	
		return false
	
	end

	-- One infected player cannot be damaged in non infection mode
	if ( !GetPreventEnraged() && IsValid( ply ) && ply:IsInfected() && ( ply:Deaths() > 1 ) && !ply:GetInfectionStatus() ) then
	
		return false
	
	end

	return true

end


-- Scale the player damage
function GM:ScalePlayerDamage( ply, hitGroup, info )

	-- Scale stuff
	if ( hitGroup == HITGROUP_HEAD ) then
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) >= 16 ) then
		
			info:ScaleDamage( 1 )
		
		elseif ( ( player.GetCount() < 8 ) || ( ( player.GetCount() >= 8 ) && ( team.NumPlayers( TEAM_SURVIVOR ) > 2 ) ) ) then
		
			info:ScaleDamage( 2 )
		
		else
		
			info:ScaleDamage( 2.5 )
		
		end
	
	elseif ( hitGroup == HITGROUP_CHEST ) then
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) >= 16 ) then
		
			info:ScaleDamage( 0.5 )
		
		elseif ( ( player.GetCount() < 8 ) || ( ( player.GetCount() >= 8 ) && ( team.NumPlayers( TEAM_SURVIVOR ) > 2 ) ) ) then
		
			info:ScaleDamage( 1 )
		
		else
		
			info:ScaleDamage( 1.5 )
		
		end
	
	elseif ( hitGroup == HITGROUP_STOMACH ) then
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) >= 16 ) then
		
			info:ScaleDamage( 0.5 )
		
		elseif ( ( player.GetCount() < 8 ) || ( ( player.GetCount() >= 8 ) && ( team.NumPlayers( TEAM_SURVIVOR ) > 2 ) ) ) then
		
			info:ScaleDamage( 1 )
		
		else
		
			info:ScaleDamage( 1.5 )
		
		end
	
	else
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) >= 16 ) then
		
			info:ScaleDamage( 0.25 )
		
		elseif ( ( player.GetCount() < 8 ) || ( ( player.GetCount() >= 8 ) && ( team.NumPlayers( TEAM_SURVIVOR ) > 2 ) ) ) then
		
			info:ScaleDamage( 0.5 )
		
		else
		
			info:ScaleDamage( 1 )
		
		end
	
	end

end


-- Create our teams here
function GM:CreateTeams()

	TEAM_SPECTATOR = 0
	team.SetUp( TEAM_SPECTATOR, "Spectator", Color( 0, 0, 0 ) )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_combine", "info_player_rebel", "info_player_counterterrorist", "info_player_terrorist" } )

	TEAM_SURVIVOR = 1
	team.SetUp( TEAM_SURVIVOR, "Survivor", Color( 255, 255, 255 ) )
	team.SetSpawnPoint( TEAM_SURVIVOR, { "info_player_combine", "info_player_rebel", "info_player_counterterrorist", "info_player_terrorist" } )

	TEAM_INFECTED = 2
	team.SetUp( TEAM_INFECTED, "Infected", Color( 0, 255, 0 ) )
	team.SetSpawnPoint( TEAM_SURVIVOR, { "info_player_combine", "info_player_rebel", "info_player_counterterrorist", "info_player_terrorist" } )

end


-- Called when two entities with custom collision check collide
function GM:ShouldCollide( ent1, ent2 )

	-- PvP Collision rule
	if ( ( IsValid( ent1 ) && ent1:IsPlayer() && ent1:Alive() && IsValid( ent2 ) && ent2:IsPlayer() && ent2:Alive() && ( ent1:Team() == ent2:Team() ) ) || ( IsValid( ent2 ) && ent2:IsPlayer() && ent2:Alive() && IsValid( ent1 ) && ent1:IsPlayer() && ent1:Alive() && ( ent2:Team() == ent1:Team() ) ) ) then
	
		return false
	
	end

	-- SLAMs should not collide with players
	if ( ( IsValid( ent1 ) && ent1:IsPlayer() && ent1:Alive() && IsValid( ent2 ) && ( ent2:GetClass() == "ent_ov_slam" ) ) || ( IsValid( ent2 ) && ent2:IsPlayer() && ent2:Alive() && IsValid( ent1 ) && ( ent1:GetClass() == "ent_ov_slam" ) ) ) then
	
		return false
	
	end

	return true

end


-- This is used to prevent certain move commands from working
function GM:StartCommand( ply, ucmd )

	local blockedKeys = { IN_JUMP, IN_DUCK, IN_SPEED, IN_WALK, IN_ZOOM }

	-- Block the keys
	if ( blockKeys:GetBool() ) then
	
		for k, v in pairs( blockedKeys ) do
		
			if ( ucmd:KeyDown( v ) ) then
			
				ucmd:RemoveKey( v )
			
			end
		
		end
	
	end

end


-- Get the player rank
function GM:GetPlayerRank( ply )

	if ( !IsValid( ply ) ) then return 0; end
	if ( !ply:IsPlayer() ) then return 0; end
	if ( ply:IsSpectating() ) then return 0; end

	local sortedPlayers = {}

	for _, ply in ipairs( player.GetAll() ) do
	
		if ( !ply:IsSpectating() ) then
		
			sortedPlayers[ ply:UserID() ] = ( ( ply:Frags() * 50 ) - ply:EntIndex() )
		
		end
	
	end

	sortedPlayers = table.SortByKey( sortedPlayers )

	for k, v in ipairs( sortedPlayers ) do
	
		if ( Player( v ) == ply ) then
		
			return k
		
		end
	
	end

	return 0;

end


-- Get the ranking player
function GM:GetRankingPlayer( num )

	if ( !num ) then return; end

	local sortedPlayers = {}

	for _, ply in ipairs( player.GetAll() ) do
	
		if ( !ply:IsSpectating() ) then
		
			sortedPlayers[ ply:UserID() ] = ( ( ply:Frags() * 50 ) - ply:EntIndex() )
		
		end
	
	end

	sortedPlayers = table.SortByKey( sortedPlayers )

	return Player( sortedPlayers[ num ] || 0 )

end
