-- Initialize the variables!

AddCSLuaFile()


-- Local variables
local roundState = 0
local roundNumber = 0
local roundTime = 0
local maxRounds = 10
local minimumPlayers = 4
local preventEnraged = false
local playerRadar = false
local playerRanking = false


-- Global variables
GAME_ROUND_TIME = 90

ROUNDSTATE_WAITING = 0
ROUNDSTATE_PREROUND = 1
ROUNDSTATE_INROUND = 2
ROUNDSTATE_LASTSURVIVOR = 3
ROUNDSTATE_ENDROUND = 4

ROUNDMUSIC_STOP = 0
ROUNDMUSIC_WFP = 1
ROUNDMUSIC_PREROUND = 2
ROUNDMUSIC_INROUND = 3
ROUNDMUSIC_LASTSURVIVOR = 4
ROUNDMUSIC_INFECTEDWIN = 5
ROUNDMUSIC_SURVIVORSWIN = 6


-- Set round state
if ( SERVER ) then

	function SetRoundState( int )
	
		if ( !isnumber( int ) ) then return; end
	
		roundState = int
	
		net.Start( "UpdateRoundState" )
			net.WriteInt( roundState, 4 )
		net.Broadcast()
	
	end

else

	function UpdateRoundState( len )
	
		roundState = net.ReadInt( 4 )
	
	end
	net.Receive( "UpdateRoundState", UpdateRoundState )

end


-- Get round state
function GetRoundState()

	return roundState

end


-- Is round state
function IsRoundState( int )

	return ( roundState == int )

end


-- Set round number
if ( SERVER ) then

	function SetRoundNumber( int )
	
		if ( !isnumber( int ) ) then return; end
	
		roundNumber = int
	
		net.Start( "UpdateRoundNumber" )
			net.WriteInt( roundNumber, 8 )
		net.Broadcast()
	
	end

else

	function UpdateRoundNumber( len )
	
		roundNumber = net.ReadInt( 8 )
	
	end
	net.Receive( "UpdateRoundNumber", UpdateRoundNumber )

end


-- Get round number
function GetRoundNumber()

	return roundNumber

end


-- Set round time
if ( SERVER ) then

	function SetRoundTime( float )
	
		if ( !isnumber( float ) ) then return; end
	
		roundTime = CurTime() + float
	
		net.Start( "UpdateRoundTime" )
			net.WriteFloat( roundTime )
		net.Broadcast()
	
		if ( timer.Exists( "RoundTimer" ) ) then
		
			timer.Destroy( "RoundTimer" )
		
		end
	
		timer.Create( "RoundTimer", float, 1, function()
		
			if ( IsRoundState( ROUNDSTATE_PREROUND ) ) then
			
				GAMEMODE:BeginMainRound()
			
			elseif ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) then
			
				GAMEMODE:EndMainRound()
			
			else
			
				GAMEMODE:BeginPreRound()
			
			end
		
		end )
	
	end

else

	function UpdateRoundTime( len )
	
		roundTime = net.ReadFloat()
	
	end
	net.Receive( "UpdateRoundTime", UpdateRoundTime )

end


-- Get round time
function GetRoundTime()

	return roundTime

end


-- Get current round time
function GetCurrentRoundTime()

	return ( roundTime - CurTime() )

end


-- Round time active
function IsRoundTimeActive()

	return ( roundTime >= CurTime() )

end


-- Set max rounds
if ( SERVER ) then

	function SetMaxRounds( int )
	
		if ( !isnumber( int ) ) then return; end
	
		maxRounds = int
	
		net.Start( "UpdateMaxRounds" )
			net.WriteInt( maxRounds, 8 )
		net.Broadcast()
	
	end

else

	function UpdateMaxRounds( len )
	
		maxRounds = net.ReadInt( 8 )
	
	end
	net.Receive( "UpdateMaxRounds", UpdateMaxRounds )

end


-- Get max rounds
function GetMaxRounds()

	return maxRounds

end


-- Set minimum players
if ( SERVER ) then

	function SetMinimumPlayers( int )
	
		if ( !isnumber( int ) ) then return; end
	
		minimumPlayers = int
	
		net.Start( "UpdateMinimumPlayers" )
			net.WriteInt( minimumPlayers, 9 )
		net.Broadcast()
	
	end

else

	function UpdateMinimumPlayers( len )
	
		minimumPlayers = net.ReadInt( 9 )
	
	end
	net.Receive( "UpdateMinimumPlayers", UpdateMinimumPlayers )

end


-- Get max rounds
function GetMinimumPlayers()

	return minimumPlayers

end


-- Set prevent enraged
if ( SERVER ) then

	function SetPreventEnraged( bool )
	
		if ( !isbool( bool ) ) then return; end
	
		preventEnraged = bool
	
		net.Start( "UpdatePreventEnraged" )
			net.WriteBool( preventEnraged )
		net.Broadcast()
	
	end

else

	function UpdatePreventEnraged( len )
	
		preventEnraged = net.ReadBool()
	
	end
	net.Receive( "UpdatePreventEnraged", UpdatePreventEnraged )

end


-- Get prevent enraged
function GetPreventEnraged()

	return preventEnraged

end


-- Set player radar
if ( SERVER ) then

	function SetPlayerRadar( bool )
	
		if ( !isbool( bool ) ) then return; end
	
		playerRadar = bool
	
		net.Start( "UpdatePlayerRadar" )
			net.WriteBool( playerRadar )
		net.Broadcast()
	
	end

else

	function UpdatePlayerRadar( len )
	
		playerRadar = net.ReadBool()
	
	end
	net.Receive( "UpdatePlayerRadar", UpdatePlayerRadar )

end


-- Is the player radar enabled
function IsPlayerRadarEnabled()

	return playerRadar

end


-- Set player ranking
if ( SERVER ) then

	function SetPlayerRanking( bool )
	
		if ( !isbool( bool ) ) then return; end
	
		playerRanking = bool
	
		net.Start( "UpdatePlayerRanking" )
			net.WriteBool( playerRanking )
		net.Broadcast()
	
	end

else

	function UpdatePlayerRanking( len )
	
		playerRanking = net.ReadBool()
	
	end
	net.Receive( "UpdatePlayerRanking", UpdatePlayerRanking )

end


-- Is the player radar enabled
function IsPlayerRankingEnabled()

	return playerRanking

end


-- Full network update
if ( SERVER ) then

	function FullNetworkUpdate( ply )
	
		if ( !IsValid( ply ) ) then return; end
		if ( !ply:IsPlayer() ) then return; end
	
		net.Start( "UpdateRoundState" )
			net.WriteInt( roundState, 4 )
		net.Send( ply )
	
		net.Start( "UpdateRoundNumber" )
			net.WriteInt( roundNumber, 8 )
		net.Send( ply )
	
		net.Start( "UpdateRoundTime" )
			net.WriteFloat( roundTime )
		net.Send( ply )
	
		net.Start( "UpdateMaxRounds" )
			net.WriteInt( maxRounds, 8 )
		net.Send( ply )
	
		net.Start( "UpdateMinimumPlayers" )
			net.WriteInt( minimumPlayers, 9 )
		net.Send( ply )
	
		net.Start( "UpdatePreventEnraged" )
			net.WriteBool( preventEnraged )
		net.Send( ply )
	
		net.Start( "UpdatePlayerRadar" )
			net.WriteBool( playerRadar )
		net.Send( ply )
	
		net.Start( "UpdatePlayerRanking" )
			net.WriteBool( playerRanking )
		net.Send( ply )
	
	end

end
