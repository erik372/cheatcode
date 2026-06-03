rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("tidydice")
library("scales")
library("ggrepel")
#install.packages("devtools")
# devtools::install_github("nicolash2/ggbrace")
library("ggbrace")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

################################################################################
#  X --> Y
################################################################################
x_arrow_y <- ggplot() +
  geom_label(aes(label=c("X","Y"), 
                 x=c(2,3), 
                 y=1
  ) ) +
  # pil X->Y
  annotate('segment', x=2.2 , xend=2.8,  y=1, yend=1, 
           arrow=arrow(length=unit(.2, 'cm'), 
                       ends='last', type='open')) +
  ylim(.7,1.3) +
  xlim(1.9, 3.1) +
  theme_void()


x_arrow_y
x_arrow_y %>% ggsave(filename="x_arrow_y.pdf", width=2, height=2)
knitr::plot_crop("x_arrow_y.pdf")

################################################################################
## omitted: Z och P, påverkar X och Y
################################################################################
g_omitted <- ggplot() +
  geom_label(aes(label=c("X","Y", "P"), 
                 x=c(2,3, 2.5), 
                 y=c(1,1, 2)
  ) ) +
  geom_text(aes(label="(Z)", x=2.5, y=0), alpha=.3) +
  
  # pil X->Y
  annotate('segment', x=2.1 , xend=2.9,  y=1, yend=1, 
           arrow=arrow(length=unit(.2, 'cm'), 
                       ends='last', type='open')) +
  # pilar för P
  annotate('segment', x=2.4 , xend=2.1,  y=1.8, yend=1.2, 
           arrow=arrow(length=unit(.2, 'cm'), ends='last', type='open')
  ) +
  annotate('segment', x=2.6 , xend=2.9,  y=1.8, yend=1.2, 
           arrow=arrow(length=unit(.2, 'cm'), ends='last', type='open')) +
  
  # pilar fr Z
  annotate('segment', x=2.4 , xend=2.1,  y=.2, yend=.8, alpha=.3,
           arrow=arrow(length=unit(.2, 'cm'), ends='last', type='open')
  ) +
  annotate('segment', x=2.6 , xend=2.9,  y=.2, yend=.8, alpha=.3,
           arrow=arrow(length=unit(.2, 'cm'), ends='last', type='open')) +
  ylim(-.1,2.1) +
  xlim(1.9, 3.1) +
  theme_void()

g_omitted
g_omitted %>% ggsave(filename="g_omitted.pdf", width=2.8, height=2.2)
knitr::plot_crop("g_omitted.pdf")


################################################################################
### Instrumentell variabel
################################################################################
g_iv <- g_omitted +
  # S
  geom_label(aes(label="S"), x=1, y=1) +
  # pil
  annotate('segment', x=1.2 , xend=1.8,  y=1, yend=1, 
           arrow=arrow(length=unit(.2, 'cm'), 
                       ends='last', type='open')) +
  xlim(1,3)

g_iv
g_iv %>% ggsave(filename="g_iv.pdf", width=3, height = 1.6)
knitr::plot_crop("g_iv.pdf")


################################################################################
### diff-in-diff
################################################################################
g_did <- tibble(
  x=c(.5,1,2, .5,1,2), 
  y=c(.95, 1, 1.1,  1.2, 1.25, 1.5), 
  group=c(1,1,1, 2,2,2)) %>% 
