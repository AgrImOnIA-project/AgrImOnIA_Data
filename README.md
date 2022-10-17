# Agrimonia dataset

The AgrImOnIA dataset is a comprehensive dataset relating air quality and livestock (expressed as the density of bovines and swine bred) along with weather and other variables. This dataset is a collection of estimated daily values for a range of measurements of different dimensions as: air quality, meteorology, emissions, livestock animals and land use. Data are related to Lombardy and the surrounding area for 2016-2021, inclusive. The surrounding area is obtained by applying a 0.3° buffer on Lombardy borders. The data uses several aggregation and interpolation methods to estimate the measurement for all days. 

# Programming languages used

Air Quality and Livestock data are pre-processed using MATALAB. Weather, Emissions and Land data are pre-processed using R as well as the spatial interpolations and the final merging.

Programming language varies according to the preference of who has worked on it.

# Repositery overview

These scripts are used in the AgrImOnIA_Dataset building process. In particular the repositery contains:

<ul>
<li><b>AQ_LI_import_temporal_transformation</b></li>
  <ul>
    <li><b>Data_AQ</b></li>
    <ul>
      <li><b>EEAFunctions</b></li>
      <ul>
        <li><b>functions</b></li>
        <ul>
          <li>EEADownload.m</li>
          <li>EEAImportMetadata.m</li>
          <li>EEAImportfile.m</li>
          <li>EEAMerge.m</li>
          <li>EEAReshape.m</li>
          <li>EEAVocabularyImport.m</li>
          <li>SSMHourly2Daily.m</li>
          <li>gaps.m</li>
        </ul>
      </ul>
      <li>AQDatabase.m</li>
      <li>AQHourly2Daily.m</li>
    </ul>
    <li><b>Data_BDN</b></li>
    <ul>
      <li><b>BDNFunction</b></li>
      <ul>
        <li>importBDRBovinifile.m</li>
        <li>importBDRSuinifile.m</li>
        <li>importComunifile.m</li>
      </ul>
      <li>BDNCreateDataset.m</li>
      <li>BDNDailySpline.m</li>
    </ul>
  </ul>
  <li><b>WE_EM_import_temporal_transformation</b></li>
  <ul>
    <li><b>Data_WE</b></li>
    <ul>
      <li>Weather.R</li>
    </ul>
    <li><b>Data_EM</b></li>
    <ul>
      <li>Emissions.R</li>
    </ul>
    <li><b>Funtions</b></li>
    <ul>
      <li><b>ERA5function</b></li>
      <ul>
        <li>ERA5LandSinglePressure.R</li>
        <li>ERA5_Land_fromHourlytoDaily.R</li>
        <li>ERA5_RelativeHumidity.R</li>
        <li>ERA5_SL_fromHourlytoDaily.R</li>
        <li>ERA5datadownload.R</li>
        <li>ERA5netcdftopoints.R</li>
        <li>Notin.R</li>
        <li>getmode.R</li>
        <li>ma.R</li>
      </ul>
      <li><b>CAMSFunctions</b></li>
      <ul>
        <li>Notin.R</li>
        <li>ma.R</li>
        <li>getmode.R</li>
        <li>getvarCAMS.R</li>
      </ul>
    </ul>
  </ul>
    <li><b>AQ_WE_EM_LI_LA_spatial_interpolation</b></li>
    <ul>
      <li>AQinterp.R</li>
      <li>AQinterpPARALLEL.R</li>
      <li>Spatial Interpolation.R</li>
    </ul>
    <li><b>Merging</b></li>
    <ul>
      <li>Final Merging.R</li>
    </ul>
  </ul>
</ul>
For details about every script the user is referred to the README.md in each folder.
# Building steps

The building process for the AgrImOnIA Dataset follows this order:
1. download air quality data using the script: AQDatabase.m
2. transform from hourly observations to daily using the script: AQHourly2Daily.m
3. download weather data, convert them from hourly to daily with different ensemble criteria, merge them: Weather.R
4. download emission data, convert them from monthly to daily with Hermite spline: Emissions.R
5. convert time series of livestock variables from bi-annual to daily using the script: BDNDailySpline.m 
6. make the spatial interpolation between AQ localisations and variables through the script: Spatial Interpolation.R
7. merge all the dataset interpolated (es AQ_WE + AQ_EM + AQ_LA + etc) using the ID of stations as key, the script is: Final Merging.R

# Further developments

The final dataset, already published on Zenodo ([link](https://zenodo.org/record/6620530#.Y0mG0dfP0Q8)), represents the first step of the AgrImOnIA project. The purpose of this data set is to give the opportunity to assess the impact of agriculture on air quality in Lombardy through statistical techniques capable of highlighting the relationship between the livestock sector and air pollutants concentrations.
