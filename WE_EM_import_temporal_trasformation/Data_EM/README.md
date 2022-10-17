# Summary

The script <i>Emissions.R</i> serves as initial step for the building process of the Agrimonia Dataset, in particular the script is used to download emissions data and prepare them for the next steps. First, variables are downloaded the CAMS dataset. For a deeper description of the dataset accessed the reader is referred to the subsection Emissions in the section Methods of the accompanying paper. The default request includes some frequent variables from all the sectors available on a grid format. The resolution of the grid depends on the kind of source of emissions. In our case, anthropogenic emissions are provided on a grid of 0.1° x 0.1°. The temporal resolution of the data is monthly. We converted them to daily using the Piecewise Hermite Cubic Interpolation technique. After, we have merged them. At the end, the output is one file containing daily observation on the same grid, ready to be spatially interpolated with the Air Quality localisations. Indeed, they will serve as input for Spatial Interpolation.R. The code makes extensive use of parallelisation via the <tt>doParallel</tt> and <tt>foreach</tt> packages. Other packages used are <tt>ecmwfr</tt>to interface with CDS web sevices <tt>ncdf4</tt> and <tt>ecmwfr</tt> for the extraction-data from netcdf files.

# Emissions.R Structure

The script is divided in sections (press Alt + o inside the R console to view it):
<ul>

<li><b>B.0. Data Download </b> makes the request to the Atmosphere Data Store (ADS) for emissions data. For this step you need an account on the <a href="https://atmosphere.copernicus.eu/data">ADS webpage</a>. 
In this section is possible to make the request for emissions from a large number of pollutants for all the globe. Not all the variables are used. To know which variables are kept in the Agrimonia porject the reader is referred to the Table 3 of the reference paper</li>. Data are downloaded using the package <tt>ncdf4</tt>.

<li><b>B.1. From netcdf to Points Dataframe</b> transforms the netcdf files obtained from the CDS service in long table of the format <i>x, y, t</i> through the function <i>getvarCAMS.R</i>. Emissions data from netcdf files can be extracted and converted to a long table format (<i>x,y,t</i>) using the <tt>ncdf4</tt> through the function <i>getvarCAMS.R</i>. For the purpose of the project AgrImOnIA we are intersted in ammonia, sulphur dioxide and nitrogen dioxide, the variables selected are listed in the Table 8 of the referring paper.
The process is made for each variables coming from different files so the section is divided in subsections:
<ul>
<li><b>B.1.1. ammonia </b> where the conversion is made for ammonia emissions</li>
<li><b>B.1.2. nitrogen dioxides</b> where the conversion is made for nitrogen dioxide emissions</li>
  <li><b>B.1.3. sulphur dioxides</b> where the conversion is made for sulphur dioxide emissions</li>
</ul></li>
After have merged them, the output of the section is a dataset with <i>n x t</i> rows where <i>n</i> is the number of cells of the grid and <i>t</i> the number of unit time in the period, and with columns equal to <i>p x s</i> where <i>p</i> is the number of pollutants and <i>s</i> the number of micro-sectors sources.  

  <li><b>B.2. From Monthly to Daily</b> where data are processed to get coherent long table to be used in the <i>Spatial Interpolation.R</i>. The section is divided in these subsections:
    <ul><li><b>B.2.1 add last month data & transformation of units of measure</b> starts transforming the value from kg*m<sup>-2</sup>*s<sup>-1</sup> to daily emission expressed as milligrams per meter square (mg*m<sup>-2</sup>*day<sup>-1</sup>) multiplying the original value for 10^6*86400. Then, in our data the last value is at the 1st December 2020. To get data until the 31st of December, because Agrimonia data covers the period 2016-2020 included, we have seen that this missing data was a challenge for the interpolation technique. So we have decided to estimate a value for the 31th December 2020 as the mean of the value associated to the 1st January of the other years (values are quite similar across years). </li>
      <li><b>B.2.2. Hermite spline</b> where the monthly long table is converted to daily long table using the Piecewise Hermite Cubic Interpolation technique. 
The process is explained and illustrated in the subsection <b>validation of EM and LI interpolation methods</b> in the section <b>Technical validation</b> of the referring paper.
      To do the temporal transformation, the script uses the function <tt>splinefun</tt>. It's possible to modify the resolution output. 
</li>

<li><b>B.2.3. plot original data VS reconstructed data from spline</b> is the subsection where a plot is generated to see the difference between the monthly data and the daily data. It uses <tt>ggplot2</tt>. </li> </ul>
