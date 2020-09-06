-- Adrenaline

SWEP.PrintName = "#weapon_ov_adrenaline"
SWEP.UseHands = true

SWEP.ViewModelFOV = 0
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_arms_animations.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.OwnerWeaponList = {}
SWEP.Used = false
SWEP.DeployTime = 0
SWEP.RemoveTime = 0

local WeaponSound = Sound( "physics/flesh/flesh_impact_bullet3.wav" )


-- Initialize the weapon
function SWEP:Initialize()

	self:SetHoldType( "slam" )

end


-- Primary attack
function SWEP:PrimaryAttack()

	if ( self.DeployTime >= CurTime() ) then return end
	if ( self.Used ) then return end

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( IsFirstTimePredicted() ) then self.RemoveTime = CurTime() + 0.5 end
	self.Used = true

end


-- Secondary attack
function SWEP:SecondaryAttack()

	return

end


-- Draw the world model
function SWEP:DrawWorldModel()

	-- Do not draw the world model
	return

end


-- Whip it out (hue)
function SWEP:Deploy()

	self.DeployTime = CurTime() + 0.1
	self.Used = false

	return true

end


-- Put it away
function SWEP:Holster()

	self.Used = false

	return true

end


-- Think
function SWEP:Think()

	if ( IsValid( self.Owner ) && self.Owner:IsBot() && ( self.Owner:GetActiveWeapon() && self.Owner:GetActiveWeapon():IsValid() && ( self.Owner:GetActiveWeapon() == self.Entity ) ) ) then
	
		self:PrimaryAttack()
	
	end

	if ( self.Used && ( self.RemoveTime < CurTime() ) ) then
	
		self.OwnerWeaponList = {}
		for k, v in pairs( self.Owner:GetWeapons() ) do
		
			if ( v != self.Weapon ) then
			
				if ( IsFirstTimePredicted() ) then table.insert( self.OwnerWeaponList, v ) end
			
			end
		
		end
	
		if ( SERVER && self.OwnerWeaponList && IsValid( self.OwnerWeaponList[ 1 ] ) ) then self.Owner:SelectWeapon( self.OwnerWeaponList[ 1 ]:GetClass() ) end
	
		if ( SERVER ) then
		
			self.Owner.timeAdrenalineStatus = CurTime() + 15
			self.Owner:SetAdrenalineStatus( true )
			self.Owner:EmitSound( WeaponSound, 75, 90 )
		
			self:Remove()
		
		end
	
	end

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "G", "CSTRIKETypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
