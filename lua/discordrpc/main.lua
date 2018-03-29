
if not discordrpc then ErrorNoHalt("DiscordRPC: missing???") return end

discordrpc.clientID = "428418963836502016" -- This is Meta Construct's Discord application ID.
discordrpc.state = "metastruct" -- This is the default state when you first load in.

http.Loaded = http.Loaded and http.Loaded or false
local function checkHTTP()
	http.Fetch("http://google.com", function()
		http.Loaded = true
	end, function()
		http.Loaded = true
	end)
end
if not http.Loaded then
	timer.Create("HTTPLoadedCheck", 3, 0, function()
		if not http.Loaded then
			checkHTTP()
		else
			hook.Run("HTTPLoaded")
			timer.Remove("HTTPLoadedCheck")
		end
	end)
end

hook.Add("HTTPLoaded", "discordrpc_metastruct", function()
	discordrpc.Init(function(succ, err)
		if succ then
			discordrpc.LoadStates()

			discordrpc.SetActivity(discordrpc.GetActivity(), discordrpc.Print)
		else
			discordrpc.Print(succ, err)
		end
	end)
end)

