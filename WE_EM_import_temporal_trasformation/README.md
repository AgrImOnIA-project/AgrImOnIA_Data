# What do these scripts do?

These scripts need to the download and pre-processing steps of the Agrimonia dataset building regarding weather (WE) and emissions (EM) data. In this scripts the ERA5 dataset, containing hundreds of weather variables, can be accessed directly from your R workspace and retrieve the same data of the Agrimonia dataset, as well as other data for other periods or other regions. The same with CAMS regarding emissions data. 

# Files

<ul> <li> <b> Data_WE/Weather.R </b> cointans several steps about weather data: the first is the download of ERA5 data from the Climate Data Store (CDS). Then, from the netcds files, a long table of the format <b> x </b>,<b> y </b>,<b> t </b>, where <b> x </b> and <b> y </b> are the coordinates and <b> t </b> the time. After, the temporal transformations are made, mainly from hourly to daily keeping some informations as the daily maximum, minimum, mode, ecc. At the end, every years are merged in one file. </li> <li> <b> Data_EM/Emissions.R </b> contains several steps about emissions data: the first is the download of the CAMS data from the Atmosphere Data Store (ADS). Then, from netcdf to long table (as for weather) and at the end the hermite spline to reconstruct and estimate daily values from monthly ones.  </li> <li> <b> Functions </b> is the folder containing the functions called in the other scripts </li>

# Folders

In each folder a README file is provided.