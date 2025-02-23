---
layout: post
title:  "Are spatial regressions 'significantly biased'?"
author: Connor Donegan
categories: Statistics
toc: true
---


A raft of recent articles in journals of statistics assert that spatial regression models are 'biased'. Elsewhere, I've outlined why I find their arguments unconvincing. This post takes a closer look at 'spatial+', which is among the recent proposals for fixing this supposed bias. With standard Monte Carlo methods, it is easy to turn the tables and show that spatial+ is obviously biased. 

**Contents:**
* TOC
{:toc}


## What is 'spatial confounding'?

Spatial autocorrelation (SA), and its implications for analyses of correlation and (later) regression, has been a topic of statistical research for more than a century. However, it remains somewhat of a specialist topic rather than one of general statistical knowledge (among trained statisticians, I mean). In fact, it appears that many authors are not aware that this research dates back at least to W.S. Gosset's work on experimental design, including his 1914 paper on 'The elimination of spurious correlation due to position in time or space'. 

A growing number of articles in journals of statistics begin with the assertion that spatial regression analysis is a new area of study (as distinct from geostatistics and other 'prediction' tasks). The papers are organized around what they call 'spatial confounding', which is one way of describing the challenge of estimating correlations with spatially referenced data. If you search through this literature you will notice that the authors routinely assert that research on correlation with spatial data dates back only to 1993, and was hardly even noticed again until 2006! 

What do these authors mean when they use the term 'spatial confounding'? Here are the first two sentences from the abstract of the paper `Spatial+: A novel approach to spatial confounding' (Dupont et al. 2021):

> In spatial regression models, collinearity between covariates and spatial effects can lead to <em>significant bias in effect estimates</em>. This problem, known as spatial confounding, is encountered [in this paper] modeling forestry data to assess the effect of temperature on tree health. Reliable inference is difficult as results depend on whether or not spatial effects are included in the model. (emphasis added)

 The phrase 'collinearity between covariates and spatial effects' refers to the way that two variables may have similar spatial patterns in them; these correlated patterns `interfere with [the] effect estimates', as Dupont et al. put it. The term 'spatial confounding' refers to this 'interference'. 

These ideas about 'spatial confounding' stem from the work of Reich et al. (2006) and Hodges and Reich (2010). Slowly, criticisms of the 'spatial confounding' literature are being published (Gilbert et al. 2024; Kahn and berrett 2023; Zimmerman and Ver Hoef 2021). I haven't yet seen a response from the spatial econometrics literature to the claims that their favorite models are biased. I have argued that the conceptual framework that defines the literature on 'spatial confounding' is internally inconsistent, and that authors in this sub-literature do not acknowledge (let alone respond to) the existing body of theory that supports standard spatial analysis methods (Donegan 2025). Of course the existing theory is not a complete or perfect body of knowledge, and some of the important insights are mired in the familiar nonsense of orthodox statistics, but one has to recognize and understand it before advancing beyond it.

## 30 years ago in *Biometriks*

The paper by Dupont et al. makes a striking contrast to previous articles in *Biometriks* that cover the same topic. I do not intend to pick on these authors; rather, the contrast I want to make is clearly one between entire professional networks or generations of researchers. 

Here is the first sentence of Dupont et al.'s (2022) article:

> Regression models for spatially referenced data use spatial random effects to account for residual spatial correlation in the response data. As first noted by Clayton et al. (1993), these models can be problematic when estimation of individual covariate effects are of interest.

We are told (1) spatial auto-regressive models are bad for estimating regression coefficients, and (2) this was first noticed by David Clayton and some co-authors in 1993.

As a matter of fact, Clayton et al. argued the opposite of this: they explained why a failure to adjust for spatial autocorrelation can easily lead to 'confounded' results. They were advocating for the use of spatial auto-regressive models. Their observations about 'confounding' were already germane to a substantial body of research on spatial autocorrelation dating to Gosset.

Now here is the first sentence of an article by Pierre Dutilleul, published March of 1993 in *Biometriks*:

> Spatial autocorrelation in sample data can alter the conclusions of statistical analyses performed without due allowance for it, because autocorrelation does not provide minimum-variance unbiased linear estimators and produces a bias in the estimation of correlation coefficients and variances. This is well known for the analysis of correlation...

