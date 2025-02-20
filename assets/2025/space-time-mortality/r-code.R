
########
## Data
########

dat_path <- "https://raw.githubusercontent.com/ConnorDonegan/connordonegan.github.io/refs/heads/main/assets/2025/space-time-mortality/cdc-mortality.txt"

# read the data into R
dat <- read.table(dat_path)


###################
## Plot crude rates
###################

# parameters for display
scale = 100e3
col = rgb(0.1, 0.4, 0.6, 0.5)

# open graphics device
png("assets/2025/space-time-mortality/crude-rates-time.png",
    width = 5.5,
    height = 4,
    units = 'in',
    res = 300
    )

# set plot margins
par(mar = c(2.5, 2.5, 0.5, 0.5))

# find y-axis limits
ylim = scale * range( dat$Deaths/dat$Population )

# make a frame for the plot
plot(range(dat$Year),
     ylim,
     t = 'n',
     bty = 'l',
     xaxt = 'n', # add axes below
     yaxt = 'n',
     xlab = NA,
     ylab = NA)
axis(1, lwd.ticks = 0.5, lwd = 0)
axis(2, lwd.ticks = 0.5, lwd = 0)

# plot crude rates by state
for (st in unique(dat$State)) {
    dst <- subset(dat, State == st)
    lines(dst$Year,
          scale * dst$Deaths/dst$Population,
          col = col)
}
dev.off()

####################################
## glimpse of the data, as html table
####################################

library(tableHTML)

dat |>
    head(5) |>    
    subset(select = c(Year, State, Deaths, Population)) |>
    tableHTML(rownames = FALSE,
              caption = "A glimpse of the mortality data, female ages 35&ndash;44.")



##############################
## multiple AR models in Stan
##############################

# load package
library(rstan)

# order by state, year
dat <- dat[ order(dat$State, dat$Year) , ]

states <- unique(dat$State)
years <- unique(dat$Year)

S <- length(states)
TT <- length(years)

# starting the list of data
stan_dl <- list(TT = TT,
                S = S)

# array of death counts
stan_dl$y <- array(dat$Deaths, dim = c(TT, S)) 

# array of log-populations
pop <- array(dat$Population, dim = c(TT, S)) 
stan_dl$log_pop <- log( pop )

# so you can verify the order using eyeballs
states_array <- array(dat$State, dim = c(TT, S))
states_array[1,]
states_array[,1]
print( states_array )

# sampling
iter = 1e3
cores = 4

ar_model <- stan_model("assets/2025/space-time-mortality/ARs.stan")

S1 <- sampling(ar_model,
               data = stan_dl, 
               iter = iter, 
               cores = cores)

print(S1, pars = c('alpha', 'beta_ar', 'tau'))

# get Alaska and Hawaii

eta <- as.matrix(S1, "phi") |>
    exp()

( ak_tmp <- grep('Alaska', states) )
ak_idx <- grep(paste0(',', ak_tmp, '\\]'), colnames(eta))

( hi_tmp <- grep('Hawaii', states) )
hi_idx <- grep(paste0(',', hi_tmp, '\\]'), colnames(eta))

eta_ak <- eta[ , ak_idx ]
eta_hi <- eta[ , hi_idx ]


##############################
## multiple CAR models in Stan
##############################


# load spatial packages
# for CAR/Stan model help 
library(geostan)
# for state boundaries, as simple features
library(tigris)
# for working with simple features
library(sf)

# coordinate reference system for cont. U.S.
us_crs = 'ESRI:102003'

# drop Alaska, Hawaii
dat_full <- dat
dat <- subset(dat_full, !grepl('Alaska|Hawaii', State))

# get state boundaries
# cb=Cartographic Boundary files (for mapping)
geo <- tigris::states(cb = TRUE)
geo <- geo |>
    st_transform(crs = us_crs) |>
    transform(State = NAME) |>
    subset(State %in% dat$State,			
        select = c(State, GEOID))

# order by state, just like 'dat'
geo <- geo[ order(geo$State), ]

