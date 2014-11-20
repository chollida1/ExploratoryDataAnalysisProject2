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

data <- ddply(data, .(year), summarize, sum = sum(Emissions))
png("plot1.png")
plot(data$year, data$sum, type="n", xlab="year", ylab="total PM Emissions")
dev.off()