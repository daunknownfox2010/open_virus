-- Fix up cs_militia for Virus gameplay

AddCSLuaFile()

if ( CLIENT ) then return; end


function VirusMapPostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "func_door_rotating" ) ) do
	
		ent:Fire( "Open" )
        ent:Fire( "Kill", "", "1" )
	
    end

end
hook.Add( "PostCleanupMap", "VirusMapPostCleanupMap", VirusMapPostCleanupMap )
