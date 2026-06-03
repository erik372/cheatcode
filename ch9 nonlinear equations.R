rm(list=ls())

library("tidyverse")
library("igraph") 
library("ggraph")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# ej vetenskapligt format
options(scipen=999)

# använd komma som decimal
options(OutDec=",")


#######################################################################
## first illustration
g_nonlin_first <- ggplot() + 
  geom_vline(xintercept=0, alpha=.3) +
  geom_hline(yintercept=0, alpha=.3) +
  stat_function(fun=function(x) 2*x^3 -x^2) +
  stat_function(fun=function(x) 5*x, linetype='dotted') +
  stat_function(fun=function(x) 10 +x, linetype='dashed')+
  geom_point(aes(x=c(-1.365,0,1.85, 2, 2.5), y=c(-6.9,0,9.25, 12, 12.5))) +
  annotate('label', x=1, y=0, label="f(x)" , size=2 ) +
  annotate('label', x=.8, y=4, label="g(x)" , size=2) +
  annotate('label', x=.3, y=10.3, label="h(x)" , size=2) +
  scale_x_continuous(limits=c(-3,3)) +
  ylim(-25,25) +
  labs(x="x", y="y") +
  theme(axis.title.y = element_text(angle = 0), 
        text=element_text(size=7))

g_nonlin_first
g_nonlin_first %>% ggsave(file="g_nonlin_first.pdf", width=3, height=3)





#######################################################################

g_nonlin_2 <- ggplot() + 
  stat_function(fun=function(x) 20 - 2*x^2, linetype='dashed') +
  stat_function(fun=function(x) x^2 -10) +
  geom_point(aes(x=c(sqrt(10), -sqrt(10)), 
                 y=c(0,0)), size=2) +
  scale_x_continuous(limits=c(-4,4), breaks=-4:4) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  annotate('label', x=-2, y=-7, size=2,
           label=TeX("$y = 20 - 2x^2$")) +
  annotate('label', x=-2, y=12, size=2,
           label=TeX("$y = -10 + x^2$")) +
  labs(x="x", y="y") +
  theme(axis.title.y = element_text(angle = 0), 
        text=element_text(size=7))

g_nonlin_2
g_nonlin_2 %>% ggsave(file="g_nonlin_2.pdf", width=3, height=3)




#######################################################################
### ex 1
g_nonlinear_1 <- 
  ggplot() + 
  stat_function(fun=function(x) x, linetype="longdash") + 
  stat_function(fun=function(x) (x-2)^2 ) +
  scale_x_continuous(limits=c(0,5)) +
  scale_y_continuous(limits=c(0,5), 
                     breaks=0:5, 
                     labels=0:5) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  
  theme(axis.title.y = element_text(angle=0), 
        text = element_text(size =8)) +
  annotate('text', x=2.5, y=3, size=2.5,
           label=TeX("$y = x$")) +
  annotate('text', x=3.9, y=4.8, hjust=1, size=2.5,
           label=TeX("$y = (x - 2)^2$")) +
  annotate('segment', y=0, x=1, yend=1, xend=1, linetype='dotted') +
  annotate('segment', y=1, x=0, yend=1, xend=1, linetype='dotted') +
  annotate('segment', y=0, x=4, yend=4, xend=4, linetype='dotted') +
  annotate('segment', y=4, x=0, yend=4, xend=4, linetype='dotted') +
  annotate('point', y=1, x=1) +
  annotate('point', y=4, x=4) 

g_nonlinear_1
g_nonlinear_1 %>% ggsave(file="g_nonlinear_1.pdf", width=3.5, height=3)  


