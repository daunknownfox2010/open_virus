-- Silenced Pistol

SWEP.PrintName = "#weapon_ov_silencedpistol"
SWEP.UseHands = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp_silencer.mdl"

SWEP.Primary.ClipSize = 24
SWEP.Primary.DefaultClip = 24
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "SilencedPistol"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 2
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 4
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.CSMuzzleFlashes = true

local WeaponSound = Sound( "Weapon_USP.SilencedShot" )


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "pistol" )

end


-- Primary attack
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end

    self.Weapon:EmitSound( WeaponSound )

    self:ShootBullet( 16, 1, 0.005 )

    self:TakePrimaryAmmo( 1 )

    self.Owner:ViewPunch( Angle( -0.5, 0, 0 ) )

end


-- Secondary attack
function SWEP:SecondaryAttack()

    return

end


-- When the weapon is reloaded
function SWEP:Reload()

	self.Weapon:DefaultReload( ACT_VM_RELOAD_SILENCED )

end


-- Play some effects when we shoot
function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end


-- Whip it out (hue)
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
	return true

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "a", "CSTRIKETypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
