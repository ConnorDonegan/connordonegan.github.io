// Connor Donegan (2024)
/*
Type 0: Partial pooling using iid normal distribution.
Type 1: AR only, giving one time trend per areal unit.
Type 2: CAR only, one spatial trend and intercept for each time period
Type 3: CAR-AR, one time trend per areal unit with CAR model for the errors
*/

functions {
#include car_lpdf.stan
}

data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // stacked observations over time
  array[TT] vector[S] log_pop;  
  int<lower=0,upper=3> type;
  
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
  real<lower=-1,upper=1> beta_ar;
  real<lower=1/min(lambda), upper=1/max(lambda)> rho;  
  array[TT] vector[S] phi_tilde;   // de-scaled phi
}

model {
  array[TT] vector[S] phi_tilde_mu;   
  
  for (tt in 1:TT) {
    
    if (type == 0) {
      // Type 0: 'rates gravitate around a mean value with characteristic variance'
      // (a.k.a. 'iid random effects')
      target += std_normal_lpdf(phi_tilde[tt] - alpha);      
      // same as:
      //phi_tilde_mu[tt] = rep_vector(alpha, S);
      //target += normal_lpdf(phi_tilde[tt] | phi_tilde_mu[tt], 1);
      
    }
    
    if (type == 1) {
      // Type 1: AR(1) models, 'rates evolve over time, with deviations displaying a characteristic scale'
      if (tt == 1) {
      	phi_tilde_mu[1] = rep_vector(alpha, S);
      	} else {    
	phi_tilde_mu[tt] = beta_ar * phi_tilde[tt-1];
	}
      
      target += std_normal_lpdf(phi_tilde[tt] - phi_tilde_mu[tt]);
      
    } 
  
    if (type == 2) {
      // Type 3: CARs only, 'rates exhibit spatial patterns'
      phi_tilde_mu[tt] = rep_vector(alpha, S);
      
     // CAR with tau=1
      target += wcar_normal_lpdf(
       phi_tilde[tt] |
       phi_tilde_mu[tt],
       1, // tau=1
       rho, 
       A_w, A_v, A_u,
       Delta_inv, 
       log_det_Delta_inv,
       lambda, 
       S);
      
    } 
    
    if (type == 3) {
      // Type 3: CAR-AR model, 'rates evolve in time, and their movements tend to dispaly spatial patterns'
      
      if (tt == 1) {
      	phi_tilde_mu[1] = rep_vector(alpha, S);
      } else {
      	phi_tilde_mu[tt] = beta_ar * phi_tilde[tt-1];
      }
      
      // CAR with tau=1
       target += wcar_normal_lpdf(
         phi_tilde[tt] |
         phi_tilde_mu[tt],
	 1, // tau=1
	 rho, // 
	 A_w, A_v, A_u,
	 Delta_inv, 
	 log_det_Delta_inv,
	 lambda, 
	 S);
    }
    
    // Now, put phi onto its proper scale: multiply phi_tilde by tau
    target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi_tilde[tt] * tau);		    		
						 
  }
  
  target += normal_lpdf(alpha | 0, 2);
  target += uniform_lpdf(beta_ar | -1, 1);
  target += std_normal_lpdf(tau);
}

generated quantities {
  array[TT] vector[S] phi;
  array[TT] vector[S] log_lik;
  for (tt in 1:TT) {
    phi[tt] = phi_tilde[tt] * tau;    
    for (i in 1:S) log_lik[tt, i] = poisson_log_lpmf(y[tt, i] | log_pop[tt, i] + phi[tt, i]);
  }
}

