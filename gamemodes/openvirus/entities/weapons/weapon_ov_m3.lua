-- M3 Shotgun

SWEP.PrintName = "#weapon_ov_m3"
SWEP.UseHands = true

SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "M3"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 2
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.CSMuzzleFlashes = true

SWEP.Reloading = false
SWEP.ReloadTime = 0

local WeaponSound = Sound( "Weapon_M3.Single" )


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "shotgun" )

end


-- Primary attack
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end
    if ( self.Reloading ) then return end

    self.Weapon:EmitSound( WeaponSound )

    self:ShootBullet( 10, 8, 0.125 )

    self:TakePrimaryAmmo( 1 )

    self.Owner:ViewPunch( Angle( -2, 0, 0 ) )

    self:SetNextPrimaryFire( CurTime() + 1 )

end


-- Secondary attack
function SWEP:SecondaryAttack()

    return

end


-- Reload
function SWEP:Reload()

    if ( self:Ammo1() <= 0 ) then return end
    if ( self.Weapon:Clip1() >= self.Primary.ClipSize ) then return end
    if ( self.Reloading ) then return end

    self.Reloading = true
    if ( IsFirstTimePredicted() ) then self.ReloadTime = CurTime() + 0.25 end
    self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
    self.Owner:SetAnimation( PLAYER_RELOAD )

end


-- Think
function SWEP:Think()

    if ( self.Reloading && ( self.ReloadTime < CurTime() ) ) then
    
        if ( ( self:Ammo1() <= 0 ) || ( self.Weapon:Clip1() >= self.Primary.ClipSize ) ) then
        
            self:SetNextPrimaryFire( CurTime() + 1 )
        
            self.Reloading = false
            self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
            return
        
        end
    
        if ( IsFirstTimePredicted() ) then self.ReloadTime = CurTime() + 0.8 end
        self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
        self.Owner:SetAnimation( PLAYER_RELOAD )
    
        self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )
        self.Owner:RemoveAmmo( 1, self.Weapon:GetPrimaryAmmoType() )
    
    end

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
        draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "k", "CSTRIKETypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