ggplot(aes(x,
           y,
           group=group)) + 
  geom_point() +
  geom_line() +
  geom_function(fun=function(x) 1.15 + x* .1, linetype="dashed", xlim=c(1,2)) +
  scale_x_continuous(breaks=1, 
                     labels="X occur", 
                     limits=c(.5,2.3)) +
  geom_vline(xintercept=1, alpha=.3) +
  ylim(.9, 1.5) +
  annotate("text", x=1.5, y=c(1, 1.5), size=1.8, 
           label=c("Control", "Treatment")) +
  annotate("text", x=1.8, y=1.25, size=1.8, hjust=0,
           label="Theoretical counter factual\ndevelopment without treatment") +
  
  # geom_brace(inherit.data=FALSE,  aes(x=c(2.02,2.06), y=c(1.35, 1.5)), rotate = 90) +
  stat_brace(data=tibble(x=c(2.02,2.06), y=c(1.35, 1.5), group=1), aes(x,y), rotate=90) +
  stat_brace(data=tibble(x=c(2.02,2.06), y=c(1.35, 1.5), group=1), aes(x,y), rotate=90) +
  annotate("text", x=2.1, y=1.43, size=1.8, hjust=0, 
           label="Effect") +
  labs(x=element_blank(), y="Y") +

  theme(text=element_text(size=8), 
        axis.title.y = element_text(angle=0), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank())  
  

g_did
g_did %>% 
  ggsave(filename="g_did.pdf", width=3.5, height=2.5)





  

################################################################################
### carpenter & dobkin 
################################################################################
### reg discont (RD)
# kopierat från https://rpubs.com/phle/r_tutorial_regression_discontinuity_design
# data från 
# https://github.com/jrnold/masteringmetrics/blob/master/masteringmetrics/data/mlda.rda
################################################################################
#setwd("C:/Users/hegel/Dropbox/_MINA TEXTER _db/Matte för samhällsvetare/litteratur/reg discont/repllikera carpenter_dobkin_2009")
load("data/mlda.rda")  

mlda %>% colnames
mlda %>% summary
mlda$agecell %>% head(13)


mlda <- mlda %>% 
  mutate(agedummy = ifelse(agecell>21,1,0)) 

## endast konstantdummy
coefs1 <- lm(all ~ agecell + agedummy, mlda) %>% coefficients() 

g_rdd1 <- mlda %>% 
  ggplot(aes(x = agecell, y = all, group=agedummy)) + 
  geom_point(size=.7) +
  geom_vline(xintercept = 21) +
  geom_function(fun=function(x) coefs1[[1]] + coefs1[[2]] *x   , xlim=c(19,21), linetype="dashed") +
  geom_function(fun=function(x) coefs1[[1]] + coefs1[[2]] *x  + coefs1[[3]] , xlim=c(21,23), 
                linetype="dashed") +
  labs(x="Age", y="Deaths per 100,000 persons", 
       title=TeX("$Y_{i}=a_{1}+a_{2}X_{i}+a_{3}T_{i}+u$")) +
  theme(text=element_text(size=7)) 


## Konstant + lutning
coefs2 <- lm(all ~ agecell + agedummy + agecell*agedummy, mlda) %>% coefficients()

g_rdd2 <- mlda %>% 
  ggplot(aes(x = agecell, y = all)) + 
  geom_point(size=.7) +
  geom_vline(xintercept = 21) +
  geom_function(fun=function(x) coefs2[[1]] + coefs2[[2]] *x   , xlim=c(19,21), linetype="dashed") +
  geom_function(fun=function(x) coefs2[[1]] + coefs2[[3]] + coefs2[[2]] *x + coefs2[[4]] *x   , xlim=c(21,23), 
                linetype="dashed") +
  labs(x="Age", y="Deaths per 100,000 persons", 
       title=TeX("$Y_{i}=b_{1}+b_{2}X_{i}+b_{3}T_{i}+b_{4}\\left(X_{i}*T_{i}\\right)+v$")) +
  theme(text=element_text(size=7)) 


(g_rdd1 + g_rdd2)
((g_rdd1 + g_rdd2) +
    labs(caption="Y = Number of alcohol related deaths per 100,000 for this age group in the US.
  X = Age in year and month.")) %>% 
  ggsave(filename="g_carpenter_dobkin.pdf", width=4.5, height=3)

knitr::plot_crop("g_carpenter_dobkin.pdf")
