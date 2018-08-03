library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(bsts)

sm <- stan_model('semilocal_linear_trend.stan')

## Nile
y <- as.vector(Nile)
T <- length(y)
x <- 1:T

### Stan
sfit <- sampling(sm, data=list(y=y, T=T),
                 control=list(adapt_delta=0.99))

### bsts
m <- list()
m <- AddSemilocalLinearTrend(m, y=y)
bfit <- bsts(y, m, niter=2000)

### plot
plot(x, y, type='l')
lines(x, colMeans(bfit$state.contributions), col='red')
lines(x, colMeans(extract(sfit, "y_pred")$y_pred), col='blue', type='l')

plot(density(bfit$trend.slope.mean), col='red')
lines(density(extract(sfit, "eta")$eta), col='blue')

summary(bfit$trend.slope.mean)
summary(extract(sfit, "eta")$eta)

## rsxfs
data(rsxfs)

y <- as.vector(rsxfs)
T <- length(y)
x <- 1:T

### Stan
sfit <- sampling(sm, data=list(y = y, T = T, x = x),
                 control=list(adapt_delta=0.99,
                              max_treedepth=15))

### bsts
m <- list()
m <- AddSemilocalLinearTrend(m, y=y)
bfit <- bsts(y, m, niter=2000)

### plot

plot(x, y, type='l')
lines(x, colMeans(bfit$state.contributions), col='red')
lines(x, colMeans(extract(sfit, "y_pred")$y_pred), col='blue')

summary(bfit$trend.slope.mean)
summary(extract(sfit, "eta")$eta)

plot(density(bfit$trend.slope.mean), col='red')
lines(density(extract(sfit, "eta")$eta), col='blue')


### goog
data(goog)

y <- as.vector(goog)
T <- length(y)
x <- 1:T

### Stan

sdata <- list(y = y, T = T, x = x)
sfit <- sampling(sm, data=sdata,
                 control=list(adapt_delta=0.99,
                              max_treedepth=15))
posterior <- as.matrix(sfit)

### bsts
m <- list()
m <- AddSemilocalLinearTrend(m, y=y)
bfit <- bsts(y, m, niter=2000)

### plot

plot(x, y, type='l')
lines(x, colMeans(bfit$state.contributions), col='red')
lines(x, colMeans(posterior[, grepl('y_pred', colnames(posterior))]), col='blue')
