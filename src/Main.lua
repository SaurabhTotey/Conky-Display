require "cairo"

--Add project source folder to the path to allow other project files to be included
package.path = package.path .. ";{{PROJECT}}/src/?.lua"

local json = require("json")
local DrawingUtility = require("DrawingUtility")
local ImageUtility = require("ImageUtility")
local LayoutUtility = require("LayoutUtility")
local NetworkUtility = require("NetworkUtility")

--[[
Extract environment variables from the .env file and initializes the layout
]]
function conky_startup()

	local environmentVariables = {}
	for line in io.lines("{{PROJECT}}/.env") do
		local splitIndex = string.find(line, "=")
		environmentVariables[string.sub(line, 1, splitIndex - 1)] = string.sub(line, splitIndex + 1, string.len(line))
	end

	LayoutUtility.initialize(24, 84, 25)

	-------------------- TITLE --------------------
	LayoutUtility.addDisplayElement(LayoutUtility.createDisplayElement(1, 84, function(context, w, h)
		DrawingUtility.setTextOptions(context)
		DrawingUtility.fitTextInsideRectangle(context, "Saurabh Totey", DrawingUtility.Rectangle(0, 0, w, h))
	end))

	-------------------- WEATHER --------------------
	LayoutUtility.addDisplayElement(LayoutUtility.createDisplayElement(3, 28, function(context, w, h)
		DrawingUtility.setTextOptions(context)

		--Load weather data
		local weatherData = json.decode(NetworkUtility.request("http://api.openweathermap.org/data/2.5/weather?appid=" .. environmentVariables["WEATHER_KEY"] .. "&id=" .. environmentVariables["CITY_ID"] .. "&units=metric"))
		local weatherDescription = weatherData["weather"][1]["description"]
		local weatherIcon = ImageUtility.getImageSurface("{{PROJECT}}/assets/weather-icons/" .. string.gsub(weatherDescription, "%s+", "-") .. ".png")
		local temperature = math.floor(weatherData["main"]["temp"] + 0.5) .. "°C"

		--Displays weather information
		DrawingUtility.fitTextInsideRectangle(context, weatherDescription, DrawingUtility.Rectangle(h, 0, w - h, h / 2))
		DrawingUtility.fitTextInsideRectangle(context, temperature, DrawingUtility.Rectangle(h, h / 2, w - h, h / 4))
		local scale = h / cairo_image_surface_get_height(weatherIcon)
		cairo_scale(context, scale, scale)
		cairo_set_source_surface(context, weatherIcon, 0, 0)
		cairo_paint(context)
		cairo_scale(context, 1 / scale, 1 / scale)
	end))

	-------------------- WORD OF THE DAY --------------------
	LayoutUtility.addDisplayElement(LayoutUtility.createDisplayElement(3, 28, function(context, w, h)
		DrawingUtility.setTextOptions(context)

		local wordOfTheDayData = json.decode(NetworkUtility.request("https://api.wordnik.com/v4/words.json/wordOfTheDay?api_key=" .. environmentVariables["WORD_KEY"], 60 * 60))
		local wordOfTheDay = wordOfTheDayData["word"]
		local definition = wordOfTheDayData["definitions"][1]["text"]
		DrawingUtility.fitTextInsideRectangle(context, wordOfTheDay, DrawingUtility.Rectangle(0, 0, w, h / 5))
		--TODO: split up definition into 4 lines somehow then write them in
	end))

	-------------------- TIME AND DAY --------------------
	LayoutUtility.addDisplayElement(LayoutUtility.createDisplayElement(3, 28, function(context, w, h)

	end))

end

--[[
Clears all caches
]]
function conky_shutdown()
	NetworkUtility.clearCache()
	ImageUtility.clearCache()
end

--[[
Main actions of the application
Gets repeatedly called every update
]]
function conky_main()

	--Ensure that the conky window acutally exists for what we are doing
	if conky_window == nil then
		return
	end

	--Create variables useful for drawing and such: will need to get passed into the draw function and then freed
	local cairoSurface = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	local cairoContext = cairo_create(cairoSurface)

	--Updates utility objects to allow them to clear their caches
	NetworkUtility.update()
	ImageUtility.update()

	--Render whatever layout and display elements we chose in conky_startup
	LayoutUtility.render(cairoContext)

	--Free resources
	cairo_destroy(cairoContext)
	cairo_surface_destroy(cairoSurface)

end
