local http = require("socket.http")

local NetworkUtility = {}

--How much time must pass before request data will be fetched over the network rather than being retrieved from a cached value in seconds
NetworkUtility.expirationDuration = 30

--A table that maps a path string to an object; the object is a pair containing requestTime and the request's data
NetworkUtility.cache = {}

--[[
Should be called periodically to update the network utility
Cleans the cache of old data
]]
function NetworkUtility.update()
	for path, data in pairs(NetworkUtility.cache) do
		if os.time() - NetworkUtility.expirationDuration > data.requestTime then
			NetworkUtility.cache[path] = nil
		end
	end
end

--[[
Gets the data at the given path
If the data was retrieved recently enough, a cached version of the data is given instead
Relies on the update function being called regularly to clear the cache of old data
]]
function NetworkUtility.request(path)
	local cached = NetworkUtility.cache[path]
	if cached ~= nil then
		return cached.data
	end
	local requestData, status, headers = http.request(path)
	NetworkUtility.cache[path] = { requestTime = os.time(), data = requestData }
	return requestData
end

return NetworkUtility
