// Connor Donegan (2024)
functions {
  //#include car_lpdf.stan
  
/**
 * Log probability density of the conditional autoregressive (CAR) model: WCAR specifications only
 *
 * @param y Process to model
 * @param mu Mean vector
 * @param tau Scale parameter
 * @param rho Spatial dependence parameter
 * @param A_w Sparse representation of the symmetric connectivity matrix, A
 * @param A_v Column indices for values in A_w
 * @param A_u Row starting indices for values in A_u
 * @param D_inv The row sums of A; i.e., the diagonal elements from the inverse of Delta, where M = Delta * tau^2 is a diagonal matrix containing the conditional variances.
 * @param log_det_D_inv Log determinant of Delta inverse.
 * @param lambda Eigenvalues of C (or of the symmetric, scaled matrix Delta^{-1/2}*C*Delta^{1/2}); for the WCAR specification, C is the row-standardized version of W.
 * @param n Length of y
 *
 * @return Log probability density of CAR prior up to additive constant
 *
 * @author Connor Donegan (connor.donegan@gmail.com) Jan 2025
 */
real wcar_normal_lpdf(vector y, vector mu,
              real tau, 
              real rho,
              vector A_w,
              array[] int A_v,
              array[] int A_u,
              vector D_inv,
              real log_det_D_inv,
              vector lambda,
              int n) {
  vector[n] z = y - mu;
  real ztDz = (z .* D_inv)' * z;
  real ztAz = z' * csr_matrix_times_vector(n, n, A_w, A_v, A_u, z);
  real ldet_ImrhoC = sum(log1m(rho * lambda));  
  return 0.5 * (
        -n * log( 2 * pi() )
        -2 * n * log(tau)
        + log_det_D_inv
        + ldet_ImrhoC
        - (1 / tau^2) * (ztDz - rho * ztAz));
}
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

