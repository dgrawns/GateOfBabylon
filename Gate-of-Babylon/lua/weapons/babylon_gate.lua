AddCSLuaFile()
AddCSLuaFile("addons/Gate_Of_Babylon/lua/entities/gold_weapon/init.lua")
SWEP.PrintName = "Gate of Babylon"
SWEP.Slot	   = 1
SWEP.SlotPos   = 1
SWEP.DrawCrosshair = true

SWEP.Base = "weapon_base"
SWEP.AutoSwitchTo = true
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = true
SWEP.Author = "dgrawns"	
SWEP.Contact = ""
SWEP.Purpose = "Show everyone who's king."
SWEP.Category = "Gilgamesh's Weapons"


SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.ViewModelDraw = false
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 65
SWEP.BobScale = 0.5
SWEP.SwayScale = 0.7
SWEP.UseHands = true
SWEP.WorldModel = ""
SWEP.HoldType = "normal"
SWEP.Instructions = "Press Left click for rapid fire, Press Right click for single fire, press R for Enkidu."

SWEP.Primary.FireSound = Sound("")
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 2
SWEP.Primary.Damage = 16
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 0.02
SWEP.Primary.Delay = 0.13
SWEP.Primary.Ammo = ""
SWEP.Primary.Force = 5
SWEP.FiresUnderwater = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


function SWEP:Initialize()
	Enkidu_Exists = false
	self:SetHoldType(self.HoldType)
	if CLIENT then
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)

		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)

				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))
					vm:SetMaterial("Debug/hsv")			
				end

			end
		end
	end
end

function SWEP:PrimaryAttack()
	Weapon_Table = {"models/weapons/w_crowbar.mdl", "models/props_junk/harpoon002a.mdl", "models/props_junk/sawblade001a.mdl"}
	-------------------------------------------------
	if ( !self:CanPrimaryAttack() ) then return end
	-------------------------------------------------
	self:SetNextPrimaryFire(CurTime() + 0.2)
	self:ShootEffects(self)
	-------------------------------------------------
	if !SERVER then return end
	-------------------------------------------------
	local eyes = self.Owner:GetAimVector()
	ent_p = ents.Create("gold_weapon")
	-------------------------------------------------
	if IsValid(ent_p) then
		-------------------------------------------------
		ent_p:SetModel(table.Random(Weapon_Table))
		ent_p:SetMaterial("models/player/shared/gold_player")
		util.SpriteTrail(ent_p, 0, Color(218, 165, 32), false, 2, 1, 1, 0.5, "trails/laser.vmt")
		ent_p:PhysicsInit(SOLID_VPHYSICS)
		ent_p:SetPos(self.Owner:GetPos() + Vector(math.random(-300, 300),math.random(-300, 300),math.random(80, 300)))
		ent_p:SetAngles(self.Owner:EyeAngles())
		ent_p:Spawn()
		ent_p:SetGravity(1)
		-------------------------------------------------
		timer.Create("GateEffect", 0.1, 7, function()
			Effects = {"GateOfBabylon", "GateToBabylon"}
			local ed = EffectData()
			ed:SetStart(ent_p:GetPos())
			ed:SetOrigin(ent_p:GetPos())
			ed:SetEntity(ent_p)
			ed:SetScale(1)
			util.Effect(table.Random(Effects), ed)
		end)
		-------------------------------------------------
		local phys = ent_p:GetPhysicsObject()
		if !IsValid(phys) then ent:Remove() return end
		phys:EnableMotion(false)
		-------------------------------------------------
		timer.Simple(1, function()
			phys:EnableMotion(true)
			local velocity = self.Owner:GetAimVector()
			velocity = velocity * 600000000 * 600000000
			push = self.Owner:GetEyeTrace().HitPos
			ent_p:EmitSound("weapons/cbar_miss1.wav", 75, 150, 1, CHAN_AUTO)
			phys:ApplyForceOffset(velocity, push)
			ent_p:SetOwner(self.Owner)
			ent_p:Input("SetTimer", self:GetOwner(), self:GetOwner(), 1.5)
		end)
		-------------------------------------------------
		function Collide(phys, data)	
		local hit_entity = data.HitEntity
		local phys_s = ent_p:GetPhysicsObject()
		if IsValid(phys_s) then
		data.PhysObject:EnableMotion(false)
		if hit_entity:GetClass() == "player" then
			
			ent_p:SetPos(hit_entity:GetPos() + Vector(0, 0, math.random(30, 60)))
			local dp = DamageInfo()
			dp:SetDamage(math.random(50, 100))
			dp:SetAttacker(self.Owner)
			dp:SetDamageType(1)
				
			hit_entity:TakeDamageInfo(dp)
		end
		for k,v in pairs(ents.FindByClass("npc_*")) do
			if hit_entity:GetClass() == "npc_helicopter" then
				ent_p:SetPos(hit_entity:GetPos() + Vector(0, 0, math.random(30, 60)))
				local d = DamageInfo()
				d:SetDamage(math.random(50, 100))
				d:SetAttacker(self.Owner)
				d:SetDamageType(33554432)
				
				hit_entity:TakeDamageInfo(d)
			end
			if hit_entity:GetClass() == v:GetClass() and hit_entity:GetClass() != "npc_helicopter" then
				ent_p:SetPos(hit_entity:GetPos() + Vector(0, 0, math.random(30, 60)))
				local d = DamageInfo()
				d:SetDamage(math.random(50, 100))
				d:SetAttacker(self.Owner)
				d:SetDamageType(128)
				
				hit_entity:TakeDamageInfo(d)
			end
		end
		timer.Create("Delete_Weapon_P", 5, 1, function()
			for k,v in pairs(ents.GetAll()) do
				if v:GetClass() == "gold_weapon" then
					v:Remove()
				end
			end
		end)
		end
		end
		ent_p:AddCallback("PhysicsCollide", Collide)
	end
end 

function SWEP:SecondaryAttack()
	Weapon_Table2 = {"models/weapons/w_crowbar.mdl","models/props_junk/harpoon002a.mdl", "models/props_junk/sawblade001a.mdl"}
	-------------------------------------------------
	self:SetNextSecondaryFire(CurTime() + 2)
	self:ShootEffects(self)
	-------------------------------------------------
	if !SERVER then return end
	-------------------------------------------------
	local eyes = self.Owner:GetAimVector()
	R = tostring(math.random(1, 1000))
	ent_s = ents.Create("gold_weapon")
	
	-------------------------------------------------
	if IsValid(ent_s) then
	-------------------------------------------------
		ent_s:SetModel(table.Random(Weapon_Table2))
		ent_s:SetMaterial("models/player/shared/gold_player")
		util.SpriteTrail(ent_s, 0, Color(218, 165, 32), false, 2, 1, 1, 0.5, "trails/laser.vmt")
		ent_s:PhysicsInit(SOLID_VPHYSICS)
		ent_s:SetPos(self.Owner:GetPos() + Vector(0, 0, 140))
		ent_s:SetAngles(self.Owner:EyeAngles())
		ent_s:Spawn()
		ent_s:SetGravity(0)
		-------------------------------------------------
		timer.Create("GateEffect", 0.1, 7, function()
			Effects2 = {"GateOfBabylon", "GateToBabylon"}
			local ed = EffectData()
			ed:SetStart(ent_s:GetPos())
			ed:SetOrigin(ent_s:GetPos())
			ed:SetEntity(ent_s)
			ed:SetScale(1)
			util.Effect(table.Random(Effects2), ed)
		end)
		-------------------------------------------------
		local phys = ent_s:GetPhysicsObject()
		if !IsValid(phys) then return end
		phys:EnableMotion(false)
		-------------------------------------------------
		timer.Simple(1, function()
			phys:EnableMotion(true)
			local velocity = self.Owner:GetAimVector()
			velocity = velocity * 600000000 * 600000000
			push = self.Owner:GetEyeTrace().HitPos
			ent_s:EmitSound("weapons/cbar_miss1.wav", 75, 150, 1, CHAN_AUTO)
			phys:ApplyForceOffset(velocity, push)
			ent_s:SetOwner(self.Owner)
			ent_s:Input("SetTimer", self:GetOwner(), self:GetOwner(), 1.5)
			-------------------------------------------------
		end)
		
		
	end
	-------------------------------------------------
	
	function Collide3(phys, data)
		if ent_s:IsValid() == false then ent_s:Remove() return end
		local hit_entity = data.HitEntity
		local phys_s = ent_s:GetPhysicsObject()
		phys_s:EnableMotion(false)
		if hit_entity:GetClass() == "player" then
			
			ent_s:SetPos(hit_entity:GetPos() + Vector(0, 0, math.random(30, 60)))
			local dp = DamageInfo()
			dp:SetDamage(math.random(50, 100))
			dp:SetAttacker(self.Owner)
			dp:SetDamageType(1)
				
			hit_entity:TakeDamageInfo(dp)
		end
		for k,v in pairs(ents.FindByClass("npc_*")) do
			
			if hit_entity:GetClass() == v:GetClass() and hit_entity:GetClass() != "npc_helicopter" then
				ent_s:SetPos(hit_entity:GetPos() + Vector(0, 0, math.random(30, 60)))
				local d = DamageInfo()
				d:SetDamage(math.random(50, 100))
				d:SetAttacker(self.Owner)
				d:SetDamageType(128)
				
				hit_entity:TakeDamageInfo(d)
			end
			
			if hit_entity:GetClass() == "npc_helicopter" then
				ent_p:SetPos(hit_entity:GetPos() + Vector(0, 0, math.random(30, 60)))
				local d = DamageInfo()
				d:SetDamage(math.random(50, 100))
				d:SetAttacker(self.Owner)
				d:SetDamageType(33554432)
				
				hit_entity:TakeDamageInfo(d)
			end
		end
		timer.Create("Delete_Weapon_S", 5, 1, function()
			for k,v in pairs(ents.GetAll()) do
				if v:GetClass() == "gold_weapon" then
					v:Remove()
				end
			end
		end)
	end
	ent_s:AddCallback("PhysicsCollide", Collide3)
	-------------------------------------------------
end

function SWEP:Think()
	if CLIENT then return end
	
	if self.Owner:KeyReleased(IN_RELOAD) then
		if Enkidu_Exists == false then
		ent1 = ents.Create("prop_physics")
		ent1_static = ents.Create("prop_physics")
		ent1:SetModel("models/props_junk/harpoon002a.mdl")
		ent1_static:SetModel("models/weapons/w_stunbaton.mdl")
		ent1:SetMaterial("models/player/shared/gold_player")
		ent1:PhysicsInit(SOLID_VPHYSICS)
		ent1_static:PhysicsInit(SOLID_NONE)
		ent1:SetPos(self.Owner:GetPos() + Vector(0, 0, 140))
		ent1_static:SetPos(self.Owner:GetPos() + Vector(0, 0, 140))
		ent1:SetAngles(self.Owner:EyeAngles())
		ent1:Spawn()
		ent1_static:Spawn()
		ent1:SetGravity(0)
		ent1_static:SetGravity(0)
		phys_static = ent1_static:GetPhysicsObject()
		phys_static:EnableMotion(false)
		if ent1:IsValid() then
			timer.Create("Effect_Timer", 0.1, 0, function()
			Effects2 = {"GateOfBabylon", "GateToBabylon"}
			local ed = EffectData()
			ed:SetStart(ent1_static:GetPos())
			ed:SetOrigin(ent1_static:GetPos())
			ed:SetEntity(ent1_static)
			ed:SetScale(1)
			util.Effect(table.Random(Effects2), ed)
			end)
		end
		local phys1 = ent1:GetPhysicsObject()
		if !IsValid(phys1) then ent1:Remove() return end
		
		local velocity = self.Owner:GetAimVector()
		velocity = velocity * 600000000
		push = self.Owner:GetEyeTrace().HitPos
		ent1:EmitSound("weapons/cbar_miss1.wav", 75, 100, 1, CHAN_AUTO)
		phys1:ApplyForceOffset(velocity, push)
		ent1:SetOwner(self.Owner)
		ent1:Input("SetTimer", self:GetOwner(), self:GetOwner(), 1.5)
		
	
	function Collide4(phys, data)
		timer.Simple(0, function()
		phys1:EnableMotion(false)
		Length = (ent1_static:GetPos() - ent1:GetPos()):Length()
		constraint.Rope(ent1, ent1_static, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), Length, 0, 0, 1, "cable/cable2", true)
		end)
		local entity_hit = data.HitEntity
		if entity_hit:GetClass() == "player" then
			entity_hit:Freeze(true)
			ent1:SetPos(entity_hit:GetPos() + Vector(0, 0, 50))
			player_name = entity_hit:Nick()
		end
		
		for k,v in pairs(ents.FindByClass("npc_*")) do
			if entity_hit:GetClass() == v:GetClass() then
				ent1:SetPos(entity_hit:GetPos() + Vector(0, 0, 50))
				timer.Create("NPC_Freeze", 0.001, 0, function()
					entity_hit:SetSchedule(73)
					entity_hit:SetNPCState(0)
				end)
			end
		end
	end
	ent1:AddCallback("PhysicsCollide", Collide4)
	Enkidu_Exists = true
	
	elseif Enkidu_Exists == true then
		Enkidu_Exists = false
		timer.Remove("Effect_Timer")
		timer.Remove("NPC_Freeze")
		ent1:Remove()
		ent1_static:Remove()
		for k,v in pairs(player.GetAll()) do
			if v:Nick() == player_name then
				v:Freeze(false)
			end
		end
		
		for k,v in pairs(ents.FindByClass("npc_*")) do
			if IsValid(v) then
				if v:GetNPCState(0) then
					v:SetCondition(68)
				end
			end
		end
	end
	end
end
function SWEP:Deploy()
	
	

	return true

end

function SWEP:PreDrawViewModel(vm)
    if self.ViewModelDraw == false then
        render.SetBlend(0)
    end
end


-- dont mess with this shit

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/
function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end