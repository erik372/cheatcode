library("tidyverse")
library("patchwork")
library("latex2exp")
library("tidydice")
library("scales")
library("readxl")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# ej vetenskapligt format
options(scipen=999)

# använd komma som decimal
options(OutDec=",")



################################################################################
### pdf och cdf, 1 perfekt balanserat mynt
################################################################################
tb1 <- tibble(x=0:1, 
                   pdf = dbinom(x, 1, .5) ,
                   cdf=  cumsum(pdf),
                   x1 = 1:2
) 

g_coin_pdf <- tb1 %>% 
  ggplot(aes(x=x, y=pdf)) + geom_col(width =.3) +
  labs(x="Possible outcomes for variable M: 1 or 2.", 
       y="Probability", 
       title="Probability mass function") +    ## för diskret rand var. Svenska: Sannolikhetsfunktionen
  theme(text=element_text(size=7), 
        axis.title.y=element_text(hjust=0)) +
  scale_y_continuous(breaks=seq(0,.6,.1), limits = c(0,.6) ) +
  scale_x_continuous(breaks=0:1, labels=1:2, 
                     limits=c(-1,2))
  
g_coin_cdf <- tb1 %>% 
  ggplot(aes(y=cdf, x=x)) + 
  geom_point() +
  geom_segment(aes(x=x, xend=x1, yend=cdf)) +
  geom_segment(x=-1, xend=0, y=0, yend=0) +
  geom_point(x=0,y=0, shape=1) + 
  scale_x_continuous(breaks=0:1, labels=1:2, 
                     limits=c(-1,2)) +
  scale_y_continuous(breaks=seq(0 , 1,.5), limits=c(0,1.1)) +
  labs(x="Values for variable M", 
       y="Cumulative\nprobability", 
       title="Cumulative distribution function") +
  theme(text=element_text(size=7), 
        axis.title.y=element_text(hjust=0)) +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  annotate("text", x=-1, y=1.05, hjust=0, size=1.7,
           label="100 % kumulativ sannolikhet.") 
  
  
(g_coin_pdf / g_coin_cdf)  
(g_coin_pdf / g_coin_cdf)  %>% 
  ggsave(filename = "g_coin_pdf_cdf.pdf", width=4.5, height=6)




################################################################################
### pdf cdf, perfekt balanserad tärning
################################################################################
tb1 <- tibble(x=1:6, 
              pdf = c(1/6,1/6,1/6,1/6,1/6,1/6) ,
              cdf=  cumsum(pdf),
              x1 = 2:7
) 

g_1dice_pdf <- tb1 %>% 
  ggplot(aes(x=x, y=pdf)) + geom_col(width =.3) +
  labs(x="Possible results for variable X: 1 to 6", 
       y="Probability", 
       title="Probability mass function") +
  theme(text=element_text(size=7)) +
  scale_y_continuous(breaks=seq(0,.2,.05), limits = c(0,.2) ) +
  scale_x_continuous(breaks=1:6, limits=c(0,7)) +
  geom_segment(x=0, xend=7, yend=1/6, linetype="dashed") +
  annotate("text", x=0, y=.18, size=1.7, hjust=0, 
           label="1/6 probability")

g_1dice_cdf <- tb1 %>% 
  ggplot(aes(y=cdf, x=x)) + 
  geom_point() +
  geom_segment(aes(x=x, xend=x1, yend=cdf)) +
  geom_segment(x=-1, xend=1, y=0, yend=0) +
  geom_point(x=1,y=0, shape=1) + 
  scale_x_continuous(breaks=1:6, limits=c(0,7)) +
  scale_y_continuous(breaks=seq(0 , 1,.2), limits=c(0,1.1)) +
  labs(x="Values for variable X", 
       y="Cumulative\nprobability", 
       title="Cumulative distribution function") +
  theme(text=element_text(size=7)) +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  annotate("text", x=0, y=1.05, size=1.7, hjust=0, 
           label="100 % cumulative probability.") 


(g_1dice_pdf / g_1dice_cdf)
(g_1dice_pdf / g_1dice_cdf) %>% 
  ggsave(filename = "g_dice_pdf_cdf.pdf", width=4.5, height=6)








################################################################################
### binominalfördelningen 
# pdf och cdf
# dbinom() = för att beräkna binominial sannolikhet
################################################################################
tb_binom <- tibble(x=0:10, 
       pdf = dbinom(x, 10, .5) ,
       cdf=  cumsum(pdf),
       x1 = 1:11
       ) 

