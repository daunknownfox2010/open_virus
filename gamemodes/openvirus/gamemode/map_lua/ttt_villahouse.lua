-- Add ttt_villahouse compatibility

AddCSLuaFile()

if ( CLIENT ) then return; end


function VirusMapPostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "info_player_start" ) ) do
	
		local start_deathmatch = ents.Create( "info_player_deathmatch" )
		start_deathmatch:SetPos( ent:GetPos() )
		start_deathmatch:SetAngles( ent:GetAngles() )
		start_deathmatch:Spawn()
		start_deathmatch:Activate()
	
		ent:Remove()
	
	end

	for _, ent in pairs( ents.FindByClass( "func_door*" ) ) do
	
		ent:Fire( "Open" )
		ent:Remove()
	
	end

	for _, ent in pairs( ents.FindByClass( "prop_door*" ) ) do
	
		ent:Fire( "Open" )
		ent:Remove()
	
	end

	for _, ent in pairs( ents.FindByClass( "npc_*" ) ) do
	
		ent:Remove()
	
	end

	for _, ent in pairs( ents.FindByClass( "func_breakable*" ) ) do
	
		ent:Fire( "SetHealth", "" )
	
	end

	for _, ent in pairs( ents.FindByClass( "prop_physics*" ) ) do
	
		if ( ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then
		
			timer.Simple( 2, function() if ( IsValid( ent ) && IsValid( ent:GetPhysicsObject() ) ) then ent:GetPhysicsObject():EnableMotion( false ) end end )
		
		end
	
	end

end
hook.Add( "PostCleanupMap", "VirusMapPostCleanupMap", VirusMapPostCleanupMap )