# verify that the order matches throughout 
test_res <- numeric(length = TT)
for (tt in seq_along(years)) {
    ddt <- subset(dat, Year == years[tt])
    test_res[tt] <- all(ddt$State == geo$State)
}
stopifnot(all(test_res == 1))

# Create an adjacency matrix 
C <- shape2mat(geo, "B", method = "rook")

# save to avoid user dependency on tidycensus
C_path = "assets/2025/space-time-mortality/C_matrix.txt"
Cm <- as.matrix(C)
Cm[1:length(as.numeric(Cm))] <- as.numeric(Cm)
write.table(Cm, C_path, col.names = FALSE, row.names = FALSE)

# for loading it back in:
#C_path <- "https://raw.githubusercontent.com/ConnorDonegan/connordonegan.github.io/refs/heads/main/assets/2025/space-time-mortality/C_matrix.txt"
Cx = read.table(C_path) |>
    as.matrix()

# Convert C to a list of data for CAR models
car_parts <- prep_car_data(C, "WCAR")

# create data list again (now S=49)
states <- unique(dat$State)
years <- unique(dat$Year)
S <- length(states)
TT <- length(years)
stan_dl <- list(TT = TT,
                S = S)
stan_dl$y <- array(dat$Deaths, dim = c(TT, S)) 
pop <- array(dat$Population, dim = c(TT, S)) 
stan_dl$log_pop <- log( pop )

# append car_parts
stan_dl <- c(stan_dl, car_parts)

# Moran's I index of spatial autocorrelation, by year
#  (also serves as another check on stan_dl: if Moran's I values are near zero then our indexing is probably incorrect.)
mc_est <- numeric(length = TT)
for (tt in 1:TT) {
    y = stan_dl$y[tt,]
    den = stan_dl$log_pop[tt,] |>
        exp()
    x = y/den    
    mc_est[tt] <- mc(x, car_parts$C)
}
print(mc_est)

car_model <- stan_model("assets/2025/space-time-mortality/CARs.stan")

iter = 1e3
cores = 4

system.time(
    S2 <- sampling(car_model,
               data = stan_dl, 
               iter = iter, 
               cores = cores)
    )

print(S2, pars = c('alpha', 'rho', 'tau'))


######################
## The CAR-AR model
######################

car_ar_path = "assets/2025/space-time-mortality/CAR_AR.stan"
#car_ar_path = "https://raw.githubusercontent.com/ConnorDonegan/connordonegan.github.io/refs/heads/main/assets/2025/space-time-mortality/CAR_AR.stan"
car_ar_model <- stan_model(car_ar_path)

system.time(
    S3 <- sampling(car_ar_model,
               data = stan_dl, 
               iter = iter, 
               cores = cores)
    )

print(S3, pars = c('alpha', 'beta_ar', 'rho', 'tau'))


################################
## Model comparison with DIC
#################################

DIC <- function(object, digits = 2) {
  ll <- as.matrix(object, 'log_lik')
  dev <- -2 * apply(ll, 1, FUN = sum)
  dev_bar <- mean(dev)
  penalty <- 0.5 * var(dev)
  DIC <- dev_bar + penalty
  x = round(c(DIC = DIC, penalty = penalty), digits)
  return(x)
}

rbind(
  DIC(S1),
  DIC(S2),
  DIC(S3)
) |>
  as.data.frame() |>
  transform(
    model = c('AR', 'CAR', 'CAR-AR')
  )

### WAIC
library(loo)
S3LL <- as.array(S3, "log_lik")
lapply(list(as.array(S3, 'log_lik')), loo::waic)

( S1_waic = loo::waic(as.array(S1, 'log_lik')) )
( S2_waic = loo::waic(as.array(S2, 'log_lik')) )
( S3_waic = loo::waic(as.array(S3, 'log_lik')) )

# S1 can't be compared by this method b/c no. observations differs
# but S1 slight higher WAIC than S2.
# overall, results are effectively the same as DIC
loo::compare(S3_waic, S2_waic)


