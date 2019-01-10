-- Laser Rifle (Hybrid)

SWEP.PrintName = "#weapon_ov_laserriflehybrid"
SWEP.UseHands = true

SWEP.ViewModelFOV = 58
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Charge = 0
SWEP.Primary.ChargeSlowdown = false
SWEP.Primary.ChargeUpdate = 0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Charge = 0
SWEP.Secondary.ChargeUpdate = 0
SWEP.Secondary.Target = nil

SWEP.Weight = 3
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 3
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

local WeaponSound = Sound( "weapons/gauss/fire1.wav" )
local OverChargeSound = Sound( "npc/attack_helicopter/aheli_damaged_alarm1.wav" )
local ReChargeSound = Sound( "weapons/physcannon/physcannon_charge.wav" )
local BlastSound = Sound( "Weapon_Mortar.Impact" )
local BlastChargeSound = Sound( "Weapon_AR2.Reload_Rotate" )


-- Initialize the weapon
function SWEP:Initialize()

	self:SetHoldType( "ar2" )

end


-- Primary attack
function SWEP:PrimaryAttack()

	if ( self.Secondary.Charge > 0 ) then return; end

	if ( self.Primary.Charge < 100 ) then
	
		if ( IsFirstTimePredicted() ) then self.Primary.Charge = self.Primary.Charge + 5; end
	
		if ( !self.Primary.ChargeSlowdown && ( self.Primary.Charge > 75 ) ) then
		
			self.Primary.ChargeSlowdown = true
			self.Weapon:EmitSound( OverChargeSound, 110, 150, 0.75, CHAN_STATIC )
		
		end
	
		if ( self.Primary.Charge > 100 ) then
		
			self.Primary.Charge = 100
		
		end
	
	end

	self.Weapon:EmitSound( WeaponSound, 90, 110 )

	self:ShootBullet( 16, 1, 0.015 )

	self.Owner:ViewPunch( Angle( -0.25, 0, 0 ) )

	self:SetNextPrimaryFire( CurTime() + math.Clamp( self.Primary.Charge / 100, 0.125, 0.75 ) )

end


-- Secondary attack
function SWEP:SecondaryAttack()

	return

end


