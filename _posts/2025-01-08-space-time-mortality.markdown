---
layout: post
title:  "Space-time modeling in Stan: mapping the evolution of U.S. mortality rates"
author: Connor Donegan
categories: [Statistics, Public_health]
toc: true
---

This post is a tutorial on modeling spatial-temporal data using the Stan modeling language, with a focus on areal data. When we take the right approach, Stan can provide a great platform for spatial statistics (presumably, so would other Hamiltonian Monte Carlo samplers). I'll illustrate by modeling mortality rates for U.S. states and D.C., covering the years 1999 through 2020.

The computational methods presented here are a fairly straigtforward extension of my previous work on CAR models for <a href="https://connordonegan.github.io/geostan">geostan</a> (mainly presented in this OSF <a href="https://osf.io/3ey65/">preprint</a>). I first began using these space-time models in my dissertation proposal and now, finally, I am getting around to sharing them. Feedback would be welcome.

**Contents:**
* TOC
{:toc} 

##  Disease mapping, minus the jargon

We'll be modeling state mortality rates for the years 1999&ndash;2020, for women ages 35&mdash;44 only. The goal for this kind of modeling project, which is often referred to as 'disease mapping', is to make inferences about systematic disease risk for population segments. We want sound answers to questions like: are mid-life mortality rates rising in Wisconsin? How fast are they rising? Is mortality higher in Ohio than Pennsylvania?

When the question pertains to massive groups of people, then raw data from a good vital statistics system can give us a suitable answer in the form of crude incidence rates. (Answering a statistical question is not the same, obviously, as developing an understanding of the matter.) Whenever our research questions concern small or 'smallish' groups of people, the patterns and trends of interest become obscured by chance (or causes of morbidity that are not persistent over time), and we may 'see' patterns where there are none.

<p>
The purpose of space-time disease mapping is to improve inferences about disease risk for a collection of population segments that are indexed by both time and geography. (Information about aggregates or averages, like whether mortality has been rising <em>on average</em> in the population, will emerge naturally from our disease mapping model if we are successful at making inferences about our collection of rates at each unit of observation.) In this case, we have mortality data for 50 states plus D.C. ( \( S = 51 \) ) spanning 22 years (\( T = 22 \)). This means we have a total of \(N = S \times T = 1,122 \) 'rates' about which we might like to make inferences. 
</p>

<p>
The crude mortality rate is defined as

$$r_{i,t} = \frac{y_{i,t}}{p_{i,t}},$$

where \( y \) is the mortality count and \( p \) is the population count. The way we improve upon the crude rate is by taking information from context. We look at rates in previous years, nearby places, similar age-groups, or other demographic segments. Having divided the population into any number of discrete, often well-motivated but at least semi-artificial categories (age groups, places, "races", etc.), we want our models to acknowledge that the categories are not so discrete after all. Whenever the crude rate itself contains minimal information (because the population or time-window of observation is small), our inferences will be more dependent on the 'external' information borrowed from neighbors.
</p>

The state-level data that we will be using here was chosen in part to keep the case study simple, rather than to illustrate all the problems of small numbers. Many of our rates are based on quite large numbers. 

## The statistical models 

Our modeling framework takes after the hierarchical Bayesian approach developed by C. Wikle, M. Berliner, and N. Cressie (1998; after Berliner 1996). The CAR-AR model specification to be discussed here was introduced by A. Rushworth, D. Lee, and R. Mitchell (2014), who also implement it in the 'CARBayesST' R package (our specification differs from theirs only in minor ways). A similar model was introduced by M.D. Ugarte and others (Urgarte et al. 2012), but they developed it within the alternative modeling framework introduced by Knorr-Held (2000). (Morris et al., 2019, may provide a good starting point for implementing the Knorr-Held approach in Stan.)

<p>
We start with the distinction between chance variation and systematic risk. Because we are modeling rare events, we use the Poisson distribution:

$$y_{i,t} \sim Poisson(\mu_{i,t}).$$

This states that we expect the number of cases or deaths \( y \) at any site \( i \) and time \( t \) to fluctuate around a mean value, equal to the population size multiplied by the systematic risk or 'incidence rate':

\begin{aligned}
&\mu_{i,t} &= p_{i,t} \cdot \eta_{i,t} \\
          &=  exp(log(p_{i,t}) + log(\eta_{i,t})).
\end{aligned}

Then the expectation of the observed rate is

$$E {\Large[} \frac{y_{i,t}}{p_{i,t}} {\Large]} = \eta_{i,t}.$$

This Poisson model is our likelihood for the observed rates. The next part of the model provides a prior probability distribution for the systematic risk ('rates' or 'risk' for short).
</p>

### Evolution through time 

The next stage of the model is focused on inferences about the systematic risk. The remainder of the modeling will be working with them on the log-scale:

$$\phi_{i,t} = log(\eta_{i,t}).$$

Systematic levels of risk typically evolve over time (except in catastrophes, when they jump up). We can view the (unknown) rate as a movement from its own value in the previous time period, helping to narrow down the range of plausible values for it:

$$\phi_{i,t} = \phi_{i, t-1} + \epsilon_{i,t},$$

or equivalently,

$$\phi_{i,t} \sim Normal(\phi_{i, t-1}, \tau^2).$$

Estimating the scale parameter for that normal distribution gives us the characteristic amount of year-to-year variability in the rates. This is known as a random walk or first-difference model. 

We will add an auto-regressive (AR) coefficient to this model, rather than keep it fixed at 1 (as implied above):

$$\phi_{i,t} \sim Normal(\beta \cdot \phi_{i, t-1}, \tau^2).$$

If we were to stop at this point we would have a perfectly valid model for our state incidence rates (understanding that we still need to assign some prior distributions for the parameters). To model the evolution of mortality rates in 50 states, for example, we would simply apply this auto-regressive Poisson model to each state (one model per state). We could do them all at once so that they all share the same AR coefficient; or all the AR coefficients could be fixed at 1; or each state could have its own AR coefficient. But in any case, the results may be perfectly usable for public health monitoring. 

### Spatial auto-regression 

Now let's start over and look at the rates differently. Instead of the time series auto-regression, we could improve our inferences about any given mortality rate by looking at the rates that are nearby and/or part of the same geographic region. Geographic trends are typically weaker than trends in time, so we won't consider fixing the auto-correlation parameter at 1, as we did above.

<p>
A spatial auto-regression for our log-mortality rates \( \phi_{,t} \)  may be written in matrix notation as

$$\phi_{,t} = \mu + \rho \cdot C (\phi_{,t} - \mu) + \epsilon,$$

