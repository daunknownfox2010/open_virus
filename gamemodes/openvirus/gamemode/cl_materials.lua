-- Add materials to the game


-- Radar player point
MATERIAL_RADAR = Material( "openvirus/radar.vmt" )
MATERIAL_RADAR_POINT = Material( "openvirus/radar_point.vmt" )

-- Player spawn effect material
MATERIAL_SPAWN_EFFECT = CreateMaterial( "spawnEffectMat", "UnlitGeneric", { [ "$basetexture" ] = "effects/blueblackflash", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )

-- Create this for the infected flame
MATERIAL_INFECTED_FLAME_FRAMES = {}
MATERIAL_INFECTED_FLAME_FRAMES[ 1 ] = CreateMaterial( "infectedFlame1", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )
MATERIAL_INFECTED_FLAME_FRAMES[ 2 ] = CreateMaterial( "infectedFlame2", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1", [ "$frame" ] = "1" } )
MATERIAL_INFECTED_FLAME_FRAMES[ 3 ] = CreateMaterial( "infectedFlame3", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1", [ "$frame" ] = "2" } )
MATERIAL_INFECTED_FLAME_FRAMES[ 4 ] = CreateMaterial( "infectedFlame4", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1", [ "$frame" ] = "3" } )

-- Render SLAM sprite
MATERIAL_SLAM_SPRITE = CreateMaterial( "slamSprite", "UnlitGeneric", { [ "$basetexture" ] = "sprites/laserdot", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )
