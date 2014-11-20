if(!require("plyr")){
  install.packages("plyr")
  library(plyr)
}

if(!require("reshape2")){
  install.packages("reshape2")
  library(reshape2)
}

if(!require("ggplot2")){
  install.packages("ggplot2")
  library(ggplot2)
}

# download the raw data
if(!file.exists("exdata-data-NEI_data.zip")) {
  t <- tempfile()
  download.file("http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip", t)
  unzip(t)
}

# read in our data set
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# turn year into a factor
data <- transform(NEI, year = factor(year))

# find emmisions from combustion, this is a bit tricky as it isn't just a simple column lookup
# we'll need to use a regex to match
combustion.emissions <-as.data.frame(SCC[grep("combustion",SCC$SCC.Level.One, ignore.case = T)
    & grep("coal", SCC$SCC.Level.Three, ignore.case = T), 1])

# now set the name so we can use the merge command to group our combustion.emisions data and 
# the original data set
names(combustion.emissions) <- "SCC"
emissions.data <- merge(combustion.emissions, data, by = "SCC")

# now do our default grouping and sum the emissions
summed.emmissions <- ddply( emissions.data, .(year), summarize, sum = sum(Emissions))
png("plot4.png")
p <- ggplot(summed.emmissions,aes(year,sum))
p + geom_point(size = 4) + labs(title="Emissions from coal combustion", y = "Total Emission")
dev.off()