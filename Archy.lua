-- ----------------------------------------------------------------------------
-- Upvalued Lua API.
-- ----------------------------------------------------------------------------
-- Libraries
local math = _G.math
local table = _G.table
local string = _G.string

-- Functions
local date = _G.date
local next = _G.next
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local tonumber = _G.tonumber
local type = _G.type

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local LibStub = _G.LibStub

local FOLDER_NAME, private = ...
local Archy = LibStub("AceAddon-3.0"):NewAddon("Archy", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceBucket-3.0", "AceTimer-3.0", "LibSink-2.0", "LibToast-1.0")
Archy.version = _G.GetAddOnMetadata(FOLDER_NAME, "Version")
_G["Archy"] = Archy

local Dialog = LibStub("LibDialog-1.0")
local HereBeDragons = LibStub("HereBeDragons-2.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Archy", false)
local LDBI = LibStub("LibDBIcon-1.0")

--local DatamineTooltip = _G.CreateFrame("GameTooltip", "ArchyScanTip", nil, "GameTooltipTemplate")
--DatamineTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")

-- ----------------------------------------------------------------------------
-- Constants
-- ----------------------------------------------------------------------------
local BFA_EXPANSION_LEVEL = 7 -- BFA is the last expansion with Archeology skills
local MAX_PROFESSION_RANK = min(BFA_EXPANSION_LEVEL, _G.GetExpansionLevel()) + 4 -- Skip the 4 ranks of vanilla
local MAX_ARCHAEOLOGY_RANK = _G.PROFESSION_RANKS[MAX_PROFESSION_RANK][1]
private.MAX_ARCHAEOLOGY_RANK = MAX_ARCHAEOLOGY_RANK

local GLOBAL_COOLDOWN_TIME = 1.5
local SURVEY_SPELL_ID = 80451
local CRATE_USE_STRING -- Populate in Archy:OnEnable()

local ZONE_DATA = {}
private.ZONE_DATA = ZONE_DATA

local MAP_CONTINENTS = {} -- Popupated in Archy:OnEnable()
private.MAP_CONTINENTS = MAP_CONTINENTS

local EasySurveyButton -- Populated in Archy:OnInitialize()

local LorewalkersLodestone = {
	itemID = 87548,
	spellID = 126956
}

local LorewalkersMap = {
	itemID = 87549,
	spellID = 126957
}

-- If fishing pole detection breaks in a future patch due to indices changing, uncomment the below code to find the correct values:
--do
--	COMPILED_ITEM_CLASSES = {}
--	local classIndex = 0
--	local className = _G.GetItemClassInfo(classIndex)
--
--	while className and className ~= "" do
--		COMPILED_ITEM_CLASSES[classIndex] = {
--			name = className,
--			subClasses = {},
--		}
--
--		local subClassIndex = 0
--		local subClassName = _G.GetItemSubClassInfo(classIndex, subClassIndex)
--
--		while subClassName and subClassName ~= "" do
--			COMPILED_ITEM_CLASSES[classIndex].subClasses[subClassIndex] = subClassName
--
--			subClassIndex = subClassIndex + 1
--			subClassName = _G.GetItemSubClassInfo(classIndex, subClassIndex)
--		end
--
--		classIndex = classIndex + 1
--		className = _G.GetItemClassInfo(classIndex)
--	end
--end

local FISHING_POLE_ITEM_TYPE_NAME
do
	local ITEM_CLASS_WEAPON = 2
	local ITEM_SUBCLASS_FISHING_POLE = 20

	FISHING_POLE_ITEM_TYPE_NAME = _G.GetItemSubClassInfo(ITEM_CLASS_WEAPON, ITEM_SUBCLASS_FISHING_POLE)
end

_G.BINDING_HEADER_ARCHY = "Archy"
_G.BINDING_NAME_OPTIONSARCHY = L["BINDING_NAME_OPTIONS"]
_G.BINDING_NAME_TOGGLEARCHY = L["BINDING_NAME_TOGGLE"]
_G.BINDING_NAME_SOLVEARCHY = L["BINDING_NAME_SOLVE"]
_G.BINDING_NAME_SOLVE_WITH_KEYSTONESARCHY = L["BINDING_NAME_SOLVESTONE"]
_G.BINDING_NAME_ARTIFACTSARCHY = L["BINDING_NAME_ARTIFACTS"]
_G.BINDING_NAME_DIGSITESARCHY = L["BINDING_NAME_DIGSITES"]

-- ----------------------------------------------------------------------------
-- Variables
-- ----------------------------------------------------------------------------
MissingDigsites = MissingDigsites or {}
local continent_digsites = {}
private.continent_digsites = continent_digsites

local lootedKeystoneRace -- this is to force a refresh after the BAG_UPDATE event
local digsitesTrackingID -- set in Archy:OnEnable()

local nearestDigsite

local playerLocation = {
	UIMapID = 0,
	UIMapType = 0,
	x = 0,
	y = 0
}

local surveyLocation = {
	UIMapID = 0,
	UIMapType = 0,
	x = 0,
	y = 0
}

local prevTheme

-- ----------------------------------------------------------------------------
-- Debugger.
-- ----------------------------------------------------------------------------
local Debug, DebugPour, GetDebugger
do
	local TextDump = LibStub("LibTextDump-1.0")

	local DEBUGGER_WIDTH = 750
	local DEBUGGER_HEIGHT = 800

	local debugger

	function Debug(...)
		if not debugger then
			debugger = TextDump:New(("%s Debug Output"):format(FOLDER_NAME), DEBUGGER_WIDTH, DEBUGGER_HEIGHT)
		end

		local message = string.format(...)
		debugger:AddLine(message)

		return message
	end

	function DebugPour(...)
		Archy:Pour(Debug(...), 1, 1, 1)
	end

	function GetDebugger()
		if not debugger then
			debugger = TextDump:New(("%s Debug Output"):format(FOLDER_NAME), DEBUGGER_WIDTH, DEBUGGER_HEIGHT)
		end

		return debugger
	end

	private.Debug = Debug
	private.DebugPour = DebugPour
end

-- ----------------------------------------------------------------------------
-- Function upvalues
-- ----------------------------------------------------------------------------
local Blizzard_SolveArtifact
local UpdateAllSites

-- ----------------------------------------------------------------------------
-- External objects. Assigned in Archy:OnEnable()
-- ----------------------------------------------------------------------------
local ArtifactFrame
local DigSiteFrame
local DistanceIndicatorFrame
local TomTomHandler

-- ----------------------------------------------------------------------------
-- Initialization.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Local helper functions
-- ----------------------------------------------------------------------------
local function UpdateMinimapIcons()
	if not private.hasArchaeology or not playerLocation.x and not playerLocation.y then
		return
	end

	local continentDigsites = continent_digsites[private.CurrentContinentID]
	if not continentDigsites then
		return
	end

	local minimapSettings = private.ProfileSettings.minimap
	local canShow = private.ProfileSettings.general.show and minimapSettings.show

	for _, digsite in pairs(continentDigsites) do
		if canShow then
			if nearestDigsite == digsite or not minimapSettings.nearest then
				digsite:EnableMapIcon()
			else
				digsite:DisableMapIcon()
			end

			if nearestDigsite == digsite and minimapSettings.fragmentNodes then
				digsite:EnableSurveyNodes()
			else
				digsite:DisableSurveyNodes()
			end
		else
			digsite:DisableMapIcon()
			digsite:DisableSurveyNodes()
		end
	end
end

local function HideFrames()
	DigSiteFrame:Hide()
	ArtifactFrame:Hide()
end

local function ShowFrames()
	if private.in_combat or private.FramesShouldBeHidden() then
		return
	end

	if private.ProfileSettings.digsite.show then
		DigSiteFrame:Show()
	end

	if private.ProfileSettings.artifact.show then
		ArtifactFrame:Show()
	end

	Archy:ConfigUpdated()
end

local SuspendClickToMove
do
	local click_to_move

	function SuspendClickToMove()
		-- we're not using easy cast, no need to mess with click to move
		if not private.ProfileSettings.general.easyCast or _G.IsEquippedItemType(FISHING_POLE_ITEM_TYPE_NAME) or not _G.CanScanResearchSite() then
			return
		end

		if private.ProfileSettings.general.show then
			if _G.GetCVarBool("autointeract") then
				_G.SetCVar("autointeract", "0")
				click_to_move = "1"
			end
		else
			if click_to_move and click_to_move == "1" then
				_G.SetCVar("autointeract", "1")
				click_to_move = nil
			end
		end
	end
end -- do-block

local function AnnounceNearestDigsite()
	if not nearestDigsite or not nearestDigsite.distance then
		return
	end
	local digsiteName = ("%s%s|r"):format(_G.GREEN_FONT_COLOR_CODE, nearestDigsite.name)
	local digsiteZoneName = ("%s%s|r"):format(_G.GREEN_FONT_COLOR_CODE, nearestDigsite.zoneName)

	Archy:Pour(L["Nearest Dig Site is: %s in %s (%.1f yards away)"]:format(digsiteName, digsiteZoneName, nearestDigsite.distance), 1, 1, 1)
end

-- returns the rank and max rank for the players archaeology skill
local function GetArchaeologyRank()
	local _, _, archaeologyIndex = _G.GetProfessions()

	if not archaeologyIndex then
		return 0, 0
	end
	local _, _, rank, maxRank = _G.GetProfessionInfo(archaeologyIndex)
	return rank, maxRank
end

private.GetArchaeologyRank = GetArchaeologyRank

local function IsTaintable()
	return (private.in_combat or _G.InCombatLockdown() or (_G.UnitAffectingCombat("player") or _G.UnitAffectingCombat("pet")))
end

private.IsTaintable = IsTaintable

local function SolveRaceArtifact(race, useKeystones)
	-- The check for race exists because its absence means we're calling this function from the default UI and should NOT perform any of the actions within the block.
	if race then
		local artifact = race.currentProject

		if artifact then
			_G.SetSelectedArtifact(race.ID)
			lootedKeystoneRace = race

			-- Override keystones that have already been added if true or false were passed.
			if type(useKeystones) == "boolean" then
				artifact.keystones_added = useKeystones and math.min(race.keystonesInInventory, artifact.sockets) or 0
			end

			if artifact.keystones_added > 0 then
				for index = 1, artifact.keystones_added do
					_G.SocketItemToArtifact()

					if not _G.ItemAddedToArtifact(index) then
						break
					end
				end
			elseif artifact.sockets > 0 then
				for index = 1, artifact.sockets do
					_G.RemoveItemFromArtifact()
				end
			end
		end
	end
	Blizzard_SolveArtifact()
end

Dialog:Register("ArchyConfirmSolve", {
	text = "",
	on_show = function(self, data)
		self.text:SetFormattedText(L["Your Archaeology skill is at %d of %d.  Are you sure you would like to solve this artifact before visiting a trainer?"], data.rank, data.maxRank)
	end,
	buttons = {
		{
			text = _G.YES,
			on_click = function(self, data)
				if data.race then
					SolveRaceArtifact(data.race, data.useKeystones)
				else
					Blizzard_SolveArtifact()
				end
			end,
		},
		{
			text = _G.NO,
		},
	},
	show_while_dead = false,
	hide_on_escape = true,
})

-- ----------------------------------------------------------------------------
-- AddOn methods
-- ----------------------------------------------------------------------------
function Archy:ShowArchaeology()
	if _G.IsAddOnLoaded("Blizzard_ArchaeologyUI") then
		if _G.ArchaeologyFrame:IsShown() then
			_G.HideUIPanel(_G.ArchaeologyFrame)
		else
			_G.ShowUIPanel(_G.ArchaeologyFrame)
		end
		return true
	end
	local loaded, reason = _G.LoadAddOn("Blizzard_ArchaeologyUI")

	if loaded then
		if _G.ArchaeologyFrame:IsShown() then
			_G.HideUIPanel(_G.ArchaeologyFrame)
		else
			_G.ShowUIPanel(_G.ArchaeologyFrame)
		end
		return true
	else
		Archy:Print(L["ArchaeologyUI not loaded: %s Try opening manually."]:format(_G["ADDON_" .. reason]))
		return false
	end
end

local CONFIG_UPDATE_FUNCTIONS = {
	artifact = function(option)
		if option == "autofill" then
			for raceID, race in pairs(private.Races) do
				race:UpdateCurrentProject()
			end
		elseif option == "color" then
			ArtifactFrame:RefreshDisplay()
		else
			ArtifactFrame:UpdateChrome()
			ArtifactFrame:RefreshDisplay()
			Archy:SetFramePosition(ArtifactFrame)
		end
	end,
	digsite = function(option)
		if option == "tooltip" then
			UpdateAllSites()
		end

		Archy:UpdateSiteDistances()
		DigSiteFrame:UpdateChrome()

		if option == "font" then
			Archy:ResizeDigSiteDisplay()
		else
			Archy:RefreshDigSiteDisplay()
		end
        
		Archy:SetFramePosition(DigSiteFrame)
		Archy:SetFramePosition(DistanceIndicatorFrame)
		DistanceIndicatorFrame:Toggle()
	end,
	minimap = function(option)
		UpdateMinimapIcons()
	end,
	waypoint = function(option)
		local digsiteSettings = private.ProfileSettings.digsite
        if not digsiteSettings.waypointNearest then
            WaypoingHandler:ClearWaypoint(true)
        else
            WaypoingHandler:Refresh(nearestDigsite, true)
        end
	end,
	tomtom = function(option)
		local tomtomSettings = private.ProfileSettings.tomtom
		TomTomHandler.hasTomTom = IsAddOnLoaded("TomTom")

		if TomTomHandler.hasTomTom and tomtomSettings.enabled and _G.TomTom.profile then
			_G.TomTom.profile.arrow.arrival = tomtomSettings.distance
			_G.TomTom.profile.arrow.enablePing = tomtomSettings.ping
		end
		TomTomHandler:Refresh(nearestDigsite)
	end,
}

function Archy:ConfigUpdated(namespace, option)
	if namespace then
		CONFIG_UPDATE_FUNCTIONS[namespace](option)
	else
		ArtifactFrame:UpdateChrome()
		ArtifactFrame:RefreshDisplay()

		DigSiteFrame:UpdateChrome()
		self:RefreshDigSiteDisplay()

		self:UpdateTracking()

		DistanceIndicatorFrame:Toggle()
		UpdateMinimapIcons()
		SuspendClickToMove()

		TomTomHandler:Refresh(nearestDigsite)
        WaypoingHandler:Refresh(nearestDigsite, false)
	end
end

function Archy:SolveAnyArtifact(useKeystones)
	local found = false

	for raceID, race in pairs(private.Races) do
		local artifact = race.currentProject

		if artifact and not race:IsOnArtifactBlacklist() and (artifact.canSolve or (useKeystones and artifact.canSolveInventory)) then
			SolveRaceArtifact(race, useKeystones)
			found = true
			break
		end
	end

	if not found then
		self:Print(L["No artifacts were solvable"])
	end
end

function Archy:SocketClicked(keystone_button, mouseButtonName, down)
	local raceID = keystone_button:GetParent():GetParent():GetID()
	private.Races[raceID]:KeystoneSocketOnClick(mouseButtonName)
	ArtifactFrame:RefreshDisplay()
end

--[[ Dig Site List Functions ]] --
local function CompareAndResetDigCounters(digsiteListA, digsiteListB)
	if not digsiteListA or not digsiteListB or (#digsiteListA == 0) or (#digsiteListB == 0) then
		return
	end

	for _, siteA in pairs(digsiteListA) do
		local exists = false
		for _, siteB in pairs(digsiteListB) do
			if siteA == siteB then
				exists = true
				break
			end
		end

		if not exists then
			siteA.stats.counter = 0
			siteA:DisableMapIcon()
			siteA:DisableSurveyNodes()
		end
	end
end

local SourceCount = 0
function UpdateAllSites()

	for continentID, continentData in pairs(MAP_CONTINENTS) do
		local sites = {}
        
        local continentSites = {}
        for _, continentSite in ipairs(C_ResearchInfo.GetDigSitesForMap(continentID)) do
            continentSites[continentSite.researchSiteID] = continentSite
        end
        
		for continentZoneIndex = 1, #continentData.zones do
			local zone = ZONE_DATA[continentData.zones[continentZoneIndex]]
			for key, zoneSite in pairs(C_ResearchInfo.GetDigSitesForMap(zone.UIMapID)) do
                if not continentSites[zoneSite.researchSiteID] then
                    return
                end
                local mapPositionX = continentSites[zoneSite.researchSiteID].position.x
                local mapPositionY = continentSites[zoneSite.researchSiteID].position.y
                local templateKey = ("%d:%.6f:%.6f"):format(continentID, mapPositionX, mapPositionY)
                local digsiteTemplate = Archy:SearchDigsiteTemplate(continentID, zone, zoneSite, mapPositionX, mapPositionY)
                if digsiteTemplate then
                    if digsiteTemplate.mapID == zone.UIMapID then
                        local digsite = private.Digsites[zoneSite.researchSiteID]			
                        if not digsite then
                            digsite = private.AddDigsite(digsiteTemplate, templateKey, zoneSite.researchSiteID, zoneSite.name, zoneSite.position.x, zoneSite.position.y)
                        end
                        table.insert(sites, digsite)
                    end
                end
			end		
		end
		
		if #sites > 0 then
			if continent_digsites[continentID] then
				CompareAndResetDigCounters(continent_digsites[continentID], sites)
				CompareAndResetDigCounters(sites, continent_digsites[continentID])
			end
		end
		continent_digsites[continentID] = sites
	end
	
	if MissingDigsites and MissingDigsites.Count and MissingDigsites.Count > SourceCount then
        Archy:DebugMissingDigsites()
	end
    SourceCount = MissingDigsites.Count or 0
end

local function SortSitesByDistance(digsiteA, digsiteB)
	if digsiteA:IsBlacklisted() and not digsiteB:IsBlacklisted() then
		return 1 < 0
	elseif not digsiteA:IsBlacklisted() and digsiteB:IsBlacklisted() then
		return 0 < 1
	end

	if (digsiteA.distance == -1 and digsiteB.distance == -1) or (not digsiteA.distance and not digsiteB.distance) then
		return digsiteA.zoneName .. ":" .. digsiteA.name < digsiteB.zoneName .. ":" .. digsiteB.name
	else
		return (digsiteA.distance or 0) < (digsiteB.distance or 0)
	end
end

local function SortSitesByZoneNameAndName(a, b)
	return a.zoneName .. ":" .. a.name < b.zoneName .. ":" .. b.name
end

function Archy:AddMissingDigSite(siteKey, id, name, continentID, mapID, zonename, raceID)
    if MissingDigsites and MissingDigsites.Sites and MissingDigsites.Sites[siteKey] then
        return
    end
    MissingDigsites = MissingDigsites or {}
    MissingDigsites.Count = MissingDigsites.Count or 0
    MissingDigsites.Sites = MissingDigsites.Sites or {}
    local RaceID = private.RaceID
    if raceID == RaceID.Unknown and continentID == 875 then --Zandalar
        raceID = RaceID.ArchRaceZandalari
    end
    if raceID == RaceID.Unknown and continentID == 876 then --Kul Tiras
        raceID = RaceID.ArchRaceDrust
    end
    MissingDigsites.Sites[siteKey] = { 
        id = id,
        name =  name,
        mapID = mapID,
        zonename = zonename,
        raceID = raceID,
        continentID = continentID
    }
    MissingDigsites.Count = MissingDigsites.Count + 1
end

function Archy:DebugMissingDigsites()
    if MissingDigsites  and MissingDigsites.Sites then
        MissingDigsites.Count = 0
        for siteKey, site in pairs(MissingDigsites.Sites) do
            if private.DIGSITE_TEMPLATES[siteKey] then
                MissingDigsites.Sites[siteKey] = nil
            elseif private.DIGSITE_TEMPLATES_BY_ID[site.id] then
                MissingDigsites.Sites[siteKey] = nil
            else
                local raceID = site.raceID
                local raceName = private.RaceIDToRaceLabel[raceID];
                Debug("\n\t\t[\""..siteKey.."\"] = {\n\t\t\t\siteID = "..site.id..", -- "..site.name.."\n\t\t\tmapID = "..site.mapID..", -- "..site.zonename.."\n\t\t\traceID = RaceID."..raceName..",\n\t\t},")
                MissingDigsites.Count = MissingDigsites.Count + 1
            end
        end
	end
    
    if ((MissingDigsites or {}).Count or 0) > 0 then
        print(MissingDigsites.Count .. " missing digsites found. Please run /archy debug and report the list")
    end
end

function Archy:SearchDigsiteTemplate(continentID, zone, zoneSite, mapPositionX, mapPositionY)
    local siteKey = ("%d:%.6f:%.6f"):format(continentID, mapPositionX, mapPositionY)
    local digsiteTemplate = private.DIGSITE_TEMPLATES[siteKey]
 
    if not digsiteTemplate then
        local oldsiteKey = private.DIGSITE_TEMPLATES_BY_ID[zoneSite.researchSiteID]
        if oldsiteKey then
            digsiteTemplate = private.DIGSITE_TEMPLATES[oldsiteKey]
            private.DIGSITE_TEMPLATES[oldsiteKey] = nil
            private.DIGSITE_TEMPLATES[siteKey] = digsiteTemplate
        end
    end
    
    if not digsiteTemplate then
        digsiteTemplate = private.DIGSITE_TEMPLATES[zoneSite.researchSiteID]
    end
    
    if not digsiteTemplate and MissingDigsites and MissingDigsites.Sites and MissingDigsites.Sites[siteKey] then
        digsiteTemplate = MissingDigsites.Sites[siteKey]
    end

    if not digsiteTemplate then
        Archy:AddMissingDigSite(siteKey, zoneSite.researchSiteID, zoneSite.name, continentID, zone.UIMapID, zone.name, 0)
        digsiteTemplate = MissingDigsites.Sites[siteKey]
    end
    
    if digsiteTemplate then
        if not digsiteTemplate.siteID then
            Archy:AddMissingDigSite(siteKey, zoneSite.researchSiteID, zoneSite.name, continentID, zone.UIMapID, zone.name, digsiteTemplate.raceID)
        end
    end
    return digsiteTemplate
end

function Archy:UpdateSiteDistances(force)
	local continentDigsites = continent_digsites[private.CurrentContinentID]
	if not continentDigsites or #continentDigsites == 0 then
		nearestDigsite = nil
		return
	end
	local closestDistance, closestDigsite

	for index = 1, #continentDigsites do
		local digsite = continentDigsites[index]

		if digsite.mapIconFrame:IsShown() then
			digsite.distance = digsite.mapIconFrame:GetDistance()
		else
			digsite.distance = HereBeDragons:GetZoneDistance(playerLocation.UIMapID, playerLocation.x, playerLocation.y, digsite.UIMapID, digsite.coordX, digsite.coordY)
		end

		if digsite.coordX and digsite.distance and not digsite:IsBlacklisted() and (not closestDistance or digsite.distance < closestDistance) then
			closestDistance = digsite.distance
			closestDigsite = digsite
		end
	end

	if closestDigsite and (nearestDigsite ~= closestDigsite or force) then
		nearestDigsite = closestDigsite
		TomTomHandler.isActive = true
		TomTomHandler:Refresh(nearestDigsite)
        WaypoingHandler.isActive = true
		WaypoingHandler:Refresh(nearestDigsite, false)
		UpdateMinimapIcons()

		if private.ProfileSettings.digsite.announceNearest and private.ProfileSettings.general.show then
			AnnounceNearestDigsite()
		end
	end

	table.sort(continentDigsites, private.ProfileSettings.digsite.sortByDistance and SortSitesByDistance or SortSitesByZoneNameAndName)
end

function Archy:OnInitialize()
	private.isLoading = true

	self.db = LibStub("AceDB-3.0"):New("ArchyDB", private.DEFAULT_SETTINGS, 'Default')
	self.db.RegisterCallback(self, "OnNewProfile", "OnProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileUpdate")

	local about_panel = LibStub:GetLibrary("LibAboutPanel-2.0", true)

	if about_panel then
		self.optionsFrame = about_panel:CreateAboutPanel("Archy")
	end
	self:DefineSinkToast(FOLDER_NAME, [[Interface\Archeology\Arch-Icon-Marker]])
	self:SetSinkStorage(self.db.profile.general.sinkOptions)
	self:SetupOptions()

	self.db.global.surveyNodes = self.db.global.surveyNodes or {}

	self.db.char.waypoint = self.db.char.waypoint or {}

	self.db.char.digsites = self.db.char.digsites or {
		stats = {},
		blacklist = {}
	}

	setmetatable(self.db.char.digsites.stats, {
		__index = function(t, k)
			if k then
				t[k] = {
					surveys = 0,
					fragments = 0,
					looted = 0,
					keystones = 0,
					counter = 0
				}
				return t[k]
			end
		end
	})

	self.db.char.digsites.blacklist = self.db.char.digsites.blacklist or {}

	local profileSettings = self.db.profile
	private.ProfileSettings = profileSettings

	prevTheme = profileSettings.general and profileSettings.general.theme or private.DEFAULT_SETTINGS.profile.general.theme

	LDBI:Register("Archy", private.LDB_object, profileSettings.general.icon)

    local survey_spell_name = GetSpellInfo(SURVEY_SPELL_ID);
	do
		local surveyButtonName = "Archy_EasySurveyButton"
		local surveyButton = _G.CreateFrame("Button", surveyButtonName, _G.UIParent, "SecureActionButtonTemplate")
		surveyButton:SetPoint("LEFT", _G.UIParent, "RIGHT", 10000, 0)
		surveyButton:Hide()
		surveyButton:SetFrameStrata("LOW")
		surveyButton:EnableMouse(true)
		surveyButton:RegisterForClicks("RightButtonDown")

		surveyButton:SetAttribute("type", "macro")
		surveyButton:SetAttribute("macrotext", "/use [noflying] " .. survey_spell_name)
		surveyButton:SetAttribute("action", nil)

		surveyButton:SetScript("PostClick", function(self, mouse_button, is_down)
			if private.override_binding_on and not IsTaintable() then
				_G.ClearOverrideBindings(self)
				private.override_binding_on = nil
			else
				private.regen_clear_override = true
			end
		end)

		EasySurveyButton = surveyButton

		local DOUBLECLICK_MAX_SECONDS = 0.2
		local DOUBLECLICK_MIN_SECONDS = 0.04

		local previousClickTime

		_G.WorldFrame:HookScript("OnMouseDown", function(frame, button, down)
			uiMapID = C_Map.GetBestMapForUnit("player")
			if button == "RightButton" and profileSettings.general.easyCast and uiMapID and ArchaeologyMapUpdateAll(uiMapID) > 0 and not IsTaintable() and not _G.IsEquippedItemType(FISHING_POLE_ITEM_TYPE_NAME) and _G.CanScanResearchSite() and _G.GetSpellCooldown(SURVEY_SPELL_ID) == 0 and not _G.IsFlying() then
				-- Ensure the LootFrame contains no items; we don't care if it's simply visible.
				if _G.GetNumLootItems() == 0 and previousClickTime then
					local doubleClickTime = _G.GetTime() - previousClickTime

					if doubleClickTime < DOUBLECLICK_MAX_SECONDS and doubleClickTime > DOUBLECLICK_MIN_SECONDS then
						previousClickTime = nil

						if not IsTaintable() then
							_G.SetOverrideBindingClick(surveyButton, true, "BUTTON2", surveyButtonName)
							private.override_binding_on = true
						end
					end
				end

				previousClickTime = _G.GetTime()
			end
		end)
	end

	private.InitializeFrames()
	ArtifactFrame = private.ArtifactFrame
	DigSiteFrame = private.DigSiteFrame
	DistanceIndicatorFrame = private.DistanceIndicatorFrame
    DistanceIndicatorFrame.surveyButton:SetAttribute("type", "macro")
	DistanceIndicatorFrame.surveyButton:SetAttribute("macrotext", "/use [noflying] " .. survey_spell_name) 

	-- ----------------------------------------------------------------------------
	-- DB cleanups.
	-- ----------------------------------------------------------------------------
	for siteID, value in pairs(self.db.char.digsites.blacklist) do
		if value == false then
			self.db.char.digsites.blacklist[siteID] = nil
		end
	end

	profileSettings.data = nil
end

function Archy:UpdateFramePositions()
	self:SetFramePosition(DistanceIndicatorFrame)
	self:SetFramePosition(DigSiteFrame)
	self:SetFramePosition(ArtifactFrame)
end

local PositionUpdateTimerHandle

function Archy:LoadWorldData(worldID)
	local info = C_Map.GetMapInfo(worldID)
	if not info then
		return
	end
	
	if info.mapType == Enum.UIMapType.Cosmic or info.mapType == Enum.UIMapType.World then
		local continents = C_Map.GetMapChildrenInfo(worldID, Enum.UIMapType.Continent, true)
		for i = 1, #continents do
		   Archy:LoadContinentData(continents[i].mapID)
		end
	end
end

function Archy:LoadContinentData(continentID)
	local info = C_Map.GetMapInfo(continentID)
	if not info then
		return
	end
	
	if info.mapType == Enum.UIMapType.Continent then

		local continentName = HereBeDragons:GetLocalizedMap(continentID)
        local continentZones = {}
        

		local zoneData = C_Map.GetMapChildrenInfo(continentID, Enum.UIMapType.Zone, true)
        
		for zoneDataIndex = 1, #zoneData do
			local zoneID = zoneData[zoneDataIndex].mapID
			local zoneName = HereBeDragons:GetLocalizedMap(zoneID)
            continentZones[zoneDataIndex] = zoneID
			ZONE_DATA[zoneID] = {
				continentID = continentID,
				ID = zoneID,
				UIMapID = zoneID,
				name = zoneName
			}
		end
        
        MAP_CONTINENTS[continentID] = 
        {
			continentID = continentID,
			ID = continentID,
			UIMapID = continentID,
			name = continentName,
            zones = continentZones
        }
        
	end
end

function Archy:OnEnable()
	-- Ignore this event for now as it's can break other Archaeology UIs
	-- Would have been nice if Blizzard passed the race index or artifact name with the event
	--    self:RegisterEvent("ARTIFACT_UPDATE")
	self:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE")
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("PET_BATTLE_CLOSE")
	self:RegisterEvent("PET_BATTLE_OPENING_START")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_STARTED_MOVING")
	self:RegisterEvent("PLAYER_STOPPED_MOVING")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("RESEARCH_ARTIFACT_COMPLETE")
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED")
	self:RegisterEvent("SKILL_LINES_CHANGED")
	self:RegisterEvent("TAXIMAP_CLOSED")
	self:RegisterEvent("TAXIMAP_OPENED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
    self:RESEARCH_ARTIFACT_HISTORY_READY()

	self:SKILL_LINES_CHANGED()

	Archy:UpdateFramePositions()
	DigSiteFrame:UpdateChrome()
	ArtifactFrame:UpdateChrome()

	--DatamineTooltip:ClearLines()
	--DatamineTooltip:SetSpellByID(private.CRATE_SPELL_ID)
	--CRATE_USE_STRING = ("%s %s"):format(_G.ITEM_SPELL_TRIGGER_ONUSE, _G["ArchyScanTipTextLeft" .. DatamineTooltip:NumLines()]:GetText())

	for trackingTypeIndex = 1, C_Minimap.GetNumTrackingTypes() do
		if (C_Minimap.GetTrackingInfo(trackingTypeIndex)) == _G.MINIMAP_TRACKING_DIGSITES then
			digsitesTrackingID = trackingTypeIndex
			break
		end
	end
	self:UpdateTracking()

	TomTomHandler = private.TomTomHandler
	TomTomHandler.isActive = true
	TomTomHandler.hasTomTom = IsAddOnLoaded("TomTom")
	TomTomHandler.hasPOIIntegration = TomTomHandler.hasTomTom and (_G.TomTom.profile and _G.TomTom.profile.poi and _G.TomTom.EnableDisablePOIIntegration) and true or false

    WaypoingHandler = private.WaypoingHandler
	WaypoingHandler.isActive = true

	private.InitializeRaces()
	private.InitializeDigsiteTemplates()
	private.InitializeArtifactTemplates()

	-- ----------------------------------------------------------------------------
	-- Map stuff.
	-- ----------------------------------------------------------------------------
	local CosmicUIMapID = 946
	Archy:LoadWorldData(CosmicUIMapID)

	private.PlayerGUID = _G.UnitGUID("player")

	self:ScheduleTimer("UpdatePlayerPosition", 2, true)
	private.isLoading = false
end

function Archy:OnProfileUpdate(event, database, ProfileKey)
	local newTheme
	if database then
		if event == "OnProfileChanged" or event == "OnProfileCopied" then
			newTheme = database.profile and database.profile.general and database.profile.general.theme or private.DEFAULT_SETTINGS.profile.general.theme
		elseif event == "OnProfileReset" or event == "OnNewProfile" then
			newTheme = database.defaults and database.defaults.profile and database.defaults.profile.general and database.defaults.profile.general.theme
		end
	end
	private.ProfileSettings = database and database.profile or self.db.profile

	if newTheme and prevTheme and (newTheme ~= prevTheme) then
		_G.ReloadUI()
	end

	self:ConfigUpdated()
	self:UpdateFramePositions()
end

-- ----------------------------------------------------------------------------
-- Slash command handler
-- ----------------------------------------------------------------------------
local SUBCOMMAND_FUNCS = {
	[L["config"]:lower()] = function()
		_G.InterfaceOptionsFrame_OpenToCategory(Archy.optionsFrame)
	end,
	[L["stealth"]:lower()] = function()
		private.ProfileSettings.general.stealthMode = not private.ProfileSettings.general.stealthMode
		Archy:ConfigUpdated()
	end,
	[L["dig sites"]:lower()] = function()
		private.ProfileSettings.digsite.show = not private.ProfileSettings.digsite.show
		Archy:ConfigUpdated('digsite')
	end,
	[L["artifacts"]:lower()] = function()
		private.ProfileSettings.artifact.show = not private.ProfileSettings.artifact.show
		Archy:ConfigUpdated('artifact')
	end,
	[_G.SOLVE:lower()] = function()
		Archy:SolveAnyArtifact()
	end,
	[L["solve stone"]:lower()] = function()
		Archy:SolveAnyArtifact(true)
	end,
	[L["nearest"]:lower()] = AnnounceNearestDigsite,
	[L["closest"]:lower()] = AnnounceNearestDigsite,
	[L["reset"]:lower()] = function()
		private:ResetFramePositions()
	end,
	[_G.MINIMAP_LABEL:lower()] = function()
		private.ProfileSettings.minimap.show = not private.ProfileSettings.minimap.show
		Archy:ConfigUpdated('minimap')
	end,
	tomtom = function()
		private.ProfileSettings.tomtom.enabled = not private.ProfileSettings.tomtom.enabled
		TomTomHandler:Refresh(nearestDigsite)
	end,
	waypoint = function(option)
		private.ProfileSettings.digsite.waypointNearest = not private.ProfileSettings.digsite.waypointNearest
        if not private.ProfileSettings.digsite.waypointNearest then
            WaypoingHandler:ClearWaypoint(true)
        else
            WaypoingHandler:Refresh(nearestDigsite, true)
        end
	end,
	test = function()
		ArtifactFrame:SetBackdropBorderColor(1, 1, 1, 0.5)
	end,
	debug = function()
		local debugger = GetDebugger()

		if debugger:Lines() == 0 then
			debugger:AddLine("Nothing to report.")
			debugger:Display()
			debugger:Clear()
			return
		end

		debugger:Display()
	end,

	scan = function()

		Debug("Scanning digsites:\n")
        
        for continentID, continentData in pairs(MAP_CONTINENTS) do

            local continentSites = {}
            for _, continentSite in ipairs(C_ResearchInfo.GetDigSitesForMap(continentID)) do
                continentSites[continentSite.researchSiteID] = continentSite
            end
            
            for continentZoneIndex = 1, #continentData.zones do
                local zone = ZONE_DATA[continentData.zones[continentZoneIndex]]
                for key, zoneSite in pairs(C_ResearchInfo.GetDigSitesForMap(zone.UIMapID)) do
                    local mapPositionX = continentSites[zoneSite.researchSiteID].position.x
                    local mapPositionY = continentSites[zoneSite.researchSiteID].position.y
                    Archy:SearchDigsiteTemplate(continentID, zone, zoneSite, mapPositionX, mapPositionY)
                end		
            end
            
        end
        
        if MissingDigsites and MissingDigsites.Count > 0 then
            Archy:DebugMissingDigsites()
        end
        
		Debug(("%d found"):format(MissingDigsites.Count))

		debugger:Display()
	end,
}

_G["SLASH_ARCHY1"] = "/archy"
_G.SlashCmdList["ARCHY"] = function(msg, editbox)
	local command = msg:lower()

	local func = SUBCOMMAND_FUNCS[command]
	if func then
		func()
	else
		Archy:Print(L["Available commands are:"])
		Archy:Print("|cFF00FF00" .. L["config"] .. "|r - " .. L["Shows the Options"])
		Archy:Print("|cFF00FF00" .. L["stealth"] .. "|r - " .. L["Toggles the display of the Artifacts and Dig Sites lists"])
		Archy:Print("|cFF00FF00" .. L["dig sites"] .. "|r - " .. L["Toggles the display of the Dig Sites list"])
		Archy:Print("|cFF00FF00" .. L["artifacts"] .. "|r - " .. L["Toggles the display of the Artifacts list"])
		Archy:Print("|cFF00FF00" .. _G.SOLVE .. "|r - " .. L["Solves the first artifact it finds that it can solve"])
		Archy:Print("|cFF00FF00" .. L["solve stone"] .. "|r - " .. L["Solves the first artifact it finds that it can solve (including key stones)"])
		Archy:Print("|cFF00FF00" .. L["nearest"] .. "|r or |cFF00FF00" .. L["closest"] .. "|r - " .. L["Announces the nearest dig site to you"])
		Archy:Print("|cFF00FF00" .. L["reset"] .. "|r - " .. L["Reset the window positions to defaults"])
		Archy:Print("|cFF00FF00" .. "tomtom" .. "|r - " .. L["Toggles TomTom Integration"])
		Archy:Print("|cFF00FF00" .. _G.MINIMAP_LABEL .. "|r - " .. L["Toggles the dig site icons on the minimap"])
	end
end

do
	local CRATE_OF_FRAGMENTS = {
		[87534] = true, -- Draenei
		[87533] = true, -- Dwarven
		[87535] = true, -- Fossil
		[117388] = true, -- Mantid
		[117387] = true, -- Mogu
		[87537] = true, -- Nerubian
		[87536] = true, -- Night Elf
		[87538] = true, -- Orc
		[117386] = true, -- Pandaren
		[87539] = true, -- Tol'vir
		[87540] = true, -- Troll
		[87541] = true, -- Vrykul
	}
    
	local function FindCrateable(bag, slot)
		if not private.hasArchaeology then
			return
		end

		if IsTaintable() then
			private.regen_scan_bags = true
			return
		end
		local itemID = C_Container.GetContainerItemID(bag, slot)

		if itemID then
			-- 86068,73410 for debug or any book-type item
			if CRATE_OF_FRAGMENTS[itemID] then
				private.crate_item_id = itemID
				return true
			elseif private.ARTIFACTS_RESTORE[itemID]  then
                private.crate_item_id = itemID
                return true
            end
		end
		return false
	end

	function Archy:ScanBags()
		if IsTaintable() then
			private.regen_scan_bags = true
			return
		end
		private.crate_bag_id, private.crate_bag_slot_id, private.crate_item_id = nil, nil, nil

		for bag = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS, 1 do
			for slot = 1, C_Container.GetContainerNumSlots(bag), 1 do
				if not private.crate_bag_id and FindCrateable(bag, slot) then
					private.crate_bag_id = bag
					private.crate_bag_slot_id = slot
					break
				end
			end

			if private.crate_bag_id then
				break
			end
		end
		local crateButton = DistanceIndicatorFrame.crateButton

		if private.crate_bag_id then
			crateButton:SetAttribute("type", "macro")
			crateButton:SetAttribute("macrotext", "/run _G.ClearCursor() if _G.MerchantFrame:IsShown() then HideUIPanel(_G.MerchantFrame) end\n/use [noflying] " .. private.crate_bag_id .. " " .. private.crate_bag_slot_id)

			crateButton:Enable()
			crateButton.icon:SetDesaturated(false)
			crateButton.tooltip = private.crate_item_id
			crateButton.shine:Show()
			_G.AutoCastShine_AutoCastStart(crateButton.shine)
			crateButton.shining = true
		else
			crateButton:Disable()
			crateButton.icon:SetDesaturated(true)
			crateButton.tooltip = _G.BROWSE_NO_RESULTS
			crateButton.shine:Hide()

			if crateButton.shining then
				_G.AutoCastShine_AutoCastStop(crateButton.shine)
				crateButton.shining = nil
			end
		end

		local lorewalkersMapCount = _G.GetItemCount(LorewalkersMap.itemID, false, false)
		local lorewalkersLodestoneCount = _G.GetItemCount(LorewalkersLodestone.itemID, false, false)
		local loreItemButton = DistanceIndicatorFrame.loritemButton

		-- Prioritize map, since it affects Archy's lists. (randomize digsites)
		if lorewalkersMapCount > 0 then
			local itemName = _G.GetItemInfo(LorewalkersMap.itemID)
			loreItemButton:SetAttribute("type", "macro")
			loreItemButton:SetAttribute("macrotext", "/use [noflying] " .. itemName)
			loreItemButton:Enable()
			loreItemButton.icon:SetDesaturated(false)
			loreItemButton.tooltip = LorewalkersMap.itemID

			local start, duration, enable = _G.GetItemCooldown(LorewalkersMap.itemID)
			if start > 0 and duration > 0 then
				_G.CooldownFrame_Set(loreItemButton.cooldown, start, duration, enable)
			end
		end

		if lorewalkersLodestoneCount > 0 then
			local itemName = _G.GetItemInfo(LorewalkersLodestone.itemID)
			loreItemButton:SetAttribute("type", "macro")
			loreItemButton:SetAttribute("macrotext", "/use [noflying] " .. itemName)
			loreItemButton:Enable()
			loreItemButton.icon:SetDesaturated(false)

			if lorewalkersMapCount > 0 then
				loreItemButton.tooltip = { LorewalkersMap.itemID, itemName }
			else
				loreItemButton.tooltip = { LorewalkersLodestone.itemID, _G.USE }
			end
		end

		if lorewalkersMapCount == 0 and lorewalkersLodestoneCount == 0 then
			loreItemButton:Disable()
			loreItemButton.icon:SetDesaturated(true)
			loreItemButton.tooltip = _G.BROWSE_NO_RESULTS
		end
	end
end -- do-block

function Archy:UpdateSkillBar()
	if private.notInWorld or not ArtifactFrame or not ArtifactFrame.skillBar or not private.CurrentContinentID or not private.hasArchaeology then
		return
	end

	local rank, maxRank = GetArchaeologyRank()

	ArtifactFrame.skillBar:SetMinMaxValues(0, maxRank)
	ArtifactFrame.skillBar:SetValue(rank)
	ArtifactFrame.skillBar.text:SetFormattedText("%s : %d/%d", _G.GetArchaeologyInfo(), rank, maxRank)
end

local CONTINENT_FROM_MAP = {}

function Archy:GetContinentFromMap(UIMapID)
    if CONTINENT_FROM_MAP[UIMapID] then
        if CONTINENT_FROM_MAP[UIMapID] == 0 then
            return
        end
        return CONTINENT_FROM_MAP[UIMapID]
    end
	local info = C_Map.GetMapInfo(UIMapID)
	if not info or info.mapType == Enum.UIMapType.Orphan then
        CONTINENT_FROM_MAP[UIMapID] = 0
		return
	end
	if info.mapType == Enum.UIMapType.Continent then
        CONTINENT_FROM_MAP[UIMapID] = info.mapID
		return info.mapID
	end
	while info.parentMapID > 0 and info.mapType ~= Enum.UIMapType.Continent do
		info = C_Map.GetMapInfo(info.parentMapID)
		if not info or info.mapType == Enum.UIMapType.Orphan then
            CONTINENT_FROM_MAP[UIMapID] = 0
			return
		end
	end
	if info.mapType == Enum.UIMapType.Continent then
        CONTINENT_FROM_MAP[UIMapID] = info.mapID
		return info.mapID
	end
end

--[[ Positional functions ]] --
function Archy:UpdatePlayerPosition(force)
	if not private.hasArchaeology or _G.IsInInstance() or _G.UnitIsGhost("player") or (not force and not private.ProfileSettings.general.show) then
		return
	end

	local mapX, mapY, UIMapID, UIMapType = HereBeDragons:GetPlayerZonePosition()

	if not UIMapID or not UIMapType or (mapX == 0 and mapY == 0) then
		return
	end

	continentID = Archy:GetContinentFromMap(UIMapID)

	if not continentID then
		return
	end

	if not playerLocation.UIMapID then
		playerLocation.x, playerLocation.y, playerLocation.UIMapID, playerLocation.UIMapType = mapX, mapY, UIMapID, UIMapType
		private.CurrentContinentID = continentID
		UpdateAllSites()
	end

	if C_Map.GetBestMapForUnit("player") == -1 then
		self:UpdateSiteDistances()
		DigSiteFrame:UpdateChrome()
		self:RefreshDigSiteDisplay()
		return
	end

	if force or playerLocation.x ~= mapX or playerLocation.y ~= mapY or playerLocation.UIMapID ~= UIMapID then
		playerLocation.x, playerLocation.y, playerLocation.UIMapID, playerLocation.UIMapType = mapX, mapY, UIMapID, UIMapType

		self:UpdateSiteDistances()

		DistanceIndicatorFrame:Update(UIMapID, mapX, mapY, surveyLocation.UIMapID, surveyLocation.x, surveyLocation.y)
		UpdateMinimapIcons()
		self:RefreshDigSiteDisplay()
	end

	if private.CurrentContinentID == continentID then
		if force then
			if private.CurrentContinentID then
				UpdateAllSites()
				DistanceIndicatorFrame:Toggle()
			elseif not continentID then
				-- Edge case where continent and private.CurrentContinentID are both nil
				self:ScheduleTimer("UpdatePlayerPosition", 1, true)
			end
		end
        if _G.CanScanResearchSite() then
            TomTomHandler:ClearWaypoint()
            WaypoingHandler:ClearWaypoint(false)
        end
		return
	end
	private.CurrentContinentID = continentID

	if force then
		DistanceIndicatorFrame:Toggle()
	end

	UpdateAllSites()

	TomTomHandler:ClearWaypoint()
    WaypoingHandler:ClearWaypoint(false)
    if not _G.CanScanResearchSite() then
        TomTomHandler:Refresh(nearestDigsite)
        WaypoingHandler:Refresh(nearestDigsite, false)
    end

	for raceID, race in pairs(private.Races) do
		race:UpdateCurrentProject()
	end

	ArtifactFrame:UpdateChrome()
	ArtifactFrame:RefreshDisplay()

	if force then
		self:UpdateSiteDistances()
	end

	DigSiteFrame:UpdateChrome()
	self:RefreshDigSiteDisplay()
	self:UpdateFramePositions()
end

--[[ UI functions ]] --
function Archy:UpdateTracking()
	if not private.hasArchaeology or private.ProfileSettings.general.manualTrack then
		return
	end

	if IsTaintable() then
		private.regen_update_tracking = true
		return
	end

	if digsitesTrackingID then
		C_Minimap.SetTracking(digsitesTrackingID, private.ProfileSettings.general.show)
	end
end

-- ------------------------------------------------------------------------------------
-- Event handler data.
-- ------------------------------------------------------------------------------------
local currentDigsite

-- ------------------------------------------------------------------------------------
-- Event handler helpers.
-- ------------------------------------------------------------------------------------
local function GetItemIDFromLink(link)
	if not link then
		return
	end
	local found, _, str = link:find("^|c%x+|H(.+)|h%[.+%]")

	if not found then
		return
	end

	local _, ID = (":"):split(str)
	return tonumber(ID)
end

-- ------------------------------------------------------------------------------------
-- Event handlers.
-- ------------------------------------------------------------------------------------
do
	function Archy:ARCHAEOLOGY_FIND_COMPLETE(eventName, numFindsCompleted, totalFinds)
		DistanceIndicatorFrame.isActive = false
		DistanceIndicatorFrame:Toggle()

		if currentDigsite then
			currentDigsite.stats.counter = numFindsCompleted
			self:Pour(L.FIND_COMPLETE_MESSAGE_FORMAT:format(currentDigsite.race.currencyName))
		end
	end

	local function SetSurveyCooldown(time)
		_G.CooldownFrame_Set(DistanceIndicatorFrame.surveyButton.cooldown, _G.GetSpellCooldown(SURVEY_SPELL_ID))
	end

	function Archy:ARCHAEOLOGY_SURVEY_CAST(eventName, numFindsCompleted, totalFinds)
		if not private.ProfileSettings.digsite.displayProgressBar then
			self:DisableProgressBar()
		end

		if not nearestDigsite then
			surveyLocation.UIMapID = 0
			surveyLocation.x = 0
			surveyLocation.y = 0
			return
		end
		surveyLocation.UIMapID = playerLocation.UIMapID
		surveyLocation.x = playerLocation.x
		surveyLocation.y = playerLocation.y

		currentDigsite = nearestDigsite
		currentDigsite.stats.surveys = currentDigsite.stats.surveys + 1
		currentDigsite.stats.counter = numFindsCompleted
        
		DistanceIndicatorFrame.isActive = true
		DistanceIndicatorFrame:Toggle()
		DistanceIndicatorFrame:Reset()

		if DistanceIndicatorFrame.surveyButton and DistanceIndicatorFrame.surveyButton:IsShown() then
			local now = _G.GetTime()
			local start, duration, enable = _G.GetSpellCooldown(SURVEY_SPELL_ID)

			if start > 0 and duration > 0 and now < (start + duration) then
				if duration <= GLOBAL_COOLDOWN_TIME then
					self:ScheduleTimer(SetSurveyCooldown, (start + duration) - now)
				elseif duration > GLOBAL_COOLDOWN_TIME then
					_G.CooldownFrame_Set(DistanceIndicatorFrame.surveyButton.cooldown, start, duration, enable)
				end
			end
		end

		currentDigsite:UpdateSurveyNodeDistanceColors()

		TomTomHandler.isActive = false
		TomTomHandler:ClearWaypoint()
        WaypoingHandler.isActive = false
		WaypoingHandler:ClearWaypoint(false)
		self:RefreshDigSiteDisplay()
	end
end

do
	local function UpdateAndRefresh(race)
		race:UpdateCurrentProject()
		ArtifactFrame:RefreshDisplay()
	end

	function Archy:RESEARCH_ARTIFACT_COMPLETE(event, artifactName)
		-- TODO: If this is fired from Blizzard's UI, do NOT immediately update projects.
		-- This is the cause of ticket 461: Race:UpdateCurrentProject() calls SetSelectedArtifact(), which affects the Blizzard UI.
		-- Instead, possibly warn the user that changes to Archy's UI will not be available until Blizzard's UI is closed, then register some events/whatever so we can update
		-- Archy when the Blizzard UI is closed.
		for raceID, race in pairs(private.Races) do
			local artifact = race.currentProject

			if artifact and artifact.name == artifactName then
				race:UpdateCurrentProject()
				self:ScheduleTimer(UpdateAndRefresh, 2, race)
				break
			end
		end
		self:ScanBags()
	end
end

function Archy:RESEARCH_ARTIFACT_DIG_SITE_UPDATED()
	if not private.CurrentContinentID then
		return
	end

	UpdateAllSites()

	self:UpdateSiteDistances()
	self:RefreshDigSiteDisplay()
end

function Archy:RESEARCH_ARTIFACT_HISTORY_READY()
	if not private.initialAnnouncementCheck then
		private.initialAnnouncementCheck = self:ScheduleTimer(function()
			for raceID, race in pairs(private.Races) do
				race:UpdateCurrentProject()
			end
		end, 5)
	end

	for raceID, race in pairs(private.Races) do
		local project = race.currentProject
		if project then
			project.completionCount = race:GetArtifactCompletionCountByName(project.name)
		end
	end

	ArtifactFrame:RefreshDisplay()
end

function Archy:BAG_UPDATE_DELAYED()
	self:ScanBags()

	if not private.CurrentContinentID or not lootedKeystoneRace then
		return
	end
	lootedKeystoneRace:UpdateCurrentProject()
	lootedKeystoneRace = nil

	ArtifactFrame:RefreshDisplay()
end

do
	local function MatchFormat(msg, pattern)
		return msg:match(pattern:gsub("(%%s)", "(.+)"):gsub("(%%d)", "(.+)"))
	end

	local function ParseLootMessage(msg)
		local player = _G.UnitName("player")
		local itemLink, quantity = MatchFormat(msg, _G.LOOT_ITEM_SELF_MULTIPLE)

		if itemLink and quantity then
			return player, itemLink, tonumber(quantity)
		end
		quantity = 1
		itemLink = MatchFormat(msg, _G.LOOT_ITEM_SELF)

		if itemLink then
			return player, itemLink, tonumber(quantity)
		end
		player, itemLink, quantity = MatchFormat(msg, _G.LOOT_ITEM_MULTIPLE)

		if player and itemLink and quantity then
			return player, itemLink, tonumber(quantity)
		end
		quantity = 1
		player, itemLink = MatchFormat(msg, _G.LOOT_ITEM)

		return player, itemLink, tonumber(quantity)
	end

	function Archy:CHAT_MSG_LOOT(event, msg)
		if not currentDigsite then
			return
		end

		local _, itemLink = ParseLootMessage(msg)
		if itemLink then
			return
		end

		local race = private.KeystoneIDToRace[GetItemIDFromLink(itemLink)]
		if race then
			currentDigsite.stats.keystones = currentDigsite.stats.keystones + 1
			lootedKeystoneRace = race
		end
	end
end -- do-block

do
	local STANDING_ON_IT_SPELL_ID = 210837

	function Archy:COMBAT_LOG_EVENT_UNFILTERED(event)
		local digsiteSettings = private.ProfileSettings.digsite
		local _, subEvent, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellDescription, _ = CombatLogGetCurrentEventInfo()
		if subEvent == "SPELL_CAST_SUCCESS" and sourceGUID == private.PlayerGUID and spellID == STANDING_ON_IT_SPELL_ID then
			self:Pour(spellDescription)
            if digsiteSettings.standingPing then
                _G.PlaySoundFile([[Interface\AddOns\Archy\Media\dingding.mp3]])
            end
		end
	end
end

function Archy:CURRENCY_DISPLAY_UPDATE()
	if not private.CurrentContinentID then
		return
	end

	for raceID, race in pairs(private.Races) do
		local _, _, _, fragmentsCollected = _G.GetArchaeologyRaceInfo(raceID)
		local diff = fragmentsCollected - (race.fragmentsCollected or 0)

		race.fragmentsCollected = fragmentsCollected
		race:UpdateCurrentProject()

		if diff < 0 then
			-- we've spent fragments, aka. Solved an artifact
			race.currentProject.keystones_added = 0
            Archy:ScanBags()
		elseif diff > 0 then
			-- we've gained fragments, aka. Successfully dug at a dig site
			if currentDigsite then
				currentDigsite.stats.looted = currentDigsite.stats.looted + 1
				currentDigsite.stats.fragments = currentDigsite.stats.fragments + diff

				currentDigsite:AddSurveyNode(playerLocation.UIMapID, playerLocation.x, playerLocation.y)
                local RaceID = private.RaceID
                if currentDigsite.raceID == RaceID.Unknown then
                    if MissingDigsites and MissingDigsites.Sites[currentDigsite.templateKey] then
                        MissingDigsites.Sites[currentDigsite.templateKey].raceID = raceID
                    end
                    if not private.DIGSITE_TEMPLATES[currentDigsite.templateKey] then
                        private.DIGSITE_TEMPLATES[currentDigsite.templateKey] = {}
                        private.DIGSITE_TEMPLATES[currentDigsite.templateKey].mapID = playerLocation.UIMapID
                    end
                    private.DIGSITE_TEMPLATES[currentDigsite.templateKey].raceID = raceID
                end
			end

			surveyLocation.UIMapID = 0
			surveyLocation.x = 0
			surveyLocation.y = 0

			UpdateMinimapIcons()
			self:RefreshDigSiteDisplay()  
		end
	end

	ArtifactFrame:RefreshDisplay()
end

function Archy:GET_ITEM_INFO_RECEIVED(event)
	for race, keystoneItemID in next, private.RaceKeystoneProcessingQueue, nil do
		local keystoneName, _, _, _, _, _, _, _, _, keystoneTexture, _ = _G.GetItemInfo(keystoneItemID)
		if keystoneName and keystoneTexture then
			race.keystone.name = keystoneName
			race.keystone.texture = keystoneTexture
			private.RaceKeystoneProcessingQueue[race] = nil
		end
	end

	for template, race in next, private.RaceArtifactProcessingQueue, nil do
		if race:AddOrUpdateArtifactFromTemplate(template) then
			private.RaceArtifactProcessingQueue[template] = nil
		end
	end

	if not next(private.RaceKeystoneProcessingQueue) and not next(private.RaceArtifactProcessingQueue) then
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	end
end

do
	local QUEST_ITEM_IDS = {
		[79049] = true, -- Serpentrider Relic
		[97986] = true, -- Digmaster's Earthblade
		[114212] = true, -- Pristine Rylak Riding Harness
	}

	function Archy:LOOT_OPENED(event, ...)
		local auto_loot_enabled = ...

		if not private.ProfileSettings.general.autoLoot or auto_loot_enabled == 1 then
			return
		end

		for slotID = 1, _G.GetNumLootItems() do
			local slotType = _G.GetLootSlotType(slotID)

			if slotType == _G.LOOT_SLOT_CURRENCY then
				_G.LootSlot(slotID)
			elseif slotType == _G.LOOT_SLOT_ITEM then
				local itemLink = _G.GetLootSlotLink(slotID)

				if itemLink then
					local itemID = GetItemIDFromLink(itemLink)

					if itemID and (private.KeystoneIDToRace[itemID] or QUEST_ITEM_IDS[itemID]) then
						_G.LootSlot(slotID)
					end
				end
			end
		end
	end
end -- do-block

function Archy:PET_BATTLE_CLOSE()
	if private.pet_battle_shown then
		private.pet_battle_shown = nil
		private.ProfileSettings.general.show = true

		-- API doesn't return correct values in this event
		if _G.C_PetBattles and _G.C_PetBattles.IsInBattle() then
			-- so let's schedule our re-show in a sec
			self:ScheduleTimer("ConfigUpdated", 1.5)
		else
			self:ConfigUpdated()
		end
	end
end

function Archy:PET_BATTLE_OPENING_START()
	if not private.ProfileSettings.general.show or private.ProfileSettings.general.stealthMode then
		return
	end

	-- store our visible state to restore after pet battle
	private.pet_battle_shown = true
	private.ProfileSettings.general.show = false
	self:ConfigUpdated()
end

function Archy:PLAYER_CONTROL_GAINED()
	if PositionUpdateTimerHandle then
		self:UpdatePlayerPosition()
		PositionUpdateTimerHandle = self:CancelTimer(PositionUpdateTimerHandle)
	end
end

function Archy:PLAYER_CONTROL_LOST()
	if private.isTaxiMapOpen then
		self:UpdatePlayerPosition()
		PositionUpdateTimerHandle = self:ScheduleRepeatingTimer("UpdatePlayerPosition", 0.1)
	end
end

function Archy:PLAYER_ENTERING_WORLD()
	private.notInWorld = nil

	-- If TomTom is configured to automatically set a waypoint to the closest quest objective, that will interfere with Archy. Warn, if applicable.
	TomTomHandler:CheckForConflict()

	if _G.IsInInstance() then
		HideFrames()
	else
		ShowFrames()
		self:UpdatePlayerPosition()
        self:UpdateSiteDistances(true)
	end
    
    self:DebugMissingDigsites()
end

function Archy:PLAYER_LEAVING_WORLD()
	-- Archaeology functions misbehave when called between now and the next PLAYER_ENTERING_WORLD, so we need to keep track of when it's safe to do so.
	private.notInWorld = true
end

function Archy:PLAYER_REGEN_DISABLED()
	private.in_combat = true

	if self.LDB_Tooltip and self.LDB_Tooltip:IsShown() then
		self.LDB_Tooltip:Hide()
	end

	if private.ProfileSettings.general.combathide then
		HideFrames()
	end
end

function Archy:PLAYER_REGEN_ENABLED()
	private.in_combat = nil

	if private.regen_toggle_distance then
		private.regen_toggle_distance = nil
		DistanceIndicatorFrame:Toggle()
	end

	if private.regen_update_tracking then
		private.regen_update_tracking = nil
		self:UpdateTracking()
	end

	if private.regen_clear_override then
		_G.ClearOverrideBindings(EasySurveyButton)
		private.override_binding_on = nil
		private.regen_clear_override = nil
	end

	if private.regen_update_digsites then
		private.regen_update_digsites = nil
		DigSiteFrame:UpdateChrome()
	end

	if private.regen_update_races then
		private.regen_update_races = nil
		ArtifactFrame:UpdateChrome()
	end

	if private.regen_scan_bags then
		private.regen_scan_bags = nil
		self:ScanBags()
	end

	if private.ProfileSettings.general.combathide then
		ShowFrames()
	end
end

function Archy:PLAYER_STARTED_MOVING()
	if not _G.IsInInstance() then
		self:UpdatePlayerPosition()
		PositionUpdateTimerHandle = self:ScheduleRepeatingTimer("UpdatePlayerPosition", 0.1)
	end
end

function Archy:PLAYER_STOPPED_MOVING()
	if PositionUpdateTimerHandle then
		self:UpdatePlayerPosition()
		PositionUpdateTimerHandle = self:CancelTimer(PositionUpdateTimerHandle)
	end
end

-- Delay loading Blizzard_ArchaeologyUI until QUEST_LOG_UPDATE so races main page doesn't bug.
function Archy:QUEST_LOG_UPDATE()
	-- Hook and overwrite the default SolveArtifact function to provide confirmations when nearing cap
	if not Blizzard_SolveArtifact then
		if not _G.IsAddOnLoaded("Blizzard_ArchaeologyUI") then
			local loaded, reason = _G.LoadAddOn("Blizzard_ArchaeologyUI")
			if not loaded then
				self:Print(L["ArchaeologyUI not loaded: %s SolveArtifact hook not installed."]:format(_G["ADDON_" .. reason]))
				return
			end
		end

		Blizzard_SolveArtifact = _G.SolveArtifact

		function _G.SolveArtifact(raceID, useKeystones)
			local rank, maxRank = GetArchaeologyRank()
			local race = private.Races[raceID]

			if private.ProfileSettings.general.confirmSolve and maxRank < MAX_ARCHAEOLOGY_RANK and (rank + 25) >= maxRank then
				Dialog:Spawn("ArchyConfirmSolve", {
					race = race,
					useKeystones = useKeystones,
					rank = rank,
					maxRank = maxRank
				})
			else
				return SolveRaceArtifact(race, useKeystones)
			end
		end
	end

	self:ConfigUpdated()
	self:UnregisterEvent("QUEST_LOG_UPDATE")
	self.QUEST_LOG_UPDATE = nil
end

function Archy:SKILL_LINES_CHANGED()
	local _, _, archaeologyIndex = _G.GetProfessions()
	private.hasArchaeology = archaeologyIndex and true or false

	self:UpdateSkillBar()
end

function Archy:TAXIMAP_CLOSED()
	private.isTaxiMapOpen = nil
end

function Archy:TAXIMAP_OPENED()
	private.isTaxiMapOpen = true
end

function Archy:UNIT_SPELLCAST_SENT(event, unit, spell, rank, target)
	if unit == "player" and spell == private.CRATE_SPELL_NAME then
		private.busy_crating = true
	end
end

do
	local function SetLoreItemCooldown(time)
		_G.CooldownFrame_Set(DistanceIndicatorFrame.loritemButton.cooldown, _G.GetItemCooldown(LorewalkersMap.itemID))
	end

	function Archy:UNIT_SPELLCAST_SUCCEEDED(event, unit, spell, rank, line_id, spellID)
		if unit ~= "player" then
			return
		end

		if spellID == LorewalkersMap.spellID and event == "UNIT_SPELLCAST_SUCCEEDED" then
			if DistanceIndicatorFrame.loritemButton:IsShown() then
				self:ScheduleTimer(SetLoreItemCooldown, 0.2)
			end
		elseif spellID == private.CRATE_SPELL_ID then
			if private.busy_crating then
				private.busy_crating = nil
				self:ScheduleTimer("ScanBags", 1)
			end
		end
	end
end -- do-block
