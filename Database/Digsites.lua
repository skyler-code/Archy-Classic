-- ----------------------------------------------------------------------------
-- Upvalued Lua API.
-- ----------------------------------------------------------------------------
-- Functions
local pairs = _G.pairs
local tonumber = _G.tonumber

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME, private = ...

-- ----------------------------------------------------------------------------
-- Constants
-- ----------------------------------------------------------------------------
function private.InitializeDigsiteTemplates()
	local RaceID = private.RaceID

	local DIGSITE_TEMPLATES = {
		-- ----------------------------------------------------------------------------
		-- Kalimdor
		-- ----------------------------------------------------------------------------
		["1414:0.554639:0.842079"] = {
			siteID = 325, -- Abyssal Sands Fossil Ridge
			mapID = 1446, -- Tanaris
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.490535:0.938357"] = {
			siteID = 576, -- Akhenet Fields Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.524584:0.687758"] = {
			siteID = 183, -- Bael Modan Digsite
			mapID = 199, -- Southern Barrens
			raceID = RaceID.ArchRaceDwarf,
		},
		["1414:0.434366:0.674429"] = {
			siteID = 281, -- Broken Commons Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.568525:0.846115"] = {
			siteID = 317, -- Broken Pillar Digsite
			mapID = 1446, -- Tanaris
			raceID = RaceID.ArchRaceTroll,
		},
		["1414:0.477519:0.337294"] = {
			siteID = 295, -- Constellas Digsite
			mapID = 1448, -- Felwood
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.539286:0.932202"] = {
			siteID = 572, -- Cursed Landing Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.438198:0.730965"] = {
			siteID = 289, -- Darkmist Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.427981:0.705815"] = {
			siteID = 279, -- Dire Maul Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.543661:0.865734"] = {
			siteID = 323, -- Dunemaul Fossil Ridge
			mapID = 1446, -- Tanaris
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.556432:0.863452"] = {
			siteID = 319, -- Eastmoon Ruins Digsite
			mapID = 1446, -- Tanaris
			raceID = RaceID.ArchRaceTroll,
		},
		["1414:0.396377:0.534088"] = {
			siteID = 193, -- Ethel Rethor Digsite
			mapID = 1443, -- Desolace
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.518117:0.602282"] = {
			siteID = 309, -- Fields of Blood Fossil Bank
			mapID = 199, -- Southern Barrens
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.548498:0.403449"] = {
			siteID = 175, -- Forest Song Digsite
			mapID = 1440, -- Ashenvale
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.592655:0.306642"] = {
			siteID = 307, -- Frostwhisper Gorge Digsite
			mapID = 1452, -- Winterspring
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.510834:0.314223"] = {
			siteID = 465, -- Grove of Aessina Digsite
			mapID = 198, -- Mount Hyjal
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.496378:0.277090"] = {
			siteID = 301, -- Ironwood Digsite
			mapID = 1448, -- Felwood
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.477791:0.321805"] = {
			siteID = 299, -- Jaedenar Digsite
			mapID = 1448, -- Felwood
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.530862:0.926699"] = {
			siteID = 574, -- Keset Pass Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.506323:0.886183"] = {
			siteID = 485, -- Khartut's Tomb Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.413714:0.576154"] = {
			siteID = 199, -- Kodo Graveyard
			mapID = 1443, -- Desolace
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.574177:0.255976"] = {
			siteID = 303, -- Lake Kel'Theril Digsite
			mapID = 1452, -- Winterspring
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.502193:0.796060"] = {
			siteID = 327, -- Lower Lakkari Tar Pits
			mapID = 1449, -- Un'Goro Crater
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.412057:0.598124"] = {
			siteID = 197, -- Mannoroc Coven Digsite
			mapID = 1443, -- Desolace
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.518389:0.830585"] = {
			siteID = 335, -- Marshlands Fossil Bank
			mapID = 1449, -- Un'Goro Crater
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.508688:0.346886"] = {
			siteID = 297, --  Morlos'Aran Digsite
			mapID = 1448, -- Felwood
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.439747:0.333789"] = {
			siteID = 167, -- Nazj'vel Digsite
			mapID = 1439, -- Darkshore
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.478932:0.984906"] = {
			siteID = 491, -- Neferset Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.524285:0.570665"] = {
			siteID = 313, -- Nightmare Scar Digsite
			mapID = 199, -- Southern Barrens
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.431323:0.724035"] = {
			siteID = 293, -- North Isildien Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.506677:0.897433"] = {
			siteID = 578, -- Obelisk of the Stars Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.415888:0.647527"] = {
			siteID = 285, -- Oneiros Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.464801:0.918425"] = {
			siteID = 493, -- Orsis Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.598036:0.292620"] = {
			siteID = 305, -- Owl Wing Thicket Digsite
			mapID = 1452, -- Winterspring
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.559231:0.684945"] = {
			siteID = 261, -- Quagmire Fossil Field
			mapID = 1445, -- Dustwallow Marsh
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.390236:0.641127"] = {
			siteID = 283, -- Ravenwind Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.508144:0.978751"] = {
			siteID = 570, -- River Delta Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.474367:0.874077"] = {
			siteID = 501, -- Ruins of Ahmtul Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.451513:0.957066"] = {
			siteID = 495, -- Ruins of Ammon Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.661732:0.332457"] = {
			siteID = 187, -- Ruins of Arkkoran
			mapID = 1447, -- Azshara
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.603905:0.379930"] = {
			siteID = 185, -- Ruins of Eldarath
			mapID = 1447, -- Azshara
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.434937:0.502743"] = {
			siteID = 179, -- Ruins of Eldre'Thar
			mapID = 1442, -- Stonetalon Mountains
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.455916:0.877786"] = {
			siteID = 497, -- Ruins of Khintaset Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.546133:0.291234"] = {
			siteID = 461, -- Ruins of Lar'donir Digsite
			mapID = 198, -- Mount Hyjal
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.463823:0.378463"] = {
			siteID = 171, -- Ruins of Ordil'Aran
			mapID = 1440, -- Ashenvale
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.470426:0.436588"] = {
			siteID = 173, -- Ruins of Stardust
			mapID = 1440, -- Ashenvale
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.481242:0.884512"] = {
			siteID = 581, -- Sahket Wastes Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.519775:0.341003"] = {
            siteID = 467, -- Sanctuary of Malorne Digsite
			mapID = 198, -- Mount Hyjal
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.439584:0.529238"] = {
			siteID = 201, -- Sargeron Digsite
			mapID = 1443, -- Desolace
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.432328:0.950096"] = {
			siteID = 583, -- Schnottz's Landing
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.550481:0.333259"] = {
			siteID = 469, -- Scorched Plain Digsite
			mapID = 198, -- Mount Hyjal
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.483253:0.796590"] = {
			siteID = 333, -- Screaming Reaches Fossil Field
			mapID = 1449, -- Un'Goro Crater
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.522410:0.305949"] = {
			siteID = 463, -- Shrine of Goldrinn Digsite
			mapID = 198, -- Mount Hyjal
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.385969:0.540773"] = {
			siteID = 191, -- Slitherblade Shore Digsite
			mapID = 1443, -- Desolace
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.366268:0.719103"] = {
			siteID = 287, -- Solarsal Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.428008:0.746046"] = {
			siteID = 291, -- South Isildien Digsite
			mapID = 1444, -- Feralas
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.545237:0.896740"] = {
			siteID = 321, -- Southmoon Ruins Digsite
			mapID = 1446, -- Tanaris
			raceID = RaceID.ArchRaceTroll,
		},
		["1414:0.454122:0.813384"] = {
			siteID = 337, -- Southwind Village Digsite
			mapID = 1451, -- Silithus
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.522737:0.937379"] = {
			siteID = 489, -- Steps of Fate Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.424693:0.399346"] = {
			siteID = 177, -- Stonetalon Peak
			mapID = 1442, -- Stonetalon Mountains
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.454258:0.899186"] = {
			siteID = 499, -- Temple of Uldum Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.482573:0.840286"] = {
			siteID = 331, -- Terror Run Fossil Field
			mapID = 1449, -- Un'Goro Crater
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.523063:0.924376"] = {
			siteID = 487, -- Tombs of the Precursors Digsite
			mapID = 249, -- Uldum
			raceID = RaceID.ArchRaceTolvir,
		},
		["1414:0.480345:0.505719"] = {
			siteID = 181, -- Unearthed Grounds
			mapID = 1442, -- Stonetalon Mountains
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.497519:0.784565"] = {
			siteID = 329, -- Upper Lakkari Tar Pits
			mapID = 1449, -- Un'Goro Crater
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.427193:0.610638"] = {
			siteID = 195, -- Valley of Bones
			mapID = 1443, -- Desolace
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.558606:0.709891"] = {
			siteID = 259, -- Wyrmbog Fossil Field
			mapID = 1445, -- Dustwallow Marsh
			raceID = RaceID.ArchRaceFossil,
		},
		["1414:0.439312:0.359957"] = {
			siteID = 169, -- Zoram Strand Digsite
			mapID = 1440, -- Ashenvale
			raceID = RaceID.ArchRaceNightElf,
		},
		["1414:0.543117:0.801114"] = {
			siteID = 315, -- Zul'Farrak Digsite
			mapID = 1446, -- Tanaris
			raceID = RaceID.ArchRaceTroll,
		},
        
		-- -- ----------------------------------------------------------------------------
		-- -- Eastern Kingdoms
		-- -- ----------------------------------------------------------------------------
		["1415:0.498463:0.405910"] = {
			siteID = 22, -- Aerie Peak Digsite
			mapID = 1425, -- The Hinterlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.528555:0.396444"] = {
			siteID = 27, -- Agol'watha Digsite
			mapID = 1425, -- The Hinterlands
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.529488:0.420533"] = {
			siteID = 24, -- Altar of Zul Digsite
			mapID = 1425, -- The Hinterlands
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.471218:0.365394"] = {
			siteID = 251, -- Andorhal Fossil Bank
			mapID = 1422, -- Western Plaguelands
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.436756:0.853650"] = {
			siteID = 227, -- Bal'lal Ruins Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.463707:0.872840"] = {
			siteID = 229, -- Balia'mah Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.515424:0.833798"] = {
			siteID = 205, -- Dreadmaul Fossil Field
			mapID = 1419, -- Blasted Lands
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.474016:0.457587"] = {
			siteID = 20, -- Dun Garok Digsite
			mapID = 1424, -- Hillsbrad Foothills
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.570552:0.584292"] = {
			siteID = 477, -- Dunwald Ruins Digsite
			mapID = 241, -- Twilight Highlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.498807:0.698105"] = {
			siteID = 213, -- Eastern Ruins of Thaurissan
			mapID = 1428, -- Burning Steppes
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.432240:0.839175"] = {
			siteID = 223, -- Eastern Zul'Kunda Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.466701:0.888863"] = {
			siteID = 233, -- Eastern Zul'Mamwe Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.474630:0.348157"] = {
			siteID = 247, -- Felstone Fossil Field
			mapID = 1422, -- Western Plaguelands
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.521069:0.543813"] = {
			siteID = 13, -- Greenwarden's Fossil Bank
			mapID = 1437, -- Wetlands
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.488252:0.669339"] = {
			siteID = 207, -- Grimsilt Digsite
			mapID = 1427, -- Searing Gorge
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.438327:0.894682"] = {
			siteID = 243, -- Gurubashi Arena Digsite
			mapID = 224, -- Stranglethorn Vale
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.529095:0.647865"] = {
			siteID = 144, -- Hammertoe's Digsite
			mapID = 1418, -- Badlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.560341:0.521087"] = {
			siteID = 481, -- Humboldt Conflagration Digsite
			mapID = 241, -- Twilight Highlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.550131:0.336812"] = {
			siteID = 221, -- Infectis Scar Fossil Field
			mapID = 1423, -- Eastern Plaguelands
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.541343:0.620130"] = {
			siteID = 9, -- Ironband's Excavation Site
			mapID = 1432, -- Loch Modan
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.500402:0.516335"] = {
			siteID = 10, -- Ironbeard's Tomb
			mapID = 1437, -- Wetlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.547062:0.424032"] = {
			siteID = 25, -- Jintha'Alor Lower City Digsite
			mapID = 1425, -- The Hinterlands
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.541932:0.427274"] = {
			siteID = 26, -- Jintha'Alor Upper City Digsite
			mapID = 1425, -- The Hinterlands
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.507029:0.767830"] = {
			siteID = 189, -- Lakeridge Highway Fossil Bank
			mapID = 1433, -- Redridge Mountains
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.548732:0.813171"] = {
			siteID = 154, -- Misty Reed Fossil Bank
			mapID = 1435, -- Swamp of Sorrows
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.435235:0.921239"] = {
			siteID = 245, -- Nek'mani Wellspring Digsite
			mapID = 210, -- The Cape of Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.485699:0.325357"] = {
			siteID = 249, -- Northridge Fossil Field
			mapID = 1422, -- Western Plaguelands
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.538079:0.298359"] = {
			siteID = 617, -- Plaguewood Digsite
			mapID = 1423, -- Eastern Plaguelands
			raceID = RaceID.ArchRaceNerubian,
		},
		["1415:0.475980:0.660978"] = {
			siteID = 209, -- Pyrox Flats Digsite
			mapID = 1427, -- Searing Gorge
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.549026:0.288929"] = {
			siteID = 219, -- Quel'Lithien Lodge Digsite
			mapID = 1423, -- Eastern Plaguelands
			raceID = RaceID.ArchRaceNightElf,
		},
		["1415:0.532311:0.872840"] = {
			siteID = 203, -- Red Reaches Fossil Bank
			mapID = 1419, -- Blasted Lands
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.453668:0.915198"] = {
			siteID = 239, -- Ruins of Aboraz
			mapID = 210, -- The Cape of Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.445519:0.903191"] = {
			siteID = 241, -- Ruins of Jubuwal
			mapID = 210, -- The Cape of Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.440119:0.859691"] = {
			siteID = 237, -- Savage Coast Raptor Fields
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.517215:0.423664"] = {
			siteID = 23, -- Shadra'Alor Digsite
			mapID = 1425, -- The Hinterlands
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.468837:0.430073"] = {
			siteID = 21, -- Southshore Fossil Field
			mapID = 1424, -- Hillsbrad Foothills
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.540337:0.800427"] = {
			siteID = 152, -- Sunken Temple Digsite
			mapID = 1435, -- Swamp of Sorrows
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.518835:0.710886"] = {
			siteID = 215, -- Terror Wing Fossil Field
			mapID = 1428, -- Burning Steppes
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.516013:0.297438"] = {
			siteID = 615, -- Terrorweb Tunnel Digsite
			mapID = 1423, -- Eastern Plaguelands
			raceID = RaceID.ArchRaceNerubian,
		},
		["1415:0.506735:0.502891"] = {
			siteID = 19, -- Thandol Span
			mapID = 1437, -- Wetlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.488890:0.436740"] = {
			siteID = 15, -- Thoradin's Wall
			mapID = 1417, -- Arathi Highlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.570896:0.533978"] = {
			siteID = 479, -- Thundermar Ruins Digsite
			mapID = 241, -- Twilight Highlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.529365:0.664698"] = {
			siteID = 146, -- Tomb of the Watchers Digsite
			mapID = 1418, -- Badlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.457080:0.797333"] = {
			siteID = 163, -- Twilight Grove Digsite
			mapID = 1431, -- Duskwood
			raceID = RaceID.ArchRaceNightElf,
		},
		["1415:0.525831:0.635232"] = {
			siteID = 150, -- Uldaman Entrance Digsite
			mapID = 1418, -- Badlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.448857:0.817149"] = {
			siteID = 165, -- Vul'Gol Fossil Bank
			mapID = 1431, -- Duskwood
			raceID = RaceID.ArchRaceFossil,
		},
		["1415:0.492155:0.698253"] = {
			siteID = 211, -- Western Ruins of Thaurissan
			mapID = 1428, -- Burning Steppes
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.428804:0.840170"] = {
			siteID = 225,-- Western Zul'Kunda Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.462185:0.888089"] = {
			siteID = 235, -- Western Zul'Mamwe Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.490486:0.540093"] = {
			siteID = 12, -- Whelgar's Excavation Site
			mapID = 1437, -- Wetlands
			raceID = RaceID.ArchRaceDwarf,
		},
		["1415:0.526469:0.477661"] = {
			siteID = 18, -- Witherbark Digsite
			mapID = 1417, -- Arathi Highlands
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.457301:0.878770"] = {
			siteID = 231, -- Ziata'jai Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.566404:0.287382"] = {
			siteID = 217, -- Zul'Mashar Digsite
			mapID = 1423, -- Eastern Plaguelands
			raceID = RaceID.ArchRaceTroll,
		},
		["1415:0.457301:0.878770"] = {
			siteID = 231, -- Ziata’jai Digsite
			mapID = 1434, -- Northern Stranglethorn
			raceID = RaceID.ArchRaceTroll,
		},
        
		-- -- ----------------------------------------------------------------------------
		-- -- Outland
		-- -- ----------------------------------------------------------------------------
		["1945:0.238263:0.685266"] = {
			-- Ancestral Grounds Digsite
			siteID = 359,
			mapID = 1951, -- Nagrand
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.560123:0.262942"] = {
			-- Arklon Ruins Digsite
			siteID = 355,
			mapID = 1953, -- Netherstorm
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.400138:0.781807"] = {
			siteID = 375, -- Bleeding Hollow Ruins Digsite
			mapID = 1952, -- Terokkar Forest
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.329479:0.525166"] = {
			siteID = 349, -- Boha'mu Ruins Digsite
			mapID = 102, -- Zangarmarsh
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.485685:0.768494"] = {
			siteID = 379, -- Bone Wastes Digsite
			mapID = 1952, -- Terokkar Forest
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.543174:0.749856"] = {
			siteID = 377, -- Bonechewer Ruins Digsite
			mapID = 1952, -- Terokkar Forest
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.387369:0.716616"] = {
			siteID = 367, -- Burning Blade Digsite
			mapID = 1951, -- Nagrand
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.647274:0.756383"] = {
			siteID = 387, -- Coilskar Point Digsite
			mapID = 1948, -- Shadowmoon Valley
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.721254:0.860569"] = {
			siteID = 399, -- Dragonmaw Fortress
			mapID = 1948, -- Shadowmoon Valley
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.470110:0.786789"] = {
			siteID = 381, -- East Auchindoun Digsite
			mapID = 1952, -- Terokkar Forest
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.647961:0.882814"] = {
			siteID = 393, -- Eclipse Point Digsite
			mapID = 1948, -- Shadowmoon Valley
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.559035:0.593964"] = {
			siteID = 339, -- Gor'gaz Outpost Digsite
			mapID = 1944, -- Hellfire Peninsula
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.460261:0.709917"] = {
			siteID = 371, -- Grangol'var Village Digsite
			mapID = 1952, -- Terokkar Forest
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.288995:0.635278"] = {
			siteID = 369, -- Halaa Digsite
			mapID = 1951, -- Nagrand
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.561154:0.525767"] = {
			siteID = 343, -- Hellfire Basin Digsite
			mapID = 1944, -- Hellfire Peninsula
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.575068:0.527914"] = {
			siteID = 345, -- Hellfire Citadel Digsite
			mapID = 1944, -- Hellfire Peninsula
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.597114:0.834630"] = {
			siteID = 385, -- Illidari Point Digsite
			mapID = 1948, -- Shadowmoon Valley
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.298501:0.565363"] = {
			siteID = 365, -- Laughing Skull Digsite
			mapID = 1951, -- Nagrand
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.682718:0.783782"] = {
			siteID = 391, -- Ruins of Baa'ri Digsite
			mapID = 1948, -- Shadowmoon Valley
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.539539:0.202190"] = {
			siteID = 353, -- Ruins of Enkaat Digsite
			mapID = 1953, -- Netherstorm
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.600377:0.100351"] = {
			siteID = 357, -- Ruins of Farahlon Digsite
			mapID = 1953, -- Netherstorm
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.468278:0.545093"] = {
			siteID = 347, -- Sha'naar Digsite
			mapID = 1944, -- Hellfire Peninsula
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.255040:0.631928"] = {
			siteID = 363, -- Sunspring Post Digsite
			mapID = 1951, -- Nagrand
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.504008:0.680456"] = {
			siteID = 373, -- Tuurem Digsite
			mapID = 1952, -- Terokkar Forest
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.338561:0.482906"] = {
			siteID = 351, -- Twin Spire Ruins Digsite
			mapID = 102, -- Zangarmarsh
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.688788:0.819857"] = {
			siteID = 395, -- Warden's Cage Digsite
			mapID = 1948, -- Shadowmoon Valley
			raceID = RaceID.ArchRaceOrc,
		},
		["1945:0.452130:0.788678"] = {
			siteID = 383, -- West Auchindoun Digsite
			mapID = 1952, -- Terokkar Forest
			raceID = RaceID.ArchRaceDraenei,
		},
		["1945:0.624713:0.584688"] = {
			siteID = 341, -- Zeth'Gor Digsite
			mapID = 1944, -- Hellfire Peninsula
			raceID = RaceID.ArchRaceOrc,
		},
		
		-- -- ----------------------------------------------------------------------------
		-- -- Northrend
		-- -- ----------------------------------------------------------------------------
		["113:0.745638:0.428748"] = {
			siteID = 435, -- Altar of Quetz'lun Digsite
			mapID = 121, -- Zul'Drak
			raceID = RaceID.ArchRaceTroll,
		},
		["113:0.665477:0.371495"] = {
			siteID = 429, -- Altar of Sseratus Digsite
			mapID = 121, -- Zul'Drak
			raceID = RaceID.ArchRaceTroll,
		},
		["113:0.816113:0.768901"] = {
			siteID = 409, -- Baleheim Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.797921:0.765361"] = {
			siteID = 409, -- Baleheim Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.605295:0.329547"] = {
			-- Brunnhildar Village Digsite
			siteID = 445,
			mapID = 120, -- The Storm Peaks
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.793467:0.505175"] = {
			siteID = 443, -- Drakil'Jin Ruins Digsite
			mapID = 116, -- Grizzly Hills
			raceID = RaceID.ArchRaceTroll,
		},
		["113:0.315702:0.564494"] = {
			siteID = 419, -- En'kilah Digsite
			mapID = 114, -- Borean Tundra
			raceID = RaceID.ArchRaceNerubian,
		},
		["113:0.720065:0.671641"] = {
			siteID = 413, -- Gjalerbron Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.769018:0.816474"] = {
			siteID = 403, -- Halgrind Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.282578:0.301614"] = {
			siteID = 457, -- Jotunheim Digsite
			mapID = 118, -- Icecrown
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.722093:0.468586"] = {
			siteID = 421, -- Kolramas Digsite
			mapID = 121, -- Zul'Drak
			raceID = RaceID.ArchRaceNerubian,
		},
		["113:0.385894:0.611983"] = {
			siteID = 417, -- Moonrest Gardens Digsite
			mapID = 115, -- Dragonblight
			raceID = RaceID.ArchRaceNightElf,
		},
		["113:0.829115:0.817147"] = {
			siteID = 441, -- Nifflevar Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.315082:0.237731"] = {
			siteID = 459, -- Njorndar Village Digsite
			mapID = 118, -- Icecrown
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.482337:0.286066"] = {
			siteID = 587, -- Pit of Fiends Digsite
			mapID = 118, -- Icecrown
			raceID = RaceID.ArchRaceNerubian,
		},
		["113:0.398569:0.584352"] = {
			siteID = 415, -- Pit of Narjun Digsite
			mapID = 115, -- Dragonblight
			raceID = RaceID.ArchRaceNerubian,
		},
		["113:0.194416:0.775830"] = {
			siteID = 423, -- Riplash Ruins Digsite
			mapID = 114, -- Borean Tundra
			raceID = RaceID.ArchRaceNightElf,
		},
		["113:0.562049:0.441800"] = {
			siteID = 427, -- Ruins of Shandaral Digsite
			mapID = 127, -- Crystalsong Forest
			raceID = RaceID.ArchRaceNightElf,
		},
		["113:0.207485:0.701216"] = {
			siteID = 589, -- Sands of Nasam
			mapID = 114, -- Borean Tundra
			raceID = RaceID.ArchRaceNerubian,
		},
		["113:0.485548:0.323499"] = {
			siteID = 451, -- Scourgeholme Digsite
			mapID = 118, -- Icecrown
			raceID = RaceID.ArchRaceNerubian,
		},
		["113:0.800847:0.902242"] = {
			siteID = 407, -- Shield Hill Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.577766:0.319359"] = {
			siteID = 447, -- Sifreldar Village Digsite
			mapID = 120, -- The Storm Peaks
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.751386:0.735270"] = {
			siteID = 401, -- Skorn Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.261171:0.528075"] = {
			siteID = 437, -- Talramas Digsite
			mapID = 114, -- Borean Tundra
			raceID = RaceID.ArchRaceNerubian,
		},
		["113:0.514109:0.272545"] = {
			siteID = 449, -- Valkyrion Digsite
			mapID = 120, -- The Storm Peaks
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.462113:0.410957"] = {
			siteID = 425, -- Violet Stand Digsite
			mapID = 127, -- Crystalsong Forest
			raceID = RaceID.ArchRaceNightElf,
		},
		["113:0.666998:0.651107"] = {
			siteID = 439, -- Voldrune Digsite
			mapID = 116, -- Grizzly Hills
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.796509:0.809038"] = {
			siteID = 405, -- Wyrmskull Digsite
			mapID = 117, -- Howling Fjord
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.413722:0.301191"] = {
			siteID = 455, -- Ymirheim Digsite
			mapID = 118, -- Icecrown
			raceID = RaceID.ArchRaceVrykul,
		},
		["113:0.719783:0.370312"] = {
			siteID = 431, -- Zim'Rhuk Digsite
			mapID = 121, -- Zul'Drak
			raceID = RaceID.ArchRaceTroll,
		},
		["113:0.771722:0.348849"] = {
			siteID = 433, -- Zol'Heb Digsite
			mapID = 121, -- Zul'Drak
			raceID = RaceID.ArchRaceTroll,
		},
	}
    
    local CONTINENT_RACES =
	{
		-- Kalimdor
		[1414] =
		{
			[RaceID.ArchRaceDwarf] = 0,
			[RaceID.ArchRaceFossil] = 0,
			[RaceID.ArchRaceNightElf] = 0,
			[RaceID.ArchRaceTroll] = 0,
			[RaceID.ArchRaceTolvir] = 0,
		},
		-- Eastern Kingdoms
		[1415] =
		{
			[RaceID.ArchRaceDwarf] = 0,
			[RaceID.ArchRaceFossil] = 0,
			[RaceID.ArchRaceNerubian] = 0,
			[RaceID.ArchRaceNightElf] = 0,
			[RaceID.ArchRaceTroll] = 0,
		},
		-- Outland
		[1945] =
		{
			[RaceID.ArchRaceOrc] = 0,
			[RaceID.ArchRaceDraenei] = 0,
		},
		-- Northrend
		[113] =
		{
			[RaceID.ArchRaceNightElf] = 0,
			[RaceID.ArchRaceVrykul] = 0,
			[RaceID.ArchRaceNerubian] = 0,
			[RaceID.ArchRaceTroll] = 0,
		},
	}

	local DIGSITE_TEMPLATES_BY_ID = {}
	local DIGSITE_TEMPLATES_BY_ZONE = {}

	for siteKey, site in pairs(DIGSITE_TEMPLATES) do
        if site.siteID and site.siteID ~= siteKey and not DIGSITE_TEMPLATES_BY_ID[site.siteID] then
            DIGSITE_TEMPLATES_BY_ID[site.siteID] = siteKey
        end
        if site.mapID then
            DIGSITE_TEMPLATES_BY_ZONE[site.mapID] = DIGSITE_TEMPLATES_BY_ZONE[site.mapID ] or {}
            DIGSITE_TEMPLATES_BY_ZONE[site.mapID][siteKey] = true
        end
	end

	private.CONTINENT_RACES = CONTINENT_RACES
	private.DIGSITE_TEMPLATES_BY_ZONE = DIGSITE_TEMPLATES_BY_ZONE
	private.DIGSITE_TEMPLATES_BY_ID = DIGSITE_TEMPLATES_BY_ID
	private.DIGSITE_TEMPLATES = DIGSITE_TEMPLATES
end
