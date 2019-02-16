Token = Token or class({})

function Token:GetPlayerID(token)
	local playerid = self.tokenToPlayerID[token]

	if not playerid then
		self:RegenerateTokens() -- someone try to brutforce tokens, regenerate it.
		return nil
	end

	return playerid
end

function Token:RegenerateTokens()
	self.tokenToPlayerID = {}

	local nPlayers = PlayerResource:GetPlayerCount()

	for i = 0, nPlayers - 1 do
		self:GenerateToken(i)
	end
end

function Token:GenerateToken(playerid)
	local lastToken = nil 

	for token, pid in pairs(self.tokenToPlayerID) do
		if pid == playerid then
			lastToken = token
		end
	end

	if lastToken then
		self.tokenToPlayerID[token] = nil
		lastToken = nil
	end 

	if not PlayerResource:IsValidPlayerID(playerid) then 
		print("Invalid playerid for creating token")

		Timers:CreateTimer(0.5, function() 
			Token:RegenerateTokens() 
		end)

		return 
	end 

	local value = math.fmod( Time() * 4096, 2147483647 )

	local token = RandomInt(1, value)

	while self.tokenToPlayerID[token] do 
		token = RandomInt(1, value)
	end

	self.tokenToPlayerID[token] = playerid

	self:__sendTokenToClient(playerid, token)
end

function Token:_DebugPrintTokens()
	print("Called _DebugPrintTokens")

	for token, playerid in pairs(self.tokenToPlayerID) do
		print("[S]", playerid, "=", token)

		local player = PlayerResource:GetPlayer(playerid)	

		CustomGameEventManager:Send_ServerToPlayer( player, "token_debug_print", {} )
	end 
end 

-------------------------------------------------------------------------------------------------------------- 
--											Private Methods 
--------------------------------------------------------------------------------------------------------------

function Token:__clientAskForToken(data)
	local playerid = data["playerid"]

	if not playerid then
		error("Token:__clientAskForToken No playerid")
	end

	playerid = tonumber(playerid)

	if not playerid then
		error("Token:__clientAskForToken playerid is not number")
	end

	self:GenerateToken(playerid)
end

function Token:__sendTokenToClient(playerid, token)
	local player = PlayerResource:GetPlayer(playerid)	

	if not player then
		print("No player for send token to client, playerid ", playerid)
		return
	end

	CustomGameEventManager:Send_ServerToPlayer( player, "token_on_token_recived", { ["token"] = token } )
end 

function Token:__reciveTokenAskFromPlayer(data)
	local playerid = data["playerid"]

	if not playerid then 
		print("Token __reciveTokenAskFromPlayer not playerid taken")
		return 
	end 

	playerid = tonumber(playerid)

	if not playerid then
		error("Token:__reciveTokenAskFromPlayer playerid is not number")
	end
	
	-- self is not avaliable here
	Token:GenerateToken(playerid)
end 

function Token:__init()
	self.tokenToPlayerID = self.tokenToPlayerID or {}

	CustomGameEventManager:RegisterListener("token_ask_regenerate", Dynamic_Wrap(Token, '__reciveTokenAskFromPlayer'))
end

Token:__init()