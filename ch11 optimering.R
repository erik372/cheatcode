library("tidyverse")
library("patchwork")
library("conflicted")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

################################################################################
# global graph setting
th <- theme(axis.title.y = element_text(angle=0), 
      text = element_text(size =7))  

p <- ggplot(tibble(x=0:10), aes(x)) + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  th

################################################################################
## a function with min and max
g_minmax <- 
  p + stat_function(fun=function(x) 10 -(x-5)^2, 
                  xlim=c(2.2,7),
                  linetype="dashed") +
  scale_x_continuous(limits=c(0,10), breaks=NULL) +
  scale_y_continuous(limits=c(0,11), breaks=NULL) +
  geom_point(aes(5,10),color="black", size=2) +
  geom_point(aes(2.2,2.2),color="black", size=2) +
  annotate("text", x=2.2, y=2.2, label="Minimum value", vjust=1.6, size=2.5) +
  annotate("text", x=5, y=10, label="Maximum value", vjust=-1, size=2.5) 

g_minmax
g_minmax %>% ggsave(file="g_minmax.pdf", width=3, height=2.5)  





################################################################################
### min -x^2
g_minx2 <- ggplot(tibble(x=-5:5)) + 
  th +
  stat_function(fun=function(x) -x^2) + xlim(-2,2) +
  labs(y=bquote("y="~ -x^2) ) +
  geom_point(aes(0,0), size=2) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) 
  

g_minx2
g_minx2 %>% ggsave(file="g_minx2.pdf", width=3, height=2.5)




################################################################################
## h(k) = k^2 - k + 3
g_min_ex2 <- 
  ggplot() +
  stat_function(fun=function(x) x^2 -x +3) +
  xlim(-1,2) + ylim(0,5) +
  geom_point(aes(.5, 2.75), size=2)  +
  labs(y="y", x="k",
       subtitle =bquote("y = h(k) ="~ x^2 - x + 3) ) +
  th +
  geom_vline(xintercept=0, alpha=.3) +
  geom_hline(yintercept=0, alpha=.3)

g_min_ex2
g_min_ex2 %>% ggsave(filename="g_min_ex2.pdf", width=3, height=2.5)

################################################################################
## lokalt och globalt min och max
g_localminmax <- 
  ggplot() + 
  stat_function(fun=function(x) x^3 - x^2 - x +2, xlim=c(-2,2.5)) +
  geom_point(aes(x=c(-.33, 1), y=c(2.19,1))) +
  scale_y_continuous(breaks =seq(-8,8,2)) +
  labs(x="x",y="y", 
       title=bquote("y = f(x) ="~ x^3 -x^2 -x+2)) +
  th +
  annotate("text", x=-.33, y=3, label="Local max.", size=2.5) +
  annotate("text", x=1, y=0, label="Local min.", size=2.5) +
  annotate("text", x=1.5, y=6, label="Global max.", size=2.5) +
  annotate("text", x=-.7, y=-4, label="Global min.", size=2.5) +
  annotate("curve", x = -.7, y = -5.2, 
           xend = -1.1, yend = -7.6, 
           curvature = -.2, arrow = arrow(length = unit(2, "mm")) ) +
  annotate("curve", x = 1.5, y = 7, 
           xend = 1.8 , yend = 8.5, 
           curvature = -.2, arrow = arrow(length = unit(2, "mm")) ) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) 


g_localminmax
g_localminmax %>% ggsave(filename="g_localminmax.pdf", height=3, width=3)


################################################################################
### min & terass
g_min_terrace <- 
  ggplot(tibble(x=-10:10)) + 
  th +
  stat_function(fun=function(x) x^4 -2*x^3 +2*x -1 ) + 
  xlim(-1.2,1.7) + ylim(-2.5,2.4) +
  geom_point(aes(x = -.5, y=-1.69), size=2) +
  geom_point(aes(x = 1, y=0 ), size=2) +
  labs(title= bquote("y =" ~ x^4 -2*x^3 +2*x -1), 
       x="x", y="y") +
  annotate(geom='text', x=-.5, y=-2, label="(0,5 , -1,7)", size=2) +
  annotate(geom='text', x=1, y=.33, label="(1 , 0)", size=2)  +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) 

g_min_terrace
g_min_terrace %>% ggsave(file="g_min_terrace.pdf", width=3.5, height=2.8)  

