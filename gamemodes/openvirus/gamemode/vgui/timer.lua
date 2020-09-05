-- Timer

if ( system.IsLinux() ) then

	surface.CreateFont( "TimerDefault", {
		font = "DejaVu Sans",
		size = ControlledScreenScale( 14 ),
		weight = 800
	} )

	surface.CreateFont( "TimerDefaultTime", {
		font = "DejaVu Sans",
		size = ControlledScreenScale( 27 ),
		weight = 900
	} )

else

	surface.CreateFont( "TimerDefault", {
		font = "Tahoma",
		size = ControlledScreenScale( 13 ),
		weight = 800
	} )

	surface.CreateFont( "TimerDefaultTime", {
		font = "Tahoma",
		size = ControlledScreenScale( 26 ),
		weight = 900
	} )

end


local TIMER_PANEL = {

	Init = function( self )
	
		self:SetSize( ControlledScreenScale( 80 ), ControlledScreenScale( 45 ) )
		self:SetPos( ( ScrW() / 2 ) - ControlledScreenScale( 35 ), 15 )
	
	end,

	Paint = function( self, w, h )
	
		-- If cl_drawhud is 0 or we are spectator
		if ( !GetConVar( "cl_drawhud" ):GetBool() ) then return; end
	
		-- Colour depending on team
		local hudColor = Color( 0, 0, 100 )
		if ( IsValid( LocalPlayer() ) && LocalPlayer():IsInfected() ) then
		
			hudColor = Color( 0, 100, 0 )
		
		end
	
		-- Draw the Timer
		if ( !IsRoundState( ROUNDSTATE_PREROUND ) && !IsRoundState( ROUNDSTATE_ENDROUND ) && IsRoundTimeActive() ) then
		
			-- Paint the timer
			draw.RoundedBox( ControlledScreenScale( 4 ), 0, 0, w, h, Color( hudColor.r, hudColor.g, hudColor.b, 200 ) )
		
			-- Draw the text
			draw.SimpleTextOutlined( "TIME LEFT", "TimerDefault", w / 2, ControlledScreenScale( 4 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, math.floor( ControlledScreenScale( 1 ) ), Color( 0, 0, 0, 255 ) )
			draw.SimpleTextOutlined( math.Round( GetCurrentRoundTime() ), "TimerDefaultTime", w / 2, ControlledScreenScale( 17 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, math.floor( ControlledScreenScale( 1 ) ), Color( 0, 0, 0, 255 ) )
		
		end
	
	end

}
vgui.Register( "Timer", TIMER_PANEL, "DPanel" )
