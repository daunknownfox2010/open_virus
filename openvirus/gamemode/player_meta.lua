-- Player meta stuff
local meta = FindMetaTable( "Player" )
if ( !meta ) then return; end

AddCSLuaFile()


-- Player is survivor
function meta:IsSurvivor()

	return ( self:Team() == TEAM_SURVIVOR )

end


-- Player is infected
function meta:IsInfected()

	return ( self:Team() == TEAM_INFECTED )

end


-- Player is spectating
function meta:IsSpectating()

	return ( self:Team() == TEAM_SPECTATOR )

end


-- Infect the player
function meta:InfectPlayer( ply )

	if ( CLIENT ) then return; end
	if ( !self:IsSurvivor() ) then return; end

	if ( self:GetAdrenalineStatus() ) then self:SetAdrenalineStatus( false ); end
	self:SetTeam( TEAM_INFECTED )
	self:SetFOV( 0, 0 )
	self:SetHealth( GAMEMODE.InfectedHealth )
	self:SetBloodColor( DONT_BLEED )
	if ( SERVER && self:FlashlightIsOn() ) then self:Flashlight( false ); end

	hook.Call( "SetPlayerSpeed", GAMEMODE, self, GAMEMODE.InfectedSpeed, GAMEMODE.InfectedSpeed )

	hook.Call( "PlayerLoadout", GAMEMODE, self )
	hook.Call( "PlayerSetModel", GAMEMODE, self )

	local plyNick = ""
	if ( IsValid( ply ) && ply:IsPlayer() ) then plyNick = string.upper( ply:Nick() ).." " end

	net.Start( "SendInformationText" )
		net.WriteString( plyNick.."INFECTED "..string.upper( self:Nick() ) )
		net.WriteColor( Color( 0, 255, 0 ) )
		net.WriteInt( 5, 4 )
	net.Broadcast()

	-- Print in console
	if ( IsValid( ply ) && ply:IsPlayer() ) then
	
		MsgAll( self:Nick().." was infected by "..ply:Nick().."\n" )
	
	else
	
		MsgAll( self:Nick().." was infected\n" )
	
	end

	-- Give the player who infected this player a point
	if ( IsValid( ply ) && ply:IsPlayer() ) then
	
		ply:AddFrags( 1 )
	
	end

	-- Set a time survived
	if ( IsValid( ply ) && ply:IsPlayer() && IsRoundTimeActive() ) then
	
		self:SetNWFloat( "SurvivorTimeSurvived", GAME_ROUND_TIME - GetCurrentRoundTime() )
	
	end

	-- Call the round to end if no survivors
	if ( team.NumPlayers( TEAM_SURVIVOR ) < 1 ) then
	
		hook.Call( "EndMainRound", GAMEMODE )
	
	end

end


-- Set the Infected Infection Status
function meta:SetInfectionStatus( bool )

	if ( CLIENT ) then return; end
	if ( !isbool( bool ) ) then return; end
	if ( self:GetNWBool( "InfectionStatus", false ) == bool ) then return; end

	if ( bool ) then
	
		-- Play a sound
		self:EmitSound( "ambient/fire/gascan_ignite1.wav", 90, 90 )
	
		-- Start enraged mode here
		if ( !GetPreventEnraged() && IsValid( self ) && self:IsInfected() && ( self:Deaths() > 1 ) ) then
		
			self:SetEnragedStatus( true )
		
		end
	
	end

	self:SetNWBool( "InfectionStatus", bool )

end


-- Get the Infected Infection Status
function meta:GetInfectionStatus()

	return self:GetNWBool( "InfectionStatus", false )

end


-- Set the player Adrenaline Status
function meta:SetAdrenalineStatus( bool )

	if ( CLIENT ) then return end
	if ( !isbool( bool ) ) then return; end
	if ( self:GetNWBool( "AdrenalineStatus", false ) == bool ) then return; end
	if ( bool && !IsRoundState( ROUNDSTATE_INROUND ) && !IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then return; end

	if ( bool ) then
	
		hook.Call( "SetPlayerSpeed", GAMEMODE, self, GAMEMODE.SurvivorAdrenSpeed, GAMEMODE.SurvivorAdrenSpeed )
	
	else
	
		hook.Call( "SetPlayerSpeed", GAMEMODE, self, GAMEMODE.SurvivorSpeed, GAMEMODE.SurvivorSpeed )
	
	end

	self:SetNWBool( "AdrenalineStatus", tobool( bool ) )

end


-- Get the player Adrenaline Status
function meta:GetAdrenalineStatus()

	return self:GetNWBool( "AdrenalineStatus", false )

end


-- Set the Infected enraged status
function meta:SetEnragedStatus( bool )

	if ( CLIENT ) then return end
	if ( !isbool( bool ) ) then return; end
	if ( self:GetNWBool( "EnragedStatus", false ) == bool ) then return; end

	if ( tobool( bool ) ) then
	
		if ( self:IsInfected() ) then
		
			hook.Call( "SetPlayerSpeed", GAMEMODE, self, GAMEMODE.InfectedEnrageSpeed, GAMEMODE.InfectedEnrageSpeed )
			self:SetColor( Color( 255, 180, 0 ) )
			self:SetPlayerColor( Vector( 1, 0.7, 0 ) )
			self:SetMaxHealth( GAMEMODE.InfectedEnrageHealth )
			self:SetHealth( GAMEMODE.InfectedEnrageHealth )
		
			net.Start( "SendInformationText" )
				net.WriteString( string.upper( self:Name() ).." IS ENRAGED" )
				net.WriteColor( Color( 255, 0, 0 ) )
				net.WriteInt( 5, 4 )
			net.Broadcast()
		
		end
	
	else
	
		if ( self:IsInfected() ) then
		
			hook.Call( "SetPlayerSpeed", GAMEMODE, self, GAMEMODE.InfectedSpeed, GAMEMODE.InfectedSpeed )
			self:SetColor( Color( 180, 255, 0 ) )
			self:SetPlayerColor( Vector( 0.7, 1, 0 ) )
			self:SetMaxHealth( GAMEMODE.InfectedHealth )
			if ( self:Alive() && ( self:Health() > GAMEMODE.InfectedHealth ) ) then
			
				self:SetHealth( GAMEMODE.InfectedHealth )
			
			end
		
		end
	
	end

	self:SetNWBool( "EnragedStatus", tobool( bool ) )

end


-- Get the Infected enraged status
function meta:GetEnragedStatus()

	return self:GetNWBool( "EnragedStatus", false )

end
