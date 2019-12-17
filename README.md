#GEOG693 Final Project  

In this project, I created a set of R functions that can read in monthly climate data from NOAA's NCDC database, and then combine that data with monthly IAEA isotope composition data to perform time-series comparisons. I have also included loops and sets of code that can assist with streamlining data gathering and wrangling.   

##Getting Started  
  
To start, clone this repository to your local environment in Rstudio.
This repo contains:
-This README.md
-The functions created (functions.R)
-A .Rprofile that contains the rnoaa API key
-IsotopeData, a folder of the isotope data for the sites I'm observing.

Unfortunately, wget does not work with the IAEA's WISER portal that contains the isotope data, and there is no API publicly available to use with it. If there are any other sites that you wish to observe, you may add them to this folder for use with the loops I've created to read the isotope data into R.
  
###Prerequisites  

If you do not have the packages "zoo', "ggplot2", or "rnoaa", install those on your machine.
 
```{r}
install.packages('zoo')
install.packages('ggplot2')
install.packages('rnoaa')
```

In addition, you will need a .Rprofile that contains a rnoaa key. I have included my own in this repository, so whenever it's opened up it will run, but if you have your own that will work as well.

###Library and Source Functions  

Ready your machine to use the packages that were just downloaded by using library()

```{r}
library(rnoaa)
library(zoo)
library(ggplot2)
```
In addition, all of the functions that I have created are in the file "functions.R". Sourcing that file will be necessary to add the functions to your environment.

```{r}
source("functions.R")
```

Finally, you can read in the isotope data to your environment using this simple loop, which names each file based on its filename in the folder

```{r}
data.path <- "./IsotopeData/" #defines path to isotope data
glob.path <- paste0(data.path, "*", ".csv") #adds wildcard to path to account for all files
dataFiles <- Sys.glob(glob.path) #creates a variable containing the names of all files in the folder
for(x in 1:length(dataFiles)){ #Loops based on the number of files in the folder
  temporaryFile <- read.csv(dataFiles[x]) #reads data to a temporary storage file
  assign(basename(dataFiles[x]), temporaryFile) #renames each file based on its basename
}
rm(temporaryFile) #deletes the temporary storage file for a cleaner environment
```

##Packages  

I will now describe the functions that I've created, to give insight into how they work and how they should be used.

###noaaGet  

This is a function that, using rnoaa, will collect monthly NCDC data (from a given site, data type, and year range) and return it in a single, usable dataframes, as opposed to a list of dataframes for each year. The rationale behind this tool is that it will do most of the painful processing of multiple rnoaa files automatically.

The inputs to the function are station, dtype, beginyr, and endyr. "station" should be an rnoaa station ID in quotes, such as 'GHCND:CI000085799'. "dtype" should be a NCDC GSOM valid data type, such as 'PRCP', 'TAVG','TMAX', or 'TMIN'. Finally, "beginyr" and "endyr" will define the data range that you want to select.

```{r}
noaaGet <- function(station, dtype, beginyr, endyr){ 
  Values <- vector(mode="list",length=1) #creates a list to temporarily store each ncdc() output
  for (year in seq(beginyr, endyr)){ #loops through each year in the date range given
  stDate <- paste0(year, "-01-01") #turns beginyr into valid date format for ncdc()
  endDate <- paste0(year, "-12-31") #turns endyr into valid date format for ncdc()
 Tdat <- ncdc(datasetid='GSOM', stationid = station, datatypeid=dtype, startdate = stDate, enddate = endDate, limit = 100, add_units=TRUE) #pulls data from NOAA for the given year
 name <- paste0(dtype, year) 
  Values[[name]] <- Tdat[[2]] #stores data in Values
  }
  totyr <- (endyr - beginyr + 2) #Tallies total number of years in the date range
Combined <- rbind(Values[[2]], Values[[3]]) #Begins the process fo combining the list of dataframes into a single data frame
  for (num in 4:totyr){ #Combines each year to the base data frame
    Combined <- rbind(Combined, Values[[num]])
  }
return(Combined)
}
```
When used correctly, the ouptut should be a single data frame of NCDC data for the year range given.

###IsoTempPrecip

This function creates a time series dataset using the package 'zoo' that contains precipitation, temperature, and O18 isotope values for each month at the given site. In essence, this tool combines the rnoaa data with the IAEA data in a more workable format that can be used with plotting and time series analysis packages. 

The inputs to this package are iso, temp, and precip. "iso" should be a data frame of IAEA data loaded in using the loop described above. "temp" and "precip" should be average temperature and precipitation datasets gathered using noaaGet. All three datasets should be from the same site for any meaningful analysis

```{r}
isoTempPrecip <- function(iso, temp, precip){ 
  temp$date <- strtrim(temp$date, 10) #alters the dates in the 'temp' file for efficient merging
  precip$date <- strtrim(precip$date, 10) #alters the dates in the 'precip' file for efficient merging
  zooIso <- zoo(iso[,c(17)], as.Date(iso[, 14])) #turns O18 data into a zoo file
  zooTemp <- zoo(temp[,4], as.Date(temp$date)) #turns temperature data into a zoo file
  zooPrecip <- zoo(precip[,4], as.Date(precip$date)) #turns precip data into a zoo file
  IsoTimeSeries <- merge(zooTemp, zooPrecip, zooIso, all=FALSE) #merges all three datasets into a singular time series
  colnames(IsoTimeSeries) <- c("Temp","Precip","O18") #names columns
  return(IsoTimeSeries)
}
```
The result should be a singular time series dataset that includes a value for O18, temperature, and precipitation at each point in time.

###IsoCompare

This function can be used to compare isotope records at different sites over time. This can be used to see if changes in O18 at one location are mirrored at another, or to glean general patterns over a location gradient.

This function requires between 2 and 5 input datasets for comparison. All inputs should be IAEA isotope data frames that have been read into the environment using the loop described in the beginning of this file.

```{r}
IsoCompare <- function(first, second, third=NULL, fourth=NULL, fifth=NULL){ #By making third, fourth, and fifth = NULL, the default input is NULL, therefore the function can run with only two inputs.
  zooIso1 <- zoo(first[,c(17)], as.Date(first[, 14])) #turns first dataset into a zoo file
  zooIso2 <- zoo(second[,c(17)], as.Date(second[, 14])) #turns second dataset into a zoo file
  IsoCombined <- merge(zooIso1, zooIso2) #merges zoo files
  if(!is.null(third)){ #if a third value is given, the following actions are performed
    zooIso3 <- zoo(third[,c(17)], as.Date(third[, 14])) ##turns third dataset into a zoo file
    IsoCombined <- merge(IsoCombined, zooIso3) #merges zoo files
  }
  if(!is.null(fourth)){ #if a fourth value is given, the following actions are performed
    zooIso4 <- zoo(fourth[,c(17)], as.Date(fourth[, 14])) #turns fourth dataset into a zoo file
    IsoCombined <- merge(IsoCombined, zooIso4) #merges zoo files
  }
  if(!is.null(fifth)){ #if a fifth value is given, the following actions are performed
    zooIso5 <- zoo(fifth[,c(17)], as.Date(fifth[, 14])) #turns fifth dataset into a zoo file
    IsoCombined <- merge(IsoCombined, zooIso5) #merges zoo files
  }
  return(IsoCombined)
}
```

The product of this function should be a single time series dataset that includes a value for O18 at each site over time.

##Usage and Loops  

Assuming that you've already run the loop in the beginning to load in the IAEA files, it's time to use noaaGet to grab our climate data. For best use, copy these loops into the R console, or the .Rmd file you are using.

The first thing to do is to make a vector containing our station IDs. Here, I will name them to make it more clear which site corresponds to each location.

```{r}
sites <- c('GHCND:CI000085799','GHCND:SHM00068906','GHCND:SF000068994','GHCND:ASN00091245','GHCND:ASN00094125')
names(sites) <- c('PuertoMontt','Gough','Marion','CapeGrim','Margate')
sites
```
Output:

```
 PuertoMontt               Gough              Marion            CapeGrim 
"GHCND:CI000085799" "GHCND:SHM00068906" "GHCND:SF000068994" "GHCND:ASN00091245" 
            Margate 
"GHCND:ASN00094125" 
```

