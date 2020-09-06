-- XM1014 Shotgun

SWEP.PrintName = "#weapon_ov_xm1014"
SWEP.UseHands = true

SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"

SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "XM1014"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 2
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 4
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.CSMuzzleFlashes = true

SWEP.Reloading = false
SWEP.ReloadTime = 0

local WeaponSound = Sound( "Weapon_XM1014.Single" )


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "shotgun" )

end


-- Primary attack
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end
    if ( self.Reloading ) then return end

    self.Weapon:EmitSound( WeaponSound )

    self:ShootBullet( 8, 8, 0.15 )

    self:TakePrimaryAmmo( 1 )

    self.Owner:ViewPunch( Angle( -2, 0, 0 ) )

    self:SetNextPrimaryFire( CurTime() + 0.25 )

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
    if ( IsFirstTimePredicted() ) then self.ReloadTime = CurTime() + 0.5 end
    self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
    self.Owner:SetAnimation( PLAYER_RELOAD )

end


-- Think
function SWEP:Think()

    if ( self.Reloading && ( self.ReloadTime < CurTime() ) ) then
    
        if ( ( self:Ammo1() <= 0 ) || ( self.Weapon:Clip1() >= self.Primary.ClipSize ) ) then
        
            self:SetNextPrimaryFire( CurTime() + 0.5 )
        
            self.Reloading = false
            self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
            return
        
        end
    
        if( IsFirstTimePredicted() ) then self.ReloadTime = CurTime() + 0.6 end
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
		draw.SimpleText( "B", "CSTRIKETypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
