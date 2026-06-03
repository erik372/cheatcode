rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("ggtext")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# ej vetenskapligt format
options(scipen=999)

# använd komma som decimal
options(OutDec=",")

#######################################################
## tårta
g_cakeutility <- ggplot() + 
  stat_function(fun=function(x) 3*x - x^2) +
  xlim(0,3) + 
  geom_vline(xintercept=0, alpha=.2) +
  geom_hline(yintercept=0, alpha=.2) +
  
  annotate('segment', x=1.5,  xend=1.5, y=0, yend=2.25, linetype='dashed') +
  annotate('text', x=1.5, y=2.66, size=2.5,
           label="Maximum happiness is achived\nat 1.5 cake") +
  annotate('text', x=.75, y=.48, size=2.5, 
           label="Zero cake and\nzero happiness") +
  annotate("curve", x = .7, y = .3, 
           xend = .1, yend = 0, 
           curvature = -.2, arrow = arrow(length = unit(2, "mm")) ) +
  geom_point(aes(x=1.5, y=2.25), size=2) +
  labs(y="Happiness", 
       x="Number of cakes") +
  scale_y_continuous(breaks=0:3, labels=0:3, limits=c(0,3)) +
  theme(axis.title.y = element_text(angle=0), 
        text=element_text(size=7)) 
  
g_cakeutility
g_cakeutility %>% ggsave(file="g_cakeutility.pdf", width=3.5, height=3) 
  



