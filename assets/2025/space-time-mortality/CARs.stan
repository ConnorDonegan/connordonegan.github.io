functions {
#include car_lpdf.stan
}

data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // outcome variable
  array[TT] vector[S] log_pop;   // offset; logdenominator in the rate y/pop
  
  // CAR parts
  int nA_w;
  vector[nA_w] A_w; 
  int A_v[nA_w];
  int A_u[S + 1];
  vector[S] Delta_inv;
  real log_det_Delta_inv;
  vector[S] lambda;
}

parameters {
  real alpha; 
  real<lower=0> tau;
  real<lower=1/min(lambda), upper=1/max(lambda)> rho;
  array[TT] vector[S] phi;  
}

model {
  vector[S] phi_mu = rep_vector(alpha, S);
  
  for (tt in 1:TT) {    
    target += wcar_normal_lpdf(
			       phi[tt] |
			       phi_mu,
			       tau,
			       rho,
			       A_w, A_v, A_u,
			       Delta_inv, 
			       log_det_Delta_inv,
			       lambda,
			       S);
    y[tt] ~ poisson_log(log_pop[tt] + phi[tt]);			    
  }
  
  target += normal_lpdf(alpha | -4, 4); 
  target += std_normal_lpdf(tau);
}

generated quantities {
  array[TT] vector[S] log_lik;
    for (tt in 1:TT) {
      for (i in 1:S) log_lik[tt, i] = poisson_log_lpmf(y[tt, i] | log_pop[tt, i] + phi[tt, i]);
    }
}

