---
layout: page
title: Software
permalink: /software/
---

**R packages**

<img src="/assets/surveil-logo.png" align="left" width="100" /> <br />
<p style="color:Gray">Donegan, Connor (2021). “surveil: Public Health Surveillance.” R package version 0.1.0. <a style="color:DarkSlateGray" href="{{ site.baseurl }}/surveil/">https://connordonegan.github.io/surveil/</a> </p> 

<p> The surveil R package provides time series models for routine public health surveillance tasks: model time trends in mortality or disease incidence rates to make inferences about levels of risk, cumulative and period percent change, age-standardized rates, and health inequalities. This software provides an accessible alternative to joinpoint regression, avoids piecewise linearity constraints, and provides users the flexibility to analyze custom quantities of interest with Markov chain Monte Carlo methods. Basic usage requires introductory-level R programming skills.</p>

<img src="/assets/geostan-logo.png" align="left" width="100" /> <br />
<p style="color:Gray">Donegan, Connor (2021). “geostan: Bayesian Spatial Analysis.” R package version 0.2.0. <a style="color:DarkSlateGray" href="{{ site.baseurl }}/geostan/">https://connordonegan.github.io/geostan/</a> </p>

<p> The geostan R package supports a complete spatial analysis workflow with Bayesian models for areal data, including a suite of functions for visualizing spatial data and model results. Users can model censored outcomes&mdash;a common feature of vital statistics and disease registry data&mdash;and access spatial measurement error models, designed for working with American Community Survey (ACS) estimates.The package offers spatial methods suitable for modeling both count and continuous outcome data types. </p>
 <br />

**R/Stan code**

<p style="color:Gray">Donegan, Connor (2021). "Building spatial conditional autoregressive (CAR) models in the Stan programming language." <em>OSF Preprints</em>. DOI: <a style="color:DarkSlateGray" href="https://osf.io/3ey65/">10.31219/osf.io/3ey65</a> Supplementary material: <a style="color:DarkSlateGray" href="https://osf.io/ewxut/">https://osf.io/ewxut/</a>.</p>

<p> This paper provides computationally efficient R and Stan code for building spatial conditional autoregressive (CAR) models in Stan. The paper details various CAR model specifications and demonstrates how users can use the geostan R package to facilitate the process of building custom spatial models in Stan. The demonstration analysis of county mortality rates also shows how to adjust for censored count data, and illustrates why it is crucial to complete throughtful spatial analyses of model residuals. The Stan functions introduced here are also implemented in geostan. </p>

<p style="color:Gray">Donegan, Connor and Mitzi Morris (2021). "Flexible functions for ICAR, BYM, and BYM2 models in Stan.” Code repository. <a style="color:DarkSlateGray" href="https://github.com/ConnorDonegan/Stan-IAR">https://github.com/ConnorDonegan/Stan-IAR</a> </p>

<p> This code repository contains a set of functions in the R and Stan programming languages that make it easier to implement the BYM and BYM2 spatial models in RStan. The code addresses multiple challenges that arise when using a disconnected graph structure with the intrinsic conditional autoregressive model. The functions support the construction of custom spatial models in Stan, and are also used by the geostan R package. </p>
