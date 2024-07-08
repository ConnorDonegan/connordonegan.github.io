---
layout: page
title: Software
permalink: /software/
---

 This page describes statistical software I have developed and lists associated papers on quantitative methodology. The software uses the R language for statistical computing and the [Stan](https://mc-stan.org) modeling language for Markov chain Monte Carlo sampling. 

#### The geostan R package

<img src="/assets/geostan-logo.png" align="left" width="100" /> <br />
<p style="color:Gray">Donegan, Connor (2022). geostan: An R package for Bayesian spatial analysis. <em>The Journal of Open Source Software</em> 7, no. 79: 4716 DOI:<a style="color:DarkSlateGray" href="https://doi.org/10.21105/joss.04716">10.21105/joss.04716</a></p>  [![](https://cranlogs.r-pkg.org/badges/geostan?color=yellow)](https://cran.rstudio.com/web/packages/geostan/index.html) [![DOI](https://joss.theoj.org/papers/10.21105/joss.04716/status.svg)](https://doi.org/10.21105/joss.04716)

<p> The geostan R package supports a complete spatial analysis workflow with Bayesian models for areal data, including a suite of functions for visualizing spatial data and model results. Users can model censored outcomes&mdash;a common feature of vital statistics and disease registry data&mdash;and access spatial measurement error models, designed for working with American Community Survey (ACS) estimates.The package offers spatial methods suitable for modeling both count and continuous outcome data types. The software also incorporates original computational methods developed to speed up spatial autoregressive models in Stan.</p>

Online documentation: [connordonegan.github.io/geostan](https://connordonegan.github.io/geostan)

<p style="color:Gray">Donegan, Connor (2021). Building spatial conditional autoregressive (CAR) models in the Stan programming language. <em>OSF Preprints</em>. DOI:<a style="color:DarkSlateGray" href="https://osf.io/3ey65/">10.31219/osf.io/3ey65</a></p>

<p style="color:Gray">Donegan, Connor, Yongwan Chun and Daniel A. Griffith (2021). Modeling community health with areal data: Bayesian inference with survey standard errors and spatial structure <em>International Journal of Environmental Research and Public Health</em> 18, no. 13: 6856. DOI:<a style="color:DarkSlateGray" href="https://doi.org/10.3390/ijerph18136856">10.3390/ijerph18136856</a> Supplementary material: <a style="color:DarkSlateGray" href="https://github.com/ConnorDonegan/survey-HBM">https://github.com/ConnorDonegan/survey-HBM</a>.</p>

<p style="color:Gray">Donegan, Connor, Yongwan Chun and Amy E. Hughes (2020). Bayesian estimation of spatial filters with Moran's eigenvectors and hierarchical shrinkage priors. <em>Spatial Statistics</em> 38: 100450. DOI:<a style="color:DarkSlateGray" href="https://doi.org/10.1016/j.spasta.2020.100450">10.1016/j.spasta.2020.100450</a> Pre-print URL: <a style="color:DarkSlateGray" href="https://osf.io/fah3z">https://osf.io/fah3z/</a></p>

#### The surveil R package

<img src="/assets/surveil-logo.png" align="left" width="100" /> 
<p style="color:Gray"> Donegan, Connor, Amy E Hughes and Simon J Craddock Lee (2022). Colorectal Cancer Incidence, Inequalities, and Prevention Priorities in Urban Texas: Surveillance Study with the "surveil" software package. <em>JMIR Public Health & Surveillance</em> 8, no. 8: e34589 DOI:<a style="color:DarkSlateGray" href="https://doi.org/10.2196/34589">10.2196/34589</a> PMID:<a style="color:DarkSlateGray" href="https://pubmed.ncbi.nlm.nih.gov/35972778/a">35972778</a> </p>
 [![](https://cranlogs.r-pkg.org/badges/surveil?color=yellow)](https://cran.rstudio.com/web/packages/surveil/index.html)

<p> The surveil R package provides time series models for routine public health surveillance tasks: model time trends in mortality or disease incidence rates to make inferences about levels of risk, cumulative and period percent change, age-standardized rates, and health inequalities. This software provides an accessible alternative to joinpoint regression. Basic usage requires introductory-level R programming skills.</p>

Online documentation: [connordonegan.github.io/surveil](https://connordonegan.github.io/surveil)

<p style="color:Gray">Donegan, Connor, Amy E Hughes and Simon J Craddock Lee (2022). Time Series Models for Public Health Surveillance: Colorectal Cancer Incidence, Inequalities, and Prevention Priorities in Urban Texas. Poster presentation to the Interdisciplinary Association of Population Health Science (IAPHS), Minneapolis, MN. <a style="color:DarkSlateGray" href="{{ site.baseurl }}/surveil-poster/">Poster PDF.</a> </p>

#### R/Stan code

<p style="color:Gray">Donegan, Connor (2021). "Building spatial conditional autoregressive (CAR) models in the Stan programming language." <em>OSF Preprints</em>. DOI: <a style="color:DarkSlateGray" href="https://osf.io/3ey65/">10.31219/osf.io/3ey65</a> Supplementary material: <a style="color:DarkSlateGray" href="https://osf.io/ewxut/">https://osf.io/ewxut/</a>.</p>

<p> This paper provides computationally efficient R and Stan code for building spatial conditional autoregressive (CAR) models in Stan. The paper details various CAR model specifications and demonstrates how users can use the geostan R package to facilitate the process of building custom spatial models in Stan. A demonstration analysis of county mortality rates also shows how to adjust for censored count data. </p>

<p style="color:Gray">Donegan, Connor and Mitzi Morris (2021). "Flexible functions for ICAR, BYM, and BYM2 models in Stan.” Code repository. <a style="color:DarkSlateGray" href="https://github.com/ConnorDonegan/Stan-IAR">https://github.com/ConnorDonegan/Stan-IAR</a> </p>

<p> This code repository contains a set of functions in the R and Stan programming languages that make it easier to implement the BYM and BYM2 spatial models in RStan. The code addresses multiple challenges that arise when using a disconnected graph structure with the intrinsic conditional autoregressive model. The functions support the construction of custom spatial models in Stan, and are also used by the geostan R package. </p>
