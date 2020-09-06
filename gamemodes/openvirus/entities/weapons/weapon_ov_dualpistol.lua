-- Dual Pistols

SWEP.PrintName = "#weapon_ov_dualpistol"
SWEP.UseHands = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "DualPistol"
SWEP.Primary.FireSecondary = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 2
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.CSMuzzleFlashes = true

local WeaponSound = Sound( "Weapon_Elite.Single" )


-- Initialize the weapon
function SWEP:Initialize()

	self:SetHoldType( "duel" )

end


-- Primary attack
function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	self.Weapon:EmitSound( WeaponSound )

	self:ShootBullet( 15, 1, 0.045 )

	if ( self.Primary.FireSecondary ) then
	
		self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	
	end

	if ( IsFirstTimePredicted() ) then self.Primary.FireSecondary = !self.Primary.FireSecondary end

	self:TakePrimaryAmmo( 1 )

	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

	self:SetNextPrimaryFire( CurTime() + 0.125 )

end


-- Secondary attack
function SWEP:SecondaryAttack()

	return

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "s", "CSTRIKETypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
