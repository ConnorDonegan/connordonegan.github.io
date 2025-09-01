---
layout: page
title: Software
permalink: /software/
---

<em>This page lists statistical software that I have developed, mostly from my time as a grad student at UT Dallas.</em>

<style>
span.desc {
  font-size: smaller;
}
dt {
  font-weight: bold;
}

dl,
dd {
  font-size: 0.9rem;
}

dd {
  margin-bottom: 1em;
}
</style>

#### The geostan R package

<img src="/assets/geostan-logo.png" align="left" width="100" /> <br />
<p>
<span class="desc">
Supports a complete spatial analysis workflow: exploratory analysis, modeling, diagnostics, and visualization.
</span>
</p>
[![](https://cranlogs.r-pkg.org/badges/geostan?color=yellow)](https://cran.rstudio.com/web/packages/geostan/index.html) [![DOI](https://joss.theoj.org/papers/10.21105/joss.04716/status.svg)](https://doi.org/10.21105/joss.04716)

<dl>
  <dt> Spatial regression and econometric models</dt>
  <dd> For data recorded across areal units (states, counties, or census
    tracts) or networks.
    </dd>
    
  <dt> Spatial analysis tools </dt>
  <dd>For visualizing and measuring
    spatial autocorrelation and map patterns, for exploratory analysis
    and model diagnostics.
    </dd>
    
  <dt> Observational error</dt>
  <dd> Incorporate standard errors (e.g., from American Community Survey
    estimates) into any geostan model.</dd>
    
  <dt> Missing and Censored observations</dt>
  <dd>
  Vital statistics and disease  surveillance systems like CDC Wonder censor case counts that fall
    below a threshold number; geostan can model disease or mortality
    risk for small areas with censored observations or with missing
    observations.
    </dd>
    
  <dt> The RStan ecosystem</dt>
  <dd>Interfaces easily with many high-quality R packages for Bayesian modeling.
  </dd>
  
  <dt> Custom spatial models</dt>
  <dd> Tools for building custom spatial or network models in Stan.
  </dd>

  <dt>Online documentation</dt>
  <dd>
  <a href="https://connordonegan.github.io/geostan">https://connordonegan.github.io/geostan</a>
  </dd>

  <dt>Package vignette</dt>
  <dd>
   <a href="{{ site.url }}/statistics/public_health/2024/08/04/spatial-analysis-geostan.html">Spatial data analysis with geostan</a>
   </dd>

  <dt>Publications</dt>
  <dd>
  <p style="color:Gray">Donegan, Connor (2022). geostan: An R package for Bayesian spatial analysis. <em>The Journal of Open Source Software</em> 7, no. 79: 4716 DOI:<a href="https://doi.org/10.21105/joss.04716">10.21105/joss.04716</a></p>
  
<p style="color:Gray">Donegan, Connor (2021). Building spatial conditional autoregressive (CAR) models in the Stan programming language. <em>OSF Preprints</em>. DOI:<a href="https://osf.io/3ey65/">10.31219/osf.io/3ey65</a></p>

<p style="color:Gray">Donegan, Connor, Yongwan Chun and Daniel A. Griffith (2021). Modeling community health with areal data: Bayesian inference with survey standard errors and spatial structure <em>International Journal of Environmental Research and Public Health</em> 18, no. 13: 6856. DOI:<a href="https://doi.org/10.3390/ijerph18136856">10.3390/ijerph18136856</a> Supplementary material: <a href="https://github.com/ConnorDonegan/survey-HBM">https://github.com/ConnorDonegan/survey-HBM</a>.</p>

<p style="color:Gray">Donegan, Connor, Yongwan Chun and Amy E. Hughes (2020). Bayesian estimation of spatial filters with Moran's eigenvectors and hierarchical shrinkage priors. <em>Spatial Statistics</em> 38: 100450. DOI:<a href="https://doi.org/10.1016/j.spasta.2020.100450">10.1016/j.spasta.2020.100450</a> Pre-print URL: <a href="https://osf.io/fah3z">https://osf.io/fah3z/</a></p>
  </dd>
 </dl>    


#### The surveil R package

<img src="/assets/surveil-logo.png" align="left" width="100" /> <br>
<p>
<span class="desc">
Models for time trends in mortality or disease incidence, for routine public health tasks. An accessible alternative to joinpoint regression. 
</span>
</p>
 [![](https://cranlogs.r-pkg.org/badges/surveil?color=yellow)](https://cran.rstudio.com/web/packages/surveil/index.html)

<dl> 
 <dt>Age-standardized rates</dt>
 <dd>
 Automatically fit and combine age-specific models for directly age-standardized rates.
 </dd>
 
 <dt>Percent change analysis</dt>
 <dd>
 Simple methods for getting cumulative percent change and period-specific percent change statistics.
 </dd>
 
 <dt>Professional figures</dt>
 <dd>Publication-quality default graphics</dd>
 
 <dt>Online documentation</dt>
 <dd>
  <a href="https://connordonegan.github.io/surveil">
   https://connordonegan.github.io/surveil
  </a>
  </dd>
  
 <dt>Package vignette</dt>
 <dd><a href="{{ site.url }}/statistics/public_health/2024/09/02/intro-to-surveil.html"> Modeling time trends for disease monitoring studies</a>
 </dd>

 <dt>Publications</dt>
 <dd>
<p style="color:Gray"> Donegan, Connor, Amy E Hughes and Simon J Craddock Lee (2022). Colorectal Cancer Incidence, Inequalities, and Prevention Priorities in Urban Texas: Surveillance Study with the "surveil" software package. <em>JMIR Public Health & Surveillance</em> 8, no. 8: e34589 DOI:<a href="https://doi.org/10.2196/34589">10.2196/34589</a> PMID:<a href="https://pubmed.ncbi.nlm.nih.gov/35972778/a">35972778</a> </p>
 </dd>
</dl>

#### Other code

<p style="color:Gray">Donegan, Connor and Mitzi Morris (2021). "Flexible functions for ICAR, BYM, and BYM2 models in Stan.” Code repository. <a href="https://github.com/ConnorDonegan/Stan-IAR">https://github.com/ConnorDonegan/Stan-IAR</a> </p>

<p> Functions in the R and Stan programming languages that make it easier to implement the BYM and BYM2 spatial models in RStan. The code addresses multiple challenges that arise when using a disconnected graph structure with the intrinsic conditional autoregressive model. The functions support the construction of custom spatial models in Stan, and are also used by the geostan R package. </p>
