library(lubridate)
library(ggplot2)
library(readr)

x <- read.csv("~/src/wittle/data/all.csv")
x$dt <- ymd_hms(x$dt)
ggplot(x, aes(x=dt,y=x)) + geom_line()
ii <- which(hour(x$dt) %in% 23)
ggplot(x[ii,], aes(x=dt,y=x)) + geom_line()

W <- 1080
H <- 1350
SZ <- 44
LSZ <- 2

jpeg(filename="a.jpg", width=W, height=H)
ii <- which(hour(x$dt) %in% 19)
ggplot(x[ii,], aes(x=dt,y=x)) + geom_line(linewidth=LSZ) +
    xlab("Time") + ylab("Tilt (deg)") +
    theme_classic(base_size = SZ)
dev.off() + theme_classic(base_size = SZ)

jpeg(filename="b.jpg", width=W, height=H)
ii <- which(hour(x$dt) %in% 23)
ggplot(x[ii,], aes(x=dt,y=x)) + geom_line(linewidth=LSZ) +
    xlab("Time") + ylab("Tilt (deg)") +
    theme_classic(base_size = SZ)
dev.off()

jpeg(filename="c.jpg", width=W, height=H)
ii <- which(hour(x$dt) %in% 19:23)
ggplot(x[ii,], aes(x=dt,y=x)) + geom_line(linewidth=LSZ) +
    xlab("Time") + ylab("Tilt (deg)") +
    theme_classic(base_size = SZ)
dev.off()

