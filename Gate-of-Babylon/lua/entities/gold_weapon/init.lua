ENT.Type = "anim"
local ENT = {}

local BaseClass = FindMetaTable("Entity")
local BaseClassName = "prop_physics"
local ClassName = "gold_weapon"

AddCSLuaFile()

function ENT:Initialize()
end

local old_FindByClass = ents.FindByClass
function ents.FindByClass ( class, ... )
	if class == ClassName then
		local entities = {}

		for _, ent in pairs( old_FindByClass( BaseClassName ) ) do
			if ent:GetClass() == ClassName then
				entities[#entities+1] = ent
			end
		end
		return entities
	elseif class == BaseClassName then
		local entities = {}

		for _, ent in pairs( old_FindByClass( BaseClassName ) ) do
			if ent:GetClass() != ClassName then
				entities[#entities+1] = ent
			end
		end
		return entities
	else
		return old_FindByClass( class, ... )
	end
end

local old_GetClass = BaseClass.GetClass
function BaseClass:GetClass ( ... )
	if self:GetNWBool( ClassName, false ) then
		return ClassName
	else
		return old_GetClass( self, ... )
	end
end
local SENT_values = {}

for FuncName, Func in pairs( ENT ) do
	if isfunction( Func ) then
		local old_Func = BaseClass[FuncName]
		if isfunction( old_Func ) then
			BaseClass[FuncName] = function ( self, ... )
				if self:GetClass() == ClassName then
					return Func( self, ... )
				else
					return old_Func( self, ... )
				end
			end
		else
			SENT_values[FuncName] = Func
		end
	else
		SENT_values[FuncName] = Func
	end
end

local old_Create = ents.Create
function ents.Create ( class, ... )
	if class == ClassName then
		local ent = old_Create( BaseClassName, ... )
		if IsValid( ent ) then
			ent:SetNWBool( ClassName, true )
			for k, v in pairs( SENT_values ) do
				ent[k] = v
			end
			if isfunction( ent.Initialize ) then
				ent:Initialize()
			end
		end
		return ent
	else
		return old_Create( class, ... )
	end
end