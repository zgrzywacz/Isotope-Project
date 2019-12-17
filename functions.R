noaaGet <- function(station, dtype, beginyr, endyr){ 
  Values <- vector(mode="list",length=1)
  for (year in seq(beginyr, endyr)){
    stDate <- paste0(year, "-01-01")
    endDate <- paste0(year, "-12-31")
    Tdat <- ncdc(datasetid='GSOM', stationid = station, datatypeid=dtype, startdate = stDate, enddate = endDate, limit = 100, add_units=TRUE)
    name <- paste0(dtype, year)
    Values[[name]] <- Tdat[[2]]
  }
  totyr <- (endyr - beginyr + 2)
  Combined <- rbind(Values[[2]], Values[[3]])
  for (num in 4:totyr){
    Combined <- rbind(Combined, Values[[num]])
  }
  return(Combined)
}

isoTempPrecip <- function(iso, temp, precip){
  temp$date <- strtrim(temp$date, 10)
  precip$date <- strtrim(precip$date, 10)
  zooIso <- zoo(iso[,c(17)], as.Date(iso[, 14]))
  zooTemp <- zoo(temp[,4], as.Date(temp$date))
  zooPrecip <- zoo(precip[,4], as.Date(precip$date))
  IsoTimeSeries <- merge(zooTemp, zooPrecip, zooIso, all=FALSE)
  colnames(IsoTimeSeries) <- c("Temp","Precip","O18")
  return(IsoTimeSeries)
}

IsoCompare <- function(first, second, third=NULL, fourth=NULL, fifth=NULL){
  zooIso1 <- zoo(first[,c(17)], as.Date(first[, 14]))
  zooIso2 <- zoo(second[,c(17)], as.Date(second[, 14]))
  IsoCombined <- merge(zooIso1, zooIso2)
  if(!is.null(third)){
    zooIso3 <- zoo(third[,c(17)], as.Date(third[, 14]))
    IsoCombined <- merge(IsoCombined, zooIso3)
  }
  if(!is.null(fourth)){
    zooIso4 <- zoo(fourth[,c(17)], as.Date(fourth[, 14]))
    IsoCombined <- merge(IsoCombined, zooIso4)
  }
  if(!is.null(fifth)){
    zooIso5 <- zoo(fifth[,c(17)], as.Date(fifth[, 14]))
    IsoCombined <- merge(IsoCombined, zooIso5)
  }
  return(IsoCombined)
}