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

# turn year into a factor and type into a factor
data <- transform(NEI, year = factor(year), type = factor(type))
baltimore <- data[data$fips == '24510',]

# again we need to use grep to find all vehicle cases
# NOTE, must have ignore case set to true otherwise I'll end up with no observations
vehicles <- as.data.frame( SCC[grep("vehicles", SCC$SCC.Level.Two,ignore.case=T), 1])

# name this frame SCC so we can merge it back into our baltimore data
names(vehicles) <- "SCC"
baltimore <- merge(vehicles, baltimore, by = "SCC")

# now do our default grouping and sum the emissions
pd <- ddply(baltimore, .(year), summarize, sum = sum(Emissions))
png("plot5.png")
p <- ggplot(pd, aes(year, sum))
p + geom_point(size=4) + labs(title="Baltimore Emissions", y="Total Emissions")
dev.off()