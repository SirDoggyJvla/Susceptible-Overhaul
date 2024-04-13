require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'


-- add Nuclear Biochemical Mask to loot spawn
-- containers
table.insert(ProceduralDistributions.list["ArmyStorageOutfit"].items, "Hat_NBCmask");
table.insert(ProceduralDistributions.list["ArmyStorageOutfit"].items, 4);

table.insert(ProceduralDistributions.list["ArmySurplusHeadwear"].items, "Hat_NBCmask");
table.insert(ProceduralDistributions.list["ArmySurplusHeadwear"].items, 4);

table.insert(ProceduralDistributions.list["FireStorageOutfit"].items, "Hat_NBCmask");
table.insert(ProceduralDistributions.list["FireStorageOutfit"].items, 0.1);

table.insert(ProceduralDistributions.list["LockerArmyBedroom"].items, "Hat_NBCmask");
table.insert(ProceduralDistributions.list["LockerArmyBedroom"].items, 4);

-- backpacks
table.insert(SuburbsDistributions.Bag_ALICEpack_Army.items, "Hat_NBCmask")
table.insert(SuburbsDistributions.Bag_ALICEpack_Army.items, 0.5)

table.insert(SuburbsDistributions.Bag_Military.items, "Hat_NBCmask")
table.insert(SuburbsDistributions.Bag_Military.items, 0.5)

-- vehicles
table.insert(VehicleDistributions.FireTruckBed.items, "Hat_NBCmask");
table.insert(VehicleDistributions.FireTruckBed.items, 0.1);