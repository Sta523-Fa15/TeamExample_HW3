library(dplyr)
library(nnet)
library(raster)

short_to_long = c("BK"="Brooklyn", 
                  "BX"="Bronx",
                  "MN"="Manhattan",
                  "QN"="Queens",
                  "SI"="Staten Island")


load('geocode.Rdata')

d = select(d, Borough, x, y)
names(d)  = c("Borough","long","lat")


## Create model
l = multinom(Borough~long*lat+I(long^2)+I(lat^2),data=d)

## Create raster for prediction locations
r = raster(nrows=500, ncols=500, 
           xmn=-74.3, xmx=-73.71, 
           ymn=40.49, ymx=40.92)
r[]=NA

pred_locs = data.frame(xyFromCell(r, 1:250000))
names(pred_locs) = c("long","lat")

pred = predict(l,pred_locs)
r[] = pred


## Create Polygons

poly = rasterToPolygons(r,dissolve=TRUE)

names(poly@data) = "Name"
poly@data$Names = short_to_long[levels(pred)]

source("write_geojson.R")
write_geojson(poly,"boroughs.json")
