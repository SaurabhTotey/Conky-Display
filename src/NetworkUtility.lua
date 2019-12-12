local http = require("socket.http")

local NetworkUtility = {}

--A table that maps a path string to an object; the object is a pair containing expirationTime, and the request's data
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
		if os.time() >= data.expirationTime then
			NetworkUtility.cache[path] = nil
		end
	end
end

--[[
Gets the data at the given path
If the data was retrieved recently enough, a cached version of the data is given instead
Relies on the update function being called regularly to clear the cache of old data
expirationDuration is an optional parameter that specifies how long the data should live in the cache in seconds (defaults to 30)
If the same request is made with a new and different expirationDuration, the request will obey the previous expirationDuration until removed from the cache
forceRefresh is an optional paramter that specifies whether to refresh the cache for this specific request (defaults to false)
]]
function NetworkUtility.request(path, expirationDuration, forceRefresh)

	--Getting parameters
	expirationDuration = expirationDuration or 30;
	forceRefresh = forceRefresh or false;

	--Get cached data if it exists and not forcing HTTP
	local cached = NetworkUtility.cache[path]
	if cached ~= nil and not forceRefresh then
		return cached.data
	end

	--Actually send out request and update cache with request data
	local requestData, status, headers = http.request(path)
	NetworkUtility.cache[path] = { expirationTime = os.time() + expirationDuration, data = requestData }
	return requestData
end

return NetworkUtility
