-- open Virus PlayerClass

AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

if ( CLIENT ) then

	CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	CreateConVar( "cl_playerskin", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The skin to use, if the model has any" )
	CreateConVar( "cl_playerbodygroups", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The bodygroups to use, if the model has any" )

end

local PLAYER = {}

PLAYER.WalkSpeed = 0
PLAYER.RunSpeed = 0
PLAYER.CrouchedWalkSpeed = 0.3
PLAYER.TeammateNoCollide = false


function PLAYER:SetModel()

	BaseClass.SetModel( self )
	
	local skin = self.Player:GetInfoNum( "cl_playerskin", 0 )
	self.Player:SetSkin( skin )

	local groups = self.Player:GetInfo( "cl_playerbodygroups" )
	if ( groups == nil ) then groups = "" end
	local groups = string.Explode( " ", groups )
	for k = 0, ( self.Player:GetNumBodyGroups() - 1 ) do
	
		self.Player:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
	
	end

end


function PLAYER:GetHandsModel()

	if ( GetConVar( "ov_sv_survivor_css_hands" ):GetBool() ) then
	
    	return { model = "models/weapons/c_arms_cstrike.mdl", skin = 1, body = "0100000" }
	
	end

	local cl_playermodel = self.Player:GetInfo( "cl_playermodel" )
	return player_manager.TranslatePlayerHands( cl_playermodel )

end


player_manager.RegisterClass( "player_virus", PLAYER, "player_default" )
