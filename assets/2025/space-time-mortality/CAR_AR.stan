functions {
#include car_lpdf.stan
}

data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // outcome 
  array[TT] vector[S] log_pop;   // offset
  
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
  real<lower=-1, upper=1> beta_ar;
  real<lower=1/min(lambda), upper=1/max(lambda)> rho;
  real<lower=0> tau;  
  array[TT] vector[S] phi;        
}

model {
  vector[S] phi_mu;
  
  for (tt in 1:TT) {
      if (tt == 1) {
        phi_mu = rep_vector(alpha, S);
      } else {
        phi_mu = beta_ar * phi[tt-1];
      }

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
			       
      target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi[tt]);		
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

