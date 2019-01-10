-- Initialize the player!


-- ConVars
local enablePlayerTaunting = CreateConVar( "ov_sv_enable_player_taunting", "0", FCVAR_NOTIFY, "Players are allowed to use taunt animations." )


-- Called when a player picks up a weapon
function GM:PlayerCanPickupWeapon( ply, ent )

	-- Only survivors can pick up weapons not created by the map
	if ( !ply:IsSurvivor() ) then return false; end
	if ( ent:CreatedByMap() ) then return false; end

	return true

end


-- Called when a player picks up an item
function GM:PlayerCanPickupItem( ply, ent )

	-- Only survivors can pick up items not created by the map
	if ( !ply:IsSurvivor() ) then return false; end
	if ( ent:CreatedByMap() ) then return false; end

	return true

end


-- Player disconnected
function GM:PlayerDisconnected( ply )

	timer.Simple( 0.05, function() hook.Call( "DelayedPlayerDisconnected", GAMEMODE ); end )

end


-- Delayed player disconnected
function GM:DelayedPlayerDisconnected()

	-- End the round when only one player exist
	if ( ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) && ( player.GetCount() <= 1 ) ) then
	
		hook.Call( "EndMainRound", GAMEMODE )
	
	end

	-- End the round when no survivors are left
	if ( ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) && ( team.NumPlayers( TEAM_SURVIVOR ) <= 0 ) ) then
	
		hook.Call( "EndMainRound", GAMEMODE )
	
	end

end


-- Called when the player is waiting for respawn
function GM:PlayerDeathThink( ply )

	-- Respawn players after a certain amount of time
	if ( ply.NextSpawnTime && ( ( ply.NextSpawnTime + 2 ) < CurTime() ) ) then
	
		ply:Spawn()
	
	end

end


-- Called when player uses the USE key
function GM:PlayerUse( ply, ent )

	-- Disable USE completely
	return false

end


-- Called when a player dies
function VirusPlayerDeath( ply, inflictor, attacker )

	-- If a player dies
	if ( ply:IsSurvivor() ) then
	
		-- Survivor managed to die in the round
		if ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then
		
			ply:InfectPlayer()
		
		end
	
		ply:SetFOV( 0, 0 )
		ply:SetAdrenalineStatus( false )
		ply.timeAdrenalineStatus = 0
		ply:RemoveAllItems()
	
	elseif ( ply:IsInfected() ) then
	
		ply:SetEnragedStatus( false )
		ply:SetInfectionStatus( false )
		ply.timeInfectionStatus = 0
		ply:SetColor( Color( 255, 255, 255 ) )
	
		-- Infected blood effects
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin( ply:LocalToWorld( ply:OBBCenter() ) )
		util.Effect( "infectedblood", bloodeffect )
	
	end

end
hook.Add( "PlayerDeath", "VirusPlayerDeath", VirusPlayerDeath )


-- Called before the first spawn
function GM:PlayerInitialSpawn( ply )

	-- player_manager initialize
	player_manager.SetPlayerClass( ply, "player_virus" )

	-- Use this networked boolean to determine we are a listen server host
	if ( !game.IsDedicated() ) then
	
		ply:SetNWBool( "ListenServerHost", ply:IsListenServerHost() )
	
	end

	-- Time survived stuff
	ply:SetNWFloat( "SurvivorTimeSurvived", 0 )

	-- Select these teams at initial spawn
	if ( IsRoundState( ROUNDSTATE_WAITING ) || IsRoundState( ROUNDSTATE_PREROUND ) ) then
	
		ply:SetTeam( TEAM_SURVIVOR )
	
	elseif ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then
	
		ply:SetTeam( TEAM_INFECTED )
	
	elseif ( IsRoundState( ROUNDSTATE_ENDROUND ) ) then
	
		ply:SetTeam( TEAM_SPECTATOR )
	
	end

	-- Full network update
	FullNetworkUpdate( ply )

end


