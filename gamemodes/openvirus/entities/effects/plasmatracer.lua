
EFFECT.Mat = CreateMaterial( "plasmatracer_plasmabeam", "UnlitGeneric", { [ "$basetexture" ] = "sprites/plasmabeam", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )
EFFECT.SpriteMat = CreateMaterial( "plasmatracer_plasmaember", "UnlitGeneric", { [ "$basetexture" ] = "sprites/plasmaember", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )

function EFFECT:Init( data )

	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()

	self.Alpha = 255
	self.Life = 0

	self.Data = data
	self.ParticleEmitter = ParticleEmitter( self.Data:GetOrigin(), false )
	for pnum = 1, 10 do
	
		self.Particle = self.ParticleEmitter:Add( "sprites/plasmaember", self.Data:GetOrigin() )

		if ( self.Particle ) then
		
			self.Particle:SetAngles( Angle( 0, 0, 0 ) )
			self.Particle:SetVelocity( Vector( math.random( -80, 80 ), math.random( -80, 80 ), math.random( -80, 80 ) ) )
			self.Particle:SetGravity( Vector( 0, 0, GetConVar( "sv_gravity" ):GetFloat() * -1 ) )
			self.Particle:SetColor( 255, 255, 255 )
			self.Particle:SetLifeTime( 0 )
			self.Particle:SetDieTime( 0.5 )
			self.Particle:SetStartAlpha( 255 )
			self.Particle:SetEndAlpha( 0 )
			self.Particle:SetStartSize( 4 )
			self.Particle:SetEndSize( 0 )
			self.Particle:SetLighting( false )
		
		end
	
	end
	self.ParticleEmitter:Finish()

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
	render.DrawSprite( self.StartPos, 32, 32, Color( 255, 255, 255, 128 * ( 1 - self.Life ) ) )

	render.SetMaterial( self.Mat )
	local texcoord = math.Rand( 0, 1 )

	local norm = ( self.StartPos - self.EndPos ) * self.Life

	self.Length = norm:Length()

	for i = 1, 3 do
	
		render.DrawBeam( self.StartPos - norm, self.EndPos, 8, texcoord, texcoord + ( self.Length / 128 ), Color( 255, 255, 255 ) )
	
	end

	render.DrawBeam( self.StartPos, self.EndPos, 8, texcoord, texcoord + ( ( self.StartPos - self.EndPos ):Length() / 128 ), Color( 255, 255, 255, 128 * ( 1 - self.Life ) ) )

end
