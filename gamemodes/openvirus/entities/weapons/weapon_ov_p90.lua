-- P90

SWEP.PrintName = "#weapon_ov_p90"
SWEP.UseHands = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "P90"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 4
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.CSMuzzleFlashes = true

local WeaponSound = Sound( "Weapon_P90.Single" )


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "smg" )

end


-- Primary attack
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end

    self.Weapon:EmitSound( WeaponSound )

    self:ShootBullet( 11, 1, 0.025 )

    self:TakePrimaryAmmo( 1 )

    self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

    self:SetNextPrimaryFire( CurTime() + 0.1 )

end


-- Secondary attack
function SWEP:SecondaryAttack()

    return

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
        draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "m", "CSTRIKETypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
