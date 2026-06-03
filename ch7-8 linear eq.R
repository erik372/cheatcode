library("patchwork")
library("tidyverse")
library("latex2exp")
library("conflicted")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

# använd komma som decimal
options(OutDec=",")



##################################################################  
### two linear equations in same graph
##################################################################  
g_2lines  <- 
  ggplot(tibble(x=-10:10), aes(x)) + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =8) ) + 
  stat_function(fun=function(x) 3 + 2*x, geom="line") + 
  stat_function(fun=function(x) x +1, geom="line", linetype="dashed") +
  geom_point(aes(-2,-1),color="black", size=2) +
  scale_y_continuous(breaks=-5:5 , limits = c(-5,5)) +
  scale_x_continuous(breaks=-5:5 , limits=c(-5,5)) +
  annotate('text', x=-1.2,y=2, angle=56,  size=2.5,
           label="y = 3 + 2x") +
  annotate('text', x=1.8, y=2, angle=33, size=2.5,
           label="y = x + 1") +
  annotate('text', x=-3.4, y=-.8, size=2.5,
           label="(-2,-1)") +
  labs(x="x",y="y") 

g_2lines
g_2lines %>% ggsave(file="g_2lines.pdf", width=4, height=3)




################################################################################
### potential solutions for linear systems of equations
################################################################################

g_onesolution <- ggplot() + 
  stat_function(fun=function(x) x) +
  stat_function(fun=function(x) 1-x, linetype='dashed') +
  scale_y_continuous(breaks=NULL) +
  scale_x_continuous(breaks=NULL) +
  labs(y=NULL, title="One solution",
       subtitle = "The lines intersect at a point") +
  theme(text=element_text(size=7))

g_nosolution <- ggplot() + 
  stat_function(fun=function(x) 1-x, linetype='dashed') +
  stat_function(fun=function(x) .7-x) +
  scale_y_continuous(breaks=NULL) +
  scale_x_continuous(breaks=NULL) +
  labs(y=NULL, title="No solution",
       subtitle="The lines have the same slope \nand never meet") +
  theme(text=element_text(size=7))

g_infsolutions <- ggplot() + 
  stat_function(fun=function(x) x) +
  stat_function(fun=function(x) .01+x, linetype='dashed') +
  scale_y_continuous(breaks=NULL) +
  scale_x_continuous(breaks=NULL) +
  labs(y=NULL, title="Infinite number of solutions",
       subtitle="The lines have the same slope \nand same y-intercept and \nmeet at all points.") +
  theme(text=element_text(size=7))


(g_onesolution + g_nosolution + g_infsolutions)
(g_onesolution + g_nosolution + g_infsolutions) %>% 
  ggsave(file="g_nonlinearsolutions.pdf", width=4.5, height=2.5)





### CH 8
################################################################################
### SUPPLY AND DEMAND
################################################################################

g_supplydemand <- ggplot(tibble(p=0:25,
                                s=3*p,
                                d=20-2*p
                                ), 
                         aes(y=p)) + 
  geom_line(aes(x=s)) + 
  geom_line(aes(x=d), linetype="longdash") + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  xlim(0,20) + ylim(0,10) +
  labs(x="Quantity (q)", y="Price (p)") + 
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =12) ) +
  annotate('text', x=15, y=7.5, size=2,hjust=0,
           label="Supply") + 
  annotate('text', x=15, y=6.5, size=2,hjust=0,
           label=TeX("$p = \\frac{1}{4}*q$")) +
  annotate('text', x=3,y=10, size=2, hjust=0, 
           label="Demand") +
  annotate('text', x=3,y=9.5, size=2, hjust=0, 
           label=TeX("$p = 10 - 2*q$"), ) +
  annotate('text', x=5, y=4.6, label="Price at\nequilibrium", size=2) +
  annotate('text', x=10.7, y=.5, label="Quantity at\nequilibrium", 
           size=2, angle=90, hjust=0) +
  
    # Add a vertical line segment
  geom_segment(aes(x = 12, y = 4, xend = 12, yend = 0), linetype="dotted") +
  # Add horizontal line segment
  geom_segment(aes(x = 0, y = 4, xend = 12, yend = 4), linetype="dotted") +
  theme(text=element_text(size=8))

g_supplydemand
g_supplydemand %>% ggsave(file="g_supplydemand.pdf", height=3, width=4)




################################################################################
### kakförsäljning
g_cookies <- ggplot() + 
  stat_function(fun=function(x) 20*x) +
  stat_function(fun=function(x) 50*x - 1000, linetype="longdash") +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  
