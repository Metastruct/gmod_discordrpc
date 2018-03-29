
if not discordrpc then ErrorNoHalt("DiscordRPC: missing???") return end

local metastruct = {}
function metastruct:GetDetails()
	-- I was thinking of adding zones there maybe, we need to get those working clientside
	local ply = LocalPlayer()
	if ply:GetNWBool("in pac3 editor") then
		return "In PAC Editor"
	end
	
	return nil
end
function metastruct:GetState()
	-- Possibly reserved for other discordrpc states
	local ply = LocalPlayer()
	local zone = landmark.nearest(ply:GetPos()) or "Unknown"
	if zone:match("dond") or zone:match("minigame") then
		return "Playing DOND"
	end
	
	return "In " .. zone:gsub("^[a-z]", string.upper)
end

local start = os.time() -- os.time since spawned in the server, do not edit
function metastruct:GetTimestamps()
	return {
		start = start,
		["end"] = nil -- nothing yet
	}
end
metastruct.mapIconAssets = { -- Has to be updated manually for now, retrieving asset list might prove difficult to do, if even possible
	gm_construct_m = true
}
function metastruct:GetAssets()
	local assets = {}

	if game.GetMap():match("^gm_construct_m_") then
		assets.large_image = "gm_construct_m"
	elseif self.mapIconAssets[game.GetMap()] then
		assets.large_image = game.GetMap()
	else
		assets.large_image = "default"
	end

	return assets
end
discordrpc.states.metastruct = metastruct