where \( \rho \) is an auto-correlation parameter, \( C \) is a connectivity matrix (more below), and \( \mu \) is an intercept (we could add covariates here too, but we won't). \( \phi_{,t} \) is an \( S \)-length vector, a snapshot at time \( t \) of mortality for all \( S \) locations. The equation states that our expectations for \( \phi_{i,t} \) will be informed by the overall average rate \( \mu \), by the values near to the \( i \)th location, and by the overall degree of spatial auto-correlation \( \rho \). 
</p>

<p>
A comparison with a more standard model may be helpful. Remember that this part of the model is our prior distribution for the rates \( \phi \) (for the moment, these could be an \( S \)-length vector, or an \( S \times T \) vector). A simple prior probability model could state that the mortality rates should display some characteristic amount of variation \( \tau \) around a center of gravity \( \mu \):

$$\phi_{i,t} \sim Normal( \mu, \tau^2).$$

As a prior distribution, this will assign low probability to values of \( \phi_{i,t} \) that are uncharacteristically far from \( \mu \). Once we have made an inference about the values of \( \mu \) and \( \tau \), we are positioned to say just what kind of value is 'uncharacteristic'. Then any crude rates that are 'uncharacteristic' will be assigned a low prior probability, as if to say 'I am skeptical that the systematic risk is as high (or low) as the crude rate alone would indicate'. 
</p>

<p>
What happens next depends on the likelihood. With respect to the crude rates that already contain a lot of information (i.e., they are based on large population sizes), our inferences will not be sensitive to our prior skepticism; the likelihood will overwhelm the prior, and the posterior probability for \( \eta_{i,t} \) will be centered right on the crude rate \( r_{i,t} \). The smaller the population is, the more our inferences will be sensitive to our prior skepticism. That skepticism is saying 'I think the systematic risk here is more like the overall mean \( \mu \), and less like the crude rate'. This is the 'shrinkage' to the mean that hierarchical models often impose on estimates.
</p>

<p>
The main difference here, with our spatial auto-regression, is that we are getting more precise by 'shrinking' our estimates towards a local mean \( \mu + \rho \cdot C (\phi - \mu) \), rather than the overall mean. This can make quite the difference. Mortality rates in Mississippi, for example, may be outliers relative to the national average. But if you understand the U.S. South as a region then it is really inappropriate to impose that kind of skepticism on the rates. Similarly for Appalachia, or for any number of areas at various spatial scales. To use the standard model would be biased (in the common-sense meaning of the word).
</p>

#### The CAR model 

There are multiple ways to translate our concept of an auto-regression from the one-dimensional temporal domain into the two-dimensional spatial domain (Cliff and Ord 1981). We will adopt what is known as the conditionally-specified spatial auto-regressive (CAR) model. The CAR model is a multivariate normal distribution, defined by its covariance matrix:

$$
\begin{aligned}
\phi \sim Normal(\mu, \Sigma) \\
\Sigma = (I - \rho \cdot C)^{-1} M
\end{aligned}
$$

Here we have:

$$
\begin{aligned}
&I:  \text{n-by-n identity matrix} \\
&\rho: \text{spatial auto-correlation parameter} \\
&C: \text{n-by-n connectivity matrix} \\
&M: \text{n-by-n diagonal matrix containing scale parameters,} \tau_i.
\end{aligned}
$$

<p>
The range of values that \( \rho \) can take on is limited by our requirement that \( \Sigma \) be a properly specified covariance matrix; depending on how one creates \( C \), the range may (or may not) be similar to a correlation coefficient: its maximum value may be 1 or less than 1, and its minimum permissible value often differs from \( -1 \). Whatever its range, the spatial dependence parameter of the CAR model does not 'behave' similarly to Pearson's correlation coefficient. A value of 0.9 is a very strong degree of correlation, but it is a more moderate value for the CAR model. (The simultaneously-specified spatial auto-regressive (SAR) model does have an SA parameter that 'behaves' more like the correlation coefficient.)
</p>

<p>
You can find an introduction to spatial connectivity matrices <a href="https://connordonegan.github.io/geostan/articles/spatial-weights-matrix.html">here</a>. <!--- Note that the term 'spatial lag' or 'mean spatial lag' refers to the average of the surrounding values for any given focal location. For focal site \( i \), take its neighboring values \( \phi_{j} \) and calculate their average. If you repeat that for every site \( i \) you obtain an \( S \)-length vector of spatial lags, one for each location. In matrix notation, this is \( \tilde{x} = C x \), where the \( i \)th row of matrix \( C \) contains the weights required to calculate the \( i \)th spatial lag. --->
</p>

<p>
The matrix \( M \) contains variance terms for each location. For our particular implementation of the CAR model, the variances will be sensitive to number of neighbors a site has: more neighbors means more information, thus we will have less uncertainty remaining (encoded as lower variance). When examining a site that has fewer neighbors, we gain less information by considering the neighboring values, so the uncertainty is greater (encoded as higher variance).
</p>

<p>
Specifically, we have a scalar variance parameter \( \tau \) multiplied by the inverse of the weights \( w_i \), where the weights are equal to the number of neighbors. So the diagonal elements of \( M \) are 

$$m_{i,i} = \tau_i = \frac{1}{w_i} \tau.$$
</p>

#### CARs only 

Now lets return to our space-time mortality data. We are specifying an alternative to the simple vector auto-regression approach that we specified earlier. We can proceed in an analogous way, though, by applying the CAR model successively at each time period. Including the likelihood, we have:

$$
\begin{aligned}
&y_{i,t} \sim Poisson(p_{i,t} \cdot exp(\phi_{i,t})) \\
&\phi_{,t} \sim Normal( \mu, \Sigma ).
\end{aligned}
$$

<p>
If desired, one can allow the parameters of the model to vary over time. The mean \( \mu \) can evolve over time, as may the auto-correlation \( \rho \) and and scale \( \tau \) parameters (yielding \(\mu_t, \rho_t, \tau_t \)).
</p>

<p>
The last part of this model is to add prior distributions for those parameters. Because we are working with rates on the log scale, something like this is not unreasonable:
</p>

$$
\begin{aligned}
&\mu \sim Normal( -4, 4) \\
&\tau \sim Normal(0, 1), \tau > 0. 
\end{aligned}
$$

<p>
The spatial auto-correlation parameter \( \rho \) will be assigned a uniform prior distribution across its full support, which is determined by the eigenvectors of \( C \) 
</p>

<p>
Once again, we have a simple way to proceed but it is nonetheless a valid space-time model which can be (and, strictly speaking, is often) applied to public health data.
</p>

### The CAR-AR model 

Now we have two options for modeling our rates: the serial auto-regressive model and the spatial auto-regressive model. Our third approach is to combine them. We model a time trend for each location, and then we apply the CAR model to their cross-sectional errors.

<p>
Altogether, our third model is:

$$
\begin{aligned}
&y_{i,t} \sim Poisson(p_{i,t} \cdot exp( \phi_{i,t}) ) \\
&\phi_{,t} \sim Normal(\beta \cdot \phi_{, t-1}, \Sigma ), t > 1 \\
&\phi_{,1} \sim Normal( \mu, \Sigma) \\
&\Sigma = (I - \rho \cdot C)^{-1} M,
\end{aligned}
$$

where we reserve the option to make any of the scalar parameters vary over time \( t \) or geography \( i \) (the possibilities indicated roughly by: \( \mu_t, \beta_t, \beta_i, \rho_t, \tau_t \) ).
</p>

That amounts to a complex space-time auto-correlation structure, but with this framework there is no need to specify the implied (potentially massive) covariance matrix (nor do we require a series of complementary 'random effect' parameter vectors). As Wikle, Berliner, and Cressie write,

> The Bayesian hierarchical strategy that we propose allows complicated structure to be modelled in terms of means at various stages, rather than a model for a massive joint covariance matrix. (118)

<p>
For example, our inference about one rate \( \eta_{i, t} \) will be informed directly by its own past value \( \eta_{i, t-1} \) and therefore indirectly by the past values of neighboring values. 
</p>

<p>
Another advantage of this particular (CAR-AR) model is that it maintains the distinction between serial and spatial auto-correlation. The two are usually not of the same degree, with the former generally being stronger than the latter. Hence, containing both an AR parameter \( \beta \) and an SA parameter \( \rho \) is a positive feature of this model. Another virtue is that the CAR-AR model can be reduced to either of its two component parts and still yield a reasonable model. It can be expanded with space- or time-varying parameters, though I suspect that provides more flexibility than most projects warrant.
</p>

<p>
Because the CAR and AR models are proper probability models, we don't have to worry about imposing additional constraints on any parameter vectors to make them identifiable. In short, the CAR-AR model has a number of advantages that distinguish it from the BYM/Knorr-Held framework.  <!--- The reason that the model of Besag, York, and Mollié (1991) was important is that the proper CAR model faced serious computational difficulties. Combining the intrinsic CAR (ICAR) model with a non-spatial 'random effect' can mimic a proper spatial auto-regression very well. Were it not for other drawbacks and limitations of the ICAR/BYM framework (like sum to zero constraints and coding challenges to handle disconnected graph structures), the benefits from have a computationally feasible proper CAR model would be more minimal than they are. --->
</p>

Next we are going to take a look at the mortality data, and then we'll implement each of our three model specifications using Stan and R.

## The mortality data 

I accessed mortality data from the CDC Wonder database and restricted the request to females between the ages of 35 and 44. I then cleaned up the column names. I'll be using R for this. You can download the data abstract from my github page:

{% highlight r %}
# data is stored here
dat_path <- "https://raw.githubusercontent.com/ConnorDonegan/connordonegan.github.io/refs/heads/main/assets/2025/space-time-mortality/cdc-mortality.txt"

# read the data into R
dat <- read.table(dat_path, header = TRUE)    
{% endhighlight %}

Here is a look at the columns of interest:

{% highlight r %}
# exported using tableHTML::tableHTML()
dat |>
    head(5) |>
    subset(select = c(Year, State, Deaths, Population)) |>
    print()
{% endhighlight %}



<table style="border-collapse:collapse;" class="table_1174" border="1">
<caption>A glimpse of the mortality data, females aged 35–44 only.</caption>
<thead>
<tr>
  <th id="tableHTML_header_1">Year</th>
  <th id="tableHTML_header_2">State</th>
  <th id="tableHTML_header_3">Deaths</th>
  <th id="tableHTML_header_4">Population</th>
</tr>
</thead>
<tbody>
<tr>
  <td id="tableHTML_column_1">1999</td>
  <td id="tableHTML_column_2">Alabama</td>
  <td id="tableHTML_column_3">728</td>
  <td id="tableHTML_column_4">351301</td>
</tr>
<tr>
  <td id="tableHTML_column_1">2000</td>
  <td id="tableHTML_column_2">Alabama</td>
  <td id="tableHTML_column_3">650</td>
  <td id="tableHTML_column_4">350582</td>
</tr>
<tr>
  <td id="tableHTML_column_1">2001</td>
  <td id="tableHTML_column_2">Alabama</td>
  <td id="tableHTML_column_3">713</td>
  <td id="tableHTML_column_4">346986</td>
</tr>
<tr>
  <td id="tableHTML_column_1">2002</td>
  <td id="tableHTML_column_2">Alabama</td>
  <td id="tableHTML_column_3">701</td>
  <td id="tableHTML_column_4">340884</td>
</tr>
<tr>
  <td id="tableHTML_column_1">2003</td>
  <td id="tableHTML_column_2">Alabama</td>
  <td id="tableHTML_column_3">674</td>
  <td id="tableHTML_column_4">335121</td>
</tr>
</tbody>
</table>


We'll plot the crude rates for each state as a time trend, reported as deaths per 100,000 at risk.

{% highlight r %}
scale = 100e3
col = rgb(0.1, 0.4, 0.6, 0.5)

# set plot margins
par(mar = c(2.5 ,2.5, 0, 0))

# find y-axis limits
ylim = scale * range( dat$Deaths/dat$Population )

# make a frame for the plot
plot(x = range(dat$Year),
     y = ylim,
     t = 'n',
     bty = 'l',
     xaxt = 'n', # add axes below
     yaxt = 'n',
     xlab = NA,
     ylab = NA)
axis(1, lwd.ticks = 0.5, lwd = 0); axis(2, lwd.ticks = 0.5, lwd = 0)

# plot crude rates by state
for (st in unique(dat$State)) {
    dst <- subset(dat, State == st)
    lines(dst$Year,
          scale * dst$Deaths/dst$Population,
          col = col)
}
{% endhighlight %}


<center>
<figure>
<img src="/assets/{{ page.date | date: "%Y" }}/{{ page.slug }}/crude-rates-time.png" style="width:75%">
<figcaption> <em>U.S. state female mortality rates per 100,000, ages 35&ndash;44, 1999&ndash;2020. </em> </figcaption>
</figure>
</center>


## Multiple AR models in Stan 

This is the first of three model specifications that we will build. In this part, we model time trends for each state using the hierarchical Poisson AR models discussed above. We will apply one AR time trend model for each state.

The notation used above to describe the AR models was working element-wise, calculating probability densities for each observation. We want to vectorize the calculations as much as possible (avoid 'for' loops).

<p>
We pass the observations to Stan as an \( S \times T \) array. 
</p>

{% highlight stan %}
data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // outcome variable
  array[TT] vector[S] log_pop;   // offset; logdenominator in the rate 'y/pop'
}
{% endhighlight %}

