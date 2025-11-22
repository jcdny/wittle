library(lubridate, warn.conflicts=FALSE)
library(ggplot2, warn.conflicts=FALSE)
library(readr, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tictoc)

ts.adj <- function(df, from, to, adj) {
    f.dt <- ymd_hms(from)
    e.dt <- ymd_hms(to)
    ii <- which(df$dt > f.dt & df$dt < e.dt)
    if (any(ii)) {
        df$x[ii] <- df$x[ii] + adj
    } else {
        ## warning(paste("no points in range", from, to))
    }

    df
}

ts.load.from <- function(from=NULL) {
    files <- dir("~/src/wittle/data", pattern = "^202.*csv$")
    dates <- ymd_hms(files)

    if (!is.null(from)) {
        ii <- which(dates > from)
    } else if (length(dates) > 0) {
        ii <- 1:length(dates)
    } else {
        ii <- c()
    }

    if (length(ii) == 0) {
        stop("No data found from", from, "onward")
    } else {
        cat("Loading", length(ii), "files of data\n")
    }

    out <- NULL

    for (file in files[ii]) {
        inp <- read.csv(paste0("~/src/wittle/data/", file)
                     , header=FALSE
                     , col.names=c("dt","x","y","z","ax","ay","az")
                       )
        out <- rbind(out,inp)

    }


    out$dt <- ymd_hms(out$dt, tz="America/Los_Angeles")
    out$day <- date(out$dt)

    tibble(out)
}

ts.load <- function() {
    ts.load.all()
}


ts.load.all <- function() {

    cspec <- cols(
        dt = col_datetime(format = ""),
        x = col_double(),
        y = col_double(),
        z = col_double(),
        ax = col_double(),
        ay = col_double(),
        az = col_double()
    )
    p <- pipe("(cd ~/src/wittle/data; echo \"dt,x,y,z,ax,ay,az\"; cat `ls -1 2025*.csv | sort`)")
    x <- read_csv(p, col_types = cspec)

    x$dt <- ymd_hms(x$dt)
    x$day <- date(x$dt)

    tibble(x)
}

ts.adjustments <- function(x) {
    cat("adjusting\n")
    ## move 7/7 jumps back to baseline
    x <- ts.adj(x, "2025-07-07T10:10:31", "2025-07-07T17:01:16", -1.3)
    x <- ts.adj(x, "2025-07-07T17:01:22", "2025-07-07T17:49:13", -0.2)

    ## fix gaps 7/6
    x <- ts.adj(x,"2025-07-06T12:43:50","2025-07-06T16:02:33", -.28)
    x <- ts.adj(x,"2025-07-06T16:02:33","2025-07-06T21:16:38", -.2)

    ## adjust all prior data to new normal
    x <- ts.adj(x,"2025-01-01T00:00:00", "2025-07-06T21:16:38", -.17)

    x
}

ts.debias <- function(x, hours=12) {
    cat("debiasing\n")

    x$raw.x <- x$x
    x$adj.x <- runmed(x$raw.x, hours * 3600 + 1, endrule="constant")
    x$x <- x$raw.x - x$adj.x

    x$raw.y <- x$y
    x$adj.y <- runmed(x$raw.y, hours * 3600 + 1, endrule="constant")
    x$y <- x$raw.y - x$adj.y

    x
}

