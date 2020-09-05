-- FlakSprite

EFFECT.SpriteMat = CreateMaterial( "flaktracer_flare1", "UnlitGeneric", { [ "$basetexture" ] = "sprites/flare1", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )


function EFFECT:Init( data )

	self.StartPos = data:GetOrigin()

    self.DieTime = CurTime() + 1

    -- Sparks
	local effectdata = EffectData()
	effectdata:SetOrigin( self.StartPos )
	effectdata:SetNormal( Vector( -3, -3, -3 ) )
	effectdata:SetMagnitude( 1 )
	effectdata:SetScale( 1 )
	effectdata:SetRadius( 6 )
	util.Effect( "Sparks", effectdata )

	-- Sound
	sound.Play( "FX_RicochetSound.Ricochet", self.StartPos )

end


function EFFECT:Think()

	return ( self.DieTime >= CurTime() )

end


function EFFECT:Render()

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self.StartPos, 32, 32, Color( 255, 200, 0, math.Clamp( 200 * ( self.DieTime - CurTime() ), 0, 200 ) ) )

end
