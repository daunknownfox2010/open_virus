-- Initialize the music system


-- Console Variables
local enableRoundMusic = CreateClientConVar( "ov_cl_round_music", 1, true, false )


-- This is used internally for a loop timer (just in case you do not want a looped WAV file)
local validLoopMusic = {}
function GM:SetupMusicLooping()

	-- Clear the loop table
	validLoopMusic = {}

	-- Create this directory if it does not exist
	if ( !file.Exists( "openvirus/client/music_loop", "DATA" ) ) then
	
		file.CreateDir( "openvirus/client/music_loop" )
	
	end

	-- Begin searching this folder for text files
	local fileList, folderList = file.Find( "openvirus/client/music_loop/*.txt", "DATA" )
	for k, v in ipairs( fileList ) do
	
		local convertedTable = util.KeyValuesToTable( file.Read( "openvirus/client/music_loop/"..v, "DATA" ) )
		for k2, v2 in pairs( convertedTable ) do
		
			validLoopMusic[ k2 ] = v2
		
		end
	
	end

end


-- Adds the music path to the game
local waitingForPlayersMusic = {}
local preRoundMusic = {}
local inRoundMusic = {}
local lastSurvivorMusic = {}
local infectedWinMusic = {}
local survivorsWinMusic = {}
function GM:AddMusicPath( path, musicType, fileType )

	if ( !isstring( path ) ) then return; end
	if ( !isnumber( musicType ) ) then return; end
	if ( !isstring( fileType ) ) then return; end

	local searchPath = path;
	if ( string.Right( searchPath, 1 ) != "/" ) then
	
		searchPath = searchPath.."/"
	
	end

	local searchPathFind = searchPath
	if ( fileType == "wav" ) then
	
		searchPathFind = "sound/"..searchPath.."*.wav"
	
	elseif ( fileType == "mp3" ) then
	
		searchPathFind = "sound/"..searchPath.."*.mp3"
	
	else
	
		print( "No file type specified!" )
		return
	
	end

	local fileList, folderList = file.Find( searchPathFind, "GAME" )
	for k, v in ipairs( fileList ) do
	
		if ( musicType == ROUNDMUSIC_WFP ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #waitingForPlayersMusic + 1
			waitingForPlayersMusic[ index ] = {}
			waitingForPlayersMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchPath..v )
			waitingForPlayersMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			waitingForPlayersMusic[ index ][ "sound" ]:Stop()
		
			if ( validLoopMusic && validLoopMusic[ searchPath..v ] ) then
			
				waitingForPlayersMusic[ index ][ "duration" ] = validLoopMusic[ searchPath..v ]
			
			end
		
		elseif ( musicType == ROUNDMUSIC_PREROUND ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #preRoundMusic + 1
			preRoundMusic[ index ] = {}
			preRoundMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchPath..v )
			preRoundMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			preRoundMusic[ index ][ "sound" ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_INROUND ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #inRoundMusic + 1
			inRoundMusic[ index ] = {}
			inRoundMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchPath..v )
			inRoundMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			inRoundMusic[ index ][ "sound" ]:Stop()
		
			if ( validLoopMusic && validLoopMusic[ searchPath..v ] ) then
			
				inRoundMusic[ index ][ "duration" ] = validLoopMusic[ searchPath..v ]
			
			end
		
		elseif ( musicType == ROUNDMUSIC_LASTSURVIVOR ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #lastSurvivorMusic + 1
			lastSurvivorMusic[ index ] = {}
			lastSurvivorMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchPath..v )
			lastSurvivorMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			lastSurvivorMusic[ index ][ "sound" ]:Stop()
		
			if ( validLoopMusic && validLoopMusic[ searchPath..v ] ) then
			
				lastSurvivorMusic[ index ][ "duration" ] = validLoopMusic[ searchPath..v ]
			
			end
		
		elseif ( musicType == ROUNDMUSIC_INFECTEDWIN ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #infectedWinMusic + 1
			infectedWinMusic[ index ] = {}
			infectedWinMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchPath..v )
			infectedWinMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			infectedWinMusic[ index ][ "sound" ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_SURVIVORSWIN ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #survivorsWinMusic + 1
			survivorsWinMusic[ index ] = {}
			survivorsWinMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchPath..v )
			survivorsWinMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			survivorsWinMusic[ index ][ "sound" ]:Stop()
		
		else
		
			print( "No valid music type specified!" )
		
		end
	
	end

end


