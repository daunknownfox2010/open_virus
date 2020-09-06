-- This is an entity created by infected

if ( SERVER ) then AddCSLuaFile() end


-- Initialize the effect
function EFFECT:Init( data )

	self.Data = data
	self.LifeTime = CurTime() + 5
	self.Particles = 10

	if ( !GetConVar( "ov_cl_infected_blood" ):GetBool() ) then return end

	self.ParticleEmitter = ParticleEmitter( self.Data:GetOrigin(), false )
	for pnum = 1, self.Particles do
	
		self.Particle = self.ParticleEmitter:Add( "effects/splash4", self.Data:GetOrigin() )
		if ( self.Particle ) then
		
			self.Particle:SetAngles( self.Data:GetAngles() )
			self.Particle:SetVelocity( Vector( math.random( -80, 80 ), math.random( -80, 80 ), 0 ) )
			self.Particle:SetGravity( Vector( 0, 0, GetConVar( "sv_gravity" ):GetFloat() * -1 ) )
			self.Particle:SetCollide( true )
			self.Particle:SetBounce( 0.1 )
			self.Particle:SetColor( 180, 255, 0 )
			self.Particle:SetLifeTime( 0 )
			self.Particle:SetDieTime( 4 )
			self.Particle:SetStartAlpha( 255 )
			self.Particle:SetEndAlpha( 0 )
			self.Particle:SetStartSize( math.random( 4, 6 ) )
			self.Particle:SetEndSize( 0 )
			self.Particle:SetLighting( false )
		
		end
	
	end
	self.ParticleEmitter:Finish()

end


-- Think
function EFFECT:Think()

	return ( self.LifeTime >= CurTime() )

end


-- Render the effect
function EFFECT:Render()

	return true

end
