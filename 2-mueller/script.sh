###################### Mueller report #######################
# The Mueller report brought in several journalists to make a grid of a pdf over and over again.
# The goal was to visually show the redactions. 
# 1. https://www.vox.com/2019/4/19/18485535/mueller-report-redactions-data-chart
# 2. https://www.nytimes.com/interactive/2019/04/19/us/politics/redacted-mueller-report.html
# 3. https://qz.com/1599481/all-488-pages-of-the-mueller-report-visualized/
# 4. https://www.latimes.com/projects/la-na-mueller-investigation-report-trump-redaction/


# Step 1 - Download the report.
curl -o report.pdf https://www.justice.gov/storage/report.pdf
# OOPS. Nothing gets downloaded. That is because the report redirects to another URL. 
# We use a flag to solve that problem. -L makes sure curl picks the redirected file.
curl -L -o report.pdf https://www.justice.gov/storage/report.pdf
# if you get the error "curl: (35) schannel: next InitializeSecurityContext failed: Unknown error (0x80092012) - The revocation function was unable to check revocation for the certificate."
# use the ss;l-no-revoke flag like this >>>> curl --ssl-no-revoke  -L -o report.pdf https://www.justice.gov/storage/report.pdf

# Now we have the report, so on to step 2

# Turn all pages into pngs
magick convert report.pdf -resize 25% output-%03d.jpg

# Turn it to a montage
magick montage -tile 15x0 -geometry +0+0 report*.png grid-withgeo.png

# Or a gif! Maybe the pages should be bigger for that?
# Make bigger images
magick convert -density 72 report.pdf -resize 50% -background white -alpha remove -alpha off report-bigger-%03d.png
# GIF it!
magick convert -delay 20 report-bigger*.png -loop 0  animate.gif
