return {
	corsd = {
		activatewhenbuilt = true,
		buildangle = 4096,
		buildcostenergy = 6787,
		buildcostmetal = 745,
		buildinggrounddecaldecayspeed = 30,
		buildinggrounddecalsizex = 6,
		buildinggrounddecalsizey = 6,
		buildinggrounddecaltype = "corsd_aoplane.dds",
		buildpic = "CORSD.DDS",
		buildtime = 11955,
		category = "ALL NOTLAND NOTSUB NOWEAPON NOTSHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -1 0",
		collisionvolumescales = "65 10 60",
		collisionvolumetype = "Box",
		corpse = "DEAD",
		description = "Intrusion Countermeasure System",
		energyuse = 125,
		explodeas = "largeBuildingExplosionGenericWhite",
		footprintx = 4,
		footprintz = 4,
		icontype = "building",
		idleautoheal = 5,
		idletime = 1800,
		levelground = false,
		maxdamage = 2500,
		maxslope = 36,
		maxwaterdepth = 0,
		name = "Nemesis",
		objectname = "CORSD",
		onoffable = true,
		seismicdistance = 2000,
		seismicsignature = 0,
		selfdestructas = "largeBuildingExplosionGenericWhite",
		sightdistance = 225,
		usebuildinggrounddecal = true,
		yardmap = "oooooooooooooooo",
		customparams = {
			death_sounds = "generic",
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "-1.15772247314 -1.86200052979 2.43579101563",
				collisionvolumescales = "68.8967437744 12.3805389404 66.8254699707",
				collisionvolumetype = "Box",
				damage = 1500,
				description = "Nemesis Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 4,
				footprintz = 4,
				height = 15,
				hitdensity = 100,
				metal = 584,
				object = "CORSD_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 750,
				description = "Nemesis Heap",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 4,
				footprintz = 4,
				height = 4,
				hitdensity = 100,
				metal = 234,
				object = "4X4A",
                collisionvolumescales = "85.0 14.0 6.0",
                collisionvolumetype = "cylY",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = { 
 			pieceExplosionGenerators = { 
				"deathceg3",
				"deathceg4",
			},
		},
		sounds = {
			activate = "targon2",
			canceldestruct = "cancel2",
			deactivate = "targoff2",
			underattack = "warning1",
			working = "targsel2",
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			select = {
				[1] = "targsel2",
			},
		},
	},
}
