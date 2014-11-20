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

# join data from Baltimore and Los Angeles
data <- data[data$fips == "24510" | data$fips == "06037",]

# again we need to use grep to find all vehicle cases
# NOTE, must have ignore case set to true otherwise I'll end up with no observations
vehicles <- as.data.frame( SCC[grep("vehicles", SCC$SCC.Level.Two,ignore.case=T), 1])
names(vehicles)<-"SCC"
data <- merge(vehicles, data, by = "SCC")

# now we label our city data so that it shows up properly on the plot
data$city[data$fips == "24510"] <- "Baltimore"
data$city[data$fips == "06037"] <- "LosAngeles"

# now group by year and city
baltimore.la <- ddply(data, .(year, city), summarize, sum = sum(Emissions))
png("plot6.png")
p <- ggplot(baltimore.la, aes(year, sum))
# we color the city emissions so we can tell them apart
p + geom_point(size = 10, aes(color = city)) + labs(title = "Motor Vehicle Emissions", y = "Total Emissions")
dev.off()