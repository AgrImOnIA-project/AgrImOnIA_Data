ma <- function(x, n = 7){filter(x, rep(1 / n, n), sides = 2)}