Then we can declare our scalar parameters plus an array of rates <code> phi </code> \(\phi\).

{% highlight stan %}
parameters {
  real alpha;          // overall mean Log mortality rate
  real<lower=0> tau;   // scale of variation
  real<lower=-1, upper=1> beta_ar;  // auto-regressive coefficient
  array[TT] vector[S] phi;          // log mortality rates  
}
{% endhighlight %}

Inside the <code>model</code> block, we are going to create another array, <code>phi_mu</code>, to store the mean of our model for the rates. For the first time period, our model for the rates \( \phi_{i,1} \) is

$$\phi_{i,1} \sim Normal( \alpha, \tau^2).$$

For all other times the model is

$$\phi_{i,t} \sim Normal( \beta \cdot \phi_{i, t-1}, \tau^2).$$

So our model block begins like this, looping over each time period, creating the mean as appropriate:

{% highlight stan %}
model {
  array[TT] vector[S] phi_mu;
  
  for (tt in 1:TT) {
      if (tt == 1) {
      phi_mu[1] = rep_vector(alpha, S);
      } else {
      phi_mu[tt] = beta_ar * phi[tt-1];   
      }
}      
{% endhighlight %}

Now we can vectorize the log-probability density calculation, using the normal distribution for the prior model and the Poisson distribution for the likelihood (adding these inside the same 'for' loop in the model block):
{% highlight stan %}
      target += normal_lpdf(phi[tt] | phi_mu[tt], tau);
      target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi[tt]);
{% endhighlight %}

We then add prior distributions for the scalar parameters:

{% highlight stan %}
  target += normal_lpdf(alpha | -4, 4);
  target += uniform_lpdf(beta_ar | -1, 1);
  target += std_normal_lpdf(tau);  
{% endhighlight %}

Lastly, we are going to collect samples of the log-likelihood of each observation. We will use these later for model comparison. We have to loop over every observation to complete these calculations. 

{% highlight stan %}
generated quantities {
  array[TT] vector[S] log_lik;
    for (tt in 1:TT) {
      for (i in 1:S) log_lik[tt, i] = poisson_log_lpmf(y[tt, i] | log_pop[tt, i] + phi[tt, i]);   
    }
}
{% endhighlight %}

The loop is not computationally expensive, but storing large arrays of parameters can slow things down with large \(N\). 


<details class="details-example">
    <summary>Click for the complete AR Stan model</summary>
{% highlight r %}
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
      if (tt == 1) {
      	 phi_mu[1] = rep_vector(alpha, S);
      } else {
      	phi_mu[tt] = beta_ar * phi[tt-1];
      }
      target += normal_lpdf(phi[tt] | phi_mu[tt], tau);
      target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi[tt]);
      }

  target += normal_lpdf(alpha | -4, 4);
  target += uniform_lpdf(beta_ar | -1, 1);
  target += std_normal_lpdf(tau);  // half-normal+, due to constraint on tau
}

generated quantities {
  array[TT] vector[S] log_lik;
    for (tt in 1:TT) {
      for (i in 1:S) log_lik[tt, i] = poisson_log_lpmf(y[tt, i] | log_pop[tt, i] + phi[tt, i]);   
    }
}
{% endhighlight %}
</details>

<p>
Our mortality data is stored in the data.frame <code>dat</code>. Creating arrays with the proper order requires a bit of care. We will first order our data.frame by state and year, and then prepare the list of data for Stan:
</p>

{% highlight r %}
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
{% endhighlight %}

<details class="details-example">
    <summary>Click here for practice creating arrays in R, they are tricky</summary>
{% highlight r %}
# notice: there's no warning for size mis-match; and the values fill up column-wise 
x = 1:13
array(x, dim = c(3, 4)) |>
  print()
{% endhighlight %}
<pre>
          [,1] [,2] [,3] [,4]
    [1,]    1    4    7   10
    [2,]    2    5    8   11
    [3,]    3    6    9   12
