data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // outcome variable
  array[TT] vector[S] log_pop;   // offset; logdenominator in the rate y/pop
}

parameters {
  real alpha;          // overall mean Log mortality rate
  real<lower=0> tau;   // scale of variation
  real<lower=-1, upper=1> beta_ar;  // auto-regressive coefficient
  array[TT] vector[S] phi;          // log mortality rates  
}

model {
  array[TT] vector[S] phi_mu;
  
  for (tt in 1:TT) {
      if (tt == 1) phi_mu[1] = rep_vector(alpha, S);
      if (tt > 1)  phi_mu[tt] = beta_ar * phi[tt-1];
      target += normal_lpdf(phi[tt] | phi_mu[tt], tau);	
      y[tt] ~ poisson_log(log_pop[tt] + phi[tt]);    
      }

  target += normal_lpdf(alpha | -4, 4);
  target += uniform_lpdf(beta_ar | -1, 1);
  target += std_normal_lpdf(tau);  
}

generated quantities {
  array[TT] vector[S] log_lik;
    for (tt in 1:TT) {
      for (i in 1:S) log_lik[tt, i] = poisson_log_lpmf(y[tt, i] | log_pop[tt, i] + phi[tt, i]);   
    }
}

