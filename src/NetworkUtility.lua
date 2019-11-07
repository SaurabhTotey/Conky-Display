local http = require("socket.http")

local NetworkUtility = {}

--How often the network utility will actually send out new requests in seconds
NetworkUtility.refreshRate = 30

NetworkUtility.cache = {}

--[[
Gets the data at the given path
If the data was requested recently enough, a cached version of the data is given instead
]]
function NetworkUtility.request(path)
	local cached = NetworkUtility.cache[path]
	local currentTime = os.time()
	if cached == nil || currentTime - NetworkUtility.refreshRate > cached.requestTime then
		local requestData, status, headers = http.request(path)
		NetworkUtility.cache[path] = {}
		NetworkUtility.cache[path].requestTime = currentTime
		NetworkUtility.cache[path].data = requestData
		return requestData
	else
		return cached.data
	end
end

return NetworkUtility