</pre>

This one allows for a visual check of the order [someone made a mistake with arrays today]
{% highlight r %}
# output not shown
states_array <- array(dat$State, dim = c(TT, S))
states_array[1,]
states_array[,1]
print( states_array )
{% endhighlight %}
</details>

Now we can compile the model and draw samples:

{% highlight r %}
# path to the file where the Stan model code is saved
mod_file <- "assets/2025/space-time-mortality/ARs.stan"

# compile the model
ar_model <- stan_model(mod_file)

# MCMC parameters
iter = 1e3
cores = 4

# sampling
S1 <- sampling(car_ar,
               data = stan_dl, 
               iter = iter, 
               cores = cores)

# print summary
print(S1, pars = c('alpha', 'beta_ar', 'tau'))
{% endhighlight %}
<pre>
Inference for Stan model: anon_model.
4 chains, each with iter=1000; warmup=500; thin=1; 
post-warmup draws per chain=500, total post-warmup draws=2000.

 mean se_mean   sd  2.5%   25%   50%   75% 97.5% n_eff Rhat
alpha   -6.55   0 0.01 -6.57 -6.56 -6.55 -6.54 -6.53  26881
beta_ar  1.00   0 0.00  1.00  1.00  1.00  1.00  1.00  25911
tau  0.07   0 0.00  0.07  0.07  0.07  0.07  0.08   8691

Samples were drawn using NUTS(diag_e) at Thu Jan  9 17:40:14 2025.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
</pre>

Before moving on, we are going to grab some results for Alaska and Hawaii. We'll come back for these later.
{% highlight r %}
# eta = exp(phi)
eta <- as.matrix(S1, "phi") |>
    exp()

# eta for Alaska 
ak_tmp <- grep('Alaska', states) 
ak_idx <- grep(paste0(',', ak_tmp, '\\]'), colnames(eta))
eta_ak <- eta[ , ak_idx ]

# eta for Hawaii
hi_tmp <- grep('Hawaii', states) 
hi_idx <- grep(paste0(',', hi_tmp, '\\]'), colnames(eta))
eta_hi <- eta[ , hi_idx ]
{% endhighlight %}

## Multiple CAR models in Stan 

Our CAR models require two data inputs than are not in AR models: (1) a spatial connectivity matrix, and (2) some quantities that will help us calculate (more quickly) the probability density for the CAR model.

Also, before getting started, note that we will be dropping Hawaii and Alaska from the modeling at this point. Why? Because they are far from all the other states (physically and otherwise), so they won't benefit from this type of model. The AR Poisson model would suffice for those states.

We are going to prepare the spatial data first, then we'll work on our Stan model.

### Preparing the spatial data 

I will use the 'geostan' (Donegan 2022) R package for help with the CAR models, 'tigris' (Walker 2023) to download some cartographic boundaries, and 'sf' (Pebesma 2018) for GIS operations and mapping.

{% highlight r %} 
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
{% endhighlight %}

The CAR models we are using here are implemented in 'geostan', which uses the <code>prep_car_data</code> function to convert a connectivity matrix into the data required by the Stan model. So we can use that here as well:

{% highlight r %}
# Create an adjacency matrix 
C <- shape2mat(geo, "B", method = "rook")

# Convert C to a list of data for CAR models
car_parts <- prep_car_data(C, "WCAR")
{% endhighlight %}
<pre>
Contiguity condition: rook
Number of neighbors per unit, summary:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  1.000   3.000   4.000   4.367   6.000   8.000 

Spatial weights, summary:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
      1       1       1       1       1       1 
Range of permissible rho values: -1.392, 1
</pre>

<details class="details-example">
    <summary>Click for distance-based connectivity</summary>
This code snippet shows how to create a distance-based CAR specification. Details can be found in the OSF preprint on CAR models in Stan (Donegan 2021).

 For our model, the adjacency-based connectivity matrix is a better option. You can try both and compare using DIC and residual diagnostics.
 
{% highlight r %}
# A matrix of pairwise distances
D <- sf::st_distance(sf::st_centroid(dat_shp)) |>
    units::set_units(km)

# Keep it sparse! You could also clip using a distance threshold, or nearest neighbor criterion
D <- C * D

# Convert D to data list for CAR models 
# a proper DCAR specification: connectivity is proportional to distance
dcar_dl <- prep_car_data(D, 'DCAR', k = 1)

# how to create an inverse distance matrix
# (this is done internally by prep_car_data when type='DCAR')
k <- 1
gamma <- 0
D_inv <- D
D_inv[D_inv > 0] <- (D[ D > 0] + gamma)^(-k)
# scaled by maxium value
max.dinv <- max(D_inv)
D_inv <- D_inv/max.dinv

# A different specification: row-standardized inverse-distances
# use D_inv as data input; prep_car_data (type='WCAR') will do the row-standardization
# Here, weights are Not proportional to distance: each location/node has its own scaling
# (we are hacking the popular WCAR specification)
dwcar_dl <- prep_car_data(D_inv, 'WCAR')
{% endhighlight %}
</details>

<p>
Now we need to create our data list again (now \( S = 49 \)) and then append the the CAR parts to it:
</p>

{% highlight r %}
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
{% endhighlight %}

Before starting, we can examine Moran's I, the index of spatial auto-correlation, at teach time point (this 'geostan' <a href="https://connordonegan.github.io/geostan/articles/measuring-sa.html">vignette</a> provides a short introduction to Moran's I, which is also known as the Moran coefficient).

{% highlight r %}
# Moran's I index of spatial autocorrelation, by year
# x = crude rates
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
{% endhighlight %}
<pre>
 [1] 0.371 0.302 0.329 0.449 0.335 0.367 0.456 0.372 0.385 0.376 0.453 0.433 0.370
[14] 0.456 0.416 0.412 0.366 0.379 0.391 0.424 0.344 0.387
</pre>

The results indicate moderately positive SA. A quick eyeball analysis suggests that the degree of SA was not changing much over time (it seems to be bouncing around 0.38, without any trend).

### CAR models in Stan 

It is possible to use Stan's built-in multivariate normal distribution functions to fit CAR models. But we want to take advantage of the fact that the connectivity matrix is sparse, as this allows us to use sparse matrix multiplication. We can also use some well-known tricks for calculating the log-determinant of the covariance matrix. For details, see the OSF preprint on CAR models in Stan (Donegan 2021). According to that study, these models can sample about 10 times faster than CAR models in Nimble (a popular R package for MCMC with spatial models).

First, we will define a custom <code> _lpdf</code> function in Stan. Second, we will update the <code>data</code> block of our Stan model. Third, we will update the <code>parameters</code> and <code>model</code> blocks.

Below is our custom Stan function for calculating the log-probability of the CAR model, <code>wcar_normal_lpdf</code>. For present purposes, just save this in a file (in your working directory) with the name <code>car_lpdf.stan</code>.

{% highlight stan %}
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

{% endhighlight %}


<details class="details-example">
    <summary>Click here for a more generally applicable CAR model</summary>
   The <code> wcar_lpdf </code> function is usually what you need. If you fit distance-based CAR models, you need a more general specification. The WCAR is generally faster than this, but this is still pretty good. This one works for any valid CAR specification (including WCAR). Again, see Donegan (2021) for details.
   
