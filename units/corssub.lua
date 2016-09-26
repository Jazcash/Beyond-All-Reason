return {
	corssub = {
		acceleration = 0.028,
		activatewhenbuilt = true,
		brakerate = 0.564,
		buildcostenergy = 12736,
		buildcostmetal = 1874,
		buildpic = "CORSSUB.DDS",
		buildtime = 23007,
		canmove = true,
		category = "ALL UNDERWATER MOBILE WEAPON NOTLAND NOTAIR NOTHOVER",
		collisionvolumeoffsets = "0 0 0",
		collisionvolumescales = "52 14 67",
		collisionvolumetype = "box",
		corpse = "DEAD",
		description = "Battle Submarine",
		energymake = 15,
		energyuse = 15,
		explodeas = "largeExplosionGenericRed",
		footprintx = 3,
		footprintz = 3,
		icontype = "sea",
		idleautoheal = 15,
		idletime = 900,
		maxdamage = 2320,
		maxvelocity = 2.59,
		minwaterdepth = 20,
		movementclass = "UBOAT3",
		name = "Leviathan",
		nochasecategory = "VTOL",
		objectname = "CORSSUB",
		seismicsignature = 0,
		selfdestructas = "largeExplosionGenericRed",
		sightdistance = 520,
		sonardistance = 550,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 1.7094,
		turnrate = 395,
		upright = true,
		waterline = 30,
		customparams = {
			death_sounds = "generic",
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "-6.04158782959 -4.50195312496e-06 -0.0",
				collisionvolumescales = "39.0926055908 13.0902709961 63.9697265625",
				collisionvolumetype = "Box",
				damage = 1172,
				description = "Leviathan Wreckage",
				energy = 0,
				featuredead = "HEAP",
				footprintx = 3,
				footprintz = 3,
				height = 4,
				hitdensity = 100,
				metal = 1202,
				object = "CORSSUB_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 2016,
				description = "Leviathan Heap",
				energy = 0,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 376,
				object = "2X2A",
                collisionvolumescales = "35.0 4.0 6.0",
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
			canceldestruct = "cancel2",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "sucormov",
			},
			select = {
				[1] = "sucorsel",
			},
		},
		weapondefs = {
			corssub_weapon = {
				areaofeffect = 16,
				avoidfeature = false,
				avoidfriendly = false,
				burnblow = true,
				collidefriendly = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				explosiongenerator = "custom:FLASH3",
				impulseboost = 0.123,
				impulsefactor = 0.123,
				model = "advtorpedo",
				name = "advTorpedo",
				noselfdamage = true,
				range = 690,
				reloadtime = 1.5,
				soundhit = "xplodep1",
				soundstart = "torpedo1",
				startvelocity = 150,
				tolerance = 8000,
				tracks = true,
				turnrate = 1500,
				turret = true,
				waterweapon = true,
				weaponacceleration = 25,
				weapontimer = 4,
				weapontype = "TorpedoLauncher",
				weaponvelocity = 220,
				damage = {
					default = 500,
					subs = 250,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "HOVER NOTSHIP",
				def = "CORSSUB_WEAPON",
				maindir = "0 0 1",
				maxangledif = 75,
				onlytargetcategory = "NOTHOVER",
			},
		},
	},
}
