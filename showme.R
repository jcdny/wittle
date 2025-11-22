source("util.R")

tic("read all")
x <- ts.load()
toc()

tide <- read_csv("tides.csv.gz")

if (any(is.na(x$dt))) {
    x <- x[-which(is.na(x$dt)), ]
}
x <- ts.adjustments(x)
x <- ts.debias(x)

g <- list()

g[["full-pitch"]] <- ggplot(x, aes(x=dt,y=runmed(x,201))) + geom_line() +
    geom_line(aes(y=runmed(adj.x,121)), color="blue") +
    ylab("Tilt (degrees)") +
    ylim(-.5, NA) +
    xlab("Date") + ggtitle("Pitch")

if (interactive()) {
    print(g[1])
}

g[["full-roll"]] <- ggplot(x, aes(x=dt,y=runmed(y,201))) + geom_line() +
    geom_line(aes(y=runmed(adj.x,121)), color="blue") +
    ylab("Tilt (degrees)") +
    ylim(-1.0, NA) +
    xlab("Date") + ggtitle("Roll")

if (interactive()) {
    print(g[["full-roll"]])
}

df <- rbind(data.frame(dt=x$dt, tilt=x$x, adj=x$adj.x, axis="Pitch")
          , data.frame(dt=x$dt, tilt=x$y, adj=x$adj.y, axis="Roll")
          , data.frame(dt=tide$dt, tilt=tide$pred, adj=NA,axis="Tide")
            )

max.dt <- max(x$dt, na.rm=TRUE)

## Do a short and medium history graph
ll <- list(short=c(3,1), medium=c(7,2), long=c(28,14))

for (nm in names(ll)) {
    dd.s <- ll[[nm]][1]
    dd.e <- ll[[nm]][2]

    ii <- which(df$dt > (max.dt - ddays(dd.s)) & df$dt < max.dt + ddays(dd.e))

    df.g <- df[ii,]

    df.lt <- df.ht <- df.g[df.g$axis == "Tide",]
    df.ht$tilt[df.ht$tilt < 5.3] <- NA
    df.lt$tilt[df.lt$tilt > 1] <- NA

    g[[nm]] <- ggplot(df.g[df.g$axis != "Tide",], aes(x=dt,y=runmed(tilt, 201))) +
        geom_line(linewidth=1.2) +
        geom_line(data=df.g[df.g$axis != "Tide",], aes(y=tilt), alpha=.3) +
        geom_line(data=df.g[df.g$axis == "Tide",], aes(y=tilt)) +
        geom_line(data=df.ht, aes(y=tilt), color="Red", linewidth=1.2) +
        geom_line(data=df.lt, aes(y=tilt), color="Green", linewidth=1) +
        ylab("") +
        xlab("Date") +
        facet_wrap(~ axis, ncol=1, scales="free_y")

    if (interactive()) {
        print(g[[nm]])
    }
}

## Plot aesthetics
W <- 3840
H <- 2160
SZ <- 44
LSZ <- 2

for (plt in names(g)) {
    outf <- paste0("./tmp/", plt, ".png")
    png(file=outf, width=W, height=H)
    print(g[[plt]] + theme_classic(base_size = SZ))
    dev.off()
}
