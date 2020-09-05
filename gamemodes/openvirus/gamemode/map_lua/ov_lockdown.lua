-- Fix up some left over mistakes in ov_lockdown

AddCSLuaFile()

if ( CLIENT ) then return; end


function VirusMapPostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "item_*" ) ) do
	
		ent:Remove()
	
    end

	for _, ent in pairs( ents.FindByClass( "prop_physics*" ) ) do
	
		if ( ent:GetModel() == "models/props_junk/metalbucket01a.mdl" ) then
		
			ent:Remove()
		
		end
	
		if ( ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then
		
			timer.Simple( 2, function() if ( IsValid( ent ) && IsValid( ent:GetPhysicsObject() ) ) then ent:GetPhysicsObject():EnableMotion( false ) end end )
		
		end
	
	end

	-- Add this to the top of the main area ladder
	local blocker_prop = ents.Create( "prop_physics" )
	blocker_prop:SetPos( Vector( -2730, 5056, 274 ) )
	blocker_prop:SetModel( "models/hunter/plates/plate1x1.mdl" )
	blocker_prop:SetRenderMode( RENDERMODE_NONE )
	blocker_prop:DrawShadow( false )
	blocker_prop:Spawn()
	blocker_prop:Activate()
	if ( IsValid( blocker_prop:GetPhysicsObject() ) ) then blocker_prop:GetPhysicsObject():EnableMotion( false ) end

	-- Add this to the top of the jail area ladder
	local blocker_prop = ents.Create( "prop_physics" )
	blocker_prop:SetPos( Vector( -4148, 4188, 274 ) )
	blocker_prop:SetModel( "models/hunter/plates/plate1x1.mdl" )
	blocker_prop:SetRenderMode( RENDERMODE_NONE )
	blocker_prop:DrawShadow( false )
	blocker_prop:Spawn()
	blocker_prop:Activate()
	if ( IsValid( blocker_prop:GetPhysicsObject() ) ) then blocker_prop:GetPhysicsObject():EnableMotion( false ) end

	-- Add this to the shower on its left
	local blocker_prop = ents.Create( "prop_physics" )
	blocker_prop:SetPos( Vector( -2832, 2450, 119 ) )
	blocker_prop:SetModel( "models/hunter/plates/plate1x1.mdl" )
	blocker_prop:SetRenderMode( RENDERMODE_NONE )
	blocker_prop:DrawShadow( false )
	blocker_prop:Spawn()
	blocker_prop:Activate()
	if ( IsValid( blocker_prop:GetPhysicsObject() ) ) then blocker_prop:GetPhysicsObject():EnableMotion( false ) end

	-- Add this to the shower on its left
	local blocker_prop = ents.Create( "prop_physics" )
	blocker_prop:SetPos( Vector( -2832, 2415, 119 ) )
	blocker_prop:SetModel( "models/hunter/plates/plate1x1.mdl" )
	blocker_prop:SetRenderMode( RENDERMODE_NONE )
	blocker_prop:DrawShadow( false )
	blocker_prop:Spawn()
	blocker_prop:Activate()
	if ( IsValid( blocker_prop:GetPhysicsObject() ) ) then blocker_prop:GetPhysicsObject():EnableMotion( false ) end

end
hook.Add( "PostCleanupMap", "VirusMapPostCleanupMap", VirusMapPostCleanupMap )
