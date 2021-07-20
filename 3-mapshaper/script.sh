########################################################
#		Make an animated map using the command line    #
########################################################

# I am making an animated map that shows 
# Mortality rate, under-5 (per 1,000 live births) for every country
# Using world bank data here https://data.worldbank.org/indicator/SH.DYN.MORT?view=chart
# You can do this for whatever indicator you feel like

# Let's get some boundaries for the world from the World Bank https://datacatalog.worldbank.org/dataset/world-bank-official-boundaries
# I am using a lowres geojson
curl -o wb-shapefile.zip https://development-data-hub-s3-public.s3.amazonaws.com/ddhfiles/779551/wb_boundaries_geojson_lowres.zip

# let's unzip it 
unzip wb-shapefile.zip

# let us merge our geojson with our data
# keys mention which ID to match on for our first dataset, and then our second dataset
# -o says which file to output this to
mapshaper WB_Boundaries_GeoJSON_lowres/WB_countries_Admin0_lowres.geojson -join world-child-mortality.csv keys=ISO_A3,code -o out.geojson

# There are these things called projections. They make our data look a certain way
# Let's check which all projections we have 
mapshaper -projections

# I like natural earth. so going to change my data to that projection using the -proj flag
mapshaper out.geojson -proj natearth -o projection.json

# Let us test out a map. 
# -colorizer defines a function to calculate colors based on breaks. we give the function a name.
# And then we give our buckets some colors 
# And then we define the breaks
# we call the function and give our svg a fill 
# The \ in the end make sure we escape the enter that comes after it. 
# If we wrote the thing in a whole long line. That would work too.
mapshaper projection.json \
	-colorizer name=getColor colors='#f0f9e8,#bae4bc,#7bccc4,#2b8cbe' \
		breaks=25,50,75 \
	-style fill='getColor(y2019)' \
	-o output.svg  # In the end, we output the whole thing as an svg

# It works!!!!!!!

# Now I want to loop through the same to create svg files for multiple years
# But first I want to create some folders for my svgs, pngs and annotated pngs
mkdir svg png annotated

# I want the thing only for select years, so I can write it like this

for year in 1980 1985 1990 1995 2000 2005 2010 2015 2019
# If I want to do a range, I will do it like this
# for ((year=1980;year<=2019;year++))
# in shell scripts, we start a block of actions in the loop with do
do
	# Get that projection
	# same colorizer jazz, followed by that fill thing
	# I also want to give a stroke. So I added that.
	# with the inpit in the end
	# Everywhere ${year} refers to the year we are looping through
	mapshaper projection.json \
	-colorizer colors='#f0f9e8,#bae4bc,#7bccc4,#2b8cbe' name=getColor breaks=25,50,75 \
	-style fill='getColor(y'${year}')' \
	-style stroke='rgba(255,255,255,.5)' \
	-o svg/${year}.svg
	# aha! here comes svg export. converts an svg to a png
	svgexport svg/${year}.svg png/${year}.png
	# Add some years as text using imagemagick
	# I take the file, say please make the background white and remove the transparent background (that is alpha)
	# Then I say -gravity South. That is because I want my text at the bottom. If I want it on top it'll be North.
	# I want by text to be black so that.
	# Then font size is called -pointsize
	# -annotate followed by x,y coords of where I want my annotation to be
	# The text of the annotation. Which in this case is ${year}
	# the file that I want to write this to
	convert png/${year}.png -background white -alpha remove -alpha off -gravity South -fill black -pointsize 24 -annotate +0+5 ${year} annotated/${year}.png
done
# We close the loop with done

# let us cd to our annotated folder
cd annotated
# and gif it all
# -delay 50 is the delay between things
# -loop 0 means it'll loop forever
convert -delay 50 *.png -loop 0  animate.gif

# Let us add a label and a title

# coalease - come together to form one mass or whole
convert animate.gif -coalesce \
          -gravity NorthWest -draw 'image over 0,0 0,0 "../label.png"' \
          -gravity North -pointsize 20 -background white -splice 0x18 \
          -annotate 0 'Mortality rate, under-5 (per 1,000 live births)' \
          -layers Optimize  animate-label.gif