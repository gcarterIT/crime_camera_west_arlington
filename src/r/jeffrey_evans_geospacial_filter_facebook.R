# Here is a worked example. For a single point radius this is quite easy. 
#First, lets add sf and some data.
  
# install.packages("lwgeom")
library(lwgeom)
# install.packages("sf")
library(sf)

# Use PROJ to return ellipsoidal distances
sf_use_s2(FALSE)

# Add data and transform to WGS84
data(meuse, package = "sp")
meuse <- st_as_sf(meuse, 
                  coords = c("x", "y"),
                  crs = 28992, 
                  agr = "constant")
meuse <- st_transform(meuse, crs=4326)

# Here we subset a single point from the data and this will be the 
#  point that we query our distance compared to the other points
x <- meuse[50,]
y <- meuse[-50,]
d = 1000 # radius distance

# Now, we create a distance vector of distances of all y points 
#  to x. Since we have a vector of distances we can use a simple 
#  ifelse statement to query our distance(s). Here we return a boolean vector.
m <- units::drop_units(st_distance(x,y))
y$intersects <- as.vector(ifelse(m <= d, TRUE, FALSE))

# Now, plot the results.
plot(y["intersects"], pch=20)
plot(st_geometry(x), pch=16, cex=3, add=TRUE, col="black")

# However, if we want to return all row indices within a dataset, 
#  we need a full matrix. We set the matrix diagonal to NA so that 
#  we omit self-realized neighbors. In this case, we return a list 
#  object with the row indices for each point. You will have to come 
#  up with a criteria that handles multiple neighbor membership.
m <- units::drop_units(st_distance(meuse))
diag(m) <- NA
lapply(1:nrow(m), function(i) { which( m[i,] <= d)})


# For large data, this can be done very efficiently, and fast, 
#  using the Arya and Mount's Approximate Nearest Neighbours (ANN) 
#  C++ library available through the RANN library. The data.frame 
#  results represent the row indices and are formatted in a way that 
#  columns represent the maximum number of neighbors in the data, with 
#  zero values when an observation does not matching neighbors.
( nn <- RANN::nn2(st_coordinates(meuse), searchtype = "radius", radius = d)$nn.idx )