

## dat_path <- "https://raw.githubusercontent.com/ConnorDonegan/connordonegan.github.io/main/assets/2025/space-time-stan-mortality/cdc-mortality-states.txt"
dat_path <- "assets/2025/space-time-mortality/cdc-mortality-states.txt"

# read the data into R
dat <- read.table(dat_path, header = TRUE, sep = "\t")

# make it presentable
dat <- transform(
    dat,
    Deaths = as.numeric(Deaths),
    Population = as.numeric(Population),
    Age = Ten.Year.Age.Groups.Code,
    Sex = Gender.Code
) |>
    transform(
        Crude.Rate = Deaths / Population
    )

unique(dat$Age)

# subset to one demographic group 
dat <- subset(dat,
                Sex == 'F' &
                Age == '25-34' 
              ) |>
    subset(
        select = c(Year, State, Deaths, Population)
    )

#










##############################


library(rstan)
library(geostan)
library(tigris)
library(sf)

##
## Project setup
##

# project variables
source("project-vars.R")

# map_pars, DIC, sfun
source("helper-funs.R")

# compile the Stan model
#car_ar_zmp <- stan_model("stan/CAR-AR-ZMP-options.stan")
car_ar <- stan_model("stan/CAR-AR.stan")

# for neighboring country outlines
data(world, package = "spData")
world <- st_transform(world, crs = proj_crs)
world_geom <- st_geometry(world)

##
## Load data
##

# State boundary file, with conformal conic projection for continental U.S.
geo <- tigris::states(cb = TRUE)
geo <- geo |>
    st_transform(crs = proj_crs) |>
    transform(State = NAME) |>
    subset(
        select = c(State, GEOID)
    )

# Mortality data: by state, year, age group, and sex
datx <- read.table("data/cdc-mortality-1999-2019-states.txt",
                  header = TRUE,
                  sep = "\t")

##
## Clean, combine data
##

datx <- transform(
    datx,
    Deaths = as.numeric(Deaths),
    Population = as.numeric(Population),
    Age = Ten.Year.Age.Groups.Code,
    Sex = Gender.Code
) |>
    transform(
        Crude.Rate = Deaths / Population
    )

# All state names must match
stopifnot( all( datx$State %in% geo$State ) )

# drop states/territories that have no mortality data in CDCWonder
# Dropping Alaska and Hawaii because there is no benefit at all to modeling them with spatial statistics,
#  they can each be modeled as an independent time trend (and appended to main results)
geodat <- subset(shp,
                  State %in% datx$State &
                  !grepl('Alaska|Hawaii', State)
                   )

# order by state name
geodat <- geodat[ order(geodat$State), ]

####
# Start with women ages 30-34 ##
###

dat <- subset(datx,
                Sex == 'F' &
                Age == '35-44' &
                State %in% geodat$State
              ) |>
    subset(
        select = c(Year, State, Age, Sex, Deaths, Population)
    )

# order by state name
dat <- dat[ order(dat$Year, dat$State) , ]

##
## Check for correct order; create adjacency matrix
##

yrs <- unique(dat$Year)
TT <- length(yrs)
N <- length(unique(dat$State))

test_res <- numeric(length = TT)
for (tt in seq_along(yrs)) {
    dds <- subset(dat, Year == yrs[tt])
    test_res[tt] <- all(dds$State == geodat$State)
}
stopifnot(all(test_res == 1))

# Connectivity matrix, adjacency
C <- shape2mat(geodat, "B", method = "rook")

# C converted to data list for CAR models
wcar_dl <- prep_car_data(C, "WCAR")

##
## Prepare data for the models
##

# TT x N arrays of y, log population
stan_dl <- list(TT = TT,
                N = N)

# Death counts
y <- array(dat$Deaths, 
           dim = c(N, TT)) |>
    t()
stan_dl$y <- y

pop <- array(dat$Population,
             dim = c(N, TT)) |>
    t()
stan_dl$log_pop <- log( pop )

stan_dl$States <- array(dat$State,
                        dim = c(N, TT)) |>
    t()

# for DIC
stan_dl$keep_log_lik <- 1

# let alpha, rho, beta_ar, tau vary with time? Default to 'fixed'
stan_dl$fixed_alpha <- 1
stan_dl$fixed_rho <- 1
stan_dl$fixed_tau <- 1
stan_dl$fixed_ar <- 1

# append car parts
stan_dl <- c(stan_dl, wcar_dl)

