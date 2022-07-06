local assets =
{
    Asset("ANIM", "anim/slingshot.zip"),
    Asset("ANIM", "anim/swap_slingshot.zip"),
}

local prefabs =
{
	"slingshotammo_rock_proj",
}

local PROJECTILE_DELAY = 2 * FRAMES

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_um_beegun", "swap_blunderbuss")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function OnProjectileLaunched(inst, attacker, target)
	if inst.components.container ~= nil then
	
		for i = 1, 2 do
			inst:DoTaskInTime((i / 8) - 0.1, function(inst)
				local ammo_stack = inst.components.container:GetItemInSlot(1)
				local item = inst.components.container:RemoveItem(ammo_stack, false)
				if item ~= nil then
					local beedart = SpawnPrefab(item.prefab.."_proj")
					beedart.Transform:SetPosition(inst.Transform:GetWorldPosition())
					beedart.components.projectile:Throw(inst, target, attacker)

					item:Remove()
				end
			end)
		end
	
		local ammo_stack = inst.components.container:GetItemInSlot(1)
		local item = inst.components.container:RemoveItem(ammo_stack, false)
		if item ~= nil then

			item:Remove()
		end
	end
end

local function OnAmmoLoaded(inst, data)
	if inst.components.weapon ~= nil then
		if data ~= nil and data.item ~= nil then
			inst.components.weapon:SetProjectile(data.item.prefab.."_proj")
		end
	end
end

local function OnAmmoUnloaded(inst, data)
	if inst.components.weapon ~= nil then
		inst.components.weapon:SetProjectile(nil)
	end
end

local floater_swap_data = {sym_build = "swap_um_beegun"}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("um_beegun")
    inst.AnimState:SetBuild("um_beegun")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("rangedweapon")
    inst:AddTag("beegun")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --inst.projectiledelay = PROJECTILE_DELAY

    MakeInventoryFloatable(inst, "med", 0.075, {0.5, 0.4, 0.5}, true, -7, floater_swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst.OnEntityReplicated = function(inst) 
			inst.replica.container:WidgetSetup("um_beegun") 
		end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/um_beegun.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(15)
    inst.components.weapon:SetRange(TUNING.SLINGSHOT_DISTANCE, TUNING.SLINGSHOT_DISTANCE_MAX)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)
	inst.components.weapon:SetProjectileOffset(1)
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("um_beegun")
	inst.components.container.canbeopened = false
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil and target.components.combat then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if attacker ~= nil and attacker:IsValid() then
            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
    end
	
    inst:Remove()
end

local function onthrown(inst, data)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function common(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("um_beegun_dart")
    inst.AnimState:SetBuild("um_beegun_dart")
    inst.AnimState:PlayAnimation("beedart_yellow")

    --inst:AddTag("blowdart")
    inst:AddTag("sharp")

    --inst:AddTag("weapon")

    inst:AddTag("projectile")

	RemovePhysicsColliders(inst)

    --MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.5, 0.75})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(15)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)
    inst.components.projectile:SetLaunchOffset(Vector3(1, 2, 0))
    -------

    --inst:AddComponent("inspectable")

    --inst:AddComponent("inventoryitem")

    return inst
end

local function yellow()
    local inst = common("beedart_yellow")

    return inst
end
	
local function red()
    local inst = common("beedart_red")

    return inst
end
	
return Prefab("um_beegun", fn, assets, prefabs),
		Prefab("bee_proj", yellow, assets, prefabs),
		Prefab("killerbee_proj", red, assets, prefabs)