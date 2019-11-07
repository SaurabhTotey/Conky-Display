local http = require("socket.http")

local NetworkUtility = {}

--How often the network utility will actually send out new requests in seconds
NetworkUtility.refreshRate = 30

--A table that maps a path string to an object; the object is a pair containing requestTime and the request's data
NetworkUtility.cache = {}

--[[
Should be called periodically to update the network utility
Cleans the cache of old data
]]
function NetworkUtility.update()
	for path, data in NetworkUtility.cache do
		if os.time() - NetworkUtility.refreshRate > data.requestTime then
			NetworkUtility.cache[path] = nil
		end
	end
end

--[[
Gets the data at the given path
If the data was requested recently enough, a cached version of the data is given instead
Relies on the update function being called regularly to clear the cache of old data
]]
function NetworkUtility.request(path)
	local cached = NetworkUtility.cache[path]
	if cached == nil then
		local requestData, status, headers = http.request(path)
		NetworkUtility.cache[path] = {}
		NetworkUtility.cache[path].requestTime = os.time()
		NetworkUtility.cache[path].data = requestData
		return requestData
	else
		return cached.data
	end
end

return NetworkUtility