{% highlight stan %}
/**
 * Log probability density of the conditional autoregressive (CAR) model
 *
 * @param y Process to model
 * @param mu Mean vector
 * @param tau Scale parameter
 * @param rho Spatial dependence parameter
 * @param C_w Sparse representation of C
 * @param C_v Column indices for values in C
 * @param C_u Row starting indices for values in C
 * @param D_inv Diagonal elements from the inverse of Delta, where M = Delta * tau^2 is a diagonal matrix containing the conditional variances.
 * @param log_det_D_inv Log determinant of Delta inverse
 * @param lambda Eigenvalues of C (or of the symmetric, scaled matrix Delta^{-1/2}*C*Delta^{1/2}).
 * @param n Length of y
 *
 * @return Log probability density of CAR model up to additive constant
*/
real car_normal_lpdf(vector y, vector mu,
		     real tau, real rho,
		     vector C_w,
		     array[] int C_v,
		     array[] int C_u, 
		     vector D_inv,
		     real log_det_D_inv,
		     vector lambda,
		     int n) {
  vector[n] z = y - mu;
  vector[n] zMinv = (1 / tau^2) * z .* D_inv; 
  vector[n] ImrhoCz = z - csr_matrix_times_vector(n, n, rho * C_w, C_v, C_u, z); 
  real ldet_ImrhoC = sum(log1m(rho * lambda));
  return 0.5 * (
		-n * log( 2 * pi() )
		- 2 * n * log(tau)
		+ log_det_D_inv
		+ ldet_ImrhoC        
		- dot_product(zMinv, ImrhoCz)
		);
}

{% endhighlight %}
</details>


To make this function available to our Stan model, we put it in the <code> functions </code> block at the top of the file:

{%highlight stan %}
functions {
#include car_lpdf.stan
}
{% endhighlight %}



Below are the data inputs we require (add these to the <code> data </code> block). Each of these items is already found in our <code>stan_dl</code> list, thanks to the <code>geostan::prep_car_data</code> function.

{% highlight r %}
  // CAR parts
  int nA_w;
  vector[nA_w] A_w; 
  int A_v[nA_w];
  int A_u[S + 1];
  vector[S] Delta_inv;
  real log_det_Delta_inv;
  vector[S] lambda;
{% endhighlight %}

Our <code>parameters</code> block now needs: an intercept <code>alpha</code>, a scale parameter <code>tau</code> (allow positive values only in the declaration), and an SA parameter <code>rho</code>. Permissible values for the SA parameter are determined by the eigenvalues <code>lambda</code> (we saw those printed to the R console when we used <code>prep_car_data</code>).

{% highlight stan %}
parameters {
  real alpha; 
  real<lower=0> tau;
  real<lower=1/min(lambda), upper=1/max(lambda)> rho;
  array[TT] vector[S] phi;  
}
{% endhighlight %}

In our <code>model</code> block, we will use <code>phi_mu</code> again, but in this case <code>phi_mu</code> is just a constant intercept. When we loop through the time periods, we calculate the CAR model (prior distribution) and then the Poisson (likelihood). The priors on our scalar parameters are the same as previously, except we drop the AR coefficient. The prior for <code>rho</code> is uniform across its full support (we don't need to declare that in Stan, its the default).

(Again, we could allow <code>alpha</code>, <code>tau</code>, and <code>rho</code> to vary over time. In that case, we would declare them as vectors in the <code>parameters</code> block, then adjust the loop as needed; e.g., assign <code>alpha[tt]</code> to <code>phi_mu</code> inside the 'for' loop. My intuition is that this is all or nothing: I would not allow one parameter to vary while fixing the others. They are not independent of one another.)

{% highlight stan%}
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
     target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi[tt]);			       			    
  }
  
  target += normal_lpdf(alpha | -4, 4); 
  target += std_normal_lpdf(tau);
}
{% endhighlight %}


<details class="details-example">
    <summary>Click here for the complete 'multiple CARs' Stan model</summary>
{% highlight stan %}  
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
    target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi[tt]);			       
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

{% endhighlight %}
</details>

### Running the CAR models 

Save the Stan model code in a file named 'CARs.stan'. Then we sample from the model and print some results. On my laptop, sampling completed in 5.5 seconds per chain; using parallel processing, the full runtime was 14 seconds.

There were no warnings from Stan, and the summary printout shows that the effective sample sizes are more than adequate for inference. For the purposes of disease mapping its important to check diagnostics for the log-rate estimates <code>phi</code>; we can examine those using <code>print(S2)</code>. Doing so (not shown below), we find that the effective samples sizes (ESS) for the log-rates are all quite high (over 2,000 and over 3,000), and the R-hats are all 1.00. 

{% highlight r %}
# compile the model
car_model <- stan_model("assets/2025/space-time-mortality/CARs.stan")

# Sampling. 
iter = 1e3
cores = 4

S2 <- sampling(car_model,
               data = stan_dl, 
               iter = iter, 
               cores = cores)

# print summary of results for main parameters
print(S2, pars = c('alpha', 'rho', 'tau'))
{% endhighlight %}
<pre>
Inference for Stan model: anon_model.
4 chains, each with iter=1000; warmup=500; thin=1; 
post-warmup draws per chain=500, total post-warmup draws=2000.

       mean se_mean   sd  2.5%   25%   50%   75% 97.5% n_eff Rhat
alpha -6.52       0 0.02 -6.56 -6.54 -6.52 -6.51 -6.49  2645    1
rho    0.93       0 0.02  0.89  0.92  0.93  0.94  0.96  2319    1
tau    0.37       0 0.01  0.35  0.36  0.37  0.38  0.39  1650    1

Samples were drawn using NUTS(diag_e) at Fri Jan 10 08:07:12 2025.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
</pre>


## The CAR-AR model in Stan 

Finally, we can fit our full CAR-AR model. We don't need to make any changes to our <code>stan_dl</code> data list (after the CAR models). We have all the peices ready for the Stan model, too, we just need to put them together.

To create this model, I started by copying and pasting the contents of <code>'ARs.stan'</code> into a new file named <code>'CAR_AR.stan'</code>. Relative to <code>'ARs.stan'</code>, only the following changes are needed:

 - Add a <code>functions</code> block with our <code>#include car_lpdf.stan</code> line.
 
 - In the <code>data</code> block, make sure you add the CAR parts. You can copy and paste from <code>CARs.stan'</code>.

 - In the <code>parameters</code> block, include all of our parameters: <code>alpha</code>, <code>rho</code>, <code>tau</code>, <code>beta_ar</code>, and <code>phi</code>. 

 - Finally, in the <code>model</code> block, we need to replace the <code>normal_lpdf</code> with our <code>wcar_normal_lpdf</code>. Again, you can copy and paste from <code>'CARs.stan'</code>.

After making those changes, the <code>'CAR_AR.stan'</code> file will look like this:

{% highlight stan %}
functions {
#include car_lpdf.stan
}

data {
  int S; 
  int TT; 
  array [TT, S] int y;  
  array[TT] vector[S] log_pop;   
  
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

{% endhighlight %}

We are ready to go now:

{% highlight r %}
car_ar_model <- stan_model("assets/2025/space-time-mortality/CAR_AR.stan")

iter = 1e3
cores = 4

S3 <- sampling(car_ar_model,
   data = stan_dl, 
   iter = iter, 
   cores = cores)

print(S3, pars = c('alpha', 'beta_ar', 'rho', 'tau'))
{% endhighlight %}
<pre>
Inference for Stan model: anon_model.
4 chains, each with iter=1000; warmup=500; thin=1; 
post-warmup draws per chain=500, total post-warmup draws=2000.

         mean se_mean   sd  2.5%   25%   50%   75% 97.5% n_eff Rhat
alpha   -6.56       0 0.04 -6.64 -6.58 -6.56 -6.53 -6.48  3019 1.00
beta_ar  1.00       0 0.00  1.00  1.00  1.00  1.00  1.00  2035 1.00
rho      0.98       0 0.01  0.96  0.97  0.98  0.98  0.99  1731 1.00
tau      0.09       0 0.00  0.08  0.08  0.09  0.09  0.09   426 1.02

Samples were drawn using NUTS(diag_e) at Fri Jan 10 08:56:57 2025.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
</pre>

On my laptop, sampling finished in 23 seconds. Stan issued a warning about bulk effective sample size (ESS) being low. There is a low threshold for warnings, which is good. In this case, the results are fine for analysis: the parameter with lowest ESS is <code>tau</code> (426), and ESS for the log-rates and log-likelihoods are all in the thousands.

I'm guessing that the warning was issued because the ESS for <code>lp__</code> is only 366. The <code>lp__</code> is the log-probability; I take this as an indicator for ESS that is relevant for <em>joint probabilities</em>, like differences between rates. So it is a fair ESS warning, although still fairly conservative.

If these results were being reported in a publication, I would run this again with more samples (<code>iter = 2e3</code> or so should be fine).

There is one interesting feature of these results already. The estimate for <code>rho</code> is 0.98, which is actually <em>higher</em> than it was in the 'CARs only' model. Why? The CAR model here is applied to deviations from the state time trends (the AR residuals). My reading of this is that the mortality rates for neighboring states are more similar in their year-by-year movements than they are in their levels.

## Model comparison 

For each of our three models, we collected samples for the log-likelihoods. Those are for computing information criteria. I will use the DIC for these models. 

(You can use WAIC if you want to; if you check diagnostics using the 'loo' R package, you may find that the diagnostics are crap for your spatial models. As I understand it, that is just a feature of WAIC with auto-correlated data, and it does not necessarily indicate a problem with your model.)

This code first defines an R function to calculate DIC from a Stan model (the model must contain a <code>log_lik</code> parameter vector), and then applies it to our three models:

{% highlight r %}
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
    model = c('ARs', 'CARs', 'CAR-AR')
  )
{% endhighlight %}
<pre>
       DIC penalty  model
