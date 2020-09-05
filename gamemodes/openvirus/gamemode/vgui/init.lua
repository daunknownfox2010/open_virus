-- VGUI Initialization

AddCSLuaFile()
AddCSLuaFile( "radar.lua" )
AddCSLuaFile( "ranking.lua" )
AddCSLuaFile( "timer.lua" )

if ( CLIENT ) then

	include( "radar.lua" )
	include( "ranking.lua" )
	include( "timer.lua" )


	-- Reloads the VGUI elements
	local vguiTimer = nil
	local vguiRanking = nil
	local vguiRadar = nil
	function GM:ReloadVGUI()
	
		-- Remove the Timer
		if ( IsValid( vguiTimer ) ) then
		
			vguiTimer:Remove()
		
		end
	
		-- Remove the Ranking
		if ( IsValid( vguiRanking ) ) then
		
			vguiRanking:Remove()
		
		end
	
		-- Remove the Radar
		if ( IsValid( vguiRadar ) ) then
		
			vguiRadar:Remove()
		
		end
	
		-- Initialize the VGUI elements
		hook.Call( "InitializeVGUI", GAMEMODE )
	
	end


	-- Called by the Initialize and Reload function
	function GM:InitializeVGUI()
	
		vguiTimer = vgui.Create( "Timer" )
		vguiRanking = vgui.Create( "Ranking" )
		vguiRadar = vgui.Create( "Radar" )
	
	end

end
