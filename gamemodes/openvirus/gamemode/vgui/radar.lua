-- Radar


local pingTime = 0
local RADAR_PANEL = {

	Init = function( self )
	
		self:SetSize( ControlledScreenScale( 128 ), ControlledScreenScale( 128 ) )
		self:SetPos( 15, 15 )
	
	end,

	Think = function( self )
	
		-- Do not think under these conditions
		if ( !GetConVar( "cl_drawhud" ):GetBool() ) then return; end
		if ( !IsPlayerRadarEnabled() ) then return; end
		if ( IsRoundState( ROUNDSTATE_PREROUND ) || IsRoundState( ROUNDSTATE_ENDROUND ) || LocalPlayer():IsSpectating() ) then return; end
	
		local pingTimeAhead = pingTime + 1
		if ( pingTimeAhead < CurTime() ) then
		
			pingTime = CurTime() + 1
		
		end
	
	end,

	Paint = function( self, w, h )
	
		-- If cl_drawhud is 0 or we are spectator
		if ( !GetConVar( "cl_drawhud" ):GetBool() ) then return; end
	
		-- Colour depending on team
		local hudColor = Color( 0, 0, 100 )
		if ( IsValid( LocalPlayer() ) && LocalPlayer():IsInfected() ) then
		
			hudColor = Color( 0, 100, 0 )
		
		end
	
		-- Radar
		if ( IsPlayerRadarEnabled() ) then
		
			if ( !IsRoundState( ROUNDSTATE_PREROUND ) && !IsRoundState( ROUNDSTATE_ENDROUND ) && !LocalPlayer():IsSpectating() ) then
			
				-- Draw some lines
				surface.SetDrawColor( hudColor.r, hudColor.g, hudColor.b, 50 )
				surface.DrawLine( w / 2, 0, w / 2, h )
				surface.DrawLine( 0, h / 2, w, h / 2 )
			
				-- Draw the circle
				surface.SetDrawColor( hudColor.r, hudColor.g, hudColor.b, 200 )
				surface.SetMaterial( MATERIAL_RADAR )
				surface.DrawTexturedRect( 0, 0, w, h )
			
				-- Draw the ping circle
				if ( pingTime >= CurTime() ) then
				
					local alpha = ( math.Clamp( ( pingTime - CurTime() ) - 0.05, 0, 0.5 ) / 0.5 ) * 50
					local size = { width = ( w - ( ( ( pingTime - CurTime() ) / 1 ) * w ) ), height = ( h - ( ( ( pingTime - CurTime() ) / 1 ) * h ) ) }
					local position = { x = ( ( w / 2 ) - ( size.width / 2 ) ), y = ( ( h / 2 ) - ( size.height / 2 ) ) }
					surface.SetDrawColor( 255, 255, 255, alpha )
					surface.SetMaterial( MATERIAL_RADAR )
					surface.DrawTexturedRect( position.x, position.y, size.width, size.height )
				
				end
			
				-- Begin putting dots on the radar
				for _, ply in pairs( player.GetAll() ) do
				
					if ( IsValid( ply ) && ply:Alive() && ( ply:IsSurvivor() || ply:IsInfected() ) && ( ply != LocalPlayer() ) ) then
					
						local x_diff = ply:GetPos().x - LocalPlayer():GetPos().x
						local y_diff = ply:GetPos().y - LocalPlayer():GetPos().y
					
						if ( x_diff == 0 ) then x_diff = 0.00001; end
						if ( y_diff == 0 ) then y_diff = 0.00001; end
					
						local iRadarRadius = w - ControlledScreenScale( 5 )
					
						local fScale = ( iRadarRadius / 2.15 ) / 1024
					
						local flOffset = math.atan( y_diff / x_diff )
						flOffset = flOffset * 180
						flOffset = flOffset / math.pi
					
						if ( ( x_diff < 0 ) && ( y_diff >= 0 ) ) then
						
							flOffset = 180 + flOffset
						
						elseif ( ( x_diff < 0 ) && ( y_diff < 0 ) ) then
						
							flOffset = 180 + flOffset
						
						elseif ( ( x_diff >= 0 ) && ( y_diff < 0 ) ) then
						
							flOffset = 360 + flOffset
						
						end
					
						y_diff = -1 * ( math.sqrt( ( x_diff ) * ( x_diff ) + ( y_diff ) * ( y_diff ) ) )
						x_diff = 0
					
						flOffset = LocalPlayer():GetAngles().y - flOffset
					
						flOffset = flOffset * math.pi
						flOffset = flOffset / 180
					
						local xnew_diff = x_diff * math.cos( flOffset ) - y_diff * math.sin( flOffset )
						local ynew_diff = x_diff * math.sin( flOffset ) + y_diff * math.cos( flOffset )
					
						if ( ( -1 * y_diff ) > 1024 ) then
						
							local flScale = ( -1 * y_diff ) / 1024
						
							xnew_diff = xnew_diff / flScale
							ynew_diff = ynew_diff / flScale
						
                        end
					
						xnew_diff = xnew_diff * fScale
						ynew_diff = ynew_diff * fScale
					
						-- Draw the dots
						local dotColor = Color( 255, 255, 255 )
						local dotAlpha = math.Clamp( 255 - ( ( ply:GetPos():Distance( LocalPlayer():GetPos() ) / 1024 ) * 255 ), 8, 255 )
						if ( LocalPlayer():Team() != ply:Team() ) then
						
							dotColor = Color( 255, 0, 0 )
						
						end
					
						surface.SetDrawColor( dotColor.r, dotColor.g, dotColor.b, dotAlpha )
						surface.SetMaterial( MATERIAL_RADAR_POINT )
						surface.DrawTexturedRect( ( iRadarRadius / 2 ) + math.Round( xnew_diff ), ( iRadarRadius / 2 ) + math.Round( ynew_diff ), ControlledScreenScale( 5 ), ControlledScreenScale( 5 ) )
					
					end
				
				end
			
			end
		
		end
	
	end

}
vgui.Register( "Radar", RADAR_PANEL, "DPanel" )
