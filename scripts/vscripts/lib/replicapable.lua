Replicapable = Replicapable or class({}) 

local fUpdateTime 			= 0.2 
local AllReplicapableTable 	= {}
local ReplicapableValues 	= {}

function Replicapable:init( iEntityIndex, sFieldName )
	self.sEntityIndex = tostring(iEntityIndex) .. sFieldName

	self.data = {}

	if IsServer() then 
		AllReplicapableTable[self.sEntityIndex] = self.data
		ReplicapableValues[self] = true 
	end 
end 

function Replicapable:fini()
	self.data = nil 

	if IsServer() then 
		AllReplicapableTable[self.sEntityIndex] = nil 
		ReplicapableValues[self] = nil  
	end 
end 

function Replicapable:updateValue() 
	if IsClient() then 
		self.data = CustomNetTables:GetTableValue( "replicapable", "values" )[self.sEntityIndex] or {} 
	end 
end 


if IsServer() then
	
function Replicapable:__s_tick()
	if not _G.replicaDisable then 
		for classitem, _ in pairs(ReplicapableValues) do 
			AllReplicapableTable[classitem.sEntityIndex] = classitem.data 
		end 

		CustomNetTables:SetTableValue( "replicapable", "values", AllReplicapableTable )
	end 

	return fUpdateTime
end 

function Replicapable:s_tick()
	Timers:CreateTimer(0, function() return Replicapable:__s_tick() end )
end 

end 