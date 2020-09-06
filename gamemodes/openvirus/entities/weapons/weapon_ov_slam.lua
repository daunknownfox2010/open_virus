-- Proximity SLAM

SWEP.PrintName = "#weapon_ov_slam"
SWEP.UseHands = true

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

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

SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.SLAMEnt = nil
SWEP.OwnerWeaponList = {}
SWEP.Used = false
SWEP.RemoveTime = 0


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "melee" )
	self:SetDeploySpeed( 10 )

end


-- Primary attack
function SWEP:PrimaryAttack()

	if ( self.Used ) then return end

	self.Used = true
	if ( IsFirstTimePredicted() ) then self.RemoveTime = CurTime() + self.Weapon:SequenceDuration( self.Weapon:SelectWeightedSequence( ACT_SLAM_THROW_THROW_ND ) ) end

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Weapon:SetNoDraw( true )

	self:SetHoldType( "normal" )

	self.Weapon:SendWeaponAnim( ACT_SLAM_THROW_THROW_ND )

end


-- Secondary attack
function SWEP:SecondaryAttack()

    return

end


-- Whip it out (hue)
function SWEP:Deploy()

	self.Used = false
	self.Weapon:SendWeaponAnim( ACT_SLAM_THROW_ND_IDLE )

	return true

end


-- Think
function SWEP:Think()

	if ( self.Used && ( self.RemoveTime < CurTime() ) ) then
	
		self.OwnerWeaponList = {}
		for k, v in pairs( self.Owner:GetWeapons() ) do
		
			if ( v != self.Weapon ) then
			
				if ( IsFirstTimePredicted() ) then table.insert( self.OwnerWeaponList, v ) end
			
			end
		
		end
	
		if ( SERVER && self.OwnerWeaponList && self.OwnerWeaponList[ 1 ] && self.OwnerWeaponList[ 1 ]:IsValid() ) then self.Owner:SelectWeapon( self.OwnerWeaponList[ 1 ]:GetClass() ) end
	
		if ( SERVER ) then
		
			self.SLAMEnt = ents.Create( "ent_ov_slam" )
			self.SLAMEnt:SetPos( self.Owner:GetShootPos() )
			self.SLAMEnt:SetAngles( self.Owner:EyeAngles() )
			self.SLAMEnt:SetOwner( self.Owner )
			self.SLAMEnt:Spawn()
			self.SLAMEnt:Activate()
			self.SLAMEnt:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector() * 400 )
		
			self.SLAMEnt:EmitSound( "Weapon_SLAM.SatchelThrow" )
		
			self:Remove()
		
		end
	
	end

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
		draw.SimpleText( "*", "HL2MPTypeDeath", x + ( w / 2 ), y + ( h / 2 ), Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