#########################################
## Visualizing mortality
#########################################

png("assets/2025/space-time-mortality/model-time-trends.png",
    width = 8,
    height = 6,
    units = 'in',
    res = 300)

par(mfrow = c(3, 3),
    mar = c(2, 3.5, 2, 2)
    )

# for matching states to model parameters
states <- geo$State

colnames(eta) |>
    tail(5) |>
    print()

# select a few states
selection <- c("Idaho", "Oregon", "California",
               "Mississippi", "Louisiana", "Alabama",
               "West Virginia",
               "Pennsylvania", "Delaware")

# rates: these are indexed and named as:  
#    phi[time_index, state_index]
# Exponentiate phi to get eta (before any other calculations)
eta <- as.matrix(S3, "phi") |>
    exp()

# index positions for our states
( state_expr <- paste0(selection, collapse = "|") )
( state_index <- grep(state_expr, states) ) 

# regular expression; to select columns (states) of eta
head( colnames(eta) )
( state_expr = paste0(',', state_index, ']') )

# rates per 100,000
scale = 100e3

# summary function for vector of MCMC samples
sfun <- function(x) {
    res <- c(mean = mean(x),
             lwr = quantile(x, 0.025) |>
            as.numeric(),
            upr = quantile(x, 0.975) |>
                as.numeric()
             ) 
    return (res)
    }

# loop over states: get their 'eta'; summarize; plot.
for (s in seq_along(selection)) {

    # dim(eta_s) is (2000, 22)
    # one row per MCMC sample; one column per year
    index_eta_s <- grep(state_expr[s], colnames(eta))
    eta_s <- eta[ , index_eta_s ]
    df <- apply(eta_s, 2, sfun) |>
        t() |>
        as.data.frame()
 
    y <- df$mean * scale
    upr <- df$upr * scale
    lwr <- df$lwr * scale
    ylim <- range(c(upr, lwr))
    
    plot(
        range(years),
        ylim,
        t = 'n',
        bty = 'L',
        xlab = NA,
        ylab = NA,
        axes = TRUE,
        mgp = c(0, 0.65, 0)        
    )
    lines(years, y, col = 'black')    
    polygon(
        c(years, rev(years)),
        c(lwr, rev(upr)),
        col = col
    )
    mtext('Cases per 100,000', side = 2, line = 2, cex = .65)
    mtext(selection[s], side = 3, line = -2)
}

dev.off()


########################
## Mapping mortality
#######################

library(classInt)

map_pars <- function(x,
                     brks,
                     pal = c("#2166ac", "#67a9cf", "#d1e5f0", "#fddbc7", "#ef8a62", "#b2182b"),
                     rev = FALSE) {

    stopifnot( length(brks) == (length(pal) +1) )
    
    # blue=high or red=high
    if (rev) pal = rev(pal)
    
    # put x values into bins
    x_cut <- cut(x, breaks = brks, include.lowest = TRUE)

    # labels for each bin
    lbls <- levels( cut(x, brks, include.lowest = TRUE) )
    
    # colors 
    rank <- as.numeric( x_cut )  
    colors <- pal[ rank ]
    
    # return list
    ls <- list(brks = brks, lbls = lbls, pal = pal, col = colors)
    
  return( ls )
}

# MCMC samples for the rates, eta
eta <- as.matrix(S3, pars = "phi") |>
    exp()
    
# map most recent period, 2020    
t_idx <- grep('\\[22,', colnames(eta))
t_eta <- eta[ , t_idx ] 
t_est <- apply(t_eta, 2, mean) * scale

# create cut-points for legend categories
brks <- classIntervals(t_est, n = 6, style = "jenks")$brks

# create map data (colors, legends)
mp <- map_pars(x = t_est,
               brks = brks)

# create map
png("assets/2025/space-time-mortality/model-map-2020.png",
    width = 8,
    height = 6,
    units = 'in',
    res = 300)

par(mar = rep(0, 4),
    oma = rep(0, 4)
    )
