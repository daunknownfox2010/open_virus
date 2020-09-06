-- Sniper Rifle

SWEP.PrintName = "#weapon_ov_sniper"
SWEP.UseHands = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Sniper"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Zoomed = false
SWEP.Secondary.ZoomedMat = Material( "gmod/scope.vmt" )

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 6
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.CSMuzzleFlashes = true

local WeaponSound = Sound( "Weapon_Scout.Single" )


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "ar2" )

end


-- Primary attack
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end

    self.Weapon:EmitSound( WeaponSound )

    self:ShootBullet( 75, 1, 0 )

    self:TakePrimaryAmmo( 1 )

    self.Owner:ViewPunch( Angle( -8, 0, 0 ) )

	self:SetNextPrimaryFire( CurTime() + 1.25 )

end


-- Secondary attack
function SWEP:SecondaryAttack()

    if ( self:GetNextSecondaryFire() > CurTime() ) then return end
	if ( !self.Secondary.Zoomed && ( self.Weapon:Clip1() <= 0 ) ) then return end

	self.Weapon:EmitSound( "Default.Zoom" )

	if ( IsFirstTimePredicted() ) then
	
		self.Secondary.Zoomed = !self.Secondary.Zoomed
	
		if ( self.Secondary.Zoomed ) then
		
			self.Owner:SetFOV( 20, 0.25 )
		
		else
		
			self.Owner:SetFOV( 0, 0.1 )
		
		end
	
	end

	self:SetNextSecondaryFire( CurTime() + 0.3 )

end


-- Reload
function SWEP:Reload()

	if ( self.Secondary.Zoomed ) then self.Owner:SetFOV( 0, 0.1 ) end
    self.Secondary.Zoomed = false

	self.Weapon:DefaultReload( ACT_VM_RELOAD )

end


-- Whip it out (hue)
function SWEP:Deploy()

	self.Secondary.Zoomed = false
	return true

end


-- Put it away
function SWEP:Holster( wep )

	self.Secondary.Zoomed = false
	return true

end


-- Draw a scope and set sensitivity
if ( CLIENT ) then

	function SWEP:DrawHUD()
	
		if ( !self.Owner:ShouldDrawLocalPlayer() && self.Secondary.Zoomed ) then
		
			surface.SetDrawColor( color_black )
		
			surface.DrawLine( ScrW() / 2, 0, ScrW() / 2, ScrH() )
			surface.DrawLine( 0, ScrH() / 2, ScrW(), ScrH() / 2 )
		
			surface.DrawRect( 0, 0, ScrW(), ( ScrH() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ) )
			surface.DrawRect( 0, ( ScrH() / 2 ) + ( ( ScrH() / 1.25 ) / 2 ) - 1, ScrW(), ( ScrH() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ) + 2 )
			surface.DrawRect( 0, ( ScrH() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ), ( ScrW() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ), ( ScrH() / 1.25 ) )
			surface.DrawRect( ( ScrW() / 2 ) + ( ( ScrH() / 1.25 ) / 2 ) - 1, ( ScrH() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ), ( ScrW() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ) + 2, ( ScrH() / 1.25 ) )
		
			surface.SetMaterial( self.Secondary.ZoomedMat )
			surface.DrawTexturedRect( ( ScrW() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ), ( ScrH() / 2 ) - ( ( ScrH() / 1.25 ) / 2 ), ScrH() / 1.25, ScrH() / 1.25 )
		
		end
	
	end

	function SWEP:AdjustMouseSensitivity()
	
		if ( self.Secondary.Zoomed ) then
		
			return 0.2
		
		end
	
	end

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "n", "CSTRIKETypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
