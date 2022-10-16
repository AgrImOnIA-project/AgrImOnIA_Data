# What do these scripts do?

These scripts need to the spatial interpolation step, where a value of each covariates is assigned to each air quality stations localisations thorugh different techniques. This procedure is inside "Spatial Interpolation.R". The other two scripts are functions that manually perform the IDW interpolation for WE and EM data. "AQinterp.R" and "AQinterpPARALLEL.R", as the names suggest, refer to AQ (stations localisations) interpolated with other spatial file (grid, shapefile, ecc.).

# Files

<ul> <li> <b> AQinterp.R </b> : is the function that interpolate the AQ stations localistations with ERA5 and CAMS grid data. The default method is the IDW with 4 nearest neighbours and power = 1. </li> <li> <b> AQinterpPARALLEL.R </b> is the same function as "AQinterp.R" but with the usage of parallelization technique (raccomanded for cluster or HPC users). </li> <li> <b> Spatial Interpolation.R </b> is the script containing the interpolation procedure between AQ data and every dimensions: WE, EM, LI, LA </li> </ul>
