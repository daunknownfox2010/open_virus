-- Make ov_underground_lockdown default the player flashlights to true

AddCSLuaFile()

if ( CLIENT ) then return; end


function VirusMapPlayerSpawn( ply )

    -- Turn on the flashlight
	if ( ply:IsValid() && ply:Alive() && ply:IsSurvivor() ) then
    
        ply:Flashlight( true )
    
    end

end
hook.Add( "PlayerSpawn", "VirusMapPlayerSpawn", VirusMapPlayerSpawn )
