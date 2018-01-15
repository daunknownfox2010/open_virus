-- Fix up cs_office for Virus gameplay


function OVMap_PostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "func_breakable*" ) ) do
	
		ent:Fire( "SetHealth", "" )
	
    end

	for _, ent in pairs( ents.FindByClass( "prop_physics*" ) ) do
	
		ent:Remove()
	
    end

end
hook.Add( "PostCleanupMap", "OVMap_PostCleanupMap", OVMap_PostCleanupMap )
