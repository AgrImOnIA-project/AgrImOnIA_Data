# Summary

The script <i>Weather.R</i> serves as initial step for the building process of the Agrimonia Dataset, in particular the script is used to download weather data and prepare it for the next steps. First, variables are downloaded from two datasets: ERA5Land and ERA5 Single Level. The two datasets come from the ERA5 reanalysis but
they differ for the spatial resolution. Indeed, ERA5Land has a better resolution, 0.1° x 0.1° compared to 0.25° x 0.25° of the ERA5 Single Level but it contains less variables and just the land-linked variables. For instance, temparature at 2 meter comes from ERA5 Land while boundary layer height comes from 
ERA5 Single Level. The default temporal resolution is hourly because when we convert them to daily we can keep the information about the daily maximum or minimum or mode. One variable is not obtained directly from the CDS but is calculated from other variables: relative humidity from the combination of
the temprature and the dew-point temperature both at 2 meter above the ground. At the end, files ready to be spatially interpolated are generated and they will serve as input for Spatial Interpolation.R. The code makes extensive use of parallelisation via the <tt>doParallel</tt> and <tt>foreach</tt> packages.

# Weather.R Structure

The script is divided in sections (press Alt + o inside the R console to view it):
<ul>

<li><b>A.0. Data Download </b> makes the request to the Climate Data Store (CDS) for weather data. For this step you need an account on the <a href="https://climate.copernicus.eu/climate-data-store">CDS webpage</a>. 
In this section is possible to make a request for another region (identified by a box of two longitude values and two latitude values) or an other temporal period. 
The intial values are the same as used by Agrimonia team so a box containing Lombardy plus a buffer of 0.3 ° around the region border.
To make the request, the section uses the function called <i>ERA5datadownload.R</i> where is possible to change the details about the request for example the variables asked or the temporal resolution.
Variables requested by deafult and their descriptions can be found in the Table 3 of the reference paper</li>

<li><b>A.1. From netcdf to Points Dataframe</b> transforms the netcdf files obtained from the CDS service in long table of the format <i>x, y, t</i> through the function <i></i>. 
The output of the function are files, already saved, containing a table with <i>s x t</i> rows where <i>s</i> is the number of localisations and <i>t</i> the number of unit time in the period. 
The process is made for variables coming from two different datasets so the section is divided in two subsections:
<ul>
<li><b>A.1.1. ERA5 Land </b> where the conversion is for variables from ERA5Land dataset</li>
<li><b>A.1.2. ERA5 Single Level</b>where the conversion is for variables from ERA5 Single Level dataset</li>
</ul></li>

<li><b>A.2. From hourly to daily</b> where hourly long table are converted to daily long table using different ensemble criteria. 
The default ensemble criteria adopted for each variables are explained and illustrated in the Table 7 of the reference paper. 
To do the temporal transformation, the script uses the function <i>ERA5_Land_fromHourlytoDaily.R</i>, so, if the user wants to modify the way to convert the temporal resolution (e.g. use the median instead of mean) the user can look and modify the function. 
As for the others sections, the temporal transformation process is divided in two subsections, according to the source dataset:
<ul>
<li><b>A.2.1. ERA5 Land </b> where the temporal resolution transformation is made for variables from ERA5Land dataset.
Here is also calculated the relative humidity using the August-Roche-Magnus approximation formula from the dew-point temperature and the temperature.
<li><b>A.2.2. ERA5 Single Level</b> where where the temporal resolution transformation is made for variables from ERA5 Single Level dataset</li>
</ul></li>

<li><b>A.3.Merge all datasets across years</b> is the section where the files divided by year, because of the sizes, are merged togheter to make a single file. 
This step is made for both the variables. 
Keep in mind that ERA5 Land variables and ERA5 Single Level variables have different spatial resolution so they can not be merged.
As in the previous sections, there are two subsections, one for each dataset:
<ul>
<li><b>A.1.1. ERA5 Land </b> where the merge is made for variables from ERA5Land dataset</li>
<li><b>A.1.2. ERA5 Single Level</b>where the merge is made for variables from ERA5 Single Level dataset</li>
