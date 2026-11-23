# Nonlinear Statistics with brms
# Benjamin Rosenbaum 2026

rm(list=ls())

library("brms")
library("ggplot2")
library("BayesFR")
library("rTPC")

setwd("~/Nextcloud/Nonlinear models workshop/slides")

# Part 2 -----------------------------------------------------------------------

df = df_Hossie_and_Murray_2010_OECOLOGIA
df = subset(df, ID=="Figure 1a")

df$N = df$N0
df$Feeding = df$NE

ggplot(df, aes(N,Feeding)) +
  geom_point(alpha=0.7) + 
  scale_x_continuous(limits=c(0,NA))

## Linear regression ----

formula = bf(Feeding ~ N)

priors  = prior(normal(0,1), class="b")

fit.1   = brm(formula,
              prior = priors,
              # backend = "stanli",
              # cores = 4,
              data = df)

summary(fit.1)

plot(fit.1)

plot(conditional_effects(fit.1),
     points=TRUE)

plot(conditional_effects(fit.1,
                         method="posterior_predict"),
     points=TRUE)

# same plots with ggeffects
# library("ggeffects")
# pred = ggpredict(fit.1, terms = c("N"))
# plot(pred, show_data=TRUE)
# pred = ggpredict(fit.1, terms = c("N"), interval="prediction")
# plot(pred, show_data=TRUE)

pp_check(fit.1, ndraws=200)

## Nonlinear FR model ----

formula = bf(Feeding ~ fmax*N/(nhalf+N),
             fmax ~ 1,
             nhalf ~ 1,
             nl = TRUE)

priors  = c(
  prior(normal(20,5), nlpar="fmax", lb=0),
  prior(normal(15,5), nlpar="nhalf", lb=0)
)

fit.2   = brm(formula,
              prior = priors,
              family = poisson(link="identity"),
              # cores = 4,
              # backend = "stanli",
              data = df)

summary(fit.2)

plot(fit.2)

plot(conditional_effects(fit.2,
                         int_conditions = list(N=0:60)),
     points=TRUE)

plot(conditional_effects(fit.2,
                         method = "posterior_predict",
                         int_conditions = list(N=0:60)),
     points=TRUE)

# same plots with ggeffects
# library("ggeffects")
# pred = ggpredict(fit.2, terms=c("N [0:60]"))
# plot(pred, show_data=TRUE)
# pred = ggpredict(fit.2, terms=c("N [0:60]"), interval="prediction")
# plot(pred, show_data=TRUE)

pp_check(fit.2, ndraws=200)
# pp_check(fit.2, ndraws=200, type="rootogram")

# Part 3a: categorical ---------------------------------------------------------

library("BayesFR") # contains dataset

data(df_Cuthbert_et_al_2020_ECOL_EVOL)

df = subset(df_Cuthbert_et_al_2020_ECOL_EVOL, 
            Predator=="Lepomis macrochirus")
str(df)

df$N = df$N0
df$Feeding = df$NE

ggplot(df, aes(N, Feeding, col=PredSize)) +
  geom_jitter(alpha=0.6) + 
  scale_x_continuous(limits=c(0,NA))

## Full model ----

formula = bf(Feeding ~ fmax*N/(nhalf+N),
             fmax  ~ 0+PredSize,
             nhalf ~ 0+PredSize,
             nl = TRUE)

priors = c(
  prior(normal(20,10), nlpar="fmax", lb=0),
  prior(normal(15,10), nlpar="nhalf", lb=0)
)

fit.1 = brm(formula,
            prior = priors,
            family = poisson(link="identity"),
            # cores = 4,
            # backend = "stanli",
            data = df)

summary(fit.1)

# plot(fit.1, ask=FALSE)
plot(fit.1, variable="fmax", regex=TRUE)
plot(fit.1, variable="nhalf", regex=TRUE)

plot(conditional_effects(fit.1,
                         effects="N:PredSize"),
     points=TRUE,
     point_args=list(alpha=0.5, width=0.5, height=0.5))

# individual plots
# p = plot(conditional_effects(fit.1,
#                              effects="N:PredSize"),
#          points=TRUE,
#          point_args=list(alpha=0.5, width=0.5, height=0.5))
# p[[1]] + 
#   facet_wrap(~PredSize) +
#   theme(legend.position="none")

# same plots with ggeffects
# library("ggeffects")
# pred = ggpredict(fit.1, terms=c("N [0:64]", "PredSize [all]"))
# plot(pred, show_data=TRUE, jitter=TRUE)

## Model analysis ----

library(emmeans)

# group means for parameter fmax
# (here the same as in summary table, because we used effects-coding fmax~0+PredSize)
em_fmax = emmeans(fit.1, ~ PredSize, nlpar = "fmax")
em_fmax

# contrasts
pairs(em_fmax)

plot(conditional_effects(fit.1,
                         effects="PredSize",
                         nlpar="fmax"))

# same plot with emmeans
# plot(em_fmax)

# pairs() gives you contrasts and their CIs
# get full distribution of a specific contrast with hypothesis() 
hypothesis(fit.1, "nhalf_PredSizelarge > nhalf_PredSizemedium")

