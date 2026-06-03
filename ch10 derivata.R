library("tidyverse")
library("patchwork")
library("latex2exp")
library("conflicted")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

# använd komma som decimal
options(OutDec=",")



################################################################################
# global graph setting
th <- theme(axis.title.y = element_text(angle=0), 
            text = element_text(size =8))  


###############################################################
# lim of 1/x
g_oneoverx <- ggplot() +
  stat_function(fun=function(x) 1/x, xlim=c(-20,-1/(10^10))) +
  stat_function(fun=function(x) 1/x, xlim=c(1/(10^10),20)) +
  scale_x_continuous(breaks=-4:4, limits=c(-4,4)) +
  scale_y_continuous(breaks=-5:5, limits=c(-5,5)) +
  geom_hline(yintercept=0, alpha=.3) +
  geom_vline(xintercept=0, alpha=.3) +
  labs(x='x', y=TeX("y = \\frac{1}{x}")) +
  coord_cartesian(expand = F) +
  th


g_oneoverx
g_oneoverx %>% ggsave(file="g_oneoverx.pdf", width=3.5, height=3)


#######################################################
## plot y=x^2 plus straight lines
g_x2_derivata <- 
  ggplot() +
  stat_function(fun=function(x) x^2, xlim=c(-1,5)) + 
  stat_function(fun=function(x) 0*x, xlim=c(-1,5), linetype='dashed') +
  stat_function(fun=function(x) -4+4*x, xlim=c(-1,5), linetype='dashed') +
  geom_vline(xintercept=0, alpha=.2) +
  geom_hline(yintercept=0, alpha=.2) +
  
  geom_point(aes(x=c(0,2), y=c(0,4))) +
  scale_y_continuous(breaks=c(0,4,10,20), 
                     labels=c(0,4,10,20), 
                     limits = c(-5,20)) +
  annotate('text', x=3.5, y=17, size=2.5,
           label=TeX("$y = x^2$")) +
  annotate('text', x=4, y=8, angle=35, size=2.5, 
           label="Slope of the line\nat the point (2,4)") +
  annotate('text', x=3, y=-3, size=2.5,
           label="Slope of the line\nat the point (0,0)") +
  annotate('label', x=0, y=5, size=2.5, 
           label="(x,y) = (0,0)") +
  annotate('label', x=1.6, y=9, size=2.5,
           label="(x,y) = (2,4)") +
  annotate('segment', x=0, xend=0, y=3.9, yend=1, 
           arrow=arrow(length=unit(.1, 'cm'))) +
  annotate('segment', x=1.5, xend=1.9, y=7.9, yend=4.6, 
           arrow=arrow(length=unit(.1, 'cm'))) +
  
  labs(y="y", x="x") +
  coord_cartesian(expand = F) +
  
  th

g_x2_derivata
g_x2_derivata %>% ggsave(file="g_x2_derivata.pdf",height=3 , width=3.5)





########################################################
# y = x^3 och derivata 1 o 2
g <- ggplot(tibble(x=0:5)) + 
  theme(axis.title.y = element_text(angle=0), text=element_text(size=8))

g_x3 <- g +
  stat_function(fun=function(x) x^3) + xlim(0,4) +
  geom_hline(yintercept=0, alpha=.3) +
  labs(y=bquote("y =" ~x^3), title="The function") +
  geom_point(aes(x=2,y=8), size=2) +
  stat_function(fun=function(x) -16+12*x, linetype='dashed') +
  coord_cartesian(expand = F) 

g_3x2 <- g + 
  stat_function(fun=function(x) 3*x^2) + xlim(0,4) +
  geom_hline(yintercept=0, alpha=.3) +
  labs(y=bquote("y =" ~3*x^2), title="The first derivative") +
  geom_point(aes(x=2,y=12), size=2) +
  stat_function(fun=function(x) -12+12*x, linetype='dashed') +
  coord_cartesian(expand = F) 


g_6x <- g +
  stat_function(fun=function(x) 6*x) + xlim(0,4) +
  geom_hline(yintercept=0, alpha=.3) +
  labs(y=bquote("y =" ~6*x), title="The second derivative") +
  geom_point(aes(x=2,y=12), size=2) +
  coord_cartesian(expand = F) 

(g_x3 / g_3x2 / g_6x)
(g_x3 / g_3x2 / g_6x) %>% 
  ggsave(file="g_x3.pdf", width=3, height=6)


######################################################
### derive a^x

h <- .0000001

g_derive_ax <- ggplot() +
  stat_function(fun=function(x) (x^(h) -1)/h  , 
                xlim=c(1,5)) +
  geom_hline(yintercept=0, alpha=.3) +
  geom_vline(xintercept=0, alpha=.3) +
  geom_point(aes(exp(1),1)) +
  labs(subtitle=TeX("$y = \\lim_{h\\rightarrow 0}\\left( \\frac{b^h -1}{h} \\right)$  for different values of b"), 
       x="b", 
       y="y") +
  scale_x_continuous(breaks=c(1,2,exp(1),4,5), 
                     labels=c(1,2,round(exp(1),3),4,5)) +
  scale_y_continuous(breaks=seq(0,1.6,.4) %>% c(1)) +
  annotate('segment', y=1, yend=1, x=0, xend=exp(1), linetype='dotted') +
  annotate('segment', y=0, yend=1, x=exp(1), xend=exp(1), linetype='dotted') +
  annotate("text", x=.75, y=1.3, hjust=0, size=2,
           label=TeX("At this point is $b\\approx 2.718$")) +
  annotate("text", x=.75, y=1.2, hjust=0, size=2,
           label="and the limit value = 1") +
  annotate("curve", x =2.3, xend=2.6, 
           y = 1.2, yend = 1.05, 
           curvature = -.2, arrow = arrow(length = unit(2, "mm")) ) +
  coord_cartesian(expand = F) +
  th

g_derive_ax
g_derive_ax %>% ggsave(file="g_derive_ax.pdf", width=3, height = 3)



################################################################################
### derive log x
################################################################################

g_lim_logx <- ggplot() +
  stat_function(fun=function(x) (1+x)^(1/x), 
                xlim=c(-.8,2)) +
  geom_point(aes(0,2.718), size=2 ) +
  geom_vline(xintercept=0, alpha=.2) +
  geom_hline(yintercept=0, alpha=.2) +
  labs(y="y", x="z", title=TeX("$y = (1+z)^{1/z}$")) +
  geom_segment(aes(x=c(-1,0), xend=c(0,0), 
                   y=c(exp(1), exp(1) ), yend=c(exp(1),0)), linetype='dotted') +
  scale_y_continuous(labels=c(0,2,round(exp(1),3),4,6), 
                     breaks=c(0,2,exp(1),4,6)) +
  annotate("text", x=.6, y=5.5, hjust=0, size=2.5,
           label="I denna punkt är z = 0 och") +
  annotate("text", x=.6, y=5, hjust=0, size=2.5,
           label=TeX("$y=(1+z)^{1/z} \\approx 2.718$")) +
  annotate("curve", 
           x = .6, xend = .2, 
           y = 4.5, yend = 3.2, 
           curvature = -.2, arrow = arrow(length = unit(2, "mm")) ) +
  coord_cartesian(expand = F) +
  theme(axis.title.y = element_text(angle=0, hjust=1), 
        text=element_text(size=8))

g_lim_logx
g_lim_logx %>% ggsave(file="g_lim_logx.pdf", width=4, height=3)  