-- Called when the player spawns
function GM:PlayerSpawn( ply )

	-- Player is in spectator
	if ( ply:IsSpectating() ) then
	
		GAMEMODE:PlayerSpawnAsSpectator( ply )
		return
	
	end

	-- Get out of spectator if we are
	ply:UnSpectate()

	-- Set up the player hands
	ply:SetupHands()

	-- player_manager stuff
	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )

	-- Player Collision
	ply:SetCustomCollisionCheck( true )
	ply:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	ply:CollisionRulesChanged()

	-- Reset player stats
	ply:SetFOV( 0, 0 )
	ply:SetColor( Color( 255, 255, 255 ) )
	ply:SetBloodColor( BLOOD_COLOR_RED )
	ply:SetInfectionStatus( false )
	ply:SetEnragedStatus( false )
	ply:SetAdrenalineStatus( false )
	ply.timeInfectionStatus = 0
	ply.timeAdrenalineStatus = 0

	-- Time the Infection status
	if ( ply:IsInfected() ) then
	
		ply.timeInfectionStatus = CurTime() + 2
	
	end

	-- Player Speed
	if ( ply:IsSurvivor() ) then
	
		GAMEMODE:SetPlayerSpeed( ply, GAMEMODE.SurvivorSpeed, GAMEMODE.SurvivorSpeed )
	
	elseif ( !ply:IsSurvivor() ) then
	
		GAMEMODE:SetPlayerSpeed( ply, GAMEMODE.InfectedSpeed, GAMEMODE.InfectedSpeed )
	
	end

	-- Player Loadout
	local enableMysteryWeapons = GetConVar( "ov_sv_survivor_mystery_weapons" )
	if ( !enableMysteryWeapons:GetBool() || ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) ) then
	
		hook.Call( "PlayerLoadout", GAMEMODE, ply )
	
	end

	-- Player Model
	hook.Call( "PlayerSetModel", GAMEMODE, ply )

	-- Do a spawn effect for clients
	if ( ply:IsSurvivor() ) then
	
		local spawnEffect = EffectData()
		spawnEffect:SetOrigin( ply:GetPos() + Vector( 0, 0, 36 ) )
		util.Effect( "survivorspawn", spawnEffect )
	
	elseif ( ply:IsInfected() ) then
	
		local spawnEffect = EffectData()
		spawnEffect:SetOrigin( ply:GetPos() + Vector( 0, 0, 36 ) )
		util.Effect( "infectedspawn", spawnEffect )
	
	end

	-- Respawn sound
	ply:EmitSound( "openvirus/effects/ov_respawn.wav", 75, 90, 0.5 )

end


-- Called when we are going to set the player model
function GM:PlayerSetModel( ply )

	-- Run this like normal
	player_manager.RunClass( ply, "SetModel" )

	-- Infected player
	if ( ply:IsInfected() ) then
	
		ply:SetModel( GAMEMODE.InfectedModel )
	
	end

	-- Set the player model to something different
	if ( ply:IsSurvivor() && ( ply:GetModel() == GAMEMODE.InfectedModel ) ) then
	
		ply:SetModel( "models/player/kleiner.mdl" )
	
	end

	-- Last but not least we should set the model color
	if ( ply:IsSurvivor() ) then
	
		ply:SetPlayerColor( Vector( ply:GetInfo( "cl_playercolor" ) ) )
	
	elseif ( ply:IsInfected() ) then
	
		ply:SetPlayerColor( Vector( 0.7, 1, 0 ) )
	
	end

end


-- Called when the player spawns and the PlayerLoadout hook is called
function GM:PlayerLoadout( ply )

	-- Remove all items
	ply:RemoveAllItems()

	-- Waiting for players session
	if ( IsRoundState( ROUNDSTATE_WAITING ) ) then return; end

	-- Spectator
	if ( ply:IsSpectating() ) then return; end

	-- Is on infected team
	if ( ply:IsInfected() ) then
	
		ply:SetColor( Color( 180, 255, 0 ) )
		ply:SetBloodColor( DONT_BLEED )
		ply:SetNWInt( "InfectedLastHurt", CurTime() + 4 )
	
		return
	
	end

	-- Survivor loadout
	for k, v in pairs( weaponLoadout ) do
	
		ply:Give( tostring( v ) )
		if ( ply:GetWeapon( tostring( v ) ) && ply:GetWeapon( tostring( v ) ):IsValid() ) then
		
			ply:GiveAmmo( ply:GetWeapon( tostring( v ) ):Clip1() * 3, ply:GetWeapon( tostring( v ) ):GetPrimaryAmmoType(), true )
		
		end
	
	end

	-- Dual pistols get extra ammo
	if ( ply:HasWeapon( "weapon_ov_dualpistol" ) ) then
	
		ply:GiveAmmo( 60, game.GetAmmoID( "DualPistol" ), true )
	
	end

end


-- Is the spawnpoint suitable
function GM:IsSpawnpointSuitable()

	return true

end


-- Should the player play the death sound
function GM:PlayerDeathSound()

	-- Mutes the death sound
	return true

end


-- Called when the player attempts to suicide
function GM:CanPlayerSuicide( ply )

	-- Disable suicide
	return false

end


-- Player tries to toggle flashlight
function GM:PlayerSwitchFlashlight( ply, on )

	if ( on && !ply:IsSurvivor() ) then return false; end

	return ply:CanUseFlashlight()

end


-- Return a damage amount for fall damage
function GM:GetFallDamage( ply, speed )

	-- No damage
	return 0

end


-- Called when a player uses an act taunt
function GM:PlayerShouldTaunt( ply, id )

	-- Disable taunts
	return ( enablePlayerTaunting:GetBool() || false )

end


-- Called when a player wants to pick up an object
function GM:AllowPlayerPickup( ply, ent )

	-- Disable pickup
	return false

end
