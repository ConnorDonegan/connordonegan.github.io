---
layout: post
title:  "Space-time modeling in Stan: charting the evolution of U.S. mortality rates"
author: Connor 
categories: [Statistics, Public health]
---

This post provides a tutorial on modeling spatial-temporal disease data using Stan. When we take the right approach, Stan (and HMC generally) provides a great platform for spatial statistics. I'll illustrate by modeling mortality rates for U.S. states and D.C., covering the years 1999 through 2020. 

<h2> The mortality data </h2>

{% highlight r %}
## dat_path <- "https://raw.githubusercontent.com/ConnorDonegan/connordonegan.github.io/main/assets/2025/space-time-stan-mortality/cdc-mortality-states.txt"
dat_path <- "assets/2025/space-time-mortality/cdc-mortality-states.txt"

# read the data into R
dat <- read.table(dat_path, header = TRUE, sep = "\t")    
{% endhighlight %}

<h2> Statistical models for spatial-temporal data </h2>

It will help to be clear from the start about the purpose of these models. 


<details class="details-example">
    <summary>Complete R code for the post</summary>
{% highlight r %}
stan_cars
{% endhighlight %}
</details>


<!---
<center>
<figure>
<img src="/assets/{{ page.date | date: "%Y" }}/{{ page.slug }}/crc-trends.png" alt="CRC time trends in one plot" style="width:75%">
<figcaption> <em>Age-specific CRC incidence per 100,000, Texas 1999-2020</em> </figcaption>
</figure>
</center>
--->