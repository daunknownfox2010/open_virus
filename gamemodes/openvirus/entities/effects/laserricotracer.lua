
EFFECT.Mat = CreateMaterial( "lasertracer_bluelaser1", "UnlitGeneric", { [ "$basetexture" ] = "effects/bluelaser1", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )
EFFECT.SpriteMat = CreateMaterial( "lasertracer_blueflare1", "UnlitGeneric", { [ "$basetexture" ] = "sprites/blueflare1", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )

function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()

	self.Alpha = 255
	self.Life = 0

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	-- Sparks
	local effectdata = EffectData()
	effectdata:SetOrigin( self.StartPos )
	effectdata:SetNormal( ( self.EndPos - self.StartPos ):GetNormalized() * -3 )
	effectdata:SetMagnitude( 1 )
	effectdata:SetScale( 1 )
	effectdata:SetRadius( 6 )
	util.Effect( "Sparks", effectdata )

	-- Sound
	sound.Play( "FX_RicochetSound.Ricochet", self.StartPos )

end

function EFFECT:Think()

	self.Life = self.Life + FrameTime() * 4
	self.Alpha = 255 * ( 1 - self.Life )

	return ( self.Life < 1 )

end

function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self.EndPos, 32, 32, Color( 128, 128, 255, 128 * ( 1 - self.Life ) ) )

	render.SetMaterial( self.Mat )
	local texcoord = math.Rand( 0, 1 )

	local norm = ( self.StartPos - self.EndPos ) * self.Life

	self.Length = norm:Length()

	for i = 1, 3 do
	
		render.DrawBeam( self.StartPos, self.EndPos, 8, texcoord, texcoord +  ( ( self.StartPos - self.EndPos ):Length() / 128 ), Color( 255, 255, 255, 128 * ( 1 - self.Life ) ) )
	
	end

end
