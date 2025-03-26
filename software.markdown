---
layout: page
title: Software
permalink: /software/
---


#### The 'geostan' R package

<img src="/assets/geostan-logo.png" align="left" width="100" /> <br />
<p style="color:Gray">Donegan, Connor (2022). geostan: An R package for Bayesian spatial analysis. <em>The Journal of Open Source Software</em> 7, no. 79: 4716 DOI:<a href="https://doi.org/10.21105/joss.04716">10.21105/joss.04716</a></p>  [![](https://cranlogs.r-pkg.org/badges/geostan?color=yellow)](https://cran.rstudio.com/web/packages/geostan/index.html) [![DOI](https://joss.theoj.org/papers/10.21105/joss.04716/status.svg)](https://doi.org/10.21105/joss.04716)

<p> The geostan R package supports a complete spatial analysis workflow with Bayesian models for areal or network data, including a suite of functions for visualizing spatial data and model results. The package implements models for spatial regression and spatial econometrics as well as hierarchical models for count data (e.g., disease mapping models). Users can model censored outcomes&mdash;a common feature of vital statistics and disease registry data&mdash;and access spatial measurement error models, designed for working with American Community Survey (ACS) estimates. The models were built using the probabilistic programming language <a href="https://mc-stan.org">Stan</a>. A tutorial on <a href="https://connordonegan.github.io/statistics/public_health/2025/01/08/space-time-mortality.html">space-time modeling in Stan</a> and a package vignette on building <a href="https://connordonegan.github.io/geostan/articles/index.html">custom spatial models</a> provide guidance for those who are interested in using geostan's custom probability density functions in their own Stan models.</p>

Online documentation: [connordonegan.github.io/geostan](https://connordonegan.github.io/geostan)

Introduction to the package: [Spatial data analysis with geostan]({{ site.url }}/statistics/public_health/2024/08/04/spatial-analysis-geostan.html) 

<p style="color:Gray">Donegan, Connor (2021). Building spatial conditional autoregressive (CAR) models in the Stan programming language. <em>OSF Preprints</em>. DOI:<a href="https://osf.io/3ey65/">10.31219/osf.io/3ey65</a></p>

<p style="color:Gray">Donegan, Connor, Yongwan Chun and Daniel A. Griffith (2021). Modeling community health with areal data: Bayesian inference with survey standard errors and spatial structure <em>International Journal of Environmental Research and Public Health</em> 18, no. 13: 6856. DOI:<a href="https://doi.org/10.3390/ijerph18136856">10.3390/ijerph18136856</a> Supplementary material: <a href="https://github.com/ConnorDonegan/survey-HBM">https://github.com/ConnorDonegan/survey-HBM</a>.</p>

<p style="color:Gray">Donegan, Connor, Yongwan Chun and Amy E. Hughes (2020). Bayesian estimation of spatial filters with Moran's eigenvectors and hierarchical shrinkage priors. <em>Spatial Statistics</em> 38: 100450. DOI:<a href="https://doi.org/10.1016/j.spasta.2020.100450">10.1016/j.spasta.2020.100450</a> Pre-print URL: <a href="https://osf.io/fah3z">https://osf.io/fah3z/</a></p>

#### The 'surveil' R package

<img src="/assets/surveil-logo.png" align="left" width="100" /> 
<p style="color:Gray"> Donegan, Connor, Amy E Hughes and Simon J Craddock Lee (2022). Colorectal Cancer Incidence, Inequalities, and Prevention Priorities in Urban Texas: Surveillance Study with the "surveil" software package. <em>JMIR Public Health & Surveillance</em> 8, no. 8: e34589 DOI:<a href="https://doi.org/10.2196/34589">10.2196/34589</a> PMID:<a href="https://pubmed.ncbi.nlm.nih.gov/35972778/a">35972778</a> </p>
 [![](https://cranlogs.r-pkg.org/badges/surveil?color=yellow)](https://cran.rstudio.com/web/packages/surveil/index.html)

<p> The surveil R package provides time series models for routine public health monitoring tasks: model time trends in mortality or disease incidence rates to make inferences about levels of risk, cumulative and period percent change, age-standardized rates, and health inequalities. This software provides an accessible alternative to joinpoint regression. Basic usage requires introductory-level R programming skills.</p>

Demonstration: [Modeling time trends for disease monitoring studies]({{ site.url }}/statistics/public_health/2024/09/02/intro-to-surveil.html)

Online documentation: [connordonegan.github.io/surveil](https://connordonegan.github.io/surveil)

<p style="color:Gray">Donegan, Connor, Amy E Hughes and Simon J Craddock Lee (2022). Time Series Models for Public Health Surveillance: Colorectal Cancer Incidence, Inequalities, and Prevention Priorities in Urban Texas. Poster presentation to the Interdisciplinary Association of Population Health Science (IAPHS), Minneapolis, MN. </p>

#### R/Stan code

<p style="color:Gray">Donegan, Connor (2021). "Building spatial conditional autoregressive (CAR) models in the Stan programming language." <em>OSF Preprints</em>. DOI: <a href="https://osf.io/3ey65/">10.31219/osf.io/3ey65</a> Supplementary material: <a href="https://osf.io/ewxut/">https://osf.io/ewxut/</a>.</p>

<p> This paper provides computationally efficient R and Stan code for building spatial conditional autoregressive (CAR) models in Stan. The paper details various CAR model specifications and provides a comparison to Nimble in terms of sampling efficiency (with about 10-fold improvement over Nimble). The paper provides a demonstration analysis of county mortality data (including censored observations). This shows how the geostan R package can facilitate the process of building custom spatial models in Stan. (This work has since been revised and extended to include the simultaneous spatial autoregressive (SAR) models, now implemented in geostan.) </p>

<p style="color:Gray">Donegan, Connor and Mitzi Morris (2021). "Flexible functions for ICAR, BYM, and BYM2 models in Stan.” Code repository. <a href="https://github.com/ConnorDonegan/Stan-IAR">https://github.com/ConnorDonegan/Stan-IAR</a> </p>

<p> This code repository contains a set of functions in the R and Stan programming languages that make it easier to implement the BYM and BYM2 spatial models in RStan. The code addresses multiple challenges that arise when using a disconnected graph structure with the intrinsic conditional autoregressive model. The functions support the construction of custom spatial models in Stan, and are also used by the geostan R package. </p>