1 10536.99  804.73     AR
2 10517.93 1066.08    CAR
3 10001.27  624.69 CAR-AR
</pre>

For interpretation: lower values of DIC indicate a better fit, and small differences between DICs are not to be given much weight.

The 'CARs only' model looks similar to the AR-only model, while the CAR-AR model has considerably lower DIC than both of the others (a difference of at least -500, including a considerably smaller penalty term). We'll use the CAR-AR model for final section.

## Visualizing mortality trends 

Using the CAR-AR model results, we will first plot time trends for a selection of states. Next we'll map mortality for 2020. Finally, we'll chart percent change in mortality rates from 1999 to 2019 (stopping just before the pandemic). 

### Model-based time trends 

<p>
Here we need to summarize MCMC samples by state and year. Once we extract a matrix of samples for <code>phi</code> (\( \phi \)), we exponentiate them to get the rates \( \eta \). Then we need to identify which columns correspond to whatever state we are interested in. The regular expressions found in the code below are introduced for that task.
</p>

For each state, we do the following:

 - Identify its corresponding column positions in <code>eta</code>. Each state has 22 columns in <code>eta</code>, one per year. Each year has 2,000 MCMC samples.
 - Summarize the posterior probability distribution at each year: calculate the mean of the samples, and extreme quantiles (2.5%, 97.5%).
 - Plot the mean (our estimate of the trend mortality risk) with credible intervals.



{% highlight r %}
# parameters for the graphics device
par(mfrow = c(3, 3),
    mar = c(2, 3.5, 2, 2)
    )

# ordered states, for matching states to model parameters
states <- geo$State

# select a few states
selection <- c("Idaho", "Oregon", "California",
               "Mississippi", "Louisiana", "Alabama",
               "West Virginia", "Pennsylvania", "Delaware")

# rates, eta: these are indexed and named as:  
#    phi[time_index, state_index]
# Exponentiate phi to get eta (do that before any other calculations)
eta <- as.matrix(S3, "phi") |>
    exp()

# find the index positions for our states: change 'Alabama' to '1', etc.
state_expr <- paste0(selection, collapse = "|") 
( state_index <- grep(state_expr, states) )
{% endhighlight %}
<pre>
[1]  1  4  7 11 17 23 36 37 47
</pre>

{% highlight r %}
# regular expression; we will use these to select columns of eta
( state_expr = paste0(',', state_index, ']') )
{% endhighlight %}
<pre>
[1] ",1]"  ",4]"  ",7]"  ",11]" ",17]" ",23]" ",36]" ",37]" ",47]"
</pre>

{% highlight r %}
# rates are per 100,000
scale = 100e3

# for shaded cred. intervals
col = rgb(0.1, 0.4, 0.6, 0.4)

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

    # match each state to its column position in eta
    index_eta_s <- grep(state_expr[s], colnames(eta))

    # dim(eta_s) is (2000, 22)
    # one row per MCMC sample; one column per year
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
{% endhighlight %}


<center>
<figure>
<img src="/assets/{{ page.date | date: "%Y" }}/{{ page.slug }}/model-time-trends.png" style="width:100%">
<figcaption> <em>Time trends in young-adult female mortality, select states.</em> </figcaption>
</figure>
</center>

### Mapping mortality 

<p>
Here we map mortality rate estimates for the year 2020. We'll start again by getting our matrix samples for \( \eta \), then we extract the columns corresponding to \( t = 22 \) (year 2020). 
</p>

{% highlight r %}
# rates per 100,000
scale = 100e3

# MCMC samples for the rates, eta
eta <- as.matrix(S3, pars = "phi") |>
    exp()
    
# most recent period (t=22), 2020    
t_idx <- grep('\\[22,', colnames(eta))
t_eta <- eta[ , t_idx ] 
est_2020 <- apply(t_eta, 2, mean) * scale
{% endhighlight %}

<p>
This function takes a vector of values \( x \), break points for assigning values to cateries, and a color palette. It returns a vector with appropriate colors from the palette together with labels for our map legend. The palette is from <a href="https://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3">ColorBrewer</a>.
</p>

