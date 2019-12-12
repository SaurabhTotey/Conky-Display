local http = require("socket.http")

local NetworkUtility = {}

--A table that maps a path string to an object; the object is a triple containing requestTime, expirationDuration, and the request's data
NetworkUtility.cache = {}

--[[
Removes all cached NetworkUtility data
]]
function NetworkUtility.clearCache()
	NetworkUtility.cache = {}
end

--[[
Should be called periodically to update the network utility
Cleans the cache of old data
]]
function NetworkUtility.update()
	for path, data in pairs(NetworkUtility.cache) do
		if os.time() - data.expirationDuration > data.requestTime then
			NetworkUtility.cache[path] = nil
		end
	end
end

--[[
Gets the data at the given path
If the data was retrieved recently enough, a cached version of the data is given instead
Relies on the update function being called regularly to clear the cache of old data
expirationDuration is an optional parameter that specifies how long the data should live in the cache in seconds (defaults to 30)
If the same request is made with a new and different expirationDuration, the request is sent out again and refreshed in the cache
]]
function NetworkUtility.request(path, expirationDuration)

	--Getting parameters
	expirationDuration = expirationDuration or 30;

	--Get cached data if possible
	local cached = NetworkUtility.cache[path]
	if cached ~= nil and cached.expirationDuration == expirationDuration then
		return cached.data
	end

	--Actually send out request and update cache with request data
	local requestData, status, headers = http.request(path)
	NetworkUtility.cache[path] = { requestTime = os.time(), expirationDuration = expirationDuration, data = requestData }
	return requestData
end

return NetworkUtility
