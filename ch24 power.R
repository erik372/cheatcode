rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("mosaic")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

# # använd komma som decimal
# options(OutDec=",")


################################################################################
### livslängd för män och kvinnor
################################################################################
library("BSDA")
set.seed(123)
x <- rnorm(290, 80, 1.5)
y <- rnorm(290, 81, 1.5)
z.test(y,x, sigma.x=1.5, sigma.y=1.5)

# z-test manuellt
(81-80) / sqrt( (1.5^2)/290 + (1.5^2)/290 )


pnorm(81, mean= 80, sd= 1.5)
sign_high <- qnorm(.975, mean=80, sd=1.5)
sign_low <- qnorm(.025, mean=80, 1.5) 
pnorm(sign_high, mean= 81, sd= 1.5)

g_power <- ggplot() +
  # grå yta
  stat_function(fun=function(x) dnorm(x, 81, 1.5), xlim=c(75, sign_high), geom="area", fill="gray", alpha=.5) +
  # mörkgrå yta 1
  stat_function(fun=function(x) dnorm(x, 80, 1.5), xlim=c(74, sign_low), geom="area", fill="black", alpha=.5) +
  # mörkgrå yta 2
  stat_function(fun=function(x) dnorm(x, 80, 1.5), xlim=c(sign_high,88), geom="area", fill="black", alpha=.5) +
  
  # normalkurvorna
  geom_function(fun=function(x) dnorm(x, 80, 1.5)) +
  geom_function(fun=function(x) dnorm(x, 81, 1.5), alpha=.3) +
  
  # vertikala streckade linjer
  geom_segment(aes( x=c(80, 81), xend=c(80, 81), y=c(0,0), 
                    yend=c(dnorm(80,80,1.5), dnorm(80,80,1.5))),  linetype="dashed", alpha=.3) +
  geom_segment(aes(x=c(sign_low, sign_high), xend=c(sign_low, sign_high), 
                   y=0, yend=c(.116 , .116)), linetype="dashed") +
  
  # alfa
  annotate("label", x=c(sign_low-.24, sign_high+.24), 
           y=.03, size=3, 
           hjust=c(1,0), 
           label=TeX("$\\alpha /2$")) +
  annotate("text", x=75.5, hjust=0, size=2, y=.29, 
           label=TeX("The level of significance and probability for type 1 error $=\\alpha=0,05$")) +
  
  # beta
  annotate("label", x=81.7, y=.055, size=2, 
           label="Probability\nfor type 2 error\n= circa 90%") +
  annotate("label", x=81.7, y=.02, size=3, 
           label=TeX("$\\beta$")) +
  
  # 1- beta
  annotate("label", x=84.3, y=.1, size=2, 
           label="Power\nof the test\n= circa 10%") +
  annotate("label", x=84.3, y=.065, size=3, 
           label=TeX("$1 - \\beta$")) +
  
  annotate("text", x=76.2, y=.14, size=2, 
           label="Critical values\nfor 95% statistical\ncertainty") +
  
  scale_x_continuous(breaks=c(sign_low,80,81,sign_high), limits=c(74,86), 
                     labels = c(paste(sign_low %>% round(1)),
                                TeX("$\\bar{X}_1=80$"),
                                TeX("$\\bar{X}_2=81$"),
                                paste(sign_high %>% round(1))) 
                     ) +
  labs(x=element_blank(), y=element_blank()) +
  theme(axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(), 
        text=element_text(size=8))

g_power
g_power %>% ggsave(filename="g_power.pdf", height=3, width=4.5)







################################################################################
## binomial test
################################################################################
# vilken x krävs för 95%
qbinom(.05, 100, .5)
# vilken x krävs för 99,5%
qbinom(.005, 100, .5)
# vad är F(x) för x=36, x=63  (för dessa är vi p<0,01)
pbinom(59, 100, .5)
pbinom(41, 100, .5) * 2
(1 - pbinom(58, 100, .5) ) *2



ggplot() +
  stat_function(fun=function(x) x=dbinom(x,100,.5) ,  alpha=.6) +
  stat_function(fun=function(x) x=dbinom(x,100,.58),  alpha=.3) +
  xlim(0,100) 
  



#### snott fr webben
plotDist("binom", params=c(100, .5), col=c("red","forestgreen"),
         groups=abs(x-50) <= 10, 
         xlim=c(30,80), 
         ylim=c(0,0.1))
plotDist("binom", params=c(100, .52), 
         col="gray60", add=TRUE)


################################################################################
# introduktion till power 1
################################################################################
pbinom(9,10,.5,lower.tail = FALSE)

pbinom(q=60, size=100, prob=.5, lower.tail = FALSE)
1-pbinom(q=60, size=100, prob=.5)

pbinom(q=62, size=100, prob=.5, lower.tail=FALSE)
1-pbinom(q=62, size=100, prob=.5, lower.tail = FALSE)
pbinom(q=37, size=100, prob=.5)
1-pbinom(q=62, size=100, prob=.5, lower.tail = FALSE)