-- Think
function SWEP:Think()

	-- Primary charge
	if ( IsValid( self.Owner ) && self.Owner:IsPlayer() && self.Owner:Alive() ) then
	
		if ( !self.Owner:KeyDown( IN_ATTACK ) || ( self.Secondary.Charge > 0 ) ) then
		
			if ( ( ( self:GetNextPrimaryFire() + 1 ) < CurTime() ) && ( self.Primary.Charge > 0 ) && ( self.Primary.ChargeUpdate < CurTime() ) ) then
			
				if ( IsFirstTimePredicted() ) then
				
					self.Primary.ChargeUpdate = CurTime() + 0.01
					self.Primary.Charge = self.Primary.Charge - ( 0.5 / ( 1 / engine.TickInterval() / 100 ) )
				
				end
			
				if ( self.Primary.ChargeSlowdown && ( self.Primary.Charge < 25 ) ) then
				
					self.Primary.ChargeSlowdown = false
					self.Weapon:EmitSound( ReChargeSound, 75, 110, 0.42, CHAN_STATIC )
				
				end
			
				if ( self.Primary.Charge < 0 ) then
				
					self.Primary.Charge = 0
				
				end
			
			end
		
		end
	
	end

	-- Secondary charge
	if ( IsValid( self.Owner ) && self.Owner:IsPlayer() && self.Owner:Alive() && ( self.Primary.Charge <= 0 ) ) then
	
		if ( self.Owner:KeyDown( IN_ATTACK2 ) ) then
		
			if ( CLIENT && IsFirstTimePredicted() ) then util.ScreenShake( self.Owner:EyePos(), self.Secondary.Charge / 100, 4, 0.1, 4 ); end
		
			if ( ( self.Secondary.Charge < 100 ) && ( self.Secondary.ChargeUpdate < CurTime() ) ) then
			
				if ( self.Secondary.Charge <= 0 ) then self.Weapon:EmitSound( BlastChargeSound ); end
			
				if ( IsFirstTimePredicted() ) then
				
					self.Secondary.ChargeUpdate = CurTime() + 0.01
					self.Secondary.Charge = self.Secondary.Charge + ( 2 / ( 1 / engine.TickInterval() / 100 ) )
				
				end
			
				if ( self.Secondary.Charge > 100 ) then
				
					self.Secondary.Charge = 100
				
				end
			
			end
		
		else
		
			if ( self.Secondary.Charge >= 100 ) then
			
				if ( IsFirstTimePredicted() ) then
				
					if ( ( CLIENT && self.Owner:ShouldDrawLocalPlayer() ) || SERVER ) then
					
						local soniceffect = EffectData()
						soniceffect:SetOrigin( self:GetAttachment( 1 ).Pos )
						util.Effect( "cball_explode", soniceffect )
					
					else
					
						local soniceffect = EffectData()
						soniceffect:SetOrigin( self.Owner:GetViewModel():GetAttachment( 1 ).Pos )
						util.Effect( "cball_explode", soniceffect )
					
					end
				
				end
			
				self.Weapon:EmitSound( BlastSound )
			
				self.Owner:LagCompensation( true )
			
				self.Secondary.Target = self.Owner:GetEyeTrace().Entity
				self.Secondary.TargetDistance = self.Secondary.Target:GetPos():Distance( self.Owner:GetPos() )
			
				self.Owner:LagCompensation( false )
			
				self.Owner:ViewPunch( Angle( -16, 0, 0 ) )
			
				if ( SERVER && IsValid( self.Secondary.Target ) && self.Secondary.Target:IsPlayer() && self.Secondary.Target:Alive() && ( self.Secondary.Target:Team() == TEAM_INFECTED ) && ( self.Secondary.TargetDistance <= 400 ) ) then
				
					local calculated_velocity = self.Secondary.Target:GetPos() - self.Owner:GetPos()
					self.Secondary.Target:SetVelocity( Vector( calculated_velocity.x, calculated_velocity.y, 16 ) * 16 )
				
				end
			
			end
		
			if ( self.Secondary.Charge > 0 ) then
			
				if ( IsFirstTimePredicted() ) then self.Secondary.Charge = 0; end
			
			end
		
		end
	
	end

end


-- Shoot bullets
function SWEP:ShootBullet( damage, num_bullets, aimcone )

	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )
	bullet.Tracer	= 1
	bullet.TracerName = "plasmatracer"
	bullet.Force	= 1
	bullet.Damage	= damage

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end


-- Whip it out (hue)
function SWEP:Deploy()

	return true

end


if ( CLIENT ) then

	-- Draw a HUD
	function SWEP:DrawHUD()
	
		if ( self.Primary.Charge > 0 ) then
		
			draw.RoundedBox( 2, ScrW() / 2 - ( ScrH() * 0.25 / 2 ), ScrH() / 1.1, ScrH() * 0.25, ScrH() * 0.025, Color( 0, 0, 0, 200 ) )
			draw.RoundedBox( 1, ScrW() / 2 - ( ScrH() * 0.25 / 2 ) + 2, ScrH() / 1.1 + 2, ( ScrH() * 0.25 - 4 ) * ( self.Primary.Charge / 100 ), ScrH() * 0.025 - 4, Color( 255, 255 - ( ( self.Primary.Charge / 100 ) * 255 ), 255 - ( ( self.Primary.Charge / 100 ) * 255 ), 200 ) )
		
		end
	
		if ( self.Secondary.Charge > 0 ) then
		
			draw.RoundedBox( 2, ScrW() / 2 - ( ScrH() * 0.25 / 2 ), ScrH() / 1.05, ScrH() * 0.25, ScrH() * 0.025, Color( 0, 0, 0, 200 ) )
			draw.RoundedBox( 1, ScrW() / 2 - ( ScrH() * 0.25 / 2 ) + 2, ScrH() / 1.05 + 2, ( ScrH() * 0.25 - 4 ) * ( self.Secondary.Charge / 100 ), ScrH() * 0.025 - 4, Color( 0, 255, 255 , 200 ) )
		
		end
	
	end

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "2", "HL2MPTypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
