# Introduction to nonlinear modeling with brms

Nonlinear models are central to ecology (e.g. growth, species interactions, thermal responses, ...), yet fitting them to data often goes beyond classical GLMMs. Bayesian statistics offers a powerful solution. In this hands-on workshop, we will learn how to use brms to flexibly specify, fit, and interpret nonlinear prediction models with coding effort that barely exceeds lme4, and apply them to real ecological questions.

General knowledge of statistical modeling is needed (ANOVA, linear regression, generalized linear models). Some experience with Bayesian statistics is helpful, but not required.

### Materials

* [Slides [html]](https://benjamin-rosenbaum.github.io/nonlinear-statistics/Slides.html)
* [Code [R]](https://benjamin-rosenbaum.github.io/nonlinear-statistics/Nonlinear_stats.R) 


### Software requirements

- Rstudio: [link](https://posit.co/download/rstudio-desktop/)
- C-toolchain: [link](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started#configuring-c-toolchain),
- which involves RTools (for Windows): [link](https://cran.r-project.org/bin/windows/Rtools/)
- Some R-packages:

```r
update.packages()
install.packages("brms")    # our main software package
install.packages("emmeans") # post-hoc analysis
install.packages("BayesFR") # example datasets
install.packages("rTPC")    # example datasets
```

### Notes

* I also have a general introduction to Bayesian statistics with `brms`:     
  [github.com/benjamin-rosenbaum/bayesian-intro](https://github.com/benjamin-rosenbaum/bayesian-intro)
* For more examples with functional responses, see my R-package `BayesFR`:     
  [benjamin-rosenbaum.github.io/BayesFR](https://benjamin-rosenbaum.github.io/BayesFR)
  
