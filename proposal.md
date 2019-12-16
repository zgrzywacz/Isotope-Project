# Isotope-Project
Final project for GEOG693

## Objectives  
My aim is to analyze the relationship between δ18O isotope precipitation values and climate data at two sites in Tasmania, Australia. I will be doing paleoclimate research in this area and I wish to give recent context to the data that I will be collecting. 
  
## Data Sources  
δ18O data will be collected from the IAEA through their WISER portal at https://nucleus.iaea.org/wiser/index.aspx. There are two historical monthly records of isotope data available in Tasmania here, in Cape Grim from 1979-2002 and in Hobart from 1994-2000.  
  
Monthly temperature and precipitation data for Hobart and Cape Grim will be collected from the Australian Bureau of Meteorology at http://www.bom.gov.au/climate/data/. I will collect data from two sites: Ellerslie Road in Hobart, and Marrawah. There is data available in Cape Grim, but it is incomplete and does not cover the entire period of isotope data available; therefore, I will use Marrawah climate data, which is in a comparable location and follows similar trends.

Kevin also suggested that we look at sea surface temperatures from the 'source' area of moisture (west of Tasmania).  This would require a spatial analysis.  It would be an excellent add on for Dr. Maxwell's class next semester.
  
## Languages Used  
I will use bash to download the data and wrangle it into the right formats for my analysis. From there, I plan to use R to perform statistical analyses on the data.  
  
## Implementation  
I plan to plot δ18O against monthly values of mean max temperature, mean minimum temperature, and rainfall accumulation. I will perform a correlation in R for all of these relationships and compare them. I will also create month-to-month averages across all data, building a model of the average yearly trends in climate and isotope data in Tasmania. I will use ggplot for my graphs to create clean, easy-to-interpret figures.  

Because δ18O values of precipitation change so much seasonally, I recommend learning how to de-seasonalize the data prior to running the correlations.
  
## Expected Products  
-Correlation plots for: δ18O vs. mean max temperature; δ18O vs. mean min temperature; δ18O vs. rainfall in mm.  
-A plot of month-to-month averages for all measures  
-A bash script and an R script that can produce the same products for different sites  
  
## Questions for Instructor  
Even though the Cape Grim climate data is incomplete, should I use that instead of Marrawah data? The minimum and maximum temperature means are very similar. Precipitation data is slightly different, but follows a similar month-to-month trend 

Hmmmm.  I wonder if a reanalysis product could be added to your analysis. Or BOM australia also has [gridded data](http://www.bom.gov.au/climate/averages/climatology/gridded-data-info/gridded-climate-data.shtml).

If I could add more to this project, I would compare the Tasmania isotope data to that of regions with similar climate conditions. Should I do this? If so, what locations should I consider?  

This is a great idea!  What other sites exist at the same latitudes, west coast (either hemisphere)?
  
Are there any other statistical measures I should use? Do you know of any statistical packages that would be helpful to me?

There are some time series analysis packages that might be useful for dealing with the seasonality - try R package zoo first.