g_binom_pdf <- tb_binom %>% 
  ggplot(aes(x=x, y=pdf)) + geom_col(width =.3) +
  scale_x_continuous(breaks=0:10) + 
  labs(x="Number of tails", 
       y="Probability", 
       title="Probability function") +
  annotate("text", x=0,y=.18, size=1.7, hjust=0,
           label="Probability that exactly\n3 out of 10 \nresults are tails") +
  geom_segment(aes(x=.5, xend=2.4, 
                   y=.15, yend=.1), arrow=arrow(length=unit(.1, 'cm'))) +
  theme(text=element_text(size=7))

g_binom_cdf <- 
  tb_binom %>% 
  ggplot(aes(y=cdf, x=x)) + 
  geom_point(size=1) +
  geom_segment(aes(x=x, xend=x1, yend=cdf), size=.5) + 
  geom_segment(x=-.5, xend=-.2, y=0, yend=0, size=.5) +
  scale_x_continuous(breaks=0:10) +
  scale_y_continuous(breaks=seq(0,1,.1)) +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  annotate("text", x=0, y=1.05, hjust=0, size=1.7,
           label="100 % cumulative proability") +
  annotate("segment", x=3, xend=3, y=0, yend=.4, linetype="dashed") +
  annotate("text", x=.6, y=.5, size=1.7, hjust=0,
           label="Probability for\n0, 1, 2 or 3 tails") +
  labs(x="Number of tails", 
       y="Cumulative\ndistribution", 
       title="Cumulative distribution function") +
  theme(text=element_text(size=7))
  

(g_binom_pdf / g_binom_cdf) 
(g_binom_pdf / g_binom_cdf) %>% 
  ggsave(filename="g_binom_pdfcdf.pdf", width=4.5, height=6)



################################################################################
### binominalfördelningen 
# mer manuellt
################################################################################
factorial(4)   # 4 fakultet = 4!
tb1 <- tibble(
  x = 0:10,
  n = 10,
  n_over_x = factorial(n) / (factorial(x) * factorial(n-x)), 
  p1 = .5^x,
  p2 = .5^(n-x),
  pdf = n_over_x * p1 * p2,
  cdf = cumsum(pdf)
  )




# g_binom_pdf <- tb1 %>% 
# g_binom_cdf <- tb1 %>% 
 ' ggplot(aes(x=x, y=cdf)) +
  geom_col(fill="gray", width =.3) + 
  geom_point() + geom_line(linetype="solid") + 
  geom_area(aes(x=x, y=if_else(x<=3, cdf, NA_real_) ), 
            fill="grey42", 
            alpha=.65) +
  scale_x_continuous(breaks=0:10) '








################################################################################
### law of large numbers
set.seed(123)
################################################################################
# LLN > coin toss
thecoin <- function(x){ sample(1:2, size=x, replace=TRUE) %>% mean() %>% return() }
tg <- function(n) {
  sapply(n, thecoin ) %>% tibble %>% mutate(r=row_number()) %>% 
    ggplot(aes(y=.,x=r)) + 
    geom_line(size=.3) + 
    geom_point(size=1) +
    scale_y_continuous(breaks=seq(1,2,.1), 
                       labels=seq(1,2,.1), 
                       limits=c(1,2)) +
    geom_hline(yintercept=1.5, linetype='dashed') +
    labs(x="Number of coin throws\nper mean value", 
         y="Mean") +
    coord_cartesian(ylim = c(1,2),
                    clip = "off") +
    theme(plot.margin = unit(c(1,1,1,4), "lines"), 
          text=element_text(size=8)) 
}
#1:10 %>% tg + 
coin1k <- 1:1000 %>% tg

g_10coins <- coin1k + 
  scale_x_continuous(breaks=seq(1,10,1), labels=seq(1,10,1), limits=c(1,10)) + 
  geom_label(x=0,y=2,hjust=1, label="100 % klave", size=2.5) +
  geom_label(x=0,y=1,hjust=1, label="100 % krona", size=2.5) +
  annotate('text', x=2, y=2, hjust=0, size=2,
           label="3 throuws, of which 2 tails and 1 heads.") +
  geom_segment(aes(x=3, xend=3, y=1.9, yend=1.75), arrow=arrow(length=unit(.1, 'cm')))

g_1000coins <- coin1k +
  scale_x_continuous(breaks=c(1,seq(100,1000,100)), 
                     labels=c(1,seq(100,1000,100))) +
  geom_label(x=-100,y=2,hjust=1, label="100 % tails", size=2.5) +
  geom_label(x=-100,y=1,hjust=1, label="100 % heads", size=2.5) 

(g_10coins / g_1000coins)
(g_10coins / g_1000coins) %>% ggsave(file="g_1000coins.pdf", 
                                     width=5, height=6.75)
knitr::plot_crop("g_1000coins.pdf")




