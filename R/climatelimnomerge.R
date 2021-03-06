#merging limno data and climate data into a single table for Shuai to use.  horizontal format here, but could switch to vertical if needed?

#merge by hu12, include all limno data but only include climate data for years where we have limno data for years and lakes where we have data for at least one limno variable (secchi tp chla or tn)

#from limno script, need dataframe lakes.limno (limno data, lakeid, year, hu12, hu4 identifiers, and lat long data in case we need it)
#from climate script, need 
#add a second year column to the limno data that is called "yearx1" to match the one with the modified yar in climate data, but it shoudl stay the same year so we can match them...

#for palmer data, need to merge separately by lagoslakeid, added that for updated data in December 2016 ater nick sent improved palmer data that are calculated by lake.

setwd("~/Dropbox/Sarah_Work/Manuscripts/2017_LAGOSClimateWaterqual/Data/Annual_monthly_calculated")

#updated the seasonal ones Dec 5th-6th - data should be same but fixed technical problem with code that was identified when modifying it for palmer data.

#updated with new limno 1.087.1 data Feb 10th - added a few hundred lakes per limno variable.

hu12.tmean.annual<-read.csv("hu12_tmean_annual.csv", header=T)
hu12.tmin.annual<-read.csv("hu12_tmin_annual.csv", header=T)
hu12.tmax.annual<-read.csv("hu12_tmax_annual.csv", header=T)
hu12.ppt.annual<-read.csv("hu12_ppt_annual.csv", header=T)
hu12.tmean.season<-read.csv("hu12_tmean_seasonal_updated.csv", header=T)
hu12.ppt.season<-read.csv("hu12_ppt_seasonal_updated.csv", header=T)


#separate out relevant columns and merge, add a second year column for x+1 that can be merged with the other year info to get previous years climate data with limno data (this seems like cheating but I was too lazy to figure out how to tell it to add each variable for year x-1 and this should work) Will just need to create a duplicate year column in the limno dataset that's called the same thing as the adjusted one here.

tmean.ann<-hu12.tmean.annual[,c(2:16)]
names(tmean.ann)<-c("hu12_zoneid", "year",  "January.tmean", "February.tmean", "March.tmean", "April.tmean",  "May.tmean", "June.tmean", "July.tmean", "August.tmean", "September.tmean", "October.tmean", "November.tmean","December.tmean", "tmean.annual")
tmin.ann<-hu12.tmin.annual[,c(2, 3, 16)]
names(tmin.ann)<-c("hu12_zoneid", "year", "tmin.annual")
tmax.ann<-hu12.tmax.annual[,c(2, 3, 16)]
names(tmax.ann)<-c("hu12_zoneid", "year", "tmax.annual")
tmean.seas<-hu12.tmean.season[,c(2,3,16:19)]
names(tmean.seas)<-c("hu12_zoneid", "year", "tmean.winter", "tmean.spring", "tmean.summer", "tmean.fall")
precip.ann<-hu12.ppt.annual[,c(2:16)]
names(precip.ann)<-c("hu12_zoneid", "year",  "January.ppt", "February.ppt", "March.ppt", "April.ppt",  "May.ppt", "June.ppt", "July.ppt", "August.ppt", "September.ppt", "October.ppt", "November.ppt","December.ppt", "precip.annual")
precip.seas<-hu12.ppt.season[,c(2,3,16:19)]
names(precip.seas)<-c("hu12_zoneid", "year", "ppt.winter", "ppt.spring", "ppt.summer", "ppt.fall")

annmeanmax<-merge(tmean.ann, tmax.ann, by=c("hu12_zoneid", "year"))
annmeanmaxmin<-merge(annmeanmax, tmin.ann, by=c("hu12_zoneid", "year"))
annseasont<-merge(annmeanmaxmin, tmean.seas, by=c("hu12_zoneid", "year"))
annseasontp<-merge(annseasont, precip.ann, by=c("hu12_zoneid", "year"))
annseasontpsp<-merge(annseasontp, precip.seas, by=c("hu12_zoneid", "year"))


annseasontpsp$yrx1<-annseasontpsp$year+1


#add indicies here too
phdi<-read.csv("phdi_with_seasonal.csv", header=T)

#pull out seasonal data only, re-name
phdi.seasons<-phdi[,c(16, 18:22)]
names(phdi.seasons)<-c("year", "lagoslakeid", "palmer.winter", "palmer.spring", "palmer.summer", "palmer.fall")
phdi.seasons$yrx1<-phdi.seasons$year+1

#wait to merge phdi into limno data later because it is calculated by lagoslakeid

setwd("~/Dropbox/Sarah_Work/Manuscripts/2017_LAGOSClimateWaterqual/Data/Climate_raw")

nao<-read.csv("NAO.csv", header=T)
enso<-read.csv("ENSO_INDEX.csv", header=T)

##ENSO and NAO have monthly data, but for now, just aggregate by year.  
##PDSI is by state, tried to get that to work but it was a pain in the ass, figure out later...

annual.enso = aggregate(enso[,c("ESPI")], by=list(enso$Year), FUN="mean")
names(annual.enso)<-c("year", "enso.espi")

climate.enso<-merge(annseasontpsp, annual.enso, by="year")

annual.nao = aggregate(nao[,c("NAO_INDEX")], by=list(nao$YEAR), FUN="mean")
names(annual.nao)<-c("year", "nao.index")

