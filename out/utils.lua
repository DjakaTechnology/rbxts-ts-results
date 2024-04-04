-- Compiled with roblox-ts v2.3.0
local TS = _G[script]
local HttpService = TS.import(script, TS.getModule(script, "@rbxts", "services")).HttpService
local function toString(val)
	return HttpService:JSONEncode(val)
end
return {
	toString = toString,
}
