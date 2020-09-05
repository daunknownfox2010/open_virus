
EFFECT.Mat = CreateMaterial( "lasertracer_bluelaser1", "UnlitGeneric", { [ "$basetexture" ] = "effects/bluelaser1", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )
EFFECT.SpriteMat = CreateMaterial( "lasertracer_physcannon_bluecore2b", "UnlitGeneric", { [ "$basetexture" ] = "sprites/physcannon_bluecore2b", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )
EFFECT.SpriteMatEnd = CreateMaterial( "lasertracer_blueflare1", "UnlitGeneric", { [ "$basetexture" ] = "sprites/blueflare1", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )

function EFFECT:Init( data )

	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()

	self.Alpha = 255
	self.Life = 0

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

end

function EFFECT:Think()

	self.Life = self.Life + FrameTime() * 4
	self.Alpha = 255 * ( 1 - self.Life )

	return ( self.Life < 1 )

end

function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self.StartPos, 16, 16, Color( 128, 128, 255, 128 * ( 1 - self.Life ) ) )

	render.SetMaterial( self.SpriteMatEnd )
	render.DrawSprite( self.EndPos, 32, 32, Color( 128, 128, 255, 128 * ( 1 - self.Life ) ) )

	render.SetMaterial( self.Mat )
	local texcoord = math.Rand( 0, 1 )

	local norm = ( self.StartPos - self.EndPos ) * self.Life

	self.Length = norm:Length()

	for i = 1, 3 do
	
		render.DrawBeam( self.StartPos, self.EndPos, 8, texcoord, texcoord +  ( ( self.StartPos - self.EndPos ):Length() / 128 ), Color( 255, 255, 255, 128 * ( 1 - self.Life ) ) )
	
	end

end
