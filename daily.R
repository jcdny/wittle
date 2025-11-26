source("util.R")

DATA <- dataDir()

W <- 3840
H <- 2160
SZ <- 44
LSZ <- 2

DAYS <- 7

x <- ts.load.from(today() - DAYS - 1)
x <- ts.adjustments(x)
x <- ts.debias(x)

GENAFTER <- today() - 1
GENFROM  <- today() - DAYS

result <- x %>% group_by(day) %>% group_map(function(x,..) {
    day <- date(x$dt[1])
    outf <- paste0(DATA, "/graphs/", date(x$dt[1]), ".png")
    if (day < GENFROM
        || (file_test("-f", outf) && day < today() - 1)) {
	## cat(outf, " skipping\n")
    } else {
        ## stop generating breaks
        ## ii <- which(abs(diff(runmed(x$x,9))) > .03)

	ii <- c()
        png(file=outf, width=W, height=H)
        g <- ggplot(x, aes(x=dt,y=runmed(x,121))) +
            geom_line(linewidth=LSZ) +
            geom_line(aes(y=runmed(x,5)), alpha=.2) +
            geom_line(aes(y=adj.x), color="blue") +
            ylim(-.1,1.3)  +
            xlab(date(x$dt[1])) +
            ylab("Tilt") +
            theme_classic(base_size = SZ)
        if (any(ii)) {
            g <- g + geom_vline(data=x[ii,], aes(xintercept=dt), color="red")
        }

        print(g)
        dev.off()
    }
}, .keep=FALSE)