-- Adds a specific music file to the game
function GM:AddMusicFile( searchFile, musicType )

	if ( !isstring( searchFile ) ) then return; end
	if ( !isnumber( musicType ) ) then return; end

	searchFilePath = "sound/"..searchFile

	if ( file.Exists( searchFilePath, "GAME" ) && ( ( string.Right( searchFilePath, 4 ) == ".wav" ) || ( string.Right( searchFilePath, 4 ) == ".mp3" ) ) ) then
	
		if ( musicType == ROUNDMUSIC_WFP ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #waitingForPlayersMusic + 1
			waitingForPlayersMusic[ index ] = {}
			waitingForPlayersMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchFile )
			waitingForPlayersMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			waitingForPlayersMusic[ index ][ "sound" ]:Stop()
		
			if ( validLoopMusic && validLoopMusic[ searchFile ] ) then
			
				waitingForPlayersMusic[ index ][ "duration" ] = validLoopMusic[ searchFile ]
			
			end
		
		elseif ( musicType == ROUNDMUSIC_PREROUND ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #preRoundMusic + 1
			preRoundMusic[ index ] = {}
			preRoundMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchFile )
			preRoundMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			preRoundMusic[ index ][ "sound" ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_INROUND ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #inRoundMusic + 1
			inRoundMusic[ index ] = {}
			inRoundMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchFile )
			inRoundMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			inRoundMusic[ index ][ "sound" ]:Stop()
		
			if ( validLoopMusic && validLoopMusic[ searchFile ] ) then
			
				inRoundMusic[ index ][ "duration" ] = validLoopMusic[ searchFile ]
			
			end
		
		elseif ( musicType == ROUNDMUSIC_LASTSURVIVOR ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #lastSurvivorMusic + 1
			lastSurvivorMusic[ index ] = {}
			lastSurvivorMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchFile )
			lastSurvivorMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			lastSurvivorMusic[ index ][ "sound" ]:Stop()
		
			if ( validLoopMusic && validLoopMusic[ searchFile ] ) then
			
				lastSurvivorMusic[ index ][ "duration" ] = validLoopMusic[ searchFile ]
			
			end
		
		elseif ( musicType == ROUNDMUSIC_INFECTEDWIN ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #infectedWinMusic + 1
			infectedWinMusic[ index ] = {}
			infectedWinMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchFile )
			infectedWinMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			infectedWinMusic[ index ][ "sound" ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_SURVIVORSWIN ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #survivorsWinMusic + 1
			survivorsWinMusic[ index ] = {}
			survivorsWinMusic[ index ][ "sound" ] = CreateSound( game.GetWorld(), searchFile )
			survivorsWinMusic[ index ][ "sound" ]:SetSoundLevel( 0 )
			survivorsWinMusic[ index ][ "sound" ]:Stop()
		
		else
		
			print( "No valid music type specified!" )
		
		end
	
	end

end


-- Play or stop music
function SetRoundMusic( len )

	local musicState = net.ReadInt( 4 )

	if ( !enableRoundMusic:GetBool() ) then return end

	if ( musicState <= ROUNDMUSIC_STOP ) then
	
		if ( timer.Exists( "MusicDuration" ) ) then
		
			timer.Destroy( "MusicDuration" )
		
		end
	
		for k, v in pairs( waitingForPlayersMusic ) do
		
			v[ "sound" ]:Stop()
		
		end
	
		for k, v in pairs( preRoundMusic ) do
		
			v[ "sound" ]:Stop()
		
		end
	
		for k, v in pairs( inRoundMusic ) do
		
			v[ "sound" ]:Stop()
		
		end
	
		for k, v in pairs( lastSurvivorMusic ) do
		
			v[ "sound" ]:Stop()
		
		end
	
		for k, v in pairs( infectedWinMusic ) do
		
			v[ "sound" ]:Stop()
		
		end
	
		for k, v in pairs( survivorsWinMusic ) do
		
			v[ "sound" ]:Stop()
		
		end
	
	elseif ( musicState == ROUNDMUSIC_WFP ) then
	
		if ( #waitingForPlayersMusic > 0 ) then
		
			local selectedMusic = table.Random( waitingForPlayersMusic )
			selectedMusic[ "sound" ]:Play()
		
			if ( !timer.Exists( "MusicDuration" ) && selectedMusic[ "duration" ] ) then
			
				timer.Create( "MusicDuration", selectedMusic[ "duration" ], 0, function() selectedMusic[ "sound" ]:Stop(); selectedMusic[ "sound" ]:Play(); end )
			
			end
		
		end
	
	elseif ( musicState == ROUNDMUSIC_PREROUND ) then
	
		if ( #preRoundMusic > 0 ) then
		
			local selectedMusic = table.Random( preRoundMusic )
			selectedMusic[ "sound" ]:Play()
		
		end
	
	elseif ( musicState == ROUNDMUSIC_INROUND ) then
	
		if ( #inRoundMusic > 0 ) then
		
			local selectedMusic = table.Random( inRoundMusic )
			selectedMusic[ "sound" ]:Play()
		
			if ( !timer.Exists( "MusicDuration" ) && selectedMusic[ "duration" ] ) then
			
				timer.Create( "MusicDuration", selectedMusic[ "duration" ], 0, function() selectedMusic[ "sound" ]:Stop(); selectedMusic[ "sound" ]:Play(); end )
			
			end
		
		end
	
	elseif ( musicState == ROUNDMUSIC_LASTSURVIVOR ) then
	
		if ( #lastSurvivorMusic > 0 ) then
		
			local selectedMusic = table.Random( lastSurvivorMusic )
			selectedMusic[ "sound" ]:Play()
		
			if ( !timer.Exists( "MusicDuration" ) && selectedMusic[ "duration" ] ) then
			
				timer.Create( "MusicDuration", selectedMusic[ "duration" ], 0, function() selectedMusic[ "sound" ]:Stop(); selectedMusic[ "sound" ]:Play(); end )
			
			end
		
		end
	
	elseif ( musicState == ROUNDMUSIC_INFECTEDWIN ) then
	
		if ( #infectedWinMusic > 0 ) then
		
			local selectedMusic = table.Random( infectedWinMusic )
			selectedMusic[ "sound" ]:Play()
		
		end
	
	elseif ( musicState >= ROUNDMUSIC_SURVIVORSWIN ) then
	
		if ( #survivorsWinMusic > 0 ) then
		
			local selectedMusic = table.Random( survivorsWinMusic )
			selectedMusic[ "sound" ]:Play()
		
		end
	
	end

end
net.Receive( "SetRoundMusic", SetRoundMusic )