This is followed by a series of references to papers on correlation with spatial data. He goes on to list the 'several solutions' that were already available for making the appropriate adjustments, including pre-whitening and tend surface analysis (all of which are quite relevant to Dupont et al.'s 'spatial+' technique). 

According to Dutilleul, spatial autocorrelation *in the data* interferes with standard methods and therefore spatial analysis techniques are required so that proper adjustments can be made. According to Dupont et al. (and the entire 'spatial confounding' literature), spatial regression models are themselves 'problematic' because of the adjustments they make. These are very different ways of looking at this topic, with the latter view being almost a complete inversion of the former (Donegan 2025 offers more details on this inversion of statistical theory).

Dutilleul's contribution was a critical response to Clifford et al.s (1993) article in *Biometriks* titled 'Modifying the t Test for Assessing the Correlation Between Two Spatial Processes'. Papers by Clifford, Richardson, and Hemon are standard references in the spatial autocorrelation literature. But Dutilleul points out that Clifford et al. fail to reference a much-cited paper by Roger Bivand (1980) on the same topic. 'This is a major oversight', he says, since Bivand's study clearly anticipates the way Clifford et al. deploy the concept of effective sample size.
 
Dupont et al.'s article was, on balance, well received in discussion papers. In discussion, no one mentioned that the reference to Clayton et al. is misleading, nor was it mentioned that a variety of potentially important references are missing. In fact, *none* of the papers cited by Dutilleul, including Clifford et al., are referenced by Dupont et al. This is something like 'a major oversight' of the discussion, but its one that is symptomatic of the entire 'spatial confounding' literature.

## Pre-whitening and correlation with spatial data

As reported by Dutilleul, one of the standard methods to adjust for spatial autocorrelation is a pre-whitening procedure (see also Cliff and Ord 1981; Haining 1991). The term 'pre-whitening' is an analogy to white noise: to pre-whiten a variable is to remove any spatial pattern (signal) from the values. You pre-whiten both variables so that you can apply the old standard statistical techniques to them, like Pearson's correlation coefficient or OLS regression. Such methods may still appear sometimes for pedagogical purposes in textbooks, but otherwise I do not see them applied very often in the spatial statistics literature.

In the 'spatial confounding' literature, pre-whitening techniques are presented as something like the cutting edge of spatial statistics research (Dupont et al. 2021; Thaden and Kneib 2018).

<p>
One can use a spatial difference operator to pre-whiten a spatial variable. That is, given some spatially-referenced vector \(x\),
$$\tilde{x} = (I - \rho \cdot W) x$$
or with \(M = (I - \rho \cdot W) \),
$$\tilde{x} = M x,$$
where \(\rho\) is a spatial autocorrelation parameters, \(W\) is a row-standardized spatial or network connectivity matrix, and \(I\) is the identity matrix. This is matrix notation for \( \tilde{x} = x - \rho \cdot \sum_{j=1} w_{[i,j]} \cdot x \). If \(\rho\) were equal to 1, then this simply subtracts the average neighboring value from \(x\).
</p>

<p>
It is easy to design a Monte Carlo study to show that pre-whitening two spatial variables can correct for the problems that are caused by SA. After pre-whitening, you can apply a standard correlation coefficient or linear regression to your two variables, \( \tilde{x}_1 \) and \(\tilde{x}_2\).

We will walk through each step here. After this, we will be better positioned to examine spatial+.
</p>

### Monte Carlo study 1: SA and OLS regression 

We will first write a Monte Carlo program that simply illustrates how SA impacts regression analyses (after, e.g., Bivand 1980). We'll take the following steps:

<ol>
  <li> Draw two spatially autocorrelated vectors, \(x\) and \(y\), using a spatial auto-regressive model; </li>

<li> Calculate a regression coefficient and its standard error using OLS; </li>

<li> Store the estimate and its standard error.</li>

<li> Repeat many times. </li>
</ol>

If desired, we can do step 1 in way that adds any non-zero correlation to the two variables.

<p>
To complete the first step, we can draw \(n\) values from the standard normal distribution, we will call those \( \epsilon_x \), and then we add SA to them by applying the inverse of the spatial difference operator:
\begin{equation}
x = M^{-1} \epsilon_x.
\end{equation}
\( M^{-1} \) is a spatial smoothing matrix. This operation is the same as drawing from the simultaneous spatial autoregressive (SAR) model, which is sometimes called the spatial error model (SEM) when it is specified in this way.
</p>

<p>
Now we can make the regression coefficient \(\beta\) whatever value we like, say \(\beta = 0.5\), and create \(y\) from a fresh set of standard normal draws, \( \epsilon_y \):
$$
y = \beta \cdot x + M^{-1} \epsilon_y.
$$
</p>

<p>
To start, let's draw these spatially-autocorrelated variables with parameter values of \(\beta = 0.5 \) and \( \rho = 0.7 \) and, at each iteration, fit a linear model by ordinary least squares (OLS). (Both variables will have the same degree of SA.) The variables and the adjacency matrix will be referenced to a regular \( 12 \times 12 \) grid (\(N=144\)). You can see the R code below for all of the details. Call this 'Monte Carlo study 1'. 
</p>

<p>
In Study 1, we don't make any corrections for SA when it comes to estimating \(\beta\). We just use OLS and document what happens.
</p>

<p>
What we always expect from a model is that the calculated standard errors are about equal to the Monte Carlo variability, i.e., the standard deviation of the estimates. If the estimates are 'unbiased', then their standard deviation is also the root-mean-squared error (RMSE) of the Monte Carlo estimates. This 'long-run' sampling RMSE is basically the meaning of 'standard error', so the RMSE in a Monte Carlo study ought to be about equal to the analytical standard error.
</p>

<p>
We see that the average of the estimates for \(\beta\) is about 0.5 (so OLS is 'unbiased' here) and that the RMSE is 0.043. At each iteration, we also collect the standard error of the estimate of \( \beta \); their mean value is 0.025.
</p>

In this case, the the RMSE of the Monte Carlo study is about 1.7 times the (average) calculated standard error.

<table border=1>
<caption> Summary of Monte Carlo results, study 1: OLS estimates. \(N=144\) observations on a \(12 \times 12 \) grid, \(\rho = 0.7\), \(\beta=0.5\), and \(M = 200\) Monte Carlo iterations.</caption>
  <tr>
  <th> Mean of M estimates of \(\beta\)</th>
 <th> RMSE </th>
 <th> Mean of M std. errors </th>
 </tr>
 <tr>		
 <td align="center"> 0.50 </td>
 <td align="center"> 0.043 </td>
 <td align="center"> 0.025 </td>
 </tr>
   </table>

Of course one can change the parameter of the study to yield different quantities and proportions, but adding positive SA to both variables will always <em>add error</em> to OLS estimates. 

### Error and information symmetry

<p>
Study 1 shows that SA adds error to the OLS estimates. We need a way of understanding why exactly that error arises. Our equation for creating the data has it that each of our \(N\) observations contains a (fractional) copy of the neighboring observations <em>plus</em> some new information. So each value is a partial duplication of its neighbors. Those partial duplications appear as 'clusters' or map patterns.
</p>


With a finite grid space (as it always is), it may be easy for clusters of two variables to overlap one another just by chance. In fact, with high degrees of SA, it becomes difficult to <em>avoid</em> that kind of overlap (or its opposite, a kind of systematic non-overlap). Just try to arrange two variables on a grid in a way that preserves a high degree of positive SA in both bariables <em>and</em> near-zero bivariate correlation.[^dag] As SA increases, the number of possible ways to preserve those two properties decreases. When our two variables exhibit positive SA, there are more chances for a big error to occur, and relatively fewer ways that a small error can occur. (The constraints on the organization of the space illustrate how the concept of degrees of freedom has been applied in spatial statistics.)

[^dag]: This challenge is similar to a classroom lesson that Daniel Griffith liked to use in his spatial statistics course. Also see the papers on correlation with spatial data by Clifford, Richardson, and Hemon (1989) and Richardson and Clifford (1991). Rudy (2011) makes good use of these ideas.

<p>
When two variables share a map pattern, that shared pattern <em>inflates</em> the absolute value of their correlation coefficient. The 'inflation' is illegitimate because it arises merely from the duplication of values (as if we had counted the same observation one and a half times). Non-shared map patterns (i.e., autocorrelation patterns that are unique to one of the two variables) <em>deflate</em> the absolute value of their correlation coefficient. Together, these two factors add error to correlation and regression coefficients. That is, they inflate the RMSE of their sampling distributions (Griffith and Paelinck 2011).
</p>

<p>
Pearson's correlation, like OLS, is 'unbiased' in our first Monte Carlo study because these two kinds of error-inflation factors mutually balanced one another across the \( M = 200 \) iterations. Some iterations have a larger than expected positive error, others have a larger than expected negative error. In some cases, the inflation/deflation factors may effectively cancel out.
</p>

From the above description of where these extra errors come from (shared and non-shared map patterns), we find no reason why the added error should be positive rather than negative. This means that our state of knowledge is one of <em>information symmetry</em> with respect to the SA-induced error. This symmetry was present in the design of the first Monte Carlo study. And of course the same principle of error cancellation is embedded in OLS.

If we wanted to, we could design a Monte Carlo study that adds an SA-induced error that is always positive or always negative, in which case OLS would appear biased. The reason studies in spatial statistics tend to be designed like our Study 1 is, ultimately, that the 'fixed bias' study represents a very specific state of knowledge, and one rarely, if ever, has the kind of information that would be required to know in advance that an SA-induced error is positive or negative; these matters are complicated, which is why we are using statistical models to begin with. By contrast, our higher-entropy study design reflects our usual state of knowledge (at the start of a study), which is ignorance with respect to the sign of the SA-induced error. 

### Monte Carlo study 2: pre-whitening and OLS regression

Pre-whitening simply removes the duplicated information that is latent in the observations. The pre-whitened variates, by definition, cannot have any inflation or deflation factors (at least, they will be reduced to a minimum). Because the source of additional error is no longer present, standard statistical methods should exhibit their usual mathematical properties when they are applied to pre-whitened variables.

<p>
Our second Monte Carlo study shows what happens to the OLS estimates when we use pre-whitening. Once again we begin by simulating spatially autocorrelated data, as in
$$x = M^{-1} \epsilon_x,$$
and similarly for \(y\).

Now when we proceed to pre-whiten the variables, we are just inverting the function we applied to add SA to them:
$$\tilde{x} = M x,$$
and similarly for \(y\).
</p>

<p>
We are trying to recover \(\epsilon_x\) and \(\epsilon_y\), which we now call \(\tilde{x}\) and \( \tilde{y} \). As is often the case for Monte Carlo studies, all we are really doing here is checking that our own reasoning is <em>consistent</em>: specifically, that our function \(M\) really is the inverse of \(M^{-1}\), as found in our contrived 'data generating model'. 
</p>

<p>
To obtain an estimate of \(\rho\) (which we need in order to create \( M \) ), we can fit an intercept-only SAR model to the data. The pre-whitened values are just the residuals from the intercept-only SAR model. (Alternatively, we can skip the estimation of \(\rho\) and just apply our spatial difference operator to \(x\) and \(y\), because we know what \(\rho\) is for our fabricated data.)
</p>

<p>
So our procedure now becomes:
<ol>
  <li> Draw two spatially autocorrelated vectors, \(x\) and \(y\), using the SAR model; </li>

<li> Replace \(x\) with \(\tilde{x}\), the residuals from a fitted SAR model; </li>
<li>  Replace \(y\) with \(\tilde{y}\), the residuals from a fitted SAR model; </li>
<li> Fit an OLS regression to \(\tilde{y}\) and \(\tilde{x}\); </li>

<li> Store the estimate for \(\beta\) and its standard error.</li>

<li> Repeat many times. </li>
</ol>
</p>

<p>
As expected, the summary of results shows that the mean of the estimates is about 0.5 and that the RMSE of the estimates is effectively equal to its theoretical value (the latter is again represented here by the mean of the calculated standard errors). 
</p>

<table border=1>
<caption>Summary of Monte Carlo results, study 2: pre-whitened OLS estimates. \(N=144\) observations on a \(12 \times 12 \) grid, \(\rho = 0.7\), \(\beta=0.5\), and \(M = 200\) Monte Carlo iterations.</caption>
<tr>
 <th> Mean of M estimates of \(\beta\)</th> <th> RMSE </th> <th> Mean of M std. errors </th>
</tr>
  <tr>
 <td align="center"> 0.50 </td>
 <td align="center"> 0.027 </td>
 <td align="center"> 0.026 </td>
  </tr>
   </table>
   


## Equivalent spatial regression

<p>
As mentioned above, pre-whitening is not used very much anymore, at least in spatial statistics. The primary reason is that computational improvements have made spatial regression a trivial thing to apply. The results are nearly the same as pre-whitening for bivariate regression, and of course a spatial regression is easily extended for multivariate analysis. Spatial regression models use the information in the data (\(W, x, y \)) to determine whether the SA-induced error is more likely positive or negative, and they effectively cut that error out of the estimate (see Donegan 2025 for details). 
</p>

<p>
Once again, we use the simultaneous spatial autoregression model with the form
$$y = \mu + (I - \rho \cdot W)^{-1} \epsilon,$$
where we have \(\mu = \alpha + \beta \cdot x \). Put differently,
$$y = \mu + \rho \cdot W (y - \mu) + \epsilon.$$
For any particular case, the estimates will be tend to be quite similar but not identical to pre-whitening; the two are the same in expectation. The results confirm this, and show that the spatial regression estimate is 'unbiased' and has standard errors that are honest. We are also completely unsurprised that the SAR model's RMSE is only 60% that of the OLS model. The results are clearly better than OLS and comparable to pre-whitening.
</p>

<table border=1>
<caption> Summary of Monte Carlo results, study 3: spatial autoregressive model. \(N=144\) observations on a \(12 \times 12 \) grid, \(\rho = 0.7\), \(\beta=0.5\), and \(M = 200\) Monte Carlo iterations.</caption>

<tr>
 <th> Mean of M estimates of \(\beta\) </th> <th> RMSE </th> <th> Mean of M std. errors </th>
</tr>
  <tr>
 <td align="center"> 0.50 </td>
 <td align="center"> 0.027 </td>
 <td align="center"> 0.026 </td>
  </tr>
   </table>

<p>
(I used a Bayesian model to estimate the spatial regression. In place of the standard error, which is a purely frequentist term, what I reported is the standard deviation of the posterior distribution of \(\beta\). Since there's no important prior information here, the posterior distribution resembles the likelihood or sampling distribution. Hence, the table still reports this as the 'standard error'.)
</p>

## Is spatial+ biased?

Dupont et al. present spatial+ as a way to address what they call 'spatial confounding'. At a glance, what they say is that spatial regressions are biased, and that their method is not. If true, then spatial+ and SAR (SEM) estimates differ in expectation. This means that if we repeat our Monte Carlo study again but this time use the spatial+ procedure in our estimation step, we ought to expect a definite bias in the spatial+ estimates. (The logic: any method that differs in expectation from an unbiased method is necessarily biased.)

<p>
Spatial+ is a procedure, like pre-whitening, rather than a model. This means we can apply spatial+ using the SAR model, just like we can use the SAR model for pre-whitening. The spatial+ procedure consists of pre-whitening the covariate, \(x\), and then passing it into a spatial regression model, as \(\tilde{x}\). In our case, we will estimate \(\beta\) using
$$y = \alpha + \beta \cdot \tilde{x} + (I - \rho \cdot W)^{-1} \epsilon.$$
</p>

<p>
The summary of results shows that the estimates are centered around 0.43, rather than \(\beta = 0.5\). Below the table is a histogram of estimates from each of the four models, in which the blue vertical lines mark out \(\beta = 0.5\). Spatial+ does differ in expectation from OLS, pre-whitening, and proper spatial regression models; therefore, it has a definite bias that is not present in any of the standard methods.
</p>

<table border=1>
<caption> Summary of Monte Carlo results, study 4: spatial+ estimates. \(N=144\) observations on a \(12 \times 12 \) grid, \(\rho = 0.7\), \(\beta=0.5\), and \(M = 200\) Monte Carlo iterations.</caption>
<tr>
 <th align="center"> Mean of M estimates of \(\beta\) </th>
 <th align="center"> RMSE </th>
 <th align="center"> Mean of M std. errors </th>
</tr>
  <tr>
 <td align="center"> 0.43 </td>
 <td align="center"> 0.077 </td>
 <td align="center"> 0.027 </td>
  </tr>
   </table>

<center>
<figure>
<img src="/assets/{{ page.date | date: "%Y" }}/{{ page.slug }}/monte_carlo_comparison.png" style="width:100%">
<figcaption> Histograms of estimates for \(\beta\) from Monte Carlo Studies 1&mdash;4. </figcaption>
</figure>
</center>

<p>
Out of curiosity and sort of inspired by spatial+, I created another procedure. I will call it 'half-whitening': pre-whiten \(x\) and then fit an OLS regression to \(y\) and \( \tilde{x} \). I put this through the same Monte Carlo study as the other methods. Whereas spatial+ shows a negative bias, our half-whitening procedure has a positive bias. The estimates are centered on 0.59.
</p>

<table border=1>
<caption> Summary of Monte Carlo results, study 5: half-whitened estimates. \(N=144\) observations on a \(12 \times 12 \) grid, \(\rho = 0.7\), \(\beta=0.5\), and \(M = 200\) Monte Carlo iterations.</caption>
<tr>
 <th align="center"> Mean of M estimates of \(\beta\) </th>
 <th align="center"> RMSE </th>
 <th align="center"> Mean of M std. errors </th>
</tr>
  <tr>
 <td align="center"> 0.59 </td>
 <td align="center"> 0.10 </td>
 <td align="center"> 0.042  </td>
  </tr>
   </table>

<!--
<p>
To understand the negative bias, it may help to use the language I introduced earlier of inflation/deflation factors or shared/non-shared map patterns (borrowed from Dan Griffith's work). We start with \(y\) and \(x\), each containing map patterns or redundancies. Some of the patterns are present in both variables (they are 'shared'), other patterns are present only in one or the other variable ('non-shared'). We can examine each type separately and reason about what must happen to them when we follow the spatial+ procedure, replacing \(x\) with \(\tilde{x}\).
</p>
<ol>
 <li><b>Non-shared map patterns</b>: these deflate the correlation coefficient. If we remove them from \(x\), they will still be non-shared map patterns. </li>
 <li><b>Shared map patterns</b>: these inflate the correlation coefficient. If we remove them from \(x\), they will become non-shared map patterns, which deflate correlations. </li> 
</ol>
<p>
Some of the patterns in \(y\) may also be present in \(x\), and those shared patterns inflate the correlation coefficient. What happens if we remove them from \(x\) only? They remain in \(y\) but they will be treated as non-shared patterns, which means that they will deflate the correlation coefficient. 
</p>
-->

## Asymmetric prior information?

Recall that a premise of our Monte Carlo studies is that our information about SA is symmetric: all of our reasons for expecting the SA-induced error to be positive are balanced by similar reasons that would lead us to expect a negative error. A positive error is no more probable than a negative one. We leave it up to the model (the likelihood) to determine whether the observations point one way or another. That is the purpose for which various spatial-statistical techniques were designed in the first place: improve estimates of correlation by considering a kind of <em>data</em> that the standard techniques do not incorporate, namely the spatial arrangement of the observations. 

What kind of prior information would lead one to suppose that the SA-induced error <em>must be</em> positive (or negative)? If spatial+ is to be justified, it seems we need to have some kind of asymmetric prior information. If you know of a specific confounder that you have not controlled for, that would be reason to expect a certain bias. And the spatial+ procedure, like Thaden and Kneib's (2018) work, is concerned precisely with making adjustments for a missing confounder. 

<p>
The Monte Carlo studies designed by Dupont et al. and Thaden and Kneib (and others) are designed to see what happens when you ignore a confounding variable which also exhibits SA. They want to show that their own techniques are unbiased when there is a spatially-patterned confounder. Using our own notation and specific techniques, Thaden and Kneib would have us begin our Monte Carlo study by constructing the following variables:
$$ c = M^{-1} \epsilon_c$$
$$ x = \gamma \cdot c + \epsilon_x$$
$$ y = \beta \cdot x - c + \epsilon_y.$$
where \(c\) is going to act as a confounder. Dupont et al. add residual SA to \(y\), as in:
$$ y = \beta \cdot x - c +  M^{-1} \epsilon_y.$$
Now in the estimation stage of our Monte Carlo study, we will pretend that we do not have \(c\). The point of the study will be to say something about how various techniques are affected by the bias caused by this missing confounder. 
</p>

It should be perfectly clear at this point that we are no longer talking about the problem of correlation with spatial data, or the challenges posed by SA; we are just talking about confounding. A missing confounder adds bias to any technique that is otherwise 'unbiased'. That is why one includes confounders as covariates, when possible.

<p>
Our last Monte Carlo study repeats all the previous studies, but uses Dupont et al.'s method for generating the data. So we are seeing the impact of a missing confounder, \(c\), on each technique. One can get quite different results depending on the Monte Carlo study parameters; the bias can be positive or negative, large or small, for example. But our results are not what we hope for, spatial+ is no less biased than the other methods. In this case it looks worse than the SAR model. 
</p>

<table border=1>
<caption> Summary of Monte Carlo results, study 6: confounded estimates. \(N=144\) observations on a \(12 \times 12 \) grid, \(\rho = 0.7\), \(\beta=0.5\), and \(M = 200\) Monte Carlo iterations.</caption>
<tr>
 <th align="center"> Method </th>
 <th align="center"> Mean of M estimates of \(\beta\) </th>
 <th align="center"> RMSE </th>
 <th align="center"> Mean of M std. errors </th>
</tr>
  <tr>
  <td align="center"> OLS </td>
 <td align="center"> 0.30 </td>
 <td align="center"> 0.21 </td>
 <td align="center">  0.60 </td>
  </tr>
  <tr>
  <td align="center"> Pre-whitening </td>
 <td align="center"> 0.40 </td>
 <td align="center"> 0.11 </td>
 <td align="center">  0.044 </td>
  </tr>
  <tr>
  <td align="center"> SAR </td>
 <td align="center"> 0.39 </td>
 <td align="center"> 0.12 </td>
 <td align="center">  0.045 </td>
  </tr>
  <tr>
  <td align="center"> Spatial+ </td>
 <td align="center"> 0.317 </td>
 <td align="center"> 0.19 </td>
 <td align="center">  0.036 </td>
  </tr>      
   </table>


## Suggestions

I had two motivations for writing this post. First, frustration with journals that keep publishing demonstrably false claims about the theory, motivation, and history behind spatial statistics. It does not help that words like 'bias' are being used in a flippant manner. The entire conceptual framework that has guided statistical research on SA for more than one hundred years is being pushed aside without any effort to seriously engage with it. Second, I had a genuine interest in spatial+. I was interested because it plays on the pre-whitening method, and at first glance I thought it might work well.

Unfortunately, it seems to me that spatial+ provides another case where the concept of 'spatial confounding' (the meaning of which keeps changing) motivated the creation of an ad hoc procedure which turns out to be flawed. The first example of this is restricted spatial regression (RSR), which I focused on in my article in <em>Geographical Analysis</em>. Both techniquues are motivated by the mistaken premise that there is something obviously wrong with standard spatial regression models that ought to be fixed. 

In light of all this confusion, I offer the following suggestions for spatial data analysis.

First, you can and should use spatial regression models to estimate regression coefficients with spatial data. Spatial regressions are not 'biased'. Various authors have claimed that spatial regression models become problematic when both the dependent and independent variables exhibit SA; the methods were supposedly designed with the assumption that only the dependent variable exhibits SA. That is false and quite misleading. Spatial statistical methods (for data analysis and study design) were first developed precisely to address the challenges that arise when both variables exhibit SA. If by 'biased' one really means 'biased when there is confounding', then there is not much to discuss because that is a truism. Break out of it! 

## R code


<details>
 <summary>R code: Monte Carlo Studies 1&mdash;5</summary>
{% highlight r %}
# for spatial analysis
library(geostan)

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

   # quick pre-whitening (skip estimation of rho):
   # xtilde = as.numeric(m_diff %*% x)
   # ytilde = as.numeric(m_diff %*% y)
   
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
mean( res3$est - res2$est )

# posterior uncertainties do not differ either, surprisingly
mean( res3$se - res2$se )
{% endhighlight %}
</details>

<details>
 <summary>R code: Monte Carlo Study 6</summary>
{% highlight r %}
##
# Attempt to reproduce Dupont et al.'s way of testing the spatial+ procedure
##

# for spatial analysis
library(geostan)

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

# smoother for the "spatial confounder"
## (making SA the same as others)
rho_2 = rho
m_smooth_conf <- solve( diag(N) - rho_2 * W )

# as in: x = Bx * m_smooth_conf %*% confounder + epsilon
Bx = 0.5

# scale of variation 
sigma_x = 1
sigma_y = 0.3

# scale of confounder
sigma_c = 0.5

# MCMC control
iter = 1e3
chains = 1

# store results in these files
f_0 = "mc_res_0c.txt"
f_1 = "mc_res_1c.txt"
f_2 = "mc_res_2c.txt"
f_3 = "mc_res_3c.txt"
f_4 = "mc_res_4c.txt"
f_5 = "mc_res_5c.txt"

# iterate M times

M = 200

# for replication
set.seed(101)

# iterate M times
quietly = sapply(1:M, function(m) {

    # draw the 'spatial confounder'     
    c = as.numeric(m_smooth_conf %*% rnorm(n = N, sd = sigma_c))

    # draw x: with no SA besides the confounder
    x = Bx * c + rnorm(n = N, sd = sigma_x)

    # draw y: contains c twice ('confounder') plus more SA which may or may not shared patterns with c
    y = beta * x - c + as.numeric(m_smooth %*% rnorm(n = N, sd = sigma_y))

    ## Study 0
    # fit the correct regression
    fit = lm(y ~ c + x)

    # collect coefficient estimate and its standard error
    res = coef(summary( fit ))[ "x" , c("Estimate", "Std. Error") ] 

    # save results
    write.table(matrix(res, nrow = 1),
                f_0,
                append = (m > 1),
                row.names = FALSE,
                col.names = FALSE)
    
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
   
   # pre-whitening (skipping estimation of rho; using plug-in value)
   # (comparison shows this to be identitical to estimating it, in terms of Monte Carlo averages)
   ytilde = as.numeric(m_diff %*% y)
   xtilde = as.numeric(m_diff %*% x)
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
RMSE <- function(est, b = beta) {
    e <- est - b
    mse <- mean(e^2)
    sqrt(mse)
}

for (f in c(f_0, f_1, f_2, f_3, f_4, f_5)) {
  res = read.table(f, col.names = c('est', 'se'))
  summ = cbind(Est = mean(res$est),
              RMSE = RMSE(res$est),
    	      SE_mean = mean(res$se) )
  print(paste(f, ":"))
  print(summ, digits = 3)
}
{% endhighlight %}
</details>
## Bibliography

Bivand, R. (1980). A Monte Carlo study of correlation coefficient estimation with spatially autocorrelated observations. *Quaestiones Geographicae* 6: 5&mdash;10. <https://ia904602.us.archive.org/3/items/bivand-1980/Bivand%201980.pdf>

Cayton, Aubrey (2021). *Bernoulli's Fallacy: Statistical Illogic and the Crisis of Modern Science*. New York: Columbia University Press.

Clayton, D.G., Bernardinelli, L. & Montomoli, C. (1993). Spatial Correlation in Ecological Analysis. <em>International Journal of Epidemiology</em>, 22(6), 1193–1202.

Cliff, A.D. & Ord, J.K. (1981). *Spatial Processes: Models and Applications*. London, Pion Press.

Clifford, Peter, Sylvia Richardson, and Denis Hemon (1989). "Assessing the significance of the correlation between two spatial processes." *Biometrics*, 45(1): 123-134. <https://doi.org/10.2307/2532039>

Dupont, E., Wood, S. N., & Augustin, N. H. (2022). Spatial+: a novel approach to spatial confounding. <em>Biometrics</em>, 78(4), 1279-1290. <https://doi.org/10.1111/biom.13656>

Dutilleul, P. (1993) Modifying the t Test for Assessing the Correlation between Two Spatial Processes. *Biometrics*, 49(1), 305–314. <https://www.jstor.org/stable/2532625>

Donegan, C. (2025). Plausible Reasoning and Spatial‐Statistical Theory: A Critique of Recent Writings on 'Spatial Confounding'. <em>Geographical Analysis</em>, 57(1): 152&ndash;172. <https://doi.org/10.1111/gean.12408>

Getis, A., & Griffith, D. A. (2002). Comparative spatial filtering in regression analysis. *Geographical Analysis*, 34(2). <https://doi.org/10.1111/j.1538-4632.2002.tb01080.x>

Gilbert, B., Ogburn, E. L., & Datta, A. (2024). Consistency of common spatial estimators under spatial confounding. *Biometrika*, asae070. <https://arxiv.org/abs/2308.12181>

Griffith, D.A. & Paelinck, J.H.P. (2011) <em>Non-standard Spatial Statistics and Spatial Econometrics</em>. Heidelberg: Springer

Haining, R. (1991). Bivariate correlation with spatial data. *Geographical Analysis*, 23(3), 210&mdash;227.

Hodges, J.S. & Reich, B.J. (2010) Adding Spatially-Correlated Errors Can Mess up the Fixed Effect you Love. <em>The American Statistician</em>, 64(4), 325&ndash;334. <https://doi.org/10.1198/tast.2010.10052>.

Khan, K., & Berrett, C. (2023). Re-thinking spatial confounding in spatial linear mixed models. *arXiv* preprint. <https://arxiv.org/abs/2301.05743>

Reich, B.J., Hodges, J.S. & Zadnik, V. (2006) Effects of Residual Smoothing on the Posterior of the Fixed Effects in Disease-Mapping Models. *Biometrics*, 62(4), 1197–1206. <https://doi.org/10.1111/j.1541-0420.2006.00617.x>

Richardson, Sylvia, and Peter Clifford (1991). "Testing association between spatial processes." *Lecture Notes-Monograph Series* (1991): 295-308.

Rudy Arthur, A General Method for Resampling Autocorrelated Spatial Data, <em>Geographical Analysis</em>. <https://doi.org/10.1111/gean.12417>

Student [W.S. Gosset] (1914). The Elimination of Spurious Correlation Due to Position in Time and Space. <em>Biometrika</em>, 10, 179&ndash;180. <https://www.jstor.org/stable/2331746>

Thaden, H., & Kneib, T. (2018). Structural equation models for dealing with spatial confounding. *The American Statistician*, 72(3), 239–252.

Zimmerman, D.L. & Ver Hoef, J.M. (2021) On Deconfounding Spatial Confounding in Linear Models. The American Statistician, 76(2), 159–167. <https://doi.org/10.1080/00031305.2021.1946149>

