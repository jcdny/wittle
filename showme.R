source("util.R")

IPLOT <- TRUE
DO.FULL <- FALSE

## Plots to generate c(<days history>, <days forecast>)
PLOTS <- list(short=c(3,1), medium=c(7,2), long=c(28,14), raw=c(5,0))

tide <- read_csv(paste0(dataDir(), "/static/tides.csv.gz"))
tz(tide$dt) <- "America/Los_Angeles"

tic("read all")
x <- ts.load()
toc()

if (any(is.na(x$dt))) {
    x <- x[-which(is.na(x$dt)), ]
}
x <- ts.adjustments(x)
x <- ts.debias(x)

g <- list()

tg <- tide %>%
    mutate(day = date(dt)) %>%
    filter(day >= (Sys.time() - ddays(2)) & day < (Sys.time() + ddays(90))) %>%
    group_by(day) %>%
    dplyr::summarise(
               max.ht = max(pred)
             , min.lt = min(pred)
             , danger = ifelse(max.ht > 5.6, "HIGH","OK")
           )

g[["tide"]] <- ggplot(tg, aes(x = day, y=max.ht, color=danger)) +
    geom_point(size = 12) +
    ylim(4, 8)

if (DO.FULL) {
    g[["full-pitch"]] <- ggplot(x, aes(x=dt,y=runmed(x,201))) + geom_line() +
        geom_line(aes(y=runmed(adj.x,121)), color="blue") +
        ylab("Tilt (degrees)") +
        ylim(-.5, NA) +
        xlab("Date") + ggtitle("Pitch")

    if (IPLOT && interactive()) {
        print(g[1])
    }

    g[["full-roll"]] <- ggplot(x, aes(x=dt,y=runmed(y,201))) + geom_line() +
        geom_line(aes(y=runmed(adj.x,121)), color="blue") +
        ylab("Tilt (degrees)") +
        ylim(-1.0, NA) +
        xlab("Date") + ggtitle("Roll")

    if (IPLOT && interactive()) {
        print(g[["full-roll"]])
    }
}

df <- rbind(data.frame(dt=x$dt, tilt=x$x, adj=x$adj.x, raw=x$raw.x, axis="Pitch")
          , data.frame(dt=x$dt, tilt=x$y, adj=x$adj.y, raw=x$raw.y, axis="Roll")
          , data.frame(dt=tide$dt, tilt=tide$pred, adj=NA, raw=NA, axis="Tide")
            )

max.dt <- max(x$dt, na.rm=TRUE)

for (nm in names(PLOTS)) {
    dd.s <- PLOTS[[nm]][1]
    dd.e <- PLOTS[[nm]][2]

    ii <- which(df$dt > (max.dt - ddays(dd.s)) & df$dt < max.dt + ddays(dd.e))

    df.g <- df[ii,]

    TILT.START <- 5.2
    WORK.LOW <- 1.0

    df.lt <- df.ht <- df.g[df.g$axis == "Tide",]
    df.ht$tilt[df.ht$tilt < TILT.START] <- NA
    df.lt$tilt[df.lt$tilt > 1] <- NA
    df.hline <- data.frame(axis="Tide", tilt=c(TILT.START, WORK.LOW))
    if (nm == "raw") {
        g[[nm]] <- ggplot(df.g[df.g$axis != "Tide",], aes(x=dt, y=runmed(raw, 201))) +
              geom_line(linewidth=1.2) +
              ylab("") +
              xlab("Date") +
              facet_wrap(~ axis, ncol=1, scales="free_y")
    } else {
        g[[nm]] <- ggplot(df.g[df.g$axis != "Tide",], aes(x=dt, y=runmed(tilt, 201))) +
            geom_line(linewidth=1.2) +
            geom_line(data=df.g[df.g$axis != "Tide",], aes(y=tilt), alpha=.3) +
            geom_line(data=df.g[df.g$axis == "Tide",], aes(y=tilt)) +
            geom_line(data=df.ht, aes(y=tilt), color="Red", linewidth=1.3) +
            geom_line(data=df.lt, aes(y=tilt), color="Green", linewidth=1.3) +
            geom_hline(data=df.hline, aes(yintercept=tilt), alpha=.3) +
            geom_hline(data=df.hline, aes(yintercept=tilt), alpha=.3, color="blue") +
            ylab("") +
            xlab("Date") +
            facet_wrap(~ axis, ncol=1, scales="free_y")

        if (IPLOT && interactive()) {
            print(g[[nm]])
        }
    }
}

## Plot aesthetics
W <- 3840
H <- 2160
SZ <- 44
LSZ <- 2


for (plt in names(g)) {
    outf <- paste0(dataDir(), "/graphs/", plt, ".png")
    png(file=outf, width=W, height=H)
    print(g[[plt]] + theme_classic(base_size = SZ))
    dev.off()
}

tmpl <- read_file(paste0(dataDir(),"/static/display.html.tmpl"))

xx <- x[nrow(x),c("dt","ax","ay")]
vars <- list(
    asof = strftime(Sys.time(), "%Y-%m-%d %H:%M")
  , lastobs = strftime(xx$dt,"%Y-%m-%d %H:%M:%S")
  , lasttilt = xx$ax
  , lastpitch = xx$ay
)

out <- str_interp(tmpl, vars)
write_file(out, paste0(dataDir(), "/graphs/display.html"))