############################################################################
### DICES
############################################################################
### 2 dices
g_2dices <- 
  tibble(Resultat=2:12, 
         `Antal fall`=c(1,2,3,4,5,6,5,4,3,2,1)) %>% 
  ggplot(aes(y=`Antal fall`, x=Resultat)) + 
  geom_col(width = .5) +
  scale_x_continuous(breaks=2:12, labels=2:12) +
  scale_y_continuous(breaks=1:6, labels=1:6) +
  labs(x="Points") +
  theme(text=element_text(size=7))

g_2dices
g_2dices %>% ggsave(file="g_2dices.pdf", width=1.8, height=2)


#####################################################################
# LLN > dice rolls
#####################################################################
diceroll <- function(x)
{
  sample(1:6, size=x, replace=TRUE) %>% mean() %>%   return()
}
# prep some
gh <- geom_hline(yintercept=3.5, linetype='dashed', alpha=.33) 
gl <- labs(x="Number of dice throws\nper mean value", y="Mean")
th <- theme(text=element_text(size=7))

# graph 1
rolls <- 1000
dice_df <- tibble(r=1:rolls, 
                  sm= sapply(1:rolls, diceroll) )
g_10dices <- dice_df %>% head(10) %>% 
  ggplot(aes(x=r, y=sm)) + geom_line() + 
  gh + gl + th +
  geom_point() +
  scale_x_continuous(breaks=1:rolls) +
  scale_y_continuous(breaks=1:6, limits = c(1,6))

# graph 2
g_1000dices <- dice_df %>% 
  ggplot(aes(x=r, y=sm)) + geom_line(linewidth=.1) + 
  gh + gl + 
  scale_x_continuous(breaks=seq(0,rolls, 100)) +
  scale_y_continuous(breaks=1:6, limits = c(1,6)) +
  theme(text=element_text(size=7), 
        axis.text.x=element_text(angle=90))

(g_10dices + g_1000dices) 

(g_10dices + g_1000dices) %>% 
  ggsave(file="g_dicemeans.pdf", width=4.5, height=3)





#############################################################################
## Illustrate probabilities for dices
#############################################################################
dices <- 1:10
myvar <- matrix(ncol=1, nrow= max(dices* 6))
results <- dices %>% map_dfc(~{
  t <- .x
  prob1 <- (1/6)^t  # 
  # create results for all dices this loop
  for(x in t:(t*6)){ 
    myvar[x,1] <-  prob1 * min(x-(t-1),(6*t+1)-x) 
    # abs()   # > absolute value
    #myvar[x,1] <-  prob1 * (t*(6/2)- abs( x - t*(6/2) - (t-1) ))
  }
  myvar %>% return()
}) 
# automated colnames
colnames(results) <- paste0("d", dices)
# add rownumber = dice result
results <- results %>%  mutate(r= row_number()) %>% relocate(r)
results







################################################################################
### Poisson
################################################################################
# Bortkiewicz data
library("vcd")
help(package="vcd")
data("VonBort")

VonBort %>% summary
VonBort$year %>% unique
VonBort$corps %>% unique
VonBort$deaths %>% sum

VonBort %>% str
196 / 280


ggplot() +
  stat_function(fun=function(x)  exp(-0.49)*(0.49^x / factorial(x)) * 200 ) +
  xlim(0,4) 

my_poisson <- function(x){
exp(-.7)*(.7^x / factorial(x))
}
c(0,1,2,3,4) %>% my_poisson %>% round(6)

c(0:2) %>% my_poisson() %>% sum

dpois(x=1,lambda=.7)


g_vonbort <- 
  VonBort %>% 
  group_by(deaths) %>% 
  add_count(deaths) %>% 
  distinct(n) %>% 
  
  ggplot(aes(x=deaths, 
             y=n)) + 
  geom_col(fill="gray") + 
  geom_point() +
  stat_function(fun=function(x)  exp(-0.7)*(0.7^x / factorial(x)) * 285 ,geom="line") +
  
  annotate("text", x=2, y=70, hjust=0, size=2, 
           label="In 32 cases, 2 soldiers died\nin one year in the same cavalry corps") +
  geom_segment(aes(x=2.1, xend=2.1, 
                   y=58, yend=41), arrow=arrow(length=unit(.1, 'cm'))) +
  annotate("text", x=1.1, y=125, hjust=0, size=2, 
           label=TeX("The line is drawn using the function$e^{-\\lambda} \\frac{\\lambda^{x}}{x!}$")) +
  
  scale_y_continuous(
    name="Number of cavalry corps\n(the bars)",
  sec.axis =   sec_axis(trans= ~.* 1/285, 
                        name="Probability\n(the line)") 
  )  +

  labs(x="Number of deaths") +
  theme(text=element_text(size=8))

g_vonbort
g_vonbort %>% ggsave(filename="g_vonbort.pdf", width=4, height=2.7)
knitr::plot_crop("g_vonbort.pdf")
