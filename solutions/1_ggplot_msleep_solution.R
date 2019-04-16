# WZB geo-data workshop
# solution for exercise 1: For those new to ggplot: Making a scatterplot
# April 2019, Markus Konrad <markus.konrad@wzb.eu>

library(ggplot2)

# to have a look at the dataset
head(msleep)
?msleep

# sleep against bodyweight on scatterplot, with color dependent on "vore"
# x on log10 scale
ggplot(msleep, aes(x = bodywt, y = sleep_total, color = vore)) +
    scale_x_log10() +
    geom_point()