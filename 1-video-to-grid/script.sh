########################################################
############### Video to grid ##########################
########################################################

# We are going to a take a timelapse video and turn it into a grid of images. 
# I am using a video of a hibiscus flower blooming from a royalty free videos site. https://www.pexels.com/video/flora-blooming-856006/
# You can use whatever! 

# Convert our video to a bunch of images. 
# -i is input. it precedes our filename.
# -filter:v scale=720:-1 means I want to scale the video to 720 pixels wide and keep the aspect ratio.
# -r flag defines the framerate. 0.5 frame rate means 1 frame every 2 seconds. 
# frame rate of 1 means 1 frame every second. 15 means 15 frames every second.
# %04d means it will assign numbers with a 4 digit padding to the images that are generated. 
ffmpeg -i hoop.mp4 -filter:v scale=720:-1 -r 1 output_%04d.png
# Now we'll have a bunch of images in our folder. 
# We want to turn our images to a grid of images. 

# Let's use imagemagick's montage feature for that
# magick is how you call imagemagick, montage is the grid tool in imagemagick

# -tile 6x0 means I want 6 columns and whatever number of rows are needed to complete my grid
# -geometry +0+0 means no spaces between images
# then I ask it to take ALL pngs starting with output using `output*.png`. it is a regex
# And save the whole thing as out.png
magick montage -tile 2x3 -geometry +0+0 output*.png grid.png

# Another way to do this will be using the legacy montage.
# both are same and work in a similar manner.
# basically the one below is the older way of using IM
# and the one above is a newer way. the legacy tool is better documented.
montage -tile 6x0 -geometry +0+0 -border 10 *.png grid.png
