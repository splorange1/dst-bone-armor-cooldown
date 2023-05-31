local UIAnim = require "widgets/uianim"

local hasSound = GetModConfigData("hasSound")
local cooldownColor = GetModConfigData("cooldownColor")

local function PlaySoundOnRecharge(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
end

local GetTime = GLOBAL.GetTime

local function CreateRechargeTimer(inst)
	inst.rechargetimestart = GetTime()
	inst.rechargetimeend = GetTime()+1
	function inst:GetRechargeTime()
		return self.rechargetimeend - self.rechargetimestart
	end
	function inst:GetRechargePercent()
		return (inst.rechargetimeend-GetTime())/self:GetRechargeTime()
	end
	function inst:IsRechargeDone()
		return GetTime() > inst.rechargetimeend
	end
	function inst:StartRecharge(timer)
		if not inst:IsRechargeDone() then return end
		inst.rechargetimestart = GetTime()
		inst.rechargetimeend = GetTime()+timer
		inst:PushEvent("bonearmor_rechargechange", {percent=0})
		inst:PushEvent("bonearmor_rechargetimechange", {t=timer})
	end
end

AddPrefabPostInit("armorskeleton",function(self)
    self.trackpercent = 100
	CreateRechargeTimer(self)
end)

AddClassPostConstruct("widgets/itemtile",function(self,invitem) -- copying recharge code over because client side tags dont work
    if self.item.prefab == "armorskeleton" then
        self.rechargepct = 1
        self.rechargetime = TUNING.ARMOR_SKELETON_COOLDOWN
        self.rechargeframe = self:AddChild(UIAnim())
        self.rechargeframe:GetAnimState():SetBank("recharge_meter")
        self.rechargeframe:GetAnimState():SetBuild("recharge_meter")
        self.rechargeframe:GetAnimState():PlayAnimation("frame")
        self.rechargeframe:GetAnimState():AnimateWhilePaused(false)
		self.rechargeframe:GetAnimState():SetMultColour(0, 0, cooldownColor, 0.64)

	if self.rechargeframe ~= nil then
        self.recharge = self:AddChild(UIAnim())
        self.recharge:GetAnimState():SetBank("recharge_meter")
        self.recharge:GetAnimState():SetBuild("recharge_meter")
        self.recharge:GetAnimState():SetMultColour(0, 0, cooldownColor, 0.64) 
        self.recharge:GetAnimState():AnimateWhilePaused(false)
        self.recharge:SetClickable(false)
    end

	self:SetChargePercent(1-self.item:GetRechargePercent())
	self:SetChargeTime(self.item:GetRechargeTime())

    if self.rechargeframe ~= nil then
        self.inst:ListenForEvent("bonearmor_rechargechange",
            function(invitem, data)
                self:SetChargePercent(data.percent)
            end, invitem)

        self.inst:ListenForEvent("bonearmor_rechargetimechange",
            function(invitem, data)
                self:SetChargeTime(data.t)
            end, invitem)
    end
    end
end)

local function ApplyCooldown(inst)
    local item = inst.entity:GetParent()
    item.trackpercent = item.replica.inventoryitem.classified.percentused:value()
    if item and item.prefab == "armorskeleton" then
        inst:ListenForEvent("percentuseddirty", function(inst) 
            if item.trackpercent > item.replica.inventoryitem.classified.percentused:value() then
                if hasSound then
                    inst:DoTaskInTime(TUNING.ARMOR_SKELETON_COOLDOWN, function() PlaySoundOnRecharge(item) end)
                end
                item:StartRecharge(TUNING.ARMOR_SKELETON_COOLDOWN)
            end
            item.trackpercent = item.replica.inventoryitem.classified.percentused:value()
        end)
    end
end

local itemEquipped = nil

local function ApplySmallCooldown(inst)
    inst:DoTaskInTime(0, function()
        local body_item = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
        if body_item ~= nil and body_item.prefab == "armorskeleton" and itemEquipped ~= body_item then
			body_item:StartRecharge(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN)
        end
        itemEquipped = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
    end)
end

AddPlayerPostInit(function(inst)
    inst:ListenForEvent("equip", ApplySmallCooldown)
    inst:ListenForEvent("unequip", function() itemEquipped = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY) end)
    inst:DoTaskInTime(0, function()
        itemEquipped = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
    end)
end)

AddPrefabPostInit("inventoryitem_classified", function(inst)
    inst:DoTaskInTime(0, function() ApplyCooldown(inst) end)
end)