plot(st_geometry(geo),
     col = mp$col,
     bg = 'gray95'
     )
legend("bottomleft",
 fill = mp$pal,
 title = 'Mortality per 100,000',
 legend = mp$lbls,
 bty = 'n'
 )

dev.off()

############################
## Percent change analysis
############################

# MCMC samples for the rates, eta
eta <- as.matrix(S3, pars = "phi") |>
    exp()

# get years '2' and '20' (2000, 2018)
idx1 <- grep('\\[1,', colnames(eta))
idx21 <- grep('\\[21,', colnames(eta))

# grab samples by year
eta1 <- eta[ , idx1 ]
eta21 <- eta[ , idx21 ]

# MCMC samples for: d = eta21 - eta1
# dim(d_eta): c(2000, 49)
d_eta <- eta21 - eta1
d_pct <- 100 * d_eta / eta1

# summarize
df_pct <- apply(d_pct, 2, sfun) |>
    t() |>
    as.data.frame() |>
    transform(State = geo$State)

# don't forget Alaska
d_eta_ak <- eta_ak[ , 21] - eta_ak[ , 1]
d_pct_ak <- 100 * d_eta_ak / eta_ak[ , 1]
df_ak <- data.frame( sfun(d_pct_ak) |> t(),
                    State = 'Alaska')

# and Hawaii
d_eta_hi <- eta_hi[ , 21] - eta_hi[ , 1]
d_pct_hi <- 100 * d_eta_hi / eta_hi[ , 1]
df_hi <- data.frame( sfun(d_pct_hi) |> t(),
                    State = 'Hawaii') 

# combine with the others
df_pct <- df_pct |>
    rbind(df_ak) |>
    rbind(df_hi)

# order by mortality
df_pct <- df_pct[ order(df_pct$mean) , ]

labels = paste0(
    51:1,
    '. ',
    df_pct$State,
    ': ',
    round( df_pct$mean ),
    ' [',
    round( df_pct$lwr ),
    ', ',
    round( df_pct$upr ),
    ']'
)
       
png("assets/2025/space-time-mortality/model-chart-pct-change.png",
    width = 7,
    height = 11,
    units = 'in',
    res = 350)

par(mar = c(4, 14, 2, 2),
    bg = 'gray90')
xlim <- range(c(df_pct$lwr, df_pct$upr))
plot(
    df_pct$mean,
    1:51,
    t = 'p',
    pch = 18,
    bty = 'L',
    xlim = xlim,
    xlab = NA,
    ylab = NA,
    axes = FALSE
)
abline(v = 0, lty = 3)
segments(
    x0 = df_pct$lwr,
    x1 = df_pct$upr,
    y0 = 1:51)
axis(1, mgp = c(0, 0.65, 0))
axis(2,
     at = 1:51,
     cex.axis = 0.85,
     labels = labels,
     lwd = 0,
     lwd.ticks = 0,
     las = 1)
mtext('Percent change in mortality, 1999 to 2019: women ages 35-44', side = 1, line = 2)

dev.off()


##############################
## The CAR-AR model, flexible
##############################


cars_flex <- stan_model("assets/2025/space-time-mortality/CARs_flex.stan")

stan_dl$fixed_alpha = 0
stan_dl$fixed_rho = 0
stan_dl$fixed_tau = 0
stan_dl$fixed_ar = 1
stan_dl$keep_log_lik = 1

iter = 1e3

system.time(
    S4 <- sampling(cars_flex,
               data = stan_dl, 
               iter = iter, 
               cores = cores)
    )

DIC(S4)



#########################
## The CAR-AR model: ZMP
#########################


# not good for this data #

car_ar_model <- stan_model("assets/2025/space-time-mortality/CAR_AR_zmp.stan")

stan_dl$type <- 1

system.time(
    S5 <- sampling(car_ar_model,
               data = stan_dl, 
               iter = iter, 
               cores = cores)
    )

print(S5, pars = c('alpha', 'beta_ar', 'rho', 'tau'))





