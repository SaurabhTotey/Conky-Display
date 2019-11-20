require "cairo"

local ImageUtility = {};

--How much time must pass before an image will be re-read from the filesystem rather than being retrieved from the cache in seconds
ImageUtility.expirationDuration = 60

--A table that maps a path string to an object; the object stores the image surface and the time that it was loaded (.surface and .readTime)
ImageUtility.cache = {}

--[[
Should be called periodically to update the image utility
Cleans the cache of old data
]]
function ImageUtility.update()
	for path, data in pairs(ImageUtility.cache) do
		if os.time() - ImageUtility.expirationDuration > data.readTime then
			cairo_surface_destroy(data.surface)
			ImageUtility.cache[path] = nil
		end
	end
end

--[[
Gets the image surface at the given path
If the surface was requested recently enough, a cached version of the image is given instead
Relies on the update function being called regularly to clear the cache of old data
Assumes images at a given path never change
]]
function ImageUtility.getImageSurface(path)
	local cached = ImageUtility.cache[path]
	if cached ~= nil then
		cached.readTime = os.time()
		return cached.surface
	end
	local surface = cairo_image_surface_create_from_png(path)
	ImageUtility.cache[path] = { readTime = os.time(), surface = surface }
	return surface
end

return ImageUtility
