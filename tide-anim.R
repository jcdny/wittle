library(tidyverse)

## Plot aesthetics
W <- 1080
H <- 1920
SZ <- 44
LSZ <- 3

tide <- read_csv("tides.csv.gz")

tide <- tide[which(tide$dt > today() & tide$dt < (today() + dyears(1))),]

T <- 60
FR <- 60
DAYS <- 7

ii <- 1:(DAYS * 240)
i <- 0
f <- 1
maxi <- dim(tide)[1]
step <- floor(maxi/T/FR)

cat("generate", T ,"sec of frames, step", step, "\n")

while (f <= T*FR && i + DAYS*240 < maxi) {
    if (f %% 100 == 0) {
        cat("frame", f, "\n")
    }

    outf <- paste0("./tmp/tl/f", sprintf("%05d", f),".png")
    png(file=outf, width=W, height=H)
    mon <- month(tide$dt[i + DAYS*204], label=TRUE)
    gp <- ggplot(tide[ii + i,], aes(x=dt,y=pred)) +
        geom_line(linewidth=LSZ) +
        ylim(-2,7.5) +
        xlab(mon) +
        ylab("Tide (ft)")

    print(gp +
          theme_classic(base_size = SZ) +
          theme(axis.text.x=element_blank()
              , axis.ticks.x=element_blank()
              , axis.ticks.y=element_blank()
                )
          )
    dev.off()

    i <- i + step
    f <- f + 1
}

cat(outf,"index",i,"of",maxi"\n")
