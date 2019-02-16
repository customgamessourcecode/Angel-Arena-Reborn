--[[ Overrides for PlayerResource and Player entity 
   
   API:
	PlayerResource:IsDisconnected(playerid)
	PlayerResource:SetDisconnected(playerid)
	PlayerResource:IsConnected(playerid)
	PlayerResource:SetConnected(playerid)
	PlayerResource:IsAbandoned(playerid)
	PlayerResource:SetAbandoned(playerid)
	PlayerResource:GetAllHeroes()
	PlayerResource:GetHeroes(iTeamNumber)
	PlayerResource:GetCursorPosition(playerid)

   Callback must be called from main callbacks
    PlayerResource:OnPlayerConnected(playerid, userid) 
]]


------------------------------------------------------------------------------------------------------------------------------------------------

require("lib/timers")

------------------------------------------------------------------------------------------------------------------------------------------------

function PlayerResource:__InitCustomPlayerResource() 
	if self.__internal__ then return end 

	self.__internal__ = {}

	self.__internal__["playerid_dict_connection_states"] = {
		[DOTA_CONNECTION_STATE_UNKNOWN] 			= {},
		[DOTA_CONNECTION_STATE_NOT_YET_CONNECTED] 	= {},
		[DOTA_CONNECTION_STATE_CONNECTED] 			= {},
		[DOTA_CONNECTION_STATE_DISCONNECTED] 		= {},
		[DOTA_CONNECTION_STATE_ABANDONED] 			= {},
		[DOTA_CONNECTION_STATE_LOADING] 			= {},
		[DOTA_CONNECTION_STATE_FAILED] 				= {},
	}

	self.__internal__["playerid_info"] = {
		["connection_times"] = {}
	}

	self.__internal__["players_cursor_positions"] = {}
	
	CustomGameEventManager:RegisterListener("UpdatedCursorPosition", Dynamic_Wrap(self, '__OnUpdateCursorPos'))

	if bReload then 
		self.__internal__.userIDs = self.__internal__.userIDs or {} -- tbl[playerid] = userid 
	else
		self.__internal__.userIDs = {}
	end 

	Timers:CreateTimer(1.0, function() 
		PlayerResource:__Tick() 
		return 1.0 
		end)
end 

function PlayerResource:__OnUpdateCursorPos(event)
	local pid = event["PlayerID"]
	local vec = Vector( tonumber(event["cursorPosition"]["0"]), tonumber(event["cursorPosition"]["1"]), tonumber(event["cursorPosition"]["2"]))
	PlayerResource.__internal__["players_cursor_positions"][ pid ] = vec
end 

function PlayerResource:GetCursorPosition(playerid) 
	return self.__internal__["players_cursor_positions"][playerid] or Vector(0,0,0)
end 

function PlayerResource:IsDisconnected(playerid)
	local val = (PlayerResource:GetConnectionState(playerid) == DOTA_CONNECTION_STATE_DISCONNECTED )

	if self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_DISCONNECTED][playerid] ~= nil then 
		val = self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_DISCONNECTED][playerid]
	end 

    return val 
end 

function PlayerResource:SetDisconnected(playerid, v)
	self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_DISCONNECTED][playerid] = v
end 

function PlayerResource:IsConnected(playerid)
    local val = (PlayerResource:GetConnectionState(playerid) == DOTA_CONNECTION_STATE_CONNECTED )

	if self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_CONNECTED][playerid] ~= nil then 
		val = self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_CONNECTED][playerid]
	end 

    return val  
end 

function PlayerResource:SetConnected(playerid, v)
	self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_CONNECTED][playerid] = v
end 

function PlayerResource:IsAbandoned(playerid)
    local val = (PlayerResource:GetConnectionState(playerid) == DOTA_CONNECTION_STATE_ABANDONED )

	if self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_ABANDONED][playerid] ~= nil then 
		val = self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_ABANDONED][playerid]
	end 

    return val 
end 

function PlayerResource:SetAbandoned(playerid, v)
	self.__internal__["playerid_dict_connection_states"][DOTA_CONNECTION_STATE_ABANDONED][playerid] = v
end 

function PlayerResource:GetAllHeroes()
	local result = {}

	for playerid = 0, PlayerResource:GetPlayerCount() - 1 do
		local ent = PlayerResource:GetSelectedHeroEntity( playerid )
		
		if ent and IsValidEntity(ent) and ent:IsRealHero() then
			table.insert(result, ent)
		end 
	end 

	return result 
end 

function PlayerResource:GetHeroes(iTeamNumber)
	local result = {}

	for playerid = 0, PlayerResource:GetPlayerCount() do
		if PlayerResource:GetTeam(playerid) == iTeamNumber then 
			local ent = PlayerResource:GetSelectedHeroEntity( playerid )

			if ent and IsValidEntity(ent) and ent:IsRealHero() then
				result[playerid] = ent 
			end 
		end 
	end 

	return result 
end 

function PlayerResource:GetHeroes(iTeamNumber)
	local result = {}

	for playerid = 0, PlayerResource:GetPlayerCount() do
		if PlayerResource:GetTeam(playerid) == iTeamNumber then 
			local ent = PlayerResource:GetSelectedHeroEntity( playerid )

			if ent and IsValidEntity(ent) and ent:IsRealHero() then
				result[playerid] = ent 
			end 
		end 
	end 

	return result 
end 

function PlayerResource:ForceDisconnect(playerid)
	if not self.__internal__.userIDs[playerid] then return end 

	SendToServerConsole('kickid '.. self.__internal__.userIDs[playerid]);
end 

-- Callback that must be called from main gamemode
function PlayerResource:OnPlayerConnected(playerid, userid)
	self.__internal__.userIDs[playerid] = userid 
end 

function PlayerResource:__Tick()
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end 
	if GameRules:State_Get() > DOTA_GAMERULES_STATE_POST_GAME then return end 

	local time_to_leave_min = 5

	for playerid = 0, PlayerResource:GetPlayerCount() do
		local v = self.__internal__["playerid_info"]["connection_times"][playerid] or time_to_leave_min * 60 

		if not PlayerResource:IsConnected(playerid) then 
			if v > 0 then
				v = v - 1
				
				if v == 0 then  
					PlayerResource:SetAbandoned(playerid, true)
				end 
			end 

			self.__internal__["playerid_info"]["connection_times"][playerid] = v
		end 
	end 
end 

PlayerResource:__InitCustomPlayerResource() 