p = plot(
  hypothesis(fit.1,"nhalf_PredSizelarge > nhalf_PredSizemedium"),
  plot = FALSE
)
p[[1]] + geom_vline(xintercept=0)

## Null model ----

formula = bf(Feeding ~ fmax*N/(nhalf+N),
             fmax  ~ 1,
             nhalf ~ 1,
             nl = TRUE)

priors = c(
  prior(normal(20,10), nlpar="fmax", lb=0),
  prior(normal(15,10), nlpar="nhalf", lb=0)
)

fit.0 = brm(formula,
            prior = priors,
            family = poisson(link="identity"),
            # cores = 4,
            # backend = "stanli",
            data = df)

summary(fit.0)

plot(fit.0)

plot(conditional_effects(fit.0,
                         effects="N"),
     points = TRUE)

# model comparison
LOO(fit.0, fit.1)

# Part 3b: continuous ----------------------------------------------------------

library(BayesFR) # contains dataset

data(df_Davidson_et_al_2021_FUN_ECOL)
df = subset(df_Davidson_et_al_2021_FUN_ECOL, 
            Predator=="Erythemis simplicicollis")
str(df)

df$Feeding = df$NE
df$N = df$N0

ggplot(aes(N,Feeding, color=HeadWidth), data=df) +
  geom_jitter(alpha=0.7, width=0.75, height=0.75) +
  # scale_colour_viridis_c() +
  scale_x_continuous(limits=c(0,NA)) +
  scale_y_continuous(limits=c(0,NA))

## Basic model ----

formula = bf(Feeding ~ fmax*N/(nhalf+N),
             fmax  ~ scale(HeadWidth),
             nhalf ~ 1,
             nl = TRUE)

default_prior(formula,
              family = poisson(link="identity"),
              data = df
)

priors = c(
  prior(normal(40,20), nlpar="fmax", coef="Intercept"),
  prior(normal(0 ,10), nlpar="fmax", coef="scaleHeadWidth"),
  prior(normal(30,20), nlpar="nhalf", lb=0)
)

fit.1 = brm(formula,
            prior = priors,
            family = poisson(link="identity"),
            # cores = 4,
            # backend = "stanli",
            data = df)

summary(fit.1)

plot(fit.1)

plot(conditional_effects(fit.1,
                         effects="N:HeadWidth"), 
     points = TRUE) # uses mean-sigma, mean, mean+sigma for predictor HeadWidth

plot(conditional_effects(fit.1,
                         effects="N:HeadWidth",
                         int_conditions = list(
                           N = 0:80,
                           HeadWidth = c(2.7, 4.0, 5.1) # min, mean, max instead
                         )
),
points = TRUE)

# same plots with ggeffects
# library("ggeffects")
# pred = ggpredict(fit.1, terms=c("N [0:80]", "HeadWidth[2.7,4.0,5.1]"))
# plot(pred, show_data=TRUE, jitter=TRUE)


## Model analysis ----

library(emmeans)

# slope of Headwidth still on z-scale
fixef(fit.1)

# scale back to original scale 
fixef(fit.1)["fmax_scaleHeadWidth", "Estimate"] / sd(df$HeadWidth)

# or use emtrends!
em_trend = emtrends(fit.1, var="HeadWidth", nlpar="fmax") 
print(em_trend)

# plot fmax ~ HeadWidth, automatically on original scale!
plot(conditional_effects(fit.1,
                         effects="HeadWidth",
                         nlpar="fmax"))

# emtrendd() gives you mean and CIs
# get full distribution with hypothesis() 

hypothesis(fit.1, "fmax_scaleHeadWidth > 0")

p = plot(
  hypothesis(fit.1, "fmax_scaleHeadWidth > 0"),
  plot = FALSE
)
p[[1]] + geom_vline(xintercept=0)

## Link model ----

formula = bf(Feeding ~ fmax*N/(nhalf+N),
             nlf(fmax ~ exp(fmaxlog)),   # exp(b0+b1*x)
             fmaxlog ~ scale(HeadWidth), # b0+b1*x
             nhalf ~ 1,
             nl = TRUE)

priors = c(
  prior(normal(log(40),1), nlpar="fmaxlog", coef="Intercept"),      # on logscale
  prior(normal(0,1),       nlpar="fmaxlog", coef="scaleHeadWidth"), # on logscale
  prior(normal(30,20), nlpar="nhalf", lb=0) # still on original scale
)

fit.2 = brm(formula,
            prior = priors,
            family = poisson(link="identity"),
            # cores = 4,
            # backend = "stanli",
            data = df)

summary(fit.2)

plot(fit.2)

plot(conditional_effects(fit.2,
                         effects="N:HeadWidth",
                         int_conditions = list(N=0:80)),
     points = TRUE)

library(emmeans)

# linear trend for fmaxlog 
em_trend = emtrends(fit.2, var="HeadWidth", nlpar="fmaxlog") 
print(em_trend)

plot(conditional_effects(fit.2,
                         effects="HeadWidth",
                         nlpar="fmaxlog"))

# exponential relationship for actual feeding rate fmax
plot(conditional_effects(fit.2,
                         effects="HeadWidth",
                         nlpar="fmax"))

