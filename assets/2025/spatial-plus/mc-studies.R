# for spatial analysis
library(geostan)

# for reporting tabular results
library(xtable)

# no. observations
row = 12
col = 12
N = row * col

# create connectivity matrix (rook adjacency criteria)
sar_parts = prep_sar_data2(row, col)
W = sar_parts$W

# level of SA
rho = 0.7

# regresion coefficient
beta = 0.5

# spatial difference operator
m_diff <- (diag(N) - rho * W)

# spatial smoothing operator
m_smooth <- solve(m_diff)

# scale of variation 
# controls relative strengh of signals
# .3/1 will show biases clearly
sigma_x = 1
sigma_y = 0.3

# MCMC control
iter = 1e3
chains = 2

# store results in these files
# store results in these files
f_1 = "mc_res_1.txt"
f_2 = "mc_res_2.txt"
f_3 = "mc_res_3.txt"
f_4 = "mc_res_4.txt"
f_5 = "mc_res_5.txt"

# iterate M times
M = 200

# for replication
set.seed(101)

# iterate M times
quietly = sapply(1:M, function(m) {

    # draw x from SAR model
    x = m_smooth %*% rnorm(n = N, sd = sigma_x)

    # draw y from SAR model 
    y = beta * x + m_smooth %*% rnorm(n = N, sd = sigma_y)

    ## Study 1
    # fit regression
    fit = lm(y ~ x)

    # collect coefficient estimate and its standard error
    res = coef(summary( fit ))[ "x" , c("Estimate", "Std. Error") ] 

    # save results
    write.table(matrix(res, nrow = 1),
                f_1,
                append = (m > 1),
                row.names = FALSE,
                col.names = FALSE)

   
   ## Study 2
   rm(fit, res)
   
   # pre-whiten x 
   xfit = stan_sar(x ~ 1,
             data = data.frame(x = x),
             sar = sar_parts,
             iter = iter,
             chains = chains,
             quiet = TRUE) |>
	     # we can silence any MCMC warnings about effective sample size:
	     # the Monte Carlo study itself would reveal any MCMC issues
	     suppressWarnings()
    xtilde <- residuals(xfit)$mean

    # pre-whiten y
    yfit = stan_sar(y ~ 1,
             data = data.frame(y = y),
             sar = sar_parts,
             iter = iter,
             chains = chains,
             quiet = TRUE) |>
	     suppressWarnings()	    
    ytilde <- residuals(yfit)$mean

    # regression with pre-whitened variates
    fit = lm(ytilde ~ xtilde)
        
    res = coef(summary( fit ))[ "xtilde" , c("Estimate", "Std. Error") ] 
    
    write.table(matrix(res, nrow = 1),
                f_2,
                append = (m > 1),
                row.names = FALSE,
                col.names = FALSE)

   ## Study 3
   rm(fit, res)
   
   # spatial regression
    fit = stan_sar(y ~ x,
             data = data.frame(y = y, x = x),
             sar = sar_parts,
             iter = iter,
             chains = chains,
             quiet = TRUE) |>
	     suppressWarnings()	  
        
    res = fit$summary[ "x" , c("mean", "sd") ] 
    
    write.table(matrix(res, nrow = 1),
                f_3,
                append = (m > 1),
                row.names = FALSE,
                col.names = FALSE)

   ## Study 4
   rm(fit, res)   
   # spatial+
   fit = stan_sar(y ~ xtilde,
             data = data.frame(y = y, xtilde = xtilde),
             sar = sar_parts,
             iter = iter,
             chains = chains,
             quiet = TRUE) |>
	     suppressWarnings()	  
        
    res = fit$summary[ "xtilde" , c("mean", "sd") ] 
    
    write.table(matrix(res, nrow = 1),
                f_4,
                append = (m > 1),
                row.names = FALSE,
                col.names = FALSE)

   # Study 5
   rm(fit, res)
   # half-whitening
   fit = lm(y ~ xtilde)

    # collect coefficient estimate and its standard error
    res = coef(summary( fit ))[ "xtilde" , c("Estimate", "Std. Error") ] 
    
    write.table(matrix(res, nrow = 1),
                f_5,
                append = (m > 1),
                row.names = FALSE,
                col.names = FALSE)           


})

# view summary of each 'study'
RMSE <- function(est, b = 0.5) {
    e <- est - b
    mse <- mean(e^2)
    sqrt(mse)
}
for (f in c(f_1, f_2, f_3, f_4, f_5)) {
  res = read.table(f, col.names = c('est', 'se'))
  summ = cbind(Est = mean(res$est),
              RMSE = RMSE(res$est),
    	      SE_mean = mean(res$se) )
  print(paste(f, ":"))
  print(summ, digits = 3)
}


# plot results
res1 = read.table(f_1, col.names = c('est', 'se'))
res2 = read.table(f_2, col.names = c('est', 'se'))
res3 = read.table(f_3, col.names = c('est', 'se'))
res4 = read.table(f_4, col.names = c('est', 'se'))

png("monte_carlo_comparison.png",
    width = 8,
    height = 3,
    res = 350,
    units = 'in')
par(mfrow = c(1, 4),
    mar = c(2, 1, 2, 1),
    oma = rep(1, 4),
    bg = rgb(0.9, 0.9, 0.95, 1)
    )
lim <- range(c(res1$est, res2$est, res3$est, res4$est))
lim[1] <- lim[1] - .05
lim[2] <- lim[2] + .05
# ols
hist(res1$est,
     main = 'OLS',
     xlim = lim,
     axes = FALSE
     )
axis(1)
abline(v = beta, lty = 2, col = 'blue', lwd = 2)
# pre-whitening
hist(res2$est,
     main = 'Pre-whitening',
     xlim = lim,
     axes = FALSE)
axis(1)
abline(v = beta, lty = 2, col = 'blue', lwd = 2)
# SEM
hist(res3$est,
     main = 'SAR',
     xlim = lim,
     axes = FALSE)
axis(1)
abline(v = beta, lty = 2, col = 'blue', lwd = 2)
# spatial+
hist(res4$est,
     main = 'Spatial+',
     xlim = lim,
     axes = FALSE)
axis(1)
abline(v = beta, lty = 2, col = 'blue', lwd = 2)
dev.off()


#  are pre-whitening and spatial regression equal in expectation?
# the mean difference should be zero 
mean( res_3$est - res2$est )

# posterior uncertainties do not differ either, surprisingly
mean( res_3$se - res2$se )
