-- ----------------------------------------------------------------------------
-- Upvalued Lua API.
-- ----------------------------------------------------------------------------
-- Functions
local pairs = _G.pairs

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME, private = ...

local LibStub = _G.LibStub
local L = LibStub("AceLocale-3.0"):GetLocale("Archy", false)
local Archy = LibStub("AceAddon-3.0"):GetAddon("Archy")

-- ----------------------------------------------------------------------------
-- Constants
-- ----------------------------------------------------------------------------

-- Extracted from ResearchProject.db2
-- ItemIDs obtained by matching ResearchProject name against known item-sparse names
function private.InitializeArtifactTemplates()
	local RaceID = private.RaceID

	local ARTIFACT_TEMPLATES = {
		-- ----------------------------------------------------------------------------
		-- Draenei
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceDraenei] = {
			[64440] = {
				-- Anklet with Golden Bells
				itemID = 64440,
				spellID = 90853,
			},
			[64456] = {
				-- Arrival of the Naaru
				isRare = true,
				itemID = 64456,
				spellID = 90983,
			},
			[64453] = {
				-- Baroque Sword Scabbard
				itemID = 64453,
				spellID = 90968,
			},
			[64442] = {
				-- Carved Harp of Exotic Wood
				itemID = 64442,
				spellID = 90860,
			},
			[64455] = {
				-- Dignified Portrait
				itemID = 64455,
				spellID = 90975,
			},
			[64454] = {
				-- Fine Crystal Candelabra
				itemID = 64454,
				spellID = 90974,
			},
			[64458] = {
				-- Plated Elekk Goad
				itemID = 64458,
				spellID = 90987,
			},
			[64444] = {
				-- Scepter of the Nathrezim
				itemID = 64444,
				spellID = 90864,
			},
			[64443] = {
				-- Strange Silver Paperweight
				itemID = 64443,
				spellID = 90861,
			},
			[64457] = {
				-- The Last Relic of Argus
				isRare = true,
				itemID = 64457,
				spellID = 90984,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Dwarf
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceDwarf] = {
			[63113] = {
				-- Belt Buckle with Anvilmar Crest
				itemID = 63113,
				spellID = 88910,
			},
			[64339] = {
				-- Bodacious Door Knocker
				itemID = 64339,
				spellID = 90411,
			},
			[63112] = {
				-- Bone Gaming Dice
				itemID = 63112,
				spellID = 86866,
			},
			[64340] = {
				-- Boot Heel with Scrollwork
				itemID = 64340,
				spellID = 90412,
			},
			[63409] = {
				-- Ceramic Funeral Urn
				itemID = 63409,
				spellID = 86864,
			},
			[64373] = {
				-- Chalice of the Mountain Kings
				isRare = true,
				itemID = 64373,
				spellID = 90553,
			},
			[64372] = {
				-- Clockwork Gnome
				isRare = true,
				itemID = 64372,
				spellID = 90521,
			},
			[64362] = {
				-- Dented Shield of Horuz Killcrow
				itemID = 64362,
				spellID = 90504,
			},
			[66054] = {
				-- Dwarven Baby Socks
				itemID = 66054,
				spellID = 93440,
			},
			[64342] = {
				-- Golden Chamber Pot
				itemID = 64342,
				spellID = 90413,
			},
			[64344] = {
				-- Ironstar's Petrified Shield
				itemID = 64344,
				spellID = 90419,
			},
			[64368] = {
				-- Mithril Chain of Angerforge
				itemID = 64368,
				spellID = 90518,
			},
			[63414] = {
				-- Moltenfist's Jeweled Goblet
				itemID = 63414,
				spellID = 89717,
			},
			[64337] = {
				-- Notched Sword of Tunadil the Redeemer
				itemID = 64337,
				spellID = 90410,
			},
			[63408] = {
				-- Pewter Drinking Cup
				itemID = 63408,
				spellID = 86857,
			},
			[64659] = {
				-- Pipe of Franclorn Forgewright
				itemID = 64659,
				spellID = 91793,
			},
			[64487] = {
				-- Scepter of Bronzebeard
				itemID = 64487,
				spellID = 91225,
			},
			[64367] = {
				-- Scepter of Charlga Razorflank
				itemID = 64367,
				spellID = 90509,
			},
			[64366] = {
				-- Scorched Staff of Shadow Priest Anund
				itemID = 64366,
				spellID = 90506,
			},
			[64483] = {
				-- Silver Kris of Korl
				itemID = 64483,
				spellID = 91219,
			},
			[63411] = {
				-- Silver Neck Torc
				itemID = 63411,
				spellID = 88181,
			},
			[64371] = {
				-- Skull Staff of Shadowforge
				itemID = 64371,
				spellID = 90519,
			},
			[64485] = {
				-- Spiked Gauntlets of Anvilrage
				itemID = 64485,
				spellID = 91223,
			},
			[64489] = {
				-- Staff of Sorcerer-Thane Thaurissan
				isRare = true,
				itemID = 64489,
				spellID = 91227,
			},
			[63410] = {
				-- Stone Gryphon
				itemID = 63410,
				spellID = 88180,
			},
			[64488] = {
				-- The Innkeeper's Daughter
				isRare = true,
				itemID = 64488,
				spellID = 91226,
			},
			[64484] = {
				-- Warmaul of Burningeye
				itemID = 64484,
				spellID = 91221,
			},
			[64343] = {
				-- Winged Helm of Corehammer
				itemID = 64343,
				spellID = 90415,
			},
			[63111] = {
				-- Wooden Whistle
				itemID = 63111,
				spellID = 88909,
			},
			[64486] = {
				-- Word of Empress Zoe
				itemID = 64486,
				spellID = 91224,
			},
			[63110] = {
				-- Worn Hunting Knife
				itemID = 63110,
				spellID = 86865,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Fossil
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceFossil] = {
			[69776] = {
				-- Ancient Amber
				isRare = true,
				itemID = 69776,
				spellID = 98560,
			},
			[64355] = {
				-- Ancient Shark Jaws
				itemID = 64355,
				spellID = 90452,
			},
			[63121] = {
				-- Beautiful Preserved Fern
				itemID = 63121,
				spellID = 88930,
			},
			[63109] = {
				-- Black Trilobite
				itemID = 63109,
				spellID = 88929,
			},
			[64349] = {
				-- Devilsaur Tooth
				itemID = 64349,
				spellID = 90432,
			},
			[69764] = {
				-- Extinct Turtle Shell
				isRare = true,
				itemID = 69764,
				spellID = 98533,
			},
			[64385] = {
				-- Feathered Raptor Arm
				itemID = 64385,
				spellID = 90617,
			},
			[60955] = {
				-- Fossilized Hatchling
				isRare = true,
				itemID = 60955,
				spellID = 89693,
			},
			[60954] = {
				-- Fossilized Raptor
				isRare = true,
				itemID = 60954,
				spellID = 90619,
			},
			[64473] = {
				-- Imprint of a Kraken Tentacle
				itemID = 64473,
				spellID = 91132,
			},
			[64350] = {
				-- Insect in Amber
				itemID = 64350,
				spellID = 90433,
			},
			[64468] = {
				-- Proto-Drake Skeleton
				itemID = 64468,
				spellID = 91089,
			},
			[69821] = {
				-- Pterrordax Hatchling
				isRare = true,
				itemID = 69821,
				spellID = 98582,
			},
			[66056] = {
				-- Shard of Petrified Wood
				itemID = 66056,
				spellID = 93442,
			},
			[66057] = {
				-- Strange Velvet Worm
				itemID = 66057,
				spellID = 93443,
			},
			[63527] = {
				-- Twisted Ammonite Shell
				itemID = 63527,
				spellID = 89895,
			},
			[64387] = {
				-- Vicious Ancient Fish
				itemID = 64387,
				spellID = 90618,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Nerubian
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceNerubian] = {
			[64481] = {
				-- Blessing of the Old God
				isRare = true,
				itemID = 64481,
				spellID = 91214,
			},
			[64479] = {
				-- Ewer of Jormungar Blood
				itemID = 64479,
				spellID = 91209,
			},
			[64477] = {
				-- Gruesome Heart Box
				itemID = 64477,
				spellID = 91191,
			},
			[64476] = {
				-- Infested Ruby Ring
				itemID = 64476,
				spellID = 91188,
			},
			[64482] = {
				-- Puzzle Box of Yogg-Saron
				isRare = true,
				itemID = 64482,
				spellID = 91215,
			},
			[64475] = {
				-- Scepter of Nezar'Azret
				itemID = 64475,
				spellID = 91170,
			},
			[64478] = {
				-- Six-Clawed Cornice
				itemID = 64478,
				spellID = 91197,
			},
			[64474] = {
				-- Spidery Sundial
				itemID = 64474,
				spellID = 91133,
			},
			[64480] = {
				-- Vizier's Scrawled Streamer
				itemID = 64480,
				spellID = 91211,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Night Elf
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceNightElf] = {
			[64646] = {
				-- Bones of Transformation
				isRare = true,
				itemID = 64646,
				spellID = 91761,
			},
			[64647] = {
				-- Carcanet of the Hundred Magi
				itemID = 64647,
				spellID = 91762,
			},
			[64379] = {
				-- Chest of Tiny Glass Animals
				itemID = 64379,
				spellID = 90610,
			},
			[63407] = {
				-- Cloak Clasp with Antlers
				itemID = 63407,
				spellID = 89696,
			},
			[63525] = {
				-- Coin from Eldre'Thalas
				itemID = 63525,
				spellID = 89893,
			},
			[64381] = {
				-- Cracked Crystal Vial
				itemID = 64381,
				spellID = 90611,
			},
			[64357] = {
				-- Delicate Music Box
				itemID = 64357,
				spellID = 90458,
			},
			[64361] = {
				-- Druid and Priest Statue Set
				isRare = true,
				itemID = 64361,
				spellID = 90493,
			},
			[63528] = {
				-- Green Dragon Ring
				itemID = 63528,
				spellID = 89896,
			},
			[64356] = {
				-- Hairpin of Silver and Malachite
				itemID = 64356,
				spellID = 90453,
			},
			[63129] = {
				-- Highborne Pyxis
				itemID = 63129,
				spellID = 89009,
			},
			[64358] = {
				-- Highborne Soul Mirror
				isRare = true,
				itemID = 64358,
				spellID = 90464,
			},
			[63130] = {
				-- Inlaid Ivory Comb
				itemID = 63130,
				spellID = 89012,
			},
			[64354] = {
				-- Kaldorei Amphora
				itemID = 64354,
				spellID = 90451,
			},
			[64383] = {
				-- Kaldorei Wind Chimes
				isRare = true,
				itemID = 64383,
				spellID = 90614,
			},
			[66055] = {
				-- Necklace with Elune Pendant
				itemID = 66055,
				spellID = 93441,
			},
			[64643] = {
				-- Queen Azshara's Dressing Gown
				isRare = true,
				itemID = 64643,
				spellID = 90616,
			},
			[63131] = {
				-- Scandalous Silk Nightgown
				itemID = 63131,
				spellID = 89014,
			},
			[64382] = {
				-- Scepter of Xavius
				itemID = 64382,
				spellID = 90612,
			},
			[63526] = {
				-- Shattered Glaive
				itemID = 63526,
				spellID = 89894,
			},
			[64648] = {
				-- Silver Scroll Case
				itemID = 64648,
				spellID = 91766,
			},
			[64378] = {
				-- String of Small Pink Pearls
				itemID = 64378,
				spellID = 90609,
			},
			[64645] = {
				-- Tyrande's Favorite Doll
				isRare = true,
				itemID = 64645,
				spellID = 91757,
			},
			[64650] = {
				-- Umbra Crescent
				itemID = 64650,
				spellID = 91769,
			},
			[64651] = {
				-- Wisp Amulet
				isRare = true,
				itemID = 64651,
				spellID = 91773,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Orc
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceOrc] = {
			[64436] = {
				-- Fiendish Whip
				itemID = 64436,
				spellID = 90831,
			},
			[64421] = {
				-- Fierce Wolf Figurine
				itemID = 64421,
				spellID = 90734,
			},
			[64418] = {
				-- Gray Candle Stub
				itemID = 64418,
				spellID = 90728,
			},
			[64644] = {
				-- Headdress of the First Shaman
				isRare = true,
				itemID = 64644,
				spellID = 90843,
			},
			[64417] = {
				-- Maul of Stone Guard Mur'og
				itemID = 64417,
				spellID = 90720,
			},
			[64419] = {
				-- Rusted Steak Knife
				itemID = 64419,
				spellID = 90730,
			},
			[64420] = {
				-- Scepter of Nekros Skullcrusher
				itemID = 64420,
				spellID = 90732,
			},
			[64438] = {
				-- Skull Drinking Cup
				itemID = 64438,
				spellID = 90833,
			},
			[64437] = {
				-- Tile of Glazed Clay
				itemID = 64437,
				spellID = 90832,
			},
			[64389] = {
				-- Tiny Bronze Scorpion
				itemID = 64389,
				spellID = 90622,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Tolvir
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceTolvir] = {
			[64657] = {
				-- Canopic Jar
				itemID = 64657,
				spellID = 91790,
			},
			[64652] = {
				-- Castle of Sand
				itemID = 64652,
				spellID = 91775,
			},
			[64653] = {
				-- Cat Statue with Emerald Eyes
				itemID = 64653,
				spellID = 91779,
			},
			[60847] = {
				-- Crawling Claw
				isRare = true,
				itemID = 60847,
				projectName = L["ProjectNames/Mummified Monkey Paw"],
				spellID = 92137,
			},
			[64656] = {
				-- Engraved Scimitar Hilt
				itemID = 64656,
				spellID = 91785,
			},
			[64881] = {
				-- Pendant of the Scarab Storm
				isRare = true,
				itemID = 64881,
				spellID = 92145,
			},
			[64904] = {
				-- Ring of the Boy Emperor
				isRare = true,
				itemID = 64904,
				spellID = 92168,
			},
			[64883] = {
				-- Scepter of Azj'Aqir
				isRare = true,
				itemID = 64883,
				spellID = 92148,
			},
			[64885] = {
				-- Scimitar of the Sirocco
				isRare = true,
				itemID = 64885,
				spellID = 92163,
			},
			[64658] = {
				-- Sketch of a Desert Palace
				itemID = 64658,
				spellID = 91792,
			},
			[64654] = {
				-- Soapstone Scarab Necklace
				itemID = 64654,
				spellID = 91780,
			},
			[64880] = {
				-- Staff of Ammunae
				isRare = true,
				itemID = 64880,
				spellID = 92139,
			},
			[64655] = {
				-- Tiny Oasis Mosaic
				itemID = 64655,
				spellID = 91782,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Troll
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceTroll] = {
			[64348] = {
				-- Atal'ai Scepter
				itemID = 64348,
				spellID = 90429,
			},
			[64346] = {
				-- Bracelet of Jade and Coins
				itemID = 64346,
				spellID = 90421,
			},
			[63524] = {
				-- Cinnabar Bijou
				itemID = 63524,
				spellID = 89891,
			},
			[64375] = {
				-- Drakkari Sacrificial Knife
				itemID = 64375,
				spellID = 90581,
			},
			[63523] = {
				-- Eerie Smolderthorn Idol
				itemID = 63523,
				spellID = 89890,
			},
			[63413] = {
				-- Feathered Gold Earring
				itemID = 63413,
				spellID = 89711,
			},
			[63120] = {
				-- Fetish of Hir'eek
				itemID = 63120,
				spellID = 88907,
			},
			[66058] = {
				-- Fine Bloodscalp Dinnerware
				itemID = 66058,
				spellID = 93444,
			},
			[64347] = {
				-- Gahz'rilla Figurine
				itemID = 64347,
				spellID = 90423,
			},
			[69777] = {
				-- Haunted War Drum
				isRare = true,
				itemID = 69777,
				spellID = 98556,
			},
			[63412] = {
				-- Jade Asp with Ruby Eyes
				itemID = 63412,
				spellID = 89701,
			},
			[63118] = {
				-- Lizard Foot Charm
				itemID = 63118,
				spellID = 88908,
			},
			[64345] = {
				-- Skull-Shaped Planter
				itemID = 64345,
				spellID = 90420,
			},
			[64374] = {
				-- Tooth with Gold Filling
				itemID = 64374,
				spellID = 90558,
			},
			[69824] = {
				-- Voodoo Figurine
				isRare = true,
				itemID = 69824,
				spellID = 98588,
			},
			[63115] = {
				-- Zandalari Voodoo Doll
				itemID = 63115,
				spellID = 88262,
			},
			[64377] = {
				-- Zin'rokh, Destroyer of Worlds
				isRare = true,
				itemID = 64377,
				spellID = 90608,
			},
		},

		-- ----------------------------------------------------------------------------
		-- Vrykul
		-- ----------------------------------------------------------------------------
		[RaceID.ArchRaceVrykul] = {
			[64464] = {
				-- Fanged Cloak Pin
				itemID = 64464,
				spellID = 91014,
			},
			[64462] = {
				-- Flint Striker
				itemID = 64462,
				spellID = 91012,
			},
			[64459] = {
				-- Intricate Treasure Chest Key
				itemID = 64459,
				spellID = 90988,
			},
			[64460] = {
				-- Nifflevar Bearded Axe
				isRare = true,
				itemID = 64460,
				spellID = 90997,
			},
			[64461] = {
				-- Scramseax
				itemID = 64461,
				spellID = 91008,
			},
			[64467] = {
				-- Thorned Necklace
				itemID = 64467,
				spellID = 91084,
			},
			[69775] = {
				-- Vrykul Drinking Horn
				isRare = true,
				itemID = 69775,
				spellID = 98569,
				usesItemForProjectName = true,
			},
		},
	}

	private.ARTIFACT_TEMPLATES = ARTIFACT_TEMPLATES

    local PRISTINE_ARTIFACT_TO_QUESTID = {}
    local ARTIFACTS_RESTORE = {}
	for raceID = 1, _G.GetNumArchaeologyRaces() do
		local artifactTemplates = private.ARTIFACT_TEMPLATES[raceID]

		if artifactTemplates then
			local race = private.Races[raceID]

			for itemID, template in pairs(artifactTemplates) do
				if not race:AddOrUpdateArtifactFromTemplate(template) then
					private.RaceArtifactProcessingQueue[template] = race
					Archy:RegisterEvent("GET_ITEM_INFO_RECEIVED")
				end
                if template.pristineItemId then
                    PRISTINE_ARTIFACT_TO_QUESTID[template.pristineItemId] = template.pristineQuestId
                    ARTIFACTS_RESTORE[itemID] = true
                end
			end

			race:UpdateCurrentProject()
		end
	end
	private.PRISTINE_ARTIFACT_TO_QUESTID = PRISTINE_ARTIFACT_TO_QUESTID
	private.ARTIFACTS_RESTORE = ARTIFACTS_RESTORE
end