labs(x="Number of sold cookie jars (k)", 
     y="Profit (v)") +
  annotate('text', x=1, y=450, size=2, hjust=0,
           label="Profit of type 1") +
  annotate('text', x=1, y=300, size=2, hjust=0,
           label=TeX("$v = 20*k$")) +
  annotate('text', x=9, y=-750, size=2, hjust=0,
           label="Profit of type 2") +
  annotate('text', x=9, y=-900, size=2, hjust=0,
           label=TeX("$v = -1,000 + 50*k$")) +
  annotate('text', x=36, y=-750, angle=90, hjust=0, size=2,
           label="At 33.3 sold jars\nprofit is the same.") +
  annotate('text', x=10, y=730, size=2, 
           label="Profit at 33.3 sold jars") +
  # Add a vertical line segment
  geom_segment(aes(x = 33.333, xend = 33.333, y=667, yend = -1000), linetype="dotted") +
  # Add horizontal line segment
  geom_segment(aes(x = 0, xend = 33.333, y=667, yend = 667), 
               linetype="dotted") +
  scale_x_continuous(breaks=c(0,10,20,30,33.3,40), 
                     labels=c(0,10,20,30,33.3,40), 
                     limits=c(0,40)) +
  scale_y_continuous(breaks=c(-1000,-500,0,500,667,1000),
                     labels=scales::comma) +
                     #labels=function(x) format(x, big.mark = " ", scientific = FALSE)) +
  theme(axis.title.y = element_text(angle=0) , 
      text = element_text(size =8) ) 


g_cookies
g_cookies %>% ggsave(file="g_cookies.pdf", height=3, width=4)



################################################################################
### dejting
################################################################################

g_dejting <- ggplot() + 
  stat_function(fun=function(x) 30 - 2*x) +
  stat_function(fun=function(x) 80 - 22*x, linetype="longdash") +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  
  labs(x="Number of dates (d)", 
       y="Happiness (l)") +
  annotate('text', x=.7, y=77, size=2, hjust=0,
           label="Dating a friend of a friend") +
  annotate('text', x=.7, y=72, size=2, hjust=0,
           label=TeX("$happiness = 100 - 22*d$")) +
  annotate('text', x=.4, y=41, size=2, hjust=0,
             label="Dating app") +
  annotate('text', x=.4, y=36, size=2, hjust=0,
           label=TeX("$happiness = 100 - 50 - 2*d$")) +
    annotate('text', x=.2, y=20, size=2, hjust=0,
             label="Happiness in equilibirum") +
    annotate('text', x=2.4, y=5, size=2, hjust=1, 
             label="At 2.5 dates the two strategies\nhave equal expected happiness") +
    # Add a vertical line segment
  geom_segment(aes(x = 2.5, xend = 2.5, y=0, yend = 25), linetype="dotted") +
  # Add horizontal line segment
  geom_segment(aes(x = 0, xend = 2.5, y=25, yend = 25), 
               linetype="dotted") +
  scale_x_continuous(limits=c(0,3), 
                     breaks=c(0,1,2,2.5,3),
                     labels=c(0,1,2,2.5,3)) +
  scale_y_continuous(limits=c(0,80), 
                     breaks=c(0,20,25,40,60,80),
                     labels=c(0,20,25,40,60,80)) +
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =8) ) 

g_dejting
g_dejting %>% ggsave(file="g_dejting.pdf", height=3, width=4)





################################################################################
### nairu
################################################################################

thelim <- 4
g_nairu1 <- ggplot() + 
  # supply
  stat_function(fun=function(x) .1/(1-x)) +
  # demand
  stat_function(fun=function(x) ((1-x)^2)/1.2  , linetype="longdash") +
  xlim(0,.9)  + ylim(0, 1) +
  
  # skyltar
  annotate('label', x=.8, y=.6, size=2,
           label=TeX("$\\frac{W}{P} = \\frac{a}{U^b}$")) +
  annotate('label', x=.2, y=.6, size=2,
           label=TeX("$\\frac{P}{W} = \\frac{U^c}{d}$")) +
  # markera jämvikten
  geom_segment(aes(x=c(.507, 0), xend=c(.507, .507), y=c(0, .203), yend=c(.203, .203)) , 
               linetype="dotted") +
  
  theme(axis.ticks = element_blank(), 
        axis.text = element_blank(), 
        axis.title.y=element_text(angle=0), 
        text=element_text(size=7), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        ) +
  labs(y=TeX("$\\frac{W}{P}$"), 
       x="1 - u\nEmployment = \nLabor force - Unemployment")

g_nairu1


#### USE THIS FOR THE LINEAR VERSION
ggplot() + 
  stat_function(fun=function(x) log(.1) - log(x)) +
  stat_function(fun=function(x) 2*log(x) - log(1.2) , linetype="longdash") +
  scale_x_log10(limits=c(.1,1))
####

g_nairu2 <- ggplot() + 
  stat_function(fun=function(x) log(.1) - log(x), linetype="longdash") +
  stat_function(fun=function(x) 2*log(x) - log(1.2) ) +
  scale_x_log10(limits=c(.1,1)) +
  geom_segment(aes(x=c(.495, 0), xend=c(.495, .495), 
                   y=c(-4.8, -1.6), yend=c(-1.6, -1.6)) , 
               linetype="dotted") + 
  theme(axis.ticks = element_blank(), 
        axis.text = element_blank(), 
        axis.title.y=element_text(angle=0), 
        text=element_text(size=7), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        ) +
  annotate('label', x=.2, y=-.7, size=2,
           label=TeX("$w - p = a - bu$")) +
  annotate('label', x=.2, y=-3.3, size=2,
           label=TeX("$p - w = c - du$")) +
  labs(y=TeX("$w - p$"), 
       x="1 - u\nEmployment = \nLabor force - Unemployment")

g_nairu2

g_nairu <- (g_nairu1 + g_nairu2) 
g_nairu
g_nairu %>% ggsave(file="g_nairu.pdf", width=4.7, height=3)


