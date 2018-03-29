
-- Credits to SpiralP and Tenrys
-- Currently Discord Canary only
-- Fail message: Not authenticated or invalid scope

discordrpc = discordrpc or {}
discordrpc.Enabled = CreateClientConVar("discordrpc_enabled", "1", true, false)
discordrpc.port = discordrpc.port

discordrpc.states = discordrpc.states or {}
discordrpc.state = discordrpc.state

-- discordrpc.clientID (string) should be set in main.lua
-- discordrpc.state (string) should be set later in main.lua as the starting state

function discordrpc.Print(...)
	local header = "[Discord RPC%s] "
	local args = {...}
	if type(args[1]) ~= "string" then
		header = header:format(" DEBUG")
	end

	MsgC(Color(114, 137, 218), header)
	print(...)
end
function discordrpc.Init(callback)
	if not discordrpc.port then
		local validPort
		for port = 6463, 6473 do
			local success = function(body)
				if body:match("Authorization Required") and not validPort then
					discordrpc.Print(("Connection success on port %s! "):format(port))
					validPort = port
					discordrpc.port = validPort

					discordrpc.SetActivity({ details = "...", state = "..." }, function(body, err)
						if not body and err:match("Not authenticated or invalid scope") then
							discordrpc.Print("Warning: first SetActivity test didn't work, make sure you're using Discord Canary!")
						else
							discordrpc.Print("First SetActivity test was successful, should be ready to work!")
						end

						if callback then
							callback(body, err)
						end
					end)
				end
			end
			local failed = function(...)
				-- do nothing
			end
			http.Fetch(("http://127.0.0.1:%s"):format(port), success, failed)
		end
	end
end
function discordrpc.SetActivity(activity, callback)
	if not discordrpc.Enabled:GetBool() then return end
	
	if not discordrpc.port then
		ErrorNoHalt("DiscordRPC: port unset, did you Init?")
		return
	end

	HTTP{
		method = "POST",
		url = ("http://127.0.0.1:%s/rpc?v=1&client_id=%s"):format(discordrpc.port, discordrpc.clientID),

		type = "application/json",
		body = util.TableToJSON{
			cmd = "SET_ACTIVITY",
			args = {
				pid = 12345, -- This doesn't really matter though it would be nice if we could get GMod's process ID in Lua
				activity = activity
			},
			nonce = tostring(SysTime())
		},

		success = function(status, body)
			local data = util.JSONToTable(body)
			if not data or data.evt == "ERROR" then
				callback(false, "Discord error: " .. tostring(data.data and data.data.message or "nil"))
			else
				callback(data)
			end
		end,
		failed = function(err)
			callback(false, "HTTP error: " .. err)
		end,
	}
end
local defaultActivity = {
	details = "???",
	state = "Default state"
}
function discordrpc.GetActivity()
	local activity = {}

	if discordrpc.state then
		local state = discordrpc.states[discordrpc.state]
		if state then
			activity = state.GetActivity and state:GetActivity() or {
				details = state:GetDetails(),
				state = state:GetState(),
				timestamps = state:GetTimestamps(),
				assets = state:GetAssets()
				-- Other fields available that we can't use (atleast I don't think so): party, secrets, instance, application_id, flags
			}
		else
			discordrpc.Print(("Error: State %s not found? Getting default activity!"):format(discordrpc.state))
			activity = defaultActivity
		end
	else
		discordrpc.Print("Warning: No state selected, getting default activity!")
		activity = defaultActivity
	end

	return activity
end

