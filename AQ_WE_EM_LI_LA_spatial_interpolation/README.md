# What do these scripts do?

These scripts need to the spatial interpolation step, where a value of each covariates is assigned to each air quality stations localisations thorugh different techniques. This procedure is inside "Spatial Interpolation.R". The other two scripts are functions that manually perform the IDW interpolation for WE and EM data. "AQinterp.R" and "AQinterpPARALLEL.R", as the names suggest, refer to AQ (stations localisations) interpolated with other spatial file (grid, shapefile, ecc.).

# Summary

The script <i>Spatial Interpolation.R</i> serves for an intermediate step during the building process of the Agrimonia Dataset, in particular the script is used to assign to each air quality stations localisations a value from other datasets with different spatial domain. Indeed, the localisations of the air quality monitoring stations in the Lombardy are spread randomly in the region while weather and emissions are provided ona grid format. missions data and prepare them for the next steps. For a deeper description of the technique used for this step the user is referred to the section "Data harmonisation and processing "of the accompanying paper. The method applied is the Inverse Distance Weighted where the distances are between the centers of the cells and the air quality station localisation. The number of neighbours considered is 4. For shapefile, as Corine Land Cover, we use instead point-extraction which makes more sense in the light of the type of data. Also soil data from raster are assigned using the point-extraction technique. At the end, the output is one file for every dimension containing daily observation for every air quality monitoring stations localisations. These files will serve as input for <i>Merging.R</i>. The code makes extensive use of parallelisation via the <tt>doParallel</tt> and <tt>foreach</tt> packages. Other packages used are <tt>ecmwfr</tt>to interface with CDS web sevices <tt>ncdf4</tt> and <tt>ecmwfr</tt> for the extraction-data from netcdf files.

# Emissions.R Structure

The script is divided in sections (press Alt + o inside the R console to view it):
<ul>

<li><b>C.1. Loading input files </b> where outputs from other preprocessing steps are called in the environment. This section is disaggregated by dimensions.
<li><b>C.2. KNN Spatial Interpolation </b> where the grid data are used to assign a value to each air quality stations localisations through the IDW technqiue. Weather data (<b>C.2.1.</b>) and emissions data (<b>C.2.2.</b>). This is done through the function <i>AQinterpPARALLEL.R</i>.
<li><b>C.3 Interpolation with shapefile and raster </b> where a value of land use (<b>C.3.1.</b>), soil (<b>C.3.2.</b>), altitude(<b>C.3.3.</b>) and livestock (<b>C.3.4.</b>) is assigned to each air quality monitoring stations localisations.

# Files

<ul> <li> <b> AQinterp.R </b> : is the function that interpolate the AQ stations localistations with ERA5 and CAMS grid data. The default method is the IDW with 4 nearest neighbours and power = 1. </li> <li> <b> AQinterpPARALLEL.R </b> is the same function as "AQinterp.R" but with the usage of parallelization technique (raccomanded for cluster or HPC users). </li> <li> <b> Spatial Interpolation.R </b> is the script containing the interpolation procedure between AQ data and every dimensions: WE, EM, LI, LA </li> </ul>
