return {
	corerad = {
		acceleration = 0,
		airsightdistance = 1060,
		brakerate = 0,
		buildangle = 65536,
		buildcostenergy = 8000,
		buildcostmetal = 750,
		buildinggrounddecaldecayspeed = 30,
		buildinggrounddecalsizex = 6,
		buildinggrounddecalsizey = 6,
		buildinggrounddecaltype = "corerad_aoplane.dds",
		buildpic = "CORERAD.DDS",
		buildtime = 12000,
		canrepeat = false,
		category = "ALL WEAPON NOTSUB NOTAIR NOTHOVER SURFACE",
		corpse = "DEAD",
		description = "Bomb-Resistant Medium-Range Missile Battery",
		explodeas = "mediumBuildingExplosionGeneric",
		footprintx = 4,
		footprintz = 4,
		icontype = "building",
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 4000,
		maxslope = 10,
		maxwaterdepth = 0,
		name = "Eradicator",
		objectname = "CORERAD",
		seismicsignature = 0,
		selfdestructas = "mediumBuildingExplosionGenericSelfd",
		sightdistance = 380,
		usebuildinggrounddecal = true,
		yardmap = "oooooooooooooooo",
		customparams = {
			removewait = true,
			removestop = true,
			prioritytarget = "air",
			},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "-0.683853149414 -1.83105470342e-07 -1.83734893799",
				collisionvolumescales = "54.6322937012 35.8339996338 48.325302124",
				collisionvolumetype = "Box",
				damage = 1560,
				description = "Eradicator Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 4,
				footprintz = 4,
				height = 20,
				hitdensity = 100,
				metal = 370,
				object = "CORERAD_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 780,
				description = "Eradicator Heap",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 4,
				hitdensity = 100,
				metal = 150,
				object = "3X3B",
                collisionvolumescales = "55.0 4.0 6.0",
                collisionvolumetype = "cylY",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = { 
 			pieceExplosionGenerators = { 
				"deathceg2",
				"deathceg3",
				"deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			cloak = "kloak1",
			uncloak = "kloak1un",
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
				[1] = "twrturn3",
			},
			select = {
				[1] = "twrturn3",
			},
		},
		weapondefs = {
			cor_erad = {
				areaofeffect = 48,
				avoidfeature = false,
				burnblow = true,
				burst = 4,
				burstrate = 0.25,
				canattackground = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				cegTag = "missiletrailaa",
				explosiongenerator = "custom:genericshellexplosion-tiny-aa",
				firestarter = 20,
				flighttime = 2.3,
				impulseboost = 0,
				impulsefactor = 0,
				model = "missile",
				name = "Long-range rapid-fire g2a missile launcher",
				noselfdamage = true,
				projectiles = 1,
				proximitypriority = -2,
				range = 1125,
				reloadtime = 1.6,
				smoketrail = false,
				soundhit = "xplosml2",
				soundhitwet = "splshbig",
				soundhitwetvolume = 0.5,
				soundstart = "rocklit1",
				soundtrigger = true,
				startvelocity = 540,
				texture1 = "trans",
				texture2 = "coresmoketrail",
				tolerance = 100000,
				tracks = true,
				turnrate = 38000,
				turret = true,
				weaponacceleration = 300,
				weapontype = "MissileLauncher",
				weaponvelocity = 1300,
				damage = {
					bombers = 260,
					fighters = 220,
					vtol = 170,
				},
				customparams = {
					bar_model = "cormissile.s3o",
					light_skip = true,		-- used by light_effects widget
					light_color = "1 0.5 0.6",
					expl_light_color = "1 0.4 0.5",
					expl_light_radius_mult = 0.66,
					expl_light_mult = 0.4,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "COR_ERAD",
				onlytargetcategory = "VTOL",
			},
		},
	},
}
