library(lubridate, warn.conflicts=FALSE)
library(ggplot2, warn.conflicts=FALSE)
library(readr, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(stringr)
library(tictoc)

dataDir <- function() {
    DATA <- Sys.getenv("DATA")
    if (DATA == "") {
        for (dir in c("/data/tilt","~/data/tilt")) {
            if (file.exists(dir)) {
                DATA <- dir
                break
            }
        }
    }
    if (DATA == "" || !file.exists(DATA)) {
        stop("Data directory not found ", DATA)
    }

    DATA
}

ts.adj <- function(df, from, to, adj, scale=1.0) {
    f.dt <- ymd_hms(from, tz="America/Los_Angeles")
    e.dt <- ymd_hms(to, tz="America/Los_Angeles")

    ii <- which(df$dt > f.dt & df$dt < e.dt)
    if (any(ii)) {
        df$x[ii] <- (df$x[ii] + adj)*scale
    } else {
        ## warning(paste("no points in range", from, to))
    }

    df
}

ts.load.from <- function(from=NULL) {
    data.dir <- paste0(dataDir(), "/data")
    files <- dir(data.dir, pattern = "^202.*csv$")
    dates <- ymd_hms(files, tz="America/Los_Angeles")


    if (!is.null(from)) {
        ii <- which(dates > from)
    } else if (length(dates) > 0) {
        ii <- 1:length(dates)
    } else {
        stop("no files found in", data.dir)
    }

    if (length(ii) == 0) {
         stop("Last data found is ", max(dates), "want data from", from, "onward")
    } else {
        cat("Loading", length(ii), "files of data\n")
    }

    out <- NULL

    for (file in files[ii]) {
        inp <- read.csv(paste0(data.dir, "/", file)
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
    data.dir <- dataDir()
    cspec <- cols(
        dt = col_datetime(format = ""),
        x = col_double(),
        y = col_double(),
        z = col_double(),
        ax = col_double(),
        ay = col_double(),
        az = col_double()
    )
    p <- pipe(paste0("(cd ", data.dir, "/data; echo \"dt,x,y,z,ax,ay,az\"; cat `ls -1 20251*.csv 2026*.csv | sort`)"))
    cat("starting read all\n")
    x <- read_csv(p, col_types = cspec)
    cat("done read all\n")
    x$dt <- ymd_hms(x$dt, tz="America/Los_Angeles")

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
    x <- ts.adj(x, "2025-11-29T20:10:00", "2030-01-01T00:00:00", 0.0, -1.0)

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