#######################################################################
### ex 2
g_twoequilibrias <- ggplot() + 
  stat_function(fun=function(x) (2-1/x^2)^(1/2)) +
  stat_function(fun=function(x) x^2, linetype="dashed") +
  
  geom_point(aes(x=c(1,.786), y=c(1,.618))) +
  scale_x_continuous(limits=c(0.5,1.25)) +
  scale_y_continuous(limits=c(0.25,1.2)) +
  labs(x="x", y="y") +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=8)) +
  annotate('text', x=.75, y=.35, hjust=0, size=2.5,
           label=TeX("$y = \\left(2 - \\frac{1}{x^2} \\right) ^{ \\frac{1}{2}}$")) +
  annotate('text', x=1.05, y=1.17, hjust=1, size=2.5,
           label=TeX("$y = x^2$"))

g_twoequilibrias
g_twoequilibrias %>% ggsave(file="g_twoequilibrias.pdf", 
                            width=3, height=3)



#######################################################################
### peer pressure and smoking
#######################################################################
g_smoking <- ggplot() +
  stat_function(fun=function(x) x^(1/2), xlim=c(0,1), linetype='dashed') +
  stat_function(fun=function(x) x^2, xlim=c(0,1)) +
  geom_point(aes(x=c(0,1), y=c(0,1)), size=2) +
  geom_text_repel(aes(x=c(0,1),y=c(0,1), label=c("(0,0)","(1,1)")), 
                  hjust=1, vjust=1,
                  nudge_x = .11,
                  nudge_y = .11,
                  size=2) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  
  xlim(0,1.3) + ylim(0,1.3) +
  theme(axis.title.y=element_text(angle=0, hjust=0), 
        text=element_text(size=7)) +
  labs(x="Maria's smoking", 
       y="Erik's \nsmoking") +
  annotate('text', x=0.25, y=.8, hjust=0, size=2.5,
           label=TeX("$x = y^2$")) +
  annotate('text', y=0.25, x=.8, hjust=1, size=2.5,
           label=TeX("$y = x^2$")) +
  annotate('label', x=.66, y=0, size=2.5,
           label="Nobody's smoking") +
  annotate('label', x=.5, y=1, size=2.5,
           label="Both smoking") +
  annotate('segment', x=.4, xend=.25, y=0, yend=0, arrow=arrow(length = unit(.2, 'cm'))) +
  annotate('segment', x=.7, xend=.9, y=1, yend=1, arrow=arrow(length = unit(.2, 'cm'))) 

g_smoking
g_smoking %>% ggsave(file="g_smoking.pdf", width=3.5, height=3)



################################################################################
## relationships
a <- .1
g_relationships <- ggplot() + 
  stat_function(fun=function(x) (x-a)^(1/2) , linetype='dashed') +
  stat_function(fun=function(x) x^2 +a ) +
  scale_x_continuous(breaks=seq(0,1,by=.2), 
                     limits=c(0,1)) +
  scale_y_continuous(breaks=seq(0,1,by=.2), 
                     limits=c(0,1)) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  
  labs(y="K", x="P") +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=7)) +
  annotate('label', x=.5, y=.3, size=2,
           label=TeX("$K = P^2 + 0,1$")) +
  annotate('label', x=.5, y=.65, size=2, 
           label=TeX("$K = (P - 0,1)^{1/2}$")) +
  geom_point(aes(x=c(.113, .885), y=c(.11, .885)), size=2) +
  annotate('text', x=c(.35,.3), y=c(.08,.93), size=2, hjust=0,
           label=c("None of them are\n highly committed", 
                   "Both are\nhighly committed")) +
  geom_curve(aes(x=.27, xend=.16, y=.05, yend=.09), 
             arrow=arrow(length=unit(.1, 'cm')), 
             curvature=-.4) +
  geom_curve(aes(x=.73, xend=.83, y=.93, yend=.9), 
             arrow=arrow(length=unit(.1, 'cm')), 
             curvature=-.4)

g_relationships  
g_relationships %>% ggsave(file="g_relationships.pdf", width=2.1, height=2.3)

x <- 0.5

