local assets=
{
    Asset("ANIM", "anim/plaguemask.zip"),
	Asset("ATLAS", "images/inventoryimages/plaguemask.xml"),
	Asset("IMAGE", "images/inventoryimages/plaguemask.tex"),
}

local function onequip(inst, owner)
	if inst.skinname ~= nil then
		owner.AnimState:OverrideSymbol("swap_hat", "hat_plaguemask_formal", "swap_hat")	
	else
		owner.AnimState:OverrideSymbol("swap_hat", "hat_plaguemask", "swap_hat")	
	end
	
	owner.AnimState:Show("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	owner.AnimState:Show("HAIRFRONT")
	owner:AddTag("goggles")
	
	if not owner:HasTag("scp049") then
		owner:AddTag("has_gasmask")
		owner:AddTag("hasplaguemask")
	end
	
	inst.components.fueled:StartConsuming()
end
 
local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
	owner.AnimState:ClearOverrideSymbol("face")
    owner.AnimState:Hide("HAT")
	
	owner:RemoveTag("goggles")
	
	if not owner:HasTag("scp049") then
		owner:RemoveTag("has_gasmask")
		owner:RemoveTag("hasplaguemask")
	end
	
	inst.components.fueled:StopConsuming()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("gasmaskhat")
    inst.AnimState:SetBuild("hat_plaguemask")
    inst.AnimState:PlayAnimation("anim")  

	inst:AddTag("hats")
	inst:AddTag("has_gasmask")
	inst:AddTag("hasplaguemask")
    inst:AddTag("goggles")
	
	inst.Transform:SetScale(1.25, 1.25, 1.25)
		
    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/plaguemask.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	--inst.components.equippable.dapperness = TUNING.CRAZINESS_SMALL

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.UMBRELLA_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	inst.opentop = true
     
	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
	
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
	MakeHauntableLaunch(inst)
    return inst
end

local function plaguemask_skin()
	local inst = fn()
	
    inst.AnimState:SetBank("hat_plaguemask_formal")
    inst.AnimState:SetBuild("hat_plaguemask_formal")
	
	inst.skinname = "hat_plaguemask_formal"
	
	inst.Transform:SetScale(1.15, 1.15, 1.15)
	
	if inst.components.inventoryitem ~= nil then
		inst.components.inventoryitem.atlasname = "images/inventoryimages/plaguemask_formal.xml"
	end

	return inst
end

return Prefab("plaguemask", fn, assets),
	CreateModPrefabSkin("plaguemask_formal",
	{
		assets = {
			Asset("ANIM", "anim/hat_plaguemask_formal.zip"),
		},
		base_prefab = "plaguemask",
		fn = plaguemask_skin, -- This is our constructor!
		rarity = "Timeless",
		reskinable = true,
		
		build_name_override = "hat_plaguemask_formal",
		
		type = "item",
		skin_tags = { },
		release_group = 0,
	})