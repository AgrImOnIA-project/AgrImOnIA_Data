# Summary

The script <i>Emissions.R</i> serves as initial step for the building process of the Agrimonia Dataset, in particular the script is used to download emissions data and prepare them for the next steps. First, variables are downloaded the CAMS dataset. For a deeper description of the dataset accessed the reader is referred to the subsection Emissions in the section Methods of the accompanying paper. The default request includes some frequent variables from all the sectors available on a grid format. The resolution of the grid depends on the kind of source of emissions. In our case, anthropogenic emissions are provided on a grid of 0.1° x 0.1°. The temporal resolution of the data is monthly. We converted them to daily using the Piecewise Hermite Cubic Interpolation technique. After, we have merged them. At the end, the output is one file containing daily observation on the same grid, ready to be spatially interpolated with the Air Quality localisations. Indeed, they will serve as input for Spatial Interpolation.R. The code makes extensive use of parallelisation via the <tt>doParallel</tt> and <tt>foreach</tt> packages. Other packages used are <tt>ecmwfr</tt>to interface with CDS web sevices <tt>ncdf4</tt> and <tt>ecmwfr</tt> for the extraction-data from netcdf files.

# Emissions.R Structure

The script is divided in sections (press Alt + o inside the R console to view it):
<ul>

<li><b>B.0. Data Download </b> makes the request to the Atmosphere Data Store (ADS) for emissions data. For this step you need an account on the <a href="https://atmosphere.copernicus.eu/data">ADS webpage</a>. 
In this section is possible to make the request for emissions from a large number of pollutants for all the globe. Not all the variables are used. To know which variables are kept in the Agrimonia porject the reader is referred to the Table 3 of the reference paper</li>. Data are downloaded using the package <tt>ncdf4</tt>.

<li><b>B.1. From netcdf to Points Dataframe</b> transforms the netcdf files obtained from the CDS service in long table of the format <i>x, y, t</i> through the function <i>getvarCAMS.R</i>. Emissions data from netcdf files can be extracted and converted to a long table format (<i>x,y,t</ii>) using the <tt>ncdf4</tt> through the function <i>getvarCAMS.R</i>. For the purpose of the project AgrImOnIA we are intersted in ammonia, sulphur dioxide and nitrogen dioxide.
The process is made for each variables coming from different files so the section is divided in a subsections for each pollutant:
<ul>
<li><b>B.1.1. ammonia </b> where the conversion is for variables from ERA5Land dataset</li>
<li><b>B.1.2. nitrogen dioxides</b>where the conversion is for variables from ERA5 Single Level dataset</li>
</ul></li>
After have merged them, the output of the section is a dataset with <i>n x t</i> rows where <i>n</i> is the number of cells of the grid and <i>t</i> the number of unit time in the period, and with columns equal to <i>p x s</i> where <i>p</i> is the number of pollutants and <i>s</i> the number of micro-sectors sources.  

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