Now, I will use a loop to go through each of these sites and gather both PRCP and TAVG (precipitation and average temperature) for each one, from 1980 to 2018. Each file will be named based on its location and data type.
The advantage to using this loop is that you don't have to use noaaGet 10 times to gather all of this data. It may take a minute, given the large amount of data being requested.

```{r}
for (x in 1:length(sites)){ #loop through each element in 'sites'
  for (y in c('PRCP','TAVG')){ #gathers both precip and temperature data
    DataTemp <- noaaGet(sites[[x]], y, 1980, 2018) #gets data for the given site and data type
    assign(paste0(names(sites[x]),y), DataTemp) #uniquely renames each file
  }
}
rm(DataTemp)
```

This loop can be reproduced with other sites, assuming the structure of the 'sites' vector remains the same.

Now that both climate data and isotope data are present, we can use IsoTempPrecip to compare them for each site. Here, I will produce a time series for the site Cape Grim.

```{r}
CG_series <- isoTempPrecip(gnip_capegrim.csv, CapeGrimTAVG, CapeGrimPRCP)
head(CG_series)
```
Output: 

```
           Temp Precip   O18
1985-09-01 10.56   18.2 -3.67
1985-10-01 12.02   66.2 -1.84
1985-11-01 13.42   90.4 -4.79
1985-12-01 15.63   89.2 -3.23
1986-01-01 15.10   24.2 -2.70
1986-02-01 15.45   22.4 -2.35
```
Note that the output does not start until 1985. IsoTempPrecip does not include years where any of the variables have only NA values (that is, NAs for all 12 months). This helps reduce gaps in the data.

Zoo includes an autoplot.zoo feature that works with ggplot2. However, given this dataset, it does not work well; the axes are all the same and should be different, given the values of the variables.

In this case, you can manually use ggplot to create graphs that give more insight.

```{r}
ggplot(fortify(CG_series, melt=TRUE), aes(x = Index, y = Value, ylab="Date")) + geom_line(aes(color = Series)) + 
      facet_grid(Series ~ ., scales = "free_y") + theme(legend.position = "none") +
      labs(x="Date", y="Value")
```

This visualization allows us to see some trends in the data, such as a spike in O18 lines up with a low point for precipitation.

Now, we can use IsoCompare to compare O18 across sites

```{r}
isoSites <- IsoCompare(gnip_puertomontt.csv, gnip_goughisland.csv, gnip_marionisland.csv, gnip_capegrim.csv, gnip_margate.csv)
colnames(isoSites) <- c("PuertoMontt","Gough","Marion","CapeGrim","Margate")
head(isoSites)
```
Output: 

```
           PuertoMontt Gough Marion CapeGrim Margate
1960-01-01          NA    NA     NA       NA      NA
1960-02-01          NA    NA     NA       NA      NA
1960-03-01          NA    NA     NA       NA      NA
1960-04-01          NA    NA     NA       NA      NA
1960-05-01          NA    NA     NA       NA      NA
1960-06-01          NA    NA     NA       NA      NA
```

In IsoCompare, I did not set all=FALSE, which would remove years where sites have only NA values. This is because some of the isotope sites have significant gaps in the data, and removing these years would limit the years available for analysis significantly. 

Because these values are so similar, we can use autoplot.zoo to get a good idea of how the sites compare. 

```{r}
autoplot.zoo(isoSites, facets = Series~ .)
```

This date range does look significantly large for analysis. Luckily, we can limit it to a range where most sites are available using window()

```{r}
isoWindow <- window(isoSites, start="1992-01-01", end="1999-12-31")
autoplot.zoo(isoWindow, facets = Series~ .)
```

Here, it is much easier to visualize any trends or oddities - such as the late 1997 spike at Cape Grim and Puerto Montt (both land sites), whereas the ocean island sites Gough and Marion remained relatively stable.

##Future Work

In the future, using these tools I've created as a base, I look to integrate time series analysis using R packages such as 'forecast' and 'deseasonalize'. I made an attempt, but it quickly became apparent that using these packages requires a greater knowledge of time series. It would be very useful to deseasonalize the temperature data, or interpolate values to fill some of the gaps present in the more complete datasets.

##Author

Zack Grzywacz, West Virginia University

##Acknowledgements

Dr. Amy Hessl, instructor for GEOG693, West Virginia University 