{% highlight r %}
# for thematic mapping
map_pars <- function(x,
                     brks,
                     pal = c('#b2182b','#ef8a62','#fddbc7','#d1e5f0','#67a9cf','#2166ac'),
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
{% endhighlight %}

I'm using the <code>classInt</code> package to create the breaks (Bivand 2023).

{% highlight r %}
library(classInt)

# create cut-points for legend categories
x_cut <- classIntervals(est_2020, n = 6, style = "jenks")

# create map data (colors, legends)
mp <- map_pars(x = t_est,
               brks = x_cut$brks,
               pal = proj_pal)

# create map
par(mar = rep(0, 4), oma = rep(0, 4))
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
{% endhighlight %}

<center>
<figure>
<img src="/assets/{{ page.date | date: "%Y" }}/{{ page.slug }}/model-map-2020.png" style="width:100%" alt = "Choropleth map of U.S. states">
<figcaption> <em>U.S. state female mortality, ages 35&ndash;44, year 2020. </em> </figcaption>
</figure>
</center>


### Percent change analysis 

<p>
This is our last analysis. We will use our matrix of MCMC samples for the rates \( \eta \) to produce samples from the posterior probability distributions for our quantities of interest, namely percent change over time. Then we will summarize those samples and put them into a figure that displays the change in mortality rates for each state plus D.C.
</p>

{% highlight r %}
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
{% endhighlight %}

We can bring in Alaska and Hawaii from our AR-only model:

{% highlight r %}
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
{% endhighlight %}

Now we add the summary of the results to a figure, displaying the states in order of their percent change while illustrating the range of plausible estimates with credible intervals.

{% highlight r %}
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

par(mar = c(4, 13, 2, 2),
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
    axes = FALSE,
    bg = 'red' 
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
{% endhighlight %}

<center>
<figure>
<img src="/assets/{{ page.date | date: "%Y" }}/{{ page.slug }}/model-chart-pct-change.png" style="width:100%" alt = "Point-interval chart with gray background and labels providing each state's mortality rate with 95% credible intervals.">
<figcaption> <em>Percent change analysis results.</em> </figcaption>
</figure>
</center>


## Time-varying parameters 

We can easily adjust our Stan models to specify time-varying parameters. Exploratory analysis and standard model comparison techniques (or workflows) can assist in deciding whether such an expansion of the model is worthwhile to consider. Our bit of exploratory analysis (time plots and Moran's I) suggest that this level of flexibility is not warranted in this case. 

For the AR only model, we can potentially allow the AR coefficient and the scale parameter to vary over time. (The intercept only applies to the first time period anyways.)

For the CARs only model, we can allow the intercept, spatial dependence, and scale parameters to vary with time.

For the CAR-AR model, the AR coefficient, spatial dependence, and scale parameters can vary with time. (The intercept only applies to the first time period anyways.)

We may want to be able to switch back and forth easily, between fixed and time-varying parameters. In the <code>data</code> block, start by introducing a binary indicator <code>fixed_ar</code>, which takes a value of either 0 or 1. Do the same with <code>fixed_tau</code>. 

{% highlight stan %}
  int<lower=0,upper=1> fixed_ar;
  int<lower=0,upper=1> fixed_tau;
{% endhighlight %}

We will use the <code>fixed_ar</code> indicator as a 'switch' when declaring the parameter <code>beta_ar</code>. If we declare <code>beta_ar</code> to be a vector, we can use the switch to decide if it should be length 1 or length <code>TT</code>:

{% highlight stan %}
 vector<lower=-1, upper=1>[fixed_ar ? 1 : TT-1] beta_ar;
{% endhighlight %}

Inside the square brackets is a conditional statement. You can read it as an 'if-else' statement: "If fixed_ar equal 1, make beta_ar a vector of length 1; otherwise, make it a vector of length TT-1." (It needs to be TT-1 because the first time period does not have a past value to use, instead its centered on the intercept.)

Similarly, use the appropriate indicator when declaring <code>tau</code> as a vector:

{% highlight stan %}
  vector<lower=0>[fixed_tau ? 1 : TT] tau;
{% endhighlight %}

We can use the same technique in the <code>model</code> block, using the contitional statement to determine the right option 'on the fly':

{% highlight stan %}
  for (tt in 1:TT) {
    if (tt == 1) {
     phi_mu[1] = rep_vector(alpha, S);
    } else {
     phi_mu[tt] = beta_ar[fixed_ar ? 1 : tt-1] * phi[tt-1]; 
    }
    target += normal_lpdf(phi[tt] | phi_mu[tt], tau[fixed_tau ? 1 : tt]);
  }
{% endhighlight %}

In terms of our workflow in R, the only modification required is the addition of the indicators:

{% highlight r%}
# for the standard AR-only model
stan_dl$fixed_tau = 1
stan_dl$fixed_ar = 1

# for time-varying AR-only model 
stan_dl$fixed_tau = 0
stan_dl$fixed_ar = 0
{% endhighlight %}

The following drop-down style code blocks contain complete Stan models with options for time-varying parameters. Each also includes a flag for inclusion of the log-likelihood, <code>keep_log_lik</code>. With large N, storing samples of <code>log_lik</code> can reduce computational efficiency, due to memory overload. In that case, you can use this flag to drop those samples unless or until you need to use them.

<details>
<summary>Click for the 'AR only' Stan model with time-varying parameters</summary>
{% highlight stan %}
data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // outcome 
  array[TT] vector[S] log_pop;   // offset
  
  int<lower=0,upper=1> keep_log_lik;
  int<lower=0,upper=1> fixed_tau;
  int<lower=0,upper=1> fixed_ar;  
  
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
  array[TT] vector[S] phi;
  vector<lower=0>[fixed_tau ? 1 : TT] tau;
  vector<lower=-1, upper=1>[fixed_ar ? 1 : TT-1] beta_ar;
}

model {
  vector[S] phi_mu;
  
  for (tt in 1:TT) {
    if (tt == 1) {
       phi_mu = rep_vector(alpha, S);
     } else {
       phi_mu = beta_ar[fixed_ar ? 1 : tt-1] * phi[tt-1];       
     }
    target += normal_lpdf(phi[tt] | phi_mu, tau[fixed_tau ? 1 : tt]);	
			       
    target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi[tt]);
      }

  target += normal_lpdf(alpha | -4, 4);
  target += uniform_lpdf(beta_ar | -1, 1);
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
{% endhighlight %}
</details>

<details>
<summary>Click for the 'CARs only' Stan model with time-varying parameters</summary>
{% highlight stan %}
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

{% endhighlight %}
</details>

<details>
<summary>Click for the full CAR-AR model with options</summary>
This includes the options for time-varying parameters, and it also includes a flag for inclusion of the log-likelihood, <code>keep_log_lik</code>. With large N, storing samples of <code>log_lik</code> can have a major impact on computational efficiency, due to memory overload. So its nice to be able to keep them only when you really want them.
{% highlight stan %}
functions {
#include car_lpdf.stan
}

data {
  int S; // sites
  int TT; // time periods
  array [TT, S] int y; // outcome 
  array[TT] vector[S] log_pop;   // offset
  
  int<lower=0,upper=1> keep_log_lik;
  int<lower=0,upper=1> fixed_rho;
  int<lower=0,upper=1> fixed_tau;
  int<lower=0,upper=1> fixed_ar;  
  
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
  real alpha; 
  vector<lower=0>[fixed_tau ? 1 : TT] tau;
  vector<lower=-1, upper=1>[fixed_ar ? 1 : TT-1] beta_ar;
  vector<lower=1/min(lambda), upper=1/max(lambda)>[fixed_rho ? 1 : TT] rho;
}

model {
  array[TT] vector[S] phi_mu;
  
  for (tt in 1:TT) {
      if (tt == 1) {
       phi_mu[1] = rep_vector(alpha, S);
      } else {
       phi_mu[tt] = beta_ar[fixed_ar ? 1 : tt-1] * phi[tt-1];       
      }
      
      target += wcar_normal_lpdf(
				 phi[tt] |
				 phi_mu[tt],
				 tau[fixed_tau ? 1 : tt],
				 rho[fixed_rho ? 1 : tt],
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
  array[TT] vector[keep_log_lik ? S : 0] log_lik;
  if (keep_log_lik) {
    for (tt in 1:TT) {
      for (s in 1:S) log_lik[tt, s] = poisson_log_lpmf(y[tt, s] | log_pop[tt, s] + phi[tt, s]);
    }
  }
}

{% endhighlight %}
</details>


## Addressing MCMC sampling failures 

All of our models sampled smoothly and quickly. If our data were more sparse, this may not have gone as smoothly. By 'sparse', I mean (based on limited experience) that many of our small areas have fewer than 10 observations. With sparse data, the CAR models I have provided above will tend to sample poorly (sampling may proceed in fits and starts, convergence statistics will be bad, and you may have warnings of divergent transitions). This is not due to a problem with, or limitation of, proper CAR models. Rather, this is a general phenomenon encountered in hierarchical modeling with MCMC.

If you use this, let me know how it goes (especially if it gives you trouble or you find an issue).

### Re-parameterizing the CAR model 

To fix it, we just have to change the way we encode our model. This is generally discussed as a change from the 'centered' to 'non-centered' parameterization (see, e.g., <a href="https://sjster.github.io/introduction_to_computational_statistics/docs/Production/Reparameterization.html">here</a>). 

<p>
To clarify, view our first CAR model like this:

\begin{aligned}
&y_i \sim Poisson(p_i \cdot exp(\phi_i)) \\
&\phi \sim Normal(\mu, \Sigma(\rho, \tau))
\end{aligned}

where the CAR covariance matrix is specified in the usual way, with a spatial dependence parameter and a scale parameter (now made explicit in the notation). To fit a spatial auto-regressive model to sparse data, we can encode the same model in a slightly different way: 

\begin{aligned}
&y_i \sim Poisson(p_i \cdot exp(\phi_i)) \\
&\phi = \mu + \tilde{\phi} \cdot \tau \\
&\tilde{\phi} \sim Normal(0, \Sigma(\rho, 1)),
\end{aligned}

where \( \tilde{\phi} \) has mean of zero and scale of 1. The latter method is known generally as the 'non-centered parameterization'. 
</p>

This works well for sparse spatial data (it is implemented in <a href="https://connordonegan.github.io/geostan/articles/custom-spatial-models.html#zero-mean-parameterization">geostan</a> as the 'zero-mean parameterization' or zmp). For space-time modeling, this approach seems to require adjustment. It does not sample adequately.

<p>
In my experience, it samples much better in the CAR-AR model if we do not force the CAR model to have a mean of zero, but we do keep the scale parameter fixed at one. This is the parameterization that we want to use for sparse space-time data:

\begin{aligned}
&\phi = \tilde{\phi} \cdot \tau \\
&\tilde{\phi} \sim Normal(\mu, \Sigma(\rho, 1))
\end{aligned}

where \( \mu \) may contains the AR model. 
</p>

An important note: neither the standard ('centered') nor the adjusted, 'sparse-data' parameterization will work well in all situations. If you apply the latter parameterization to non-sparse data (like our state mortality rates) it will probably sample poorly. If one doesn't seem to work well, try the other.

### Stan code for the sparse-data fix 

We can use the 'sparse-data' CAR model without making any other changes to our workflow.

<p>
For the CAR-AR model, our <code>parameters</code> block needs to include \( \tilde{\phi} \) as <code>phi_tilde</code> (replacing <code>phi</code>):
</p>

{% highlight stan %}
  array[TT] vector[S] phi_tilde;
{% endhighlight %}

Then the <code>model</code> block needs to be adjusted, as:

{% highlight stan %}
  for (tt in 1:TT) {
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
	 rho, 
	 A_w, A_v, A_u,
	 Delta_inv, 
	 log_det_Delta_inv,
	 lambda, 
	 S);
    
    // Now, put phi onto its proper scale: multiply phi_tilde by tau
    target += poisson_log_lpmf(y[tt] | log_pop[tt] + phi_tilde[tt] * tau);
    }
{% endhighlight %}

To avoid having to change your workflow in R, adjust the generated quantities block too (so we get samples from the posterior for <code>phi</code>):

{% highlight stan %}
generated quantities {
  array[TT] vector[S] phi;
  array[TT] vector[S] log_lik;
  for (tt in 1:TT) {
    phi[tt] = phi_tilde[tt] * tau;    
    for (i in 1:S) log_lik[tt, i] = poisson_log_lpmf(y[tt, i] | log_pop[tt, i] + phi[tt, i]);
  }
}
{% endhighlight %}

You can run this model using the same data input as our standard CAR-AR model, <code>stan_dl</code>.

Below, I provide full Stan code for this model but also apply the technique to each of our model types. 

<details>
 <summary>Click to view the complete Stan model with sparse-data parameterization</summary>
 When using this Stan model, you have to specify which model type you want to use. In R:

{% highlight r %}
# for CAR-AR
stan_dl$type <- 3
{% endhighlight %}

{% highlight r %}
/*
Type 0: Partial pooling using iid normal distribution.
Type 1: AR only, giving one time trend per areal unit.
Type 2: CAR only, one spatial trend for each time period
Type 3: CAR-AR, one time trend per areal unit with CAR model for the cross-sectional errors
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
      target += std_normal_lpdf(phi_tilde[tt] - alpha);      
      // same as:
      //phi_tilde_mu[tt] = rep_vector(alpha, S);
      //target += normal_lpdf(phi_tilde[tt] | phi_tilde_mu[tt], 1);
      
    }
    
    if (type == 1) {
      if (tt == 1) {
      	phi_tilde_mu[1] = rep_vector(alpha, S);
      	} else {    
	phi_tilde_mu[tt] = beta_ar * phi_tilde[tt-1];
	}
      
      target += std_normal_lpdf(phi_tilde[tt] - phi_tilde_mu[tt]);
      
    } 
  
    if (type == 2) {
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
{% endhighlight %}
</details>


## Resources 

This tutorial is part of a fairly small body of work focused on implementing spatial model in Stan, including the following [please let me know if I've missed any work that you've found helpful]:

 - Max Joseph's work on proper <a href="https://mc-stan.org/users/documentation/case-studies/mbjoseph-CARStan.html">CAR models</a>. These methods are implemented in the 'brms' R package.
 - Mitzi Morris's work on <a href="https://mc-stan.org/users/documentation/case-studies/icar_stan.html">intrinsic CAR</a> models.
 - James Hogg's work on CAR models and disease modeling, including the <a href="https://doi.org/10.1016/j.healthplace.2024.103295">Leroux<a/> CAR specification.
 - Adam Howe's contribution to adjusting ICAR models for <a href="https://athowes.github.io/posts/2021-11-04-fast-disconnected-icar-in-stan/">disconnected graphs</a>.
 - My own work on proper <a href="https://osf.io/3ey65/">CAR</a> models and spatial econometric models for <a href="https://connordonegan.github.io/geostan">geostan</a>, and <a href="https://github.com/ConnorDonegan/Stan-IAR">extending</a> Howe's contributions with M. Morris.


## References 

Berliner, L. Mark (1996). Hierarchical Bayesian time series models. In K. Hanson and R. Silver (eds), <em>Maximum Entropy and Bayesian Methods</em>, Kluwer Academic Publishers, Dordrecht, pp. 15&mdash;22.

Bivand R (2023). classInt: Choose Univariate Class Intervals. R  package version 0.4-10, <https://CRAN.R-project.org/package=classInt>.

Cliff, AD and JK Ord (1981). <em> Spatial Processes: Models and Applications</em>. Pion Press.

Donegan, Connor (2021). Building spatial conditional autoregressive (CAR) models in the Stan programming language.  OSF Preprints. <https://doi.org/10.31219/osf.io/3ey65> <em>Nb: the present blog post contains an updated implementation of the Stan models that were introduced by this OSF preprint.</em>

Donegan, Connor (2022) 'geostan': An R package for Bayesian spatial analysis. <em>The Journal of Open Source Software</em>. 7, no. 79: 4716. <https://joss.theoj.org/papers/10.21105/joss.04716>

Knorr-Held, Leonhard  (2000). Bayesian modelling of inseparable space-time variation in disease risk. <em>Statistics in Medicine</em> 19(17-18), 2555&mdash;2567.

Lee, Duncan, A. Rushworth, and G. Napier (2018). Spatio-Temporal Areal Unit Modeling in R with Conditional Autoregressive Priors Using the CARBayesST Package. <em>Journal of Statistical Software</em>, <em>84</em>(9), 1&ndash;39 <https://doi.org/10.18637/jss.v084.i09>.

Morris, Mitzi, Katherine Wheeler-Martin, Dan Simpson, Stephen J. Mooney, Andrew Gelman, and Charles DiMaggio. Bayesian hierarchical spatial models: Implementing the Besag York Mollié model in Stan. <em>Spatial and spatio-temporal epidemiology</em> 31 (2019): 100301.

Pebesma, Edzer (2018). Simple Features for R: Standardized Support for Spatial Vector Data. The R Journal 10 (1), 439-446,  <https://doi.org/10.32614/RJ-2018-009>

Rushworth, Alastair, Duncan Lee, and Richard Mitchell (2014). A spatio-temporal model for estimating the long-term effects of air pollution on respiratory hospital admissions in Greater London. <em>Spatial and Spatio-temporal Epidemiology</em> 10, 29&mdash;38.

Urgart, Maria Dolores, Jaione Etxeberria, T. Goicoa, and E. Ardanaz. Gender-speciﬁc spatio-temporal patterns of colorectal cancer incidence in Navarre, Spain (1990–2005). <em>Cancer Epidemiology</em> 36, 254&mdash;262.

Walker, Kyle (2023). <em>tigris: Load Census TIGER/Line Shapefiles</em>. R package version 2.0.4, <https://CRAN.R-project.org/package=tigris>.

Wikle, Christopher K., L. Mark Berliner, and Noel Cressie (1998). Hierarchical Bayesian space-time models. <em> Environmental and Ecological Statistics </em> 5, 117&mdash;154.


