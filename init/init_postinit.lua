--Update this list when adding files
local component_post = {
	"combat",
	"health",
}

local prefab_post = {
	"staffs", --generic staffs.
	"stalker",
}

local class_post = {
	--example:
	"widgets/bloodover"
}

for _, v in pairs(component_post) do
	modimport("postinit/components/" .. v)
end

for _, v in pairs(prefab_post) do
	modimport("postinit/prefabs/" .. v)
end

for _, v in pairs(class_post) do
	--These contain a path already, e.g. v= "widgets/inventorybar"
	modimport("postinit/" .. v)
end