yaxeln <- c(0, .005, .01, .02, .05, .1)
g_pbinom_illustration <- 
  tibble(
    x=50:100,
    y1 = pbinom(50:100, 100, .45, lower.tail = FALSE),
    y2 = pbinom(50:100, 100, .5, lower.tail = FALSE),
    y3 = pbinom(50:100, 100, .55, lower.tail = FALSE)
    
  ) %>% pivot_longer(y1:y3) %>% 
  filter(x<76) %>% 
  
  ggplot(aes(x=x,y=value, 
             shape=name, 
             color=value<.005)) +
  geom_point(size=2) +
  geom_line(size=.1) +
  scale_shape_discrete(name="Sannolikhet\np per mynt", 
                       breaks=c("y1","y2","y3"),
                       labels=c("0,45", "0,5","0,55")) +
  scale_color_manual(values=c("gray", "black"), guide="none") +
  scale_y_continuous(breaks=yaxeln, labels=yaxeln, minor_breaks = NULL,
                     limits=c(0,.05),) +
  
  scale_x_continuous(breaks=c(55,58, 63, 68, 70, 75) , 
                     # minor_breaks = seq(52.5,72.5,5) %>% setdiff(62.5), 
                     limits=c(55,75)) +
  theme(text=element_text(size=8), 
        legend.position = c(.7,.7)) +
  labs(x="Antal x (klave) på 100 försök",
       y="Sannolikheten för x\neller fler klave")

g_pbinom_illustration
g_pbinom_illustration %>% 
  ggsave(filename="g_pbinom_illustration.pdf", height=3, width=3.5)


################################################################################
### beräkna power 2
# beräkna kritiskt värde
n_toss <- 14015
#n_heads
qbinom(.001, n_toss, .5, lower.tail = FALSE)
pbinom(7190,n_toss, .52, lower.tail = FALSE)



power_at_n <- c(0) # initialize vector that stores power for each number of tosses
n_heads <- c() # save "critical" number of heads for that toss-amount that would result 
n_toss <- 2 # initialize the toss-counter
while(power_at_n[n_toss-1] < .95){ # continue as long as power is not 95 %
  n_heads[n_toss] <- qbinom(.001, 
                            n_toss, 
                            .5, 
                            lower.tail = FALSE) # retrieve critical value
  
  power_at_n[n_toss] <- pbinom(n_heads[n_toss], 
                               n_toss, 
                               .52, 
                               lower.tail = FALSE) # calculate power (1-beta) for each coin-toss
  
  n_toss <- n_toss+1 # increase toss-number 
}


yaxeln <- c(0,.25,.5,.75,.95,1)
g_binom_power <- tibble(
  k = 1:(n_toss-1), 
  y = power_at_n
) %>% 
  # behåll var 500e rad
  slice(which(row_number() %% 200 == 1)) %>% 
  ggplot(aes(x=k, y=y)) + 
  geom_point(size=.2) +
  scale_y_continuous(breaks=yaxeln, labels=yaxeln, limits=c(0,1), 
                     minor_breaks =seq(0,1,1/8) ) +
  geom_hline(yintercept = .95, alpha=.5, size=.1) +
  scale_x_continuous(breaks=(seq(0,(n_toss-1), 2500) %>% c(n_toss-1)), 
                     labels=(seq(0,(n_toss-1), 2500) %>% c(n_toss-1)),
                     minor_breaks = seq(1250, 12500, 2500)  ) +
  labs(x="Antal kast", 
       y="Statistisk styrka") +
  theme(text=element_text(size=8))

g_binom_power
g_binom_power %>% ggsave(filename="g_binom_power.pdf", width=3.5, height=3)



################################################################################
### power för regression... 
################################################################################

set.seed( 12345)
n <- 1000000
small_s <- 500
big_s <- 20000

x <- rnorm(n, 2.5, .4)
# (n/10) + runif(100000, min=-10, max=10)
df <- tibble(1:n, x, y= 5*x + exp(rnorm(n, 5, .5)) )  
lm(y~x, data=df) 

# ggplot(df, aes(y=y, x=x)) + geom_point() + geom_smooth(method="lm", se=FALSE)


mysamplefunction <- function(sample_size) {
  map_dfr(1:2000, ~{
    lmres <- lm(y~x, data=slice_sample(df, n=sample_size) ) %>% summary()
    tibble(calculation = .x,
           beta = lmres$coefficients[2,1],
           p_value = lmres$coefficients[2,4]
    ) %>% 
      return()
  })
}


set.seed( 12345)
results_df_big <- mysamplefunction(big_s)
results_df_small <- mysamplefunction(small_s)

conflict_prefer("count","dplyr")
results_df_big %>% filter(p_value <.05) %>% count



g_styrka_regression <- results_df_big %>% 
  bind_rows(results_df_small, 
            .id="sample") %>% 
  mutate(sample = case_when(sample=="1" ~ "Big sample, n = 20,000", 
                            sample=="2" ~ "Small sample, n = 500")) %>% 
  ggplot(aes(x=beta, 
             fill=if_else(p_value<.01, "sign", "nosign"))) + 
  geom_histogram(bins=50, 
                 alpha=.9, 
                 position="identity") + 
  scale_fill_manual(breaks=c("sign","nosign"), 
                    values=c("black","gray"), 
                    labels=c("Yes","No"), 
                    name="Statistical\nsignificance") +
  scale_x_continuous(breaks=seq(-30,40,10) %>% c(5)) +
  facet_wrap(~sample, 
             ncol = 1, 
             scale="free_y") +
  labs(y="Number of estimates",
       x=TeX("Estimated slope coefficient $\\hat{b}$")
       ) +
  theme(text=element_text(size = 8))

g_styrka_regression
g_styrka_regression %>% ggsave(filename="g_styrka_regression.pdf", 
                               height=6.2, width=4.5)