###################
# check the order of things once again
# Moran's I by time: these should all be moderately positive (like > .2),
#  if they are negative/near zero then the indexing is probably incorrect.
for (tt in 1:TT) {
    y = stan_dl$y[tt,]
    den = stan_dl$log_pop[tt,] |>
        exp()
    x = y/den    
    mc(x, wcar_dl$C) |>
        print()
}

###################


##
## N iterations per chain
##

iter = 1e3

##
## iid model
##

stan_dl$type = 0
S0 <- sampling(car_ar,
               data = stan_dl, 
               iter = iter, 
               control = list(adapt_delta = .99),
               cores = 4)

##
## AR only 
##

stan_dl$type = 1
stan_dl$fixed_ar = 0
S1 <- sampling(car_ar,
               data = stan_dl, 
               iter = iter, 
               cores = 4)

print(S1, "beta_ar")

##
## CAR only 
##

stan_dl$type = 2
stan_dl$fixed_alpha = 0 # time-varying intercept
S2 <- sampling(car_ar,
               data = stan_dl, 
               iter = iter, 
               control = list(adapt_delta = .99),
               cores = 4)

## as.matrix(S2, "alpha") |>
##     exp() |>
##     apply(2, mean) * proj_scale

##
## CAR-AR model
##

stan_dl$fixed_alpha <- 1
stan_dl$fixed_rho <- 1
stan_dl$fixed_tau <- 1
stan_dl$fixed_ar <- 1
stan_dl$type = 3
S3 <- sampling(car_ar,
               data = stan_dl, 
               iter = iter, 
               control = list(adapt_delta = .97, 
                              max_treedepth = 12),
               cores = 4)

print(S3, pars = c("alpha", "rho", "beta_ar", "tau"))
plot(S3, pars = c("rho", "beta_ar", "tau"))


par(mar = c(2.5 ,2.5, 0, 0))
ylim = proj_scale * range( dat$Deaths/dat$Population )
plot(range(dat$Year),
     ylim,
     t = 'n',
     bty = 'l',
     xaxt = 'n', # add axes below
     yaxt = 'n',
     xlab = NA,
     ylab = NA)
axis(1, lwd.ticks = 0.5, lwd = 0); axis(2, lwd.ticks = 0.5, lwd = 0)
eta <- as.matrix(S3, pars = "phi") |>
    exp()
years <- unique(dat$Year)
states <- stan_dl$States[1,]
for (st in states) {
    st_id <- grep(paste0("^", st, "$"), states)
    print(st_id)
    st_idx <- grep(paste0(',', st_id, '\\]$'), colnames(eta))
    st_eta <- eta[ , st_idx ] 
    st_est <- proj_scale * apply(st_eta, 2, mean)     
    lines(years,
          st_est,
          lwd = .75,
          col = rgb(0.2, 0.2, 0.2, 0.5))
    dst = subset(dat, State == st)
    with(dst,
         lines(Year, proj_scale * Deaths/Population,
              t = 'l',
              col = rgb(0.4,0.1,0.1,0.3)
              )
         )
}
mtext('Deaths per 100,000', line = -2)

# map most recent period
eta <- as.matrix(S3, pars = "phi") |>
    exp()
t_idx <- grep('\\[22,', colnames(eta))
t_eta <- eta[ , t_idx ] 
t_est <- proj_scale * apply(t_eta, 2, mean)

mp <- map_pars(x = t_est,
               brks = quantile(t_est, probs = seq(0, 1, by = .2)),
               pal = proj_pal)
par(mar = rep(0, 4), oma = rep(0, 4))
plot(world_geom,
     lwd = 0.4,
     xlim = st_bbox(gdat)[c(1, 3)],
     ylim = st_bbox(gdat)[c(2, 4)],
     col =  rgb(0, 0.2, 0.4, 0.05),     
     bg = rgb(0, 0.2,  0.4, .05)
     )
plot(st_geometry(gdat),
     col = mp$col,
     add = TRUE
     )
legend("bottomleft",
 fill = mp$pal,
 title = 'Mortality per 100,000',
 legend = mp$lbls,
 bty = 'n'
 )



##
## Compare with DIC
##

rbind(
  #DIC(S0), 'iid'
  DIC(S1),
  DIC(S2),
  DIC(S3)
) |>
  as.data.frame() |>
  transform(
    model = c('AR', 'CAR', 'CAR-AR')
  )

##
## View some results
##

s <- as.matrix(S3, pars = c("alpha", "rho", "beta_ar", "tau"))

apply(s, 2, sfun) |>
  round(2) |>
  t() |>
  as.data.frame() |>

