return {
	corfort = {
		acceleration = 0,
		blocking = true,
		brakerate = 0,
		buildangle = 0,
		buildcostenergy = 1098,
		buildcostmetal = 38,
		buildinggrounddecaldecayspeed = 30,
		buildinggrounddecalsizex = 4,
		buildinggrounddecalsizey = 4,
		buildinggrounddecaltype = "corfort_aoplane.dds",
		buildpic = "CORFORT.DDS",
		buildtime = 1010,
		canattack = false,
		canrepeat = false,
		category = "ALL NOTLAND NOTSUB NOWEAPON NOTSHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -4 0",
		collisionvolumescales = "32 52 32",
		collisionvolumetype = "CylY",
		corpse = "ROCKTEETHX",
		crushresistance = 1000,
		description = "Perimeter Defense",
		footprintx = 2,
		footprintz = 2,
		hidedamage = true,
		idleautoheal = 0,
		levelground = false,
		maxdamage = 8000,
		maxslope = 24,
		maxwaterdepth = 0,
		name = "Fortification Wall",
		objectname = "CORFORT",
		repairable = false,
		seismicsignature = 0,
		sightdistance = 1,
		usebuildinggrounddecal = true,
		yardmap = "ffff",
		customparams = {
			death_sounds = "generic",
		},
		featuredefs = {
			rockteethx = {
				animating = 0,
				animtrans = 0,
				blocking = true,
				category = "rocks NOTHOVER",
				damage = 3000,
				description = "Rubble",
				footprintx = 2,
				footprintz = 2,
				height = 20,
				hitdensity = 100,
				metal = 7,
				object = "2X2A",
                collisionvolumescales = "35.0 4.0 6.0",
                collisionvolumetype = "cylY",
				reclaimable = true,
				shadtrans = 1,
				world = "greenworld",
			},
		},
		sfxtypes = { 
			pieceExplosionGenerators = { 
				"deathceg3", 
				"deathceg4", 
			}, 
		},
	},
}