################################################################################
### fishers intertemporal theory
# konsumera och spara
################################################################################
g_intertemporal <- 
  ggplot() +
  stat_function(fun=function(x) .1/x  ) +
  #stat_function(fun=function(x) .15/x  , linetype='dashed', alpha=.5) +
  #stat_function(fun=function(x) .03/x  , linetype='dashed', alpha=.5) +
  # tradeoff 1: låg r
  stat_function(fun=function(x) .4-.4*x, linetype="longdash") +
  # tradeoff 2: hög r 
  stat_function(fun=function(x) 1-2.5*x, linetype="dashed", alpha=.6) +
  xlim(0,1)  + ylim(0,1) +
  
  geom_point(aes(x=c(.2,.5), 
                 y=c(.5,.2)), size=1.9) +
  geom_label(aes(x=c(.13,.5), 
                 y=c(.5,.13)), size=2, 
             label=c("A","B")) +
  
  labs(x="Consumption\nperiod 1",
       y="Consumption\nperiod 2") +
  geom_label(aes(x=c(.41, .03), y=c(0,.4)), size=2, 
             label=c("High interest rate", "Low interest rate")) +
  
  annotate("text", x= .2, y=.9, hjust=0, size=1.8, 
           label="
           Indifference curve:
           How much we value 
           consumption today 
           and tomorrow") +
  annotate("curve", 
           x = .22, y = .9, 
           xend = .16, yend = .9, 
           curvature = .2, arrow = arrow(length = unit(2, "mm")) ) +
  annotate("text", x=.3, y=.5, hjust=0, size=1.8, 
           label="
           If the interest rate goes up,
           we consume more tomorrow 
           and less today") +
  annotate("curve", 
           x = .33, y = .51, 
           xend = .26, yend = .51, 
           curvature = .1, arrow = arrow(length = unit(2, "mm")) )  +
    theme(text = element_text(size=8), 
        axis.text = element_blank() ,
        axis.ticks = element_blank(),
        axis.title.y = element_text(angle=0, hjust=0),
        axis.title.x = element_text(hjust=1), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        ) 

g_intertemporal
g_intertemporal %>% 
  ggsave(filename="g_intertemporal.pdf", width=4.2, height=3)
  
knitr::plot_crop("g_intertemporal.pdf")








################################################################################
### Lafferkurvan
################################################################################
1/(1+.5)
g_laffer <- ggplot() +
  stat_function(fun=function(x) x*100*(1-x)^3) +
  stat_function(fun=function(x) x*100*(1-x)^.5, linetype="dashed") + 
  geom_vline(xintercept=0, alpha=.2) +
  geom_hline(yintercept=0, alpha=.2) +
  annotate("text", 
           x=c(.25, .66), 
           y=c(13.5, 42), 
           size=2,
           hjust=c(0,.5), 
           label=c("Inefficient system\nb = 3", 
                   "Efficient system\nb = 0,5")) +
  annotate("segment", x=.25, xend=.25, y=0, yend=10, linetype="dotted") +
  annotate("segment", x=2/3, xend=2/3, y=0, yend=38, linetype="dotted") +
  theme(text=element_text(size=8), 
        #axis.ticks.y = element_blank(), 
        #axis.text.y = element_blank(), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        ) +
  labs(x="Tax level,\npercent", y="Total tax revenue") +
  scale_y_continuous(breaks=0, labels=0) +
  scale_x_continuous(breaks=c(0,.25, 2/3, 1), 
                     labels=c("0%","25%", "66.6%" , "100%"), limits = c(0,1))


g_laffer
g_laffer %>% ggsave(filename="g_laffer.pdf", width=4, height=3)





################################################################################
## example firm profit
################################################################################

g_revcombos <-   ggplot(tibble(x=0:200)) + 
  stat_function(fun=function(x) 100 - .5*x , linetype='dashed' ) +
  stat_function(fun=function(x) 80 - .5*x  , linetype='dashed') +
  stat_function(fun=function(x) 60 - .5*x  , linetype='dashed') +
  stat_function(fun=function(x) 40 - .5*x  , linetype='dashed') +
  stat_function(fun=function(x) 20 - .5*x  , linetype='dashed') +
  annotate('richtext', x = 20, y = 10, label="R = 400", angle=315 , size=2.5) +
  annotate('richtext', x = 40, y = 20, label="R = 800", angle=315 , size=2.5) +
  annotate('richtext', x = 60, y = 30, label="R = 1 200", angle=315 , size=2.5) +
  annotate('richtext', x = 80, y = 40, label="R = 1 600", angle=315 , size=2.5) +
  annotate('richtext', x = 100, y = 50, label="R = 2 000", angle=315 , size=2.5) +
  scale_x_continuous(labels=c(0,40,80,120,160,200), 
                     breaks=c(0,40,80,120,160,200), 
                     limits = c(0,200) ) +
  scale_y_continuous(labels=c(0,20,40,60,80,100), 
                     breaks=c(0,20,40,60,80,100),
                     limits=c(0,100) ) +
  annotate("curve", 
           x = 125, y = 65, 
           xend = 105, yend = 58, 
           curvature = .2, 
           arrow = arrow(length = unit(2, "mm")) ) +
  annotate(geom = "text", x = 130, y=65, hjust=0, size=2.2,
           label="Revenue for all\ncombinations of\ny and x along\nthis line.") +
  annotate('text', x=58, y=90, hjust=0, size=2.2, 
           label="The lines illustrate\npossible combinations of x and y\nfor different levels of revenue\ny = R - (1/2)*x.") +
  theme(text = element_text(size=8), 
              axis.text = element_blank() ,
              axis.ticks = element_blank(),
              axis.title.y = element_text(angle=0),
              axis.title.x = element_text(hjust=1), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        )
        
g_revcombos
g_revcombos %>% ggsave(file="g_revcombos.pdf", 
                          width=3, height=3)



################################################################################
## add profit lines
################################################################################

g_profit_revenue <- 
  ggplot(tibble(x=0:200)) + 
  # y=5
  stat_function(fun=function(x) 10*x + 100 -(x^2 + 50 + 10), xlim=c(0,14)) + 
  # y=4
  stat_function(fun=function(x) 10*x + 80 -(x^2 + 32 + 10) , linetype='dashed', xlim=c(0,14)) +
  # y=7
  stat_function(fun=function(x) 10*x + 140 -(x^2 + 98 + 10) , linetype='dashed', xlim=c(0,14)) + 
               ylim(0,75) +
  geom_point(aes(x=5, y=65), size=2.5) +
  geom_segment(x=5, xend=5, y=65, yend=0, linetype='dotted') +
  
  geom_vline(xintercept=0, alpha=.2) +
  geom_hline(yintercept=0, alpha=.2) +
  
  annotate('text', x=5.5, y=15, size=2.5, hjust=0,
           label="Maximum profit\nat x = 5.") +
  #annotate('text', x=14, y=75, size=2.5, hjust=1,
  #         label=TeX("$v = 10x + 20y - (x^2 + 2y^2 + 10)$")) +
  geom_label(data=tibble(x=c(8,8,8), 
                              y=c(47.5,53.5,59), 
                              label=c("y = 7","y = 4","y = 5")), 
                  aes(x,y,label=label), size=2.5) +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=7)) +
  labs(y="Profit, v", 
       x="Production, x", 
       title=TeX("$v = 10x + 20y - (x^2 + 2y^2 + 10)$")) 

g_profit_revenue
g_profit_revenue %>% ggsave(file="g_profit_revenue.pdf", width=4, height=3)





################################################################################
## example utility function
################################################################################

g_utilitycombos <- ggplot(tibble(x=0:10)) +
  ylim(0,100) + xlim(0,1) +
  stat_function(fun=function(x) 30/x , linetype='dotted') +
  stat_function(fun=function(x) 25/x , linetype='dotted') +
  stat_function(fun=function(x) 20/x , linetype='dotted'  ) +
  stat_function(fun=function(x) 15/x , linetype='dotted' ) +
  stat_function(fun=function(x) 10/x , linetype='dotted'  ) +
  stat_function(fun=function(x) 5/x , linetype='dotted'  ) +
  geom_segment(x=.17,y=17, 
               xend=.6, yend=60, 
             arrow=arrow(length=unit(.12, "inches"), ends='both'), 
             size=.2) +
  theme(text = element_text(size=8), 
        axis.text = element_blank() ,
        axis.ticks.y= element_blank(),
        axis.ticks.x= element_blank(),
        axis.title.y = element_text(angle=0),
        axis.title.x = element_text(hjust=1), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        ) +
  labs(y="Consumption", 
       x="Leisure") +
  
  annotate('text', x=.47, y=100, hjust=0, vjust=1, size=2.2,
           label="The indifference curves show different\ncombinations of consumption\nand leisure where utility is constant\nalong each line.")+
  geom_curve(aes(x = .44, xend = .36,
                 y =98, yend = 88),
             arrow = arrow(length = unit(0.08, "inch")), size = 0.2,
             color = "gray20", curvature = 0.3) +
  
  annotate(geom = "text", x =.66, y=66.6, size=2.2, hjust=0,
           label="Lines further out illustrate\ncombinations with greater utility.") +
  annotate(geom = "text", x = 0, y=6.5, size=2.2, hjust=0,
           label="Lines further in illustrates\ncombinations with lower utility.")
  
g_utilitycombos
g_utilitycombos %>% ggsave(file="g_utilitycombos.pdf", 
                           width=3.7, height=3)




################################################################################
## budget line + utility lines
################################################################################

g_budget_utility <- ggplot(tibble(x=0:10, y=50-x*100)) +
  ylim(0,80) + xlim(0,.8) +
  stat_function(fun=function(x) 25/x , linetype='dotted' ) +
  stat_function(fun=function(x) 20/x , linetype='dotted' ) +
  stat_function(fun=function(x) 15/x , linetype='dotted' ) +
  stat_function(fun=function(x) 10/x , linetype='dotted', alpha=.3 ) +
  stat_function(fun=function(x) 5/x , linetype='dotted', alpha=.3 ) +
  
  stat_function(fun=function(x) 50-x*100, geom='area', fill='gray', alpha=.7) +
  stat_function(fun=function(x) 50-x*100) +
    
  theme(text = element_text(size=8), 
        axis.text = element_blank() ,
        axis.ticks.y= element_blank(),
        axis.ticks.x= element_blank(),
        axis.title.y = element_text(angle=0),
        axis.title.x = element_text(hjust=1), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        
  ) +
  labs(y="Consumption", 
       x="Leisure") +
    
    annotate('text', x=.45, y=77, size=2.2,
             label="Indifference lines") +
  
    annotate(geom = "text", x =.05, y=10,  size=2, hjust=0,
           label="All combinations of\nconsumption and leisure\nthat Erik can afford") +
    annotate('text', x=.55, y=12, size=2.2, 
             label="Maximum leisure") +
    annotate('text', x=0, y=60, size=2.2, hjust=0,
             label="Maximum consumption\nat present salary") +
    annotate('text', x=.27, y=27, angle=-40, size=2.2, 
             label="The budget line") +
    geom_curve(aes(x = .08, xend = .01,
                   y =56.5, yend = 51),
               arrow = arrow(length = unit(0.08, "inch")), size = 0.2,
               color = "gray20", curvature = -0.3) +
    geom_curve(aes(x = .55, xend = .51,
                   y = 10, yend = 1),
               arrow = arrow(length = unit(0.08, "inch")), size = 0.2,
               color = "gray20", curvature = -0.3)
    
g_budget_utility    
g_budget_utility %>% ggsave(file="g_budget_utility.pdf", 
                           width=4, height=3)

################################################################################
### indifference curve tangent
################################################################################
## budget line + utility lines
g_utilitymaxbudget <- ggplot(tibble(x=0:10, y=50-x*100)) +
  ylim(0,80) + xlim(0,.8) +
  stat_function(fun=function(x) 6.3/x  , linetype="longdash") +
  stat_function(fun=function(x) 2.3/x  , linetype='dotted', alpha=.2) +
  stat_function(fun=function(x) 11.3/x  , linetype='dotted', alpha=.2) +
  stat_function(fun=function(x) 50-x*100) +
  geom_point(aes(x=.25, y=25), size=1.9) +
  
  theme(text = element_text(size=8), 
        axis.text = element_blank() ,
        axis.ticks.y= element_blank(),
        axis.ticks.x= element_blank(),
        axis.title.y = element_text(angle=0),
        axis.title.x = element_text(hjust=1), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        
  ) +
  labs(y="Consumption", x="Leisure") +
  annotate(geom = "text", x = .2, y=20, angle=-45, size=2.2,
           label="All the budget\nis used") +
  annotate(geom = "text", x = .3, y=30, angle=-45, size=2.2,
           label="Maximum \npossible utility") 


g_utilitymaxbudget
g_utilitymaxbudget %>% ggsave(file="g_utilitymaxbudget.pdf", 
                              width=3.6, height=3)  
  

################################################################################
### monopol
################################################################################
g_monopol <- 
ggplot(tibble(NULL)) +
  stat_function(fun=function(x) 100 - 2*x) +
  stat_function(fun=function(x) 100- 4*x, linetype="longdash") +
  stat_function(fun=function(x) 2*x, linetype="dashed") +
  
  geom_vline(xintercept=0, alpha=.2) +
  geom_hline(yintercept=0, alpha=.2) +
  
  geom_label(aes(x=c(10,10,10), 
                 y=c(80,60,20), 
                 label=c("Demand","MR","MC")), size=2.3) +
  labs(x="Production (Q)", y="Price (P)") +
  geom_point(aes(y=33.33,x=16.67), size=2) +
  # pris
  annotate("segment", x=0, xend=16.67, y=66.67, yend=66.67, linetype='dotted') +
  # q
  annotate("segment", x=16.67, xend=16.67, y=0, yend=66.67, linetype='dotted') +
  theme(text=element_text(size=7)) +
  scale_x_continuous(breaks=c(0,10,16.67,20), 
                 labels=c(0,10,16.67,20), limits=c(0,27)) +
  scale_y_continuous(breaks=c(0,25,50,66.67,75,100), 
                     labels=c(0,25,50,66.67,75,100), limits=c(-10,110)) +
  annotate("curve", x = 6, xend=13, 
           y = 40, yend = 33.33,
           curvature=.2,
           arrow = arrow(length = unit(2, "mm")) ) +
  annotate('text', x=4, y=44, label="MR = MC", size=2.5) +
  annotate('text', x=23, y=69, label="Profit maximizing P", size=2) +
  annotate('text', x=17, y=91, label="Profit maximizing Q", size=2, angle=90) 

g_monopol
g_monopol %>% ggsave(filename = "g_monopol.pdf", width =3.4, height=3)




################################################################################
### monopsoni
################################################################################
g_monopsoni <- ggplot() + 
  # utbud, inköpsvaran
  stat_function(fun=function(x) x/2) +
  # mc, företaget
  stat_function(fun=function(x) x, linetype="longdash") +
  # efterfrågan, produktionsvaran
  stat_function(fun=function(x) 10-x) +
  # mr, företaget
  stat_function(fun=function(x) 10-2*x, linetype="dashed") +
  
  geom_vline(xintercept=0, alpha=.2) +
  geom_hline(yintercept=0, alpha=.2) +
  
  geom_point(aes(x=c(10/3,10/3), y=c(5/3, 20/3)), size=1) +
  
  geom_label(aes(x=c(7.3, 7.8, 7.8, 5), 
                 y=c(2, 4, 8, 0), 
                 label=c("Demand","Supply","MC","MR")), size=2.3) +
  # q
  annotate("segment", x=10/3, xend=10/3, y=0, yend=20/3, linetype='dotted') +
  # p sälj
  annotate("segment", x=0, xend=10/3, y=20/3, yend=20/3, linetype='dotted') +
  # p inköp
  annotate("segment", x=0, xend=10/3, y=5/3, yend=5/3, linetype='dotted') +
  
  # text priser
  annotate('text', x=0, y=6.3, label="Sales price", size=2, hjust=0) +
  annotate('text', x=0, y=2, label="Purchase price", size=2, hjust=0) +
  
  labs(x="Production (q)", y="Price (p)") +
  
  scale_y_continuous(breaks=seq(0,10,2), limits=c(0,11)) +
  xlim(0,8) +
  theme(text=element_text(size=7))
  

g_monopsoni
g_monopsoni %>% ggsave(filename="g_monopsoni.pdf", width=3.4, height=3)
