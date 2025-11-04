source("util.R")

x <- ts.load()
if (any(is.na(x$dt))) {
    x <- x[-which(is.na(x$dt)), ]
}
x <- ts.adjustments(x)
x <- ts.debias(x)

gp <- ggplot(x, aes(x=dt,y=runmed(x,201))) + geom_line() +
    geom_line(aes(y=runmed(adj.x,121)), color="blue") +
    ylab("Tilt (degrees)") +
    xlab("Date") + ggtitle("Pitch")

if (interactive()) {
    print(gp)
}

gr <- ggplot(x, aes(x=dt,y=runmed(y,201))) + geom_line() +
    geom_line(aes(y=runmed(adj.x,121)), color="blue") +
    ylab("Tilt (degrees)") +
    xlab("Date") + ggtitle("Roll")

if (interactive()) {
    print(gr)
}

df1 <- data.frame(dt=x$dt,tilt=x$x, adj=x$adj.x, axis="Pitch")
df2 <- data.frame(dt=x$dt,tilt=x$y, adj=x$adj.y, axis="Roll")
df <- rbind(df1,df2)

ii <- which(df$dt > (max(df$dt, na.rm=TRUE) - ddays(2)))

gs <- ggplot(df[ii,], aes(x=dt,y=runmed(tilt, 201))) +
    geom_line() + geom_line(aes(y=tilt), alpha=.3) +
    geom_line(aes(y=runmed(adj, 121)), color="blue") +
    ylab("Tilt (degrees)") +
    xlab("Date") +
    facet_wrap(~ axis, ncol=1, scales="free_y")

if (interactive()) {
    print(gs)
}

W <- 3840
H <- 2160
SZ <- 44
LSZ <- 2


outf <- "./tmp/full-pitch.png"
png(file=outf, width=W, height=H)
print(gp + theme_classic(base_size = SZ))
dev.off()

outf <- "./tmp/full-roll.png"
png(file=outf, width=W, height=H)
print(gr + theme_classic(base_size = SZ))
dev.off()

outf <- "./tmp/short.png"
png(file=outf, width=W, height=H)
print(gs + theme_classic(base_size = SZ))
dev.off()
