-- Only used for things that need to be called early


-- Console Variables
local screenScale = CreateClientConVar( "ov_cl_screen_scale", 0, true, false, "Scales screen elements with 0 being automatic (useful for higher resolutions)." )


-- Alternative ScreenScale
function ControlledScreenScale( num )

	local scale = screenScale:GetFloat()

	-- 0 is automatic
	if ( !screenScale:GetBool() ) then
	
		-- Automatic scaling is determined by the lowest acceptable res width (1024)
		scale = math.Round( math.Clamp( ScrW() / 1024, 1, 3 ) )
	
	end

	return ( num * scale )

end
