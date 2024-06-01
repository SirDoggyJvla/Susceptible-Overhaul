
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

local NONE = "None"; --wtf is even the point of that one lol
local CLOTH = "Cloth";
local FILTER = "Filter";
local WASH = "Wash";
local OXYGEN = "Oxygen";

-- Function to merge two dictionaries
local function mergeTables(dest, src)
    for key, value in pairs(src) do
        dest[key] = value
    end
end

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

--- Enclosed Military Helmets ---  
	-- KATTAJ1 Military Pack
	["Military_FullHelmet_Vanguard-Black"] =			{ durability=350, 		repairType=CLOTH 	},
	["Military_FullHelmet_Vanguard-Desert"] =			{ durability=350, 		repairType=CLOTH 	},
	["Military_FullHelmet_Vanguard-Green"] =			{ durability=350, 		repairType=CLOTH 	},
	["Military_FullHelmet_Vanguard-White"] =			{ durability=350, 		repairType=CLOTH 	},
	-- CRM armor pack
	CRM_Helmet =										{ durability=350, 		repairType=CLOTH 	},
	CRM_Helmet2 =										{ durability=350, 		repairType=CLOTH 	},

--- Unique Mod masks ---
	-- Buffing Undead Survivor Gas Masks.
	-- Previously 250 durability (why the fuck would they even consider those to be so bad even tho they are clean asf gasmaks???)
	NomadMask =											{ durability=26, 		repairType=WASH 	}, -- changed to wash
	OminousNomadMask =									{ durability=26, 		repairType=WASH 	}, -- changed to wash
	PrepperMask =										{ durability=400, 		repairType=FILTER 	},
	StalkerMask =										{ durability=400, 		repairType=FILTER 	},
	HeadhunterGasmask  =								{ durability=400, 		repairType=FILTER 	},
	DeadlyHeadhunterGasmask =							{ durability=400, 		repairType=FILTER 	},

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
}

mergeTables(SusceptibleMaskItems,mask_data)