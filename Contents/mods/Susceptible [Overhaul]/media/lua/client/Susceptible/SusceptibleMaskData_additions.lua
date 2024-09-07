--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the addition of new compatible mods to masks and shit.

]]--
--[[ ================================================ ]]--

-- load SusceptibleMaskItems first
require "Susceptible/SusceptibleMaskData"

-- yea had to fix his shit manually
if getActivatedMods():contains("Susceptible") then
	require "SusceptibleNewHorizon"
	SusceptibleMaskItems["NH_Hazmat_Hood"] = nil
end

-- define protection types
local CLOTH = "Cloth";
local FILTER = "Filter";
local WASH = "Wash";
local OXYGEN = "Oxygen";


-- quality defaults to infinite
-- repairType defaults to CLOTH

-- Function to merge two dictionaries
local function mergeTables(dest, src)
    for key, value in pairs(src) do
        dest[key] = value
    end
end

-- new added data
local mask_data = {
--- Hazmat Suits ---
	-- Brita's Antibelok Hazmats
	Antibelok =											{ durability=600, 		repairType=OXYGEN 	},
	Antibelok_ON =										{ durability=600, 		repairType=OXYGEN 	},
	Chempak_Level =										{ durability=600, 		repairType=OXYGEN 	},

--- Gas masks ---
	-- vanilla Nuclear Biochemical Mask
	Hat_NBCmask =										{ durability=400, 		repairType=FILTER 	},
	-- KATTAJ1 Military Pack
	["Military_MaskHelmet_GasMask-M80"]  =				{ durability=400, 		repairType=FILTER 	},
	-- zRe Armor Pack
	zRe_Respirator =									{ durability=400, 		repairType=FILTER 	},
	zRe_Tractor_Hat_GasMask =							{ durability=400, 		repairType=FILTER 	},
	-- zRe Vaccine 2.0 ReMod
	zReV2_1ECO_fullhelmet1 =							{ durability=400, 		repairType=FILTER 	},
	zReV2_1ECO_fullhelmet2 =							{ durability=400, 		repairType=FILTER 	},
	zReV2_1ECO_fullhelmet1A =							{ durability=400, 		repairType=FILTER 	},
	zReV2_1ECO_fullhelmet2A =							{ durability=400, 		repairType=FILTER 	},
	-- New Horizon Uniforms
	NH_Hazmat_Hood =									{ durability=400, 		repairType=FILTER 	},
	-- Post-Soviet Clothing
	Mask_GP5 =											{ durability=400, 		repairType=FILTER 	},
	Mask_GP5M =											{ durability=400, 		repairType=FILTER 	},
	Mask_GP7 =											{ durability=400, 		repairType=FILTER 	},
	Mask_PMK =											{ durability=400, 		repairType=FILTER 	},
	-- zRe Apo Modern Armor
	zRe_Apo_HelmetClose_Black =							{ durability=400, 		repairType=FILTER 	},
	zRe_Apo_HelmetClose_Green =							{ durability=400, 		repairType=FILTER 	},
	zRe_Apo_HelmetClose_Desert =						{ durability=400, 		repairType=FILTER 	},
	zRe_Apo_HelmetClose_White =							{ durability=400, 		repairType=FILTER 	},
	-- OCP Gear
	["OCP-GasMask"] =									{ durability=400, 		repairType=FILTER 	},
	-- zRe SWAT ARMOR ny kERHUS
	zReSWAT_Hat_GasMask =								{ durability=400, 		repairType=FILTER 	},
	zReSWAT_Hat_GasMask_NoBelts =						{ durability=400, 		repairType=FILTER 	},
	-- darlak's The Jin_Roh
	Jin_Roh_Mask =										{ durability=400, 		repairType=FILTER 	},
	-- [J&G] Forest Multicam Uniform
	["Forest_Camo_GasMask-M80"] =						{ durability=400, 		repairType=FILTER 	},
	-- [J&G] Black Multicam Uniform
	["Black_Camo_GasMask-M80"] =						{ durability=400, 		repairType=FILTER 	},
	-- [J&G] Alpine Uniform
	["Alpine_Camo_GasMask-M80"] =						{ durability=400, 		repairType=FILTER 	},
	-- [J&G] Desert Uniform
	["Desert_Camo_GasMask-M80"] =						{ durability=400, 		repairType=FILTER 	},
	-- Manhunt Clothing Pack
	Cerber_Helmet1 =									{ durability=400, 		repairType=FILTER 	},
	Cerber_Led_Helmet =									{ durability=400, 		repairType=FILTER 	},

--- Enclosed Military Helmets
	-- KATTAJ1 Military Pack
	["Military_FullHelmet_Vanguard-Black"] =			{ durability=350, 		repairType=CLOTH 	},
	["Military_FullHelmet_Vanguard-Desert"] =			{ durability=350, 		repairType=CLOTH 	},
	["Military_FullHelmet_Vanguard-Green"] =			{ durability=350, 		repairType=CLOTH 	},
	["Military_FullHelmet_Vanguard-White"] =			{ durability=350, 		repairType=CLOTH 	},
	-- CRM armor pack
	CRM_Helmet =										{ durability=350, 		repairType=CLOTH 	},
	CRM_Helmet2 =										{ durability=350, 		repairType=CLOTH 	},
	-- Militek Faction Clothing
	["Military_FullHelmet_Vanguard-Militek"] =			{ durability=350, 		repairType=CLOTH 	},
	["Military_FullHelmet_Vanguard-MilitekOfficer"] =	{ durability=350, 		repairType=CLOTH 	},

--- Unique Mod masks ---
	-- Buffing Undead Survivor Gas Masks.
	-- Previously 250 durability (why the fuck would they even consider those to be so bad even tho they are clean asf gasmaks???)
	NomadMask =											{ durability=26, 		repairType=WASH 	}, -- changed to wash
	OminousNomadMask =									{ durability=26, 		repairType=WASH 	}, -- changed to wash
	PrepperMask =										{ durability=400, 		repairType=FILTER 	},
	StalkerMask =										{ durability=400, 		repairType=FILTER 	},
	HeadhunterGasmask  =								{ durability=400, 		repairType=FILTER 	},
	DeadlyHeadhunterGasmask =							{ durability=400, 		repairType=FILTER 	},
	-- Buffing rebreather from Scrap Armor to 400 durability
	Hat_Rebreather =									{ durability=400,		repairType=FILTER	},
	-- I haven't searched which mods add those, but they are marked as respirators
	-- so I bet they deserve 400 durability like other gasmasks and respirators
	Hat_HalfMaskRespirator_Black =						{ durability=400,		repairType=FILTER	},
	Hat_HalfMaskRespirator_White =						{ durability=400,		repairType=FILTER	},
	Hat_HalfMaskRespiratorII_Black =					{ durability=400,		repairType=FILTER	},
	Hat_HalfMaskRespiratorII_White =					{ durability=400,		repairType=FILTER	},
	chiGasMask =										{ durability=400,		repairType=FILTER	},

--- Surgical, dust and face masks ---
	-- Post-Soviet Clothing
	Hat_FaceMask =										{ durability=120, 		repairType=WASH 	},

--- Basic face covering helmets/headgear --- 
	-- zRe Armor Pack
	zRe_Hat_Altyn_Black =								{ durability=90 							},
	zRe_Hat_Altyn_Green =								{ durability=90 							},
	zRe_Hat_Altyn_Olive =								{ durability=90 							},
	-- Post-Soviet Clothing
	Hat_Altyn =											{ durability=90 							},
	Hat_Vityaz =										{ durability=90 							},
	-- Ballistic Mask Pack
	DM_Smile_Yellow  =									{ durability=90 							},
	DM_Smile_Green  =									{ durability=90 							},
	DM_Smile_Orange  =									{ durability=90 							},
	DM_Camo_Grey  =										{ durability=90 							},
	DM_Camo_Black  =									{ durability=90 							},
	DM_Deserted  =										{ durability=90 							},
	DM_Killer  =										{ durability=90 							},
	DM_Hearted  =										{ durability=90 							},
	DM_Flames  =										{ durability=90 							},
	DM_Panda  =											{ durability=90 							},
	DM_Panda_Cross  =									{ durability=90 							},
	-- Cerberus Pack
	MaskFull_BallisticMask_Cerberus  =					{ durability=90 							},
	MaskFull_BallisticMask_Cerberus_NoBelts  =			{ durability=90 							},
	-- Lynx Pack
	Helmet_BallisticFaceShield_Lynx_DOWN  =				{ durability=90 							},
	["Helmet_RysT_Lynx_DOWN-Black"]  =					{ durability=90 							},
	["Helmet_RysT_Lynx_DOWN-Green"]  =					{ durability=90 							},
	-- Gangs+
	AC_AcidMask01  =									{ durability=90 							},
	AC_SkullMask01  =									{ durability=90 							},
	AC_SkullMask02  =									{ durability=90 							},
	Hat_HockeyMask  =									{ durability=90 							},
	HelmetPsycho =										{ durability=90 							},
	Hat_CrashHelmetFULL =								{ durability=90 							},
	-- Manhunt Clothing Pack
	Bunny_Mask  =										{ durability=90 							},
	Innocent_Mask  =									{ durability=90 							},
	Innocent_Mask2  =									{ durability=90 							},
	Monkey_Mask  =										{ durability=90 							},
	Piggsy_Mask  =										{ durability=90 							},
	Skin_Mask01  =										{ durability=90 							},
	Skin_Mask02  =										{ durability=90 							},
	Smiley_Mask  =										{ durability=90 							},
	Smiley_Mask2  =										{ durability=90 							},
	SWAT_Helmet =										{ durability=90 							},

--- Bandanas & cloth masks ---
	-- KATTAJ1 Military Pack
	["Military_Mask_Balaclava1-Black"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_Balaclava1-Desert"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_Balaclava1-Green"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_Balaclava1-White"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_Balaclava2-Black"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_Balaclava2-Desert"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_Balaclava2-Green"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_Balaclava2-White"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_BandanaMask-Black"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_BandanaMask-Desert"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_BandanaMask-Green"] =				{ durability=26, 		repairType=WASH 	},
	["Military_Mask_BandanaMask-White"] =				{ durability=26, 		repairType=WASH 	},
	-- zRe Armor Pack
	zRe_Hat_BalaclavaFace =								{ durability=26, 		repairType=WASH 	},
	-- New Horizon Uniforms
	NH_Mask =											{ durability=26, 		repairType=WASH 	},
	NH_Balaclava =										{ durability=26, 		repairType=WASH 	},
	Balaclava_OneHole =									{ durability=26, 		repairType=WASH 	},
	-- zRe SWAT ARMOR by kERHUS
	zReSWAT_BalaclavaFace =								{ durability=26, 		repairType=WASH 	},
	-- Cerberus Pack
	Mask_Balaclava_Cerberus =							{ durability=26, 		repairType=WASH 	},
	Mask_BandanaMask_Cerberus =							{ durability=26, 		repairType=WASH 	},
	Helmet_Mandible_Cerberus =							{ durability=26, 		repairType=WASH 	},
	-- Lynx Pack
	Mask_Balaclava_Lynx =								{ durability=26, 		repairType=WASH 	},
	Mask_BandanaMask_Lynx =								{ durability=26, 		repairType=WASH 	},
	-- [J&G] Forest Multicam Uniform
	Forest_Camo_Balaclava =								{ durability=26, 		repairType=WASH 	},
	-- [J&G] Black Multicam Uniform
	Black_Camo_Balaclava =								{ durability=26, 		repairType=WASH 	},
	-- [J&G] Alpine Uniform
	Alpine_Camo_Balaclava =								{ durability=26, 		repairType=WASH 	},
	-- [J&G] Desert Uniform
	Desert_Camo_Balaclava =								{ durability=26, 		repairType=WASH 	},
	-- Gangs+
	Hat_SkullBalaclavaFull =							{ durability=26, 		repairType=WASH 	},
	Hat_TacticalBalaclavaFull =							{ durability=26, 		repairType=WASH 	},
	-- Manhunt Clothing Pack
	Hoods_Balaclava =									{ durability=26, 		repairType=WASH 	},
	Hoods_Hat =											{ durability=26, 		repairType=WASH 	},
	Wardogs_Balaclava =									{ durability=26, 		repairType=WASH 	},
	Wardogs_Bandana =									{ durability=26, 		repairType=WASH 	},
}

mergeTables(SusceptibleMaskItems,mask_data)