climate.all<-merge(climate.enso, annual.nao, by="year")

#add in limno data and palmer data
head(lakes.limno)
lakes.limno$yrx1<-lakes.limno$year
climate.yearx<-climate.all[,c(1:10,15:20,22:29,34:37,40:41)]
climate.yearx1<-climate.all[,c(2, 11:17, 21,30:34,38:41)]
names(climate.yearx1)<-c("hu12_zoneid", "September.tmean.x1","October.tmean.x1", "November.tmean.x1", "December.tmean.x1", "tmean.annual.x1", "tmax.annual.x1", "tmin.annual.x1", "tmean.fall.x1", "September.ppt.x1", "October.ppt.x1", "November.ppt.x1", "December.ppt.x1", "precip.annual.x1", "ppt.fall.x1", "yrx1", "enso.espi.x1", "nao.index.x1")

limno.climatex<-merge(lakes.limno, climate.yearx, by=c("hu12_zoneid", "year"), all.x=TRUE, all.y=FALSE)
limno.allclimate<-merge(limno.climatex, climate.yearx1, by=c("hu12_zoneid", "yrx1"), all.x=TRUE, all.y=FALSE)

palmer.yearx<-phdi.seasons[,c(1:5)]
palmer.yearx1<-phdi.seasons[,c(2,6:7)]
names(palmer.yearx1)<-c("lagoslakeid", "palmer.fall.x1", "yrx1")

limno.all.climate.palmerx<-merge(limno.allclimate, palmer.yearx, by=c("lagoslakeid", "year"), all.x=TRUE, all.y=FALSE)
limno.all.climate.palmer<-merge(limno.all.climate.palmerx, palmer.yearx1, by=c("lagoslakeid", "yrx1"), all.x=TRUE, all.y=FALSE)
limno.all.climate.palmer$yrx1=NULL


setwd("~/Dropbox/Sarah_Work/Manuscripts/2017_LAGOSClimateWaterqual/Data/SummaryforShuai/updated_feb2017")
write.csv(limno.all.climate.palmer, "ClimateCompiled_1.087_updated_Feb2017_summer.csv")

##did not update monthly data with 1.087 because no plans to use it in future analysis
#merge climate data with June, July and Aug data to make three additional files for Shuai for separate monthly analyses
lakes.limno.june$yrx1<-lakes.limno.june$year
lakes.limno.july$yrx1<-lakes.limno.july$year
lakes.limno.aug$yrx1<-lakes.limno.aug$year

limno.june.climatex<-merge(lakes.limno.june, climate.yearx, by=c("hu12_zoneid", "year"), all.x=TRUE, all.y=FALSE)
limno.june.allclimate<-merge(limno.june.climatex, climate.yearx1, by=c("hu12_zoneid", "yrx1"), all.x=TRUE, all.y=FALSE)
limno.june.all.climate.palmerx<-merge(limno.june.allclimate, palmer.yearx, by=c("lagoslakeid", "year"), all.x=TRUE, all.y=FALSE)
limno.june.all.climate.palmer<-merge(limno.june.all.climate.palmerx, palmer.yearx1, by=c("lagoslakeid", "yrx1"), all.x=TRUE, all.y=FALSE)
limno.june.all.climate.palmer$yrx1=NULL

write.csv(limno.june.all.climate.palmer, "ClimateCompiled_1.054_updated_Dec2016_june.csv")

limno.july.climatex<-merge(lakes.limno.july, climate.yearx, by=c("hu12_zoneid", "year"), all.x=TRUE, all.y=FALSE)
limno.july.allclimate<-merge(limno.july.climatex, climate.yearx1, by=c("hu12_zoneid", "yrx1"), all.x=TRUE, all.y=FALSE)
limno.july.all.climate.palmerx<-merge(limno.july.allclimate, palmer.yearx, by=c("lagoslakeid", "year"), all.x=TRUE, all.y=FALSE)
limno.july.all.climate.palmer<-merge(limno.july.all.climate.palmerx, palmer.yearx1, by=c("lagoslakeid", "yrx1"), all.x=TRUE, all.y=FALSE)
limno.july.all.climate.palmer$yrx1=NULL

write.csv(limno.july.all.climate.palmer, "ClimateCompiled_1.054_updated_Dec2016_july.csv")

limno.aug.climatex<-merge(lakes.limno.aug, climate.yearx, by=c("hu12_zoneid", "year"), all.x=TRUE, all.y=FALSE)
limno.aug.allclimate<-merge(limno.aug.climatex, climate.yearx1, by=c("hu12_zoneid", "yrx1"), all.x=TRUE, all.y=FALSE)
limno.aug.all.climate.palmerx<-merge(limno.aug.allclimate, palmer.yearx, by=c("lagoslakeid", "year"), all.x=TRUE, all.y=FALSE)
limno.aug.all.climate.palmer<-merge(limno.aug.all.climate.palmerx, palmer.yearx1, by=c("lagoslakeid", "yrx1"), all.x=TRUE, all.y=FALSE)
limno.aug.all.climate.palmer$yrx1=NULL

write.csv(limno.aug.all.climate.palmer, "ClimateCompiled_1.054_updated_Dec2016_august.csv")


##THERE ARE 170 ROWS OF NAS FOR THE OUT OF HU12 LAKES, NEED TO ADD CODE TO DELETE THESE FOR NEXT TIME ;)
