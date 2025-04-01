// Connor Donegan (2024)
functions {
#include car_lpdf.stan
}

data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // outcome variable
  array[TT] vector[S] log_pop;   // offset
  
  // indicators
  int<lower=0,upper=1> keep_log_lik;
  int<lower=0,upper=1> fixed_alpha;
  int<lower=0,upper=1> fixed_rho;
  int<lower=0,upper=1> fixed_tau;
  
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
  array[TT] vector[S] phi;  
  vector[fixed_alpha ? 1 : TT] alpha;
  vector<lower=0>[fixed_tau ? 1 : TT] tau;
  vector<lower=1/min(lambda), upper=1/max(lambda)>[fixed_rho ? 1 : TT] rho;
}

model {
  vector[S] phi_mu;
  
  for (tt in 1:TT) {    
    phi_mu = rep_vector(alpha[fixed_alpha ? 1 : tt], S);
    target += wcar_normal_lpdf(
			       phi[tt] |
			       phi_mu,
			       tau[ fixed_tau ? 1 : tt ],
			       rho[ fixed_rho ? 1 : tt ],
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
  array[TT] vector[keep_log_lik ? S : 0] log_lik;
  if (keep_log_lik) {
    for (tt in 1:TT) {
      for (s in 1:S) log_lik[tt, s] = poisson_log_lpmf(y[tt, s] | log_pop[tt, s] + phi[tt, s]);
    }
  }
}
