
# https://gis.stackexchange.com/questions/251643/approx-distance-between-any-2-longitudes-at-a-given-latitude


# camera location: 39.33866714, -76.68489829


# example
#  given 51.43567 longitude, 
#  what is the distance between 0 latitude and 1 latitude at that longitude?

# To convert a given latitude into the approximate distance in miles between 1 longitude at that point:
# (90 - Decimal degrees) * Pi / 180 * 69.172

(90 - 51.43567) * 3.1415927 / 180 * 69.172
# [1] 46.55791


# for crime data
# dist btwn longitudes at equator = 69.172
# lat = 39.33866714
(90 - 39.33866714) * 3.1415927 / 180 * 69.172
# [1] 61.16237
# this the distance between 1 longitude at latitude = 39.33866714, in miles

# we only want a distance of .5 miles btwn longtiudes
.5/69.172
# 0.007228358
# the .5 %  mile distance measuring .5 mi between 2 whole longitudes

# add this to center longitude to get right longitude to the right
# note: longitudes decrease from east to west

# so decrease/increase longitude by adding/subtracting 0.007228358 to get to .5 mile left/right border

# camera location: 39.33866714, -76.68489829

-76.68489829 + 0.007228358 
# -76.67767

# manual result using online calculator
# https://www.omnicalculator.com/other/latitude-longitude-distance and
# google earth pro
# -76.6755

# so distance between
# 39.33866714, -76.68489829
# and
# 39.33866714, -76.67767
# should be ~ .5 mile
# but this .38 miles

# 39.33866714, -76.6755