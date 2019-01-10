-- Ranking

if ( system.IsLinux() ) then

	surface.CreateFont( "RankingDefault", {
		font = "DejaVu Sans",
		size = ControlledScreenScale( 12 ),
		weight = 800
	} )

else

	surface.CreateFont( "RankingDefault", {
		font = "Tahoma",
		size = ControlledScreenScale( 11 ),
		weight = 800
	} )

end

surface.CreateFont( "RankingDisplayDefault", {
	font = "Verdana",
	size = ControlledScreenScale( 16 ),
	weight = 700,
	antialias = false,
	shadow = true
} )


local storedFrags = 0
local storedFragsTime = 0
local RANKING_PANEL = {

	Init = function( self )
	
		self:SetSize( ControlledScreenScale( 60 ), ControlledScreenScale( 36 ) )
		self:SetPos( 15, ScrH() - ControlledScreenScale( 36 ) - 15 )
	
	end,

	Paint = function( self, w, h )
	
		-- If cl_drawhud is 0 or we are spectator
		if ( !GetConVar( "cl_drawhud" ):GetBool() ) then return; end
	
		-- Colour depending on team
		local hudColor = Color( 0, 0, 100 )
		if ( IsValid( LocalPlayer() ) && LocalPlayer():IsInfected() ) then
		
			hudColor = Color( 0, 100, 0 )
		
		end
	
		-- Show score on the HUD
		if ( IsValid( LocalPlayer() ) && ( storedFrags != LocalPlayer():Frags() ) ) then
		
			storedFrags = LocalPlayer():Frags()
			storedFragsTime = CurTime() + 4
		
		end
	
		-- Ranking
		if ( IsPlayerRankingEnabled() ) then
		
			local localPlayerRank = GAMEMODE:GetPlayerRank( LocalPlayer() )
			if ( ( IsRoundState( ROUNDSTATE_INROUND ) || IsRoundState( ROUNDSTATE_LASTSURVIVOR ) ) && ( localPlayerRank != 0 ) && !LocalPlayer():IsSpectating() ) then
			
				draw.RoundedBox( ControlledScreenScale( 4 ), 0, 0, w, h, Color( hudColor.r, hudColor.g, hudColor.b, 200 ) )
			
				local rankAlpha = ( ( 0.5 - math.Clamp( storedFragsTime - CurTime(), 0, 0.5 ) ) / 0.5 ) * 255
				draw.SimpleTextOutlined( "RANK", "RankingDefault", w / 2, h - ControlledScreenScale( 4 ), Color( 255, 255, 255, rankAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, math.floor( ControlledScreenScale( 1 ) ), Color( 0, 0, 0, rankAlpha ) )
				draw.SimpleTextOutlined( localPlayerRank, "RankingDisplayDefault", w / 2, h - ControlledScreenScale( 16 ), Color( 255, 255, 255, rankAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, math.floor( ControlledScreenScale( 1 ) ), Color( 0, 0, 0, rankAlpha ) )
			
				if ( storedFragsTime >= CurTime() ) then
				
					local fragsAlpha = ( math.Clamp( storedFragsTime - CurTime(), 0, 0.5 ) / 0.5 ) * 255
					draw.SimpleTextOutlined( "SCORE", "RankingDefault", w / 2, h - ControlledScreenScale( 4 ), Color( 255, 255, 255, fragsAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, math.floor( ControlledScreenScale( 1 ) ), Color( 0, 0, 0, fragsAlpha ) )
					draw.SimpleTextOutlined( storedFrags, "RankingDisplayDefault", w / 2, h - ControlledScreenScale( 16 ), Color( 255, 255, 255, fragsAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, math.floor( ControlledScreenScale( 1 ) ), Color( 0, 0, 0, fragsAlpha ) )
				
				end
			
			end
		
		end
	
	end

}
vgui.Register( "Ranking", RANKING_PANEL, "DPanel" )