g_p_polynom <- ggplot() +
  stat_function(fun=function(x) x^4 + .2*(x^2) - x + .11) +
  geom_hline(yintercept=0, alpha=.35) +
  theme(axis.title.y=element_blank(), 
        text=element_text(size=7)) +
  labs(x="P") +
  annotate('text', x=.9, y=.3, size=2, hjust=1, 
           label=TeX("$P^4 + 0,2*P^2 - P + 0,11$")) +
  scale_x_continuous(breaks=seq(0,1,by=.2), 
                     limits=c(0,1)) + 
  annotate('segment', y=0, x=.1127, yend=-.3, xend=.1127, linetype='dotted') +
  annotate('segment', y=0, x=.8873, yend=-.3, xend=.8873, linetype='dotted') +
  geom_point(aes(x=c(.1127,.8873), y=c(0,0)), size=2)


g_p_polynom
g_p_polynom %>% ggsave(file="g_p_polynom.pdf", width=2.1, height=2.3)



################################################################################
### (un)employment multiple equilibria
################################################################################

## first illustrate the value of a
g_the_a <- ggplot() + 
  # supply
  stat_function(fun=function(x) (x-.25)^-.5, linetype='dotted') +
  # demand
  stat_function(fun=function(x) (x-.25)^.5 , linetype='dashed')+
  xlim(0,2) + ylim(0,2) +
  annotate('label', x=.75, y=1.35, size=2,
           label="0 < a < 1") +
  annotate('label', x=.75, y=.75, size=2,
           label="a > 1") +
  theme(axis.ticks = element_blank(), 
        axis.text = element_blank(), 
        axis.title.y=element_text(angle=0), 
        text=element_text(size=7)) +
  labs(y=TeX("$\\frac{W}{P}$"), 
       x="1 - u\nEmployment = \nLabor force - Unemployment") +
  annotate('text', x=1.7, y=1.75, size=2, hjust=1,
           label="Both lines describes the function") +
  annotate('text', x=1.55, y=1.55, size=2, hjust=1,
           label=TeX("$\\frac{W}{P} = (U - a)^{a-1}$")) 

g_the_a
g_the_a %>% ggsave(file="g_the_a.pdf", height=3, width=3)  



################################################################################
### 2 equilibria
################################################################################
g_2equilibria <- 
  ggplot() + ylim(.1,.8) +
  # demand
  stat_function(fun=function(x)  .7*(x^.5), linetype='dashed') +
  # supply
  stat_function(fun=function(x) .2/(1-x)  ) +
  
  geom_point(aes( x=c(.095,.646), 
                  y=c(.22,.566)), size=2) +
  xlim(.01,.8)  +
  theme(axis.ticks = element_blank(), 
        axis.text = element_blank(), 
        axis.title.y=element_text(angle=0), 
        text=element_text(size=7), 
        axis.line=element_line(arrow=arrow(length=unit(.2, "cm")), linewidth = .1)
        ) +
  labs(y=TeX("$\\frac{W}{P}$"), 
       x="1 - u\nEmployment = \nLabor force - Unemployment") +
  annotate('label', x=.7, y=.73, size=2,
           label=TeX("$\\frac{W}{P} = \\frac{a}{U}$")) +
  annotate('label', x=.4, y=.45, size=2, 
           label=TeX("$\\frac{P}{W}=\\frac{c}{d(1-U)^{1/2}}$")) +
  annotate('text', x=.65, y=.1, size=2, hjust=1, 
           label="Equilibrium 1: Fewer jobs and lower wages") +
  geom_curve(aes(x=.2, y=.15, xend=.11, yend=.2), curvature = -.3 , 
             arrow=arrow(length=unit(.1, 'cm')) ) +
  annotate('text', x=.58, y=.75, size=2, hjust=1,
           label="Equilibrium 2: More jobs and higher wages") +
  geom_curve(aes(x=.53, y=.7, xend=.635, yend=.6), curvature = -.3 , 
             arrow=arrow(length=unit(.1, 'cm')) ) 

g_2equilibria
g_2equilibria %>% ggsave(file="g_2equilibria.pdf", width=3, height=3)

