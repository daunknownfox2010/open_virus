-- Add dm_alcys_camping compatibility

AddCSLuaFile()

if ( CLIENT ) then return; end


function VirusMapPostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "info_player_start" ) ) do
	
		ent:Remove()
	
	end

	for _, ent in pairs( ents.FindByClass( "item_*" ) ) do
	
		ent:Remove()
	
	end

	for _, ent in pairs( ents.FindByClass( "weapon_*" ) ) do
	
		if ( ent:CreatedByMap() ) then ent:Remove() end
	
	end

	for _, ent in pairs( ents.FindByClass( "func_door*" ) ) do
	
		ent:Remove()
	
	end

	for _, ent in pairs( ents.FindByClass( "prop_physics*" ) ) do
	
		if ( ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then
		
			timer.Simple( 2, function() if ( IsValid( ent ) && IsValid( ent:GetPhysicsObject() ) ) then ent:GetPhysicsObject():EnableMotion( false ) end end )
		
		end
	
	end

end
hook.Add( "PostCleanupMap", "VirusMapPostCleanupMap", VirusMapPostCleanupMap )
