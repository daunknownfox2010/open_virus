-- Fix up cs_compound for Virus gameplay

AddCSLuaFile()

if ( CLIENT ) then return; end


function VirusMapPostCleanupMap()

	ents.FindByClass( "info_player_start" )[ 1 ]:Remove()

	for _, ent in pairs( ents.FindByClass( "func_breakable" ) ) do
	
		ent:Fire( "SetHealth", "0" )
	
    end

end
hook.Add( "PostCleanupMap", "VirusMapPostCleanupMap", VirusMapPostCleanupMap )
