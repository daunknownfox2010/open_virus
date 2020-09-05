-- This is an entity created when survivors spawn

if ( SERVER ) then AddCSLuaFile() end


-- Initialize the effect
function EFFECT:Init( data )

	self.Data = data
	self.LifeTime = CurTime() + 2

	self.DLight = DynamicLight( self.Data:GetEntity():EntIndex() )
	if ( self.DLight ) then
	
		self.DLight.brightness = 1
		self.DLight.decay = 660
		self.DLight.dietime = CurTime() + 1.5
		self.DLight.pos = self.Data:GetOrigin()
		self.DLight.size = 512
		self.DLight.r = 0
		self.DLight.g = 0
		self.DLight.b = 255
	
	end

	self.ParticleEmitter = ParticleEmitter( self.Data:GetOrigin(), false )
	for pnum = 1, 4 do
	
		self.Particle = self.ParticleEmitter:Add( MATERIAL_SPAWN_EFFECT, self.Data:GetOrigin() )
		if ( self.Particle ) then
		
			self.Particle:SetAngles( self.Data:GetAngles() )
			self.Particle:SetColor( 0, 255, 255 )
			self.Particle:SetLifeTime( 0 )
			self.Particle:SetDieTime( 1 )
			self.Particle:SetStartAlpha( 255 )
			self.Particle:SetEndAlpha( 0 )
			self.Particle:SetStartSize( 64 )
			self.Particle:SetEndSize( 64 )
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
