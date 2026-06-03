rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("ggformula")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##################################################################
## Integral 1, olika värden för konstant C
g_integral_constant_C <- ggplot() + 
  stat_function(fun=function(x) x^4  /4 + 4*x + -1, linetype=3) +
  stat_function(fun=function(x) x^4  /4 + 4*x + 0, linetype=2) +
  stat_function(fun=function(x) x^4  /4 + 4*x + 1, linetype=5) +
  stat_function(fun=function(x) x^4  /4 + 4*x + 2) +
  xlim(-2.5,0) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  annotate("label", x=-2 , y=c(-2,-3,-4,-5) , size=1.7, 
           label=c("C = 2", 
                   "C = 1",
                   "C = 0",
                   "C = -1")) +
  annotate("label", x=-1.8, y=-1, hjust=0, size=2, 
           label=TeX("y = $G(x) =  \\frac{x^4}{4} + 4x + C")) +
  labs(x="x", y="y") +
  theme(axis.title.y=element_text(angle=0), 
        text = element_text(size=8)) 

g_integral_constant_C
g_integral_constant_C %>%  
  ggsave(filename="g_integral_constant_C.pdf", width=3, height=2.5)





##################################################################
## y=4
g_y4 <- 
ggplot() +
  geom_area(aes(x=0:4, y=4:4), fill='gray') + xlim(0,5) + ylim(0,5) +
  geom_line(aes(x=0:4, y=4:4), color='black') +
  annotate('text', x=4, y=4.3, hjust=1, size=2.5, 
           label=TeX("$y = f(x) = 4, \\forall 0\\leq x \\leq 4$")) +
  annotate('text', x=2, y=2, size=2.5,
           label=TeX("Area: $4 \\times 4 = 16\\; a.u.$")) +
  labs(x="x", y="y") +
  theme(axis.title.y=element_text(angle=0), 
        text = element_text(size=8))
  
g_y4
g_y4 %>% ggsave(file="g_y4.pdf", height=3, width=3)  




##################################################################
g_yequalx <- ggplot() + 
  geom_area(aes(x=0:5, y=0:5), fill='gray', color='black') +
  theme(axis.title.y=element_text(angle=0), 
        text = element_text(size=8)) +
  annotate('text', x=2.5, y=3, size=2.5, angle=45, 
           label=TeX("$y = f(x) = x$")) +
  annotate('text', x=3, y=1.3, size=2.5, 
           label=TeX("Area = \\frac{5 \\times{} 5}{2}")) +
  labs(x="x", y="y") + 
  coord_fixed()

g_yequalx
g_yequalx %>% ggsave(file="g_yequalx.pdf", width=3, height=3)



############################################################
### plot area under exp plot  

g_area_x2 <- ggplot(tibble(x=-4:7)) + 
  stat_function(fun=function(x) x^2, xlim=c(-4,7)) +
  geom_area(stat='function', fun=function(x) x^2, 
            xlim=c(-3,6), fill='gray', color='black') +
  theme(axis.title.y = element_text(angle=0), 
        text = element_text(size=8)) +
  annotate('text', x=6, y=40, hjust=1, size=2.5,
           label=TeX("$y = g(x) = x^2$")) +
  annotate('text', x=4.5, y=7, size=2.5, 
           label=TeX("Area, $y = x^2$,")) +
  annotate('text', x=4.5, y=4, size=2.5,
           label=TeX("$-3 \\leq x \\leq 6$")) +
  scale_x_continuous(breaks=-4:7) +
  geom_vline(xintercept=0, alpha=.3) +
  geom_hline(yintercept=0, alpha=.3)

g_area_x2
g_area_x2 %>% ggsave(file="g_area_x2.pdf" , height=3, width=4.2)

##################################################################
## negative 1
g_negative1 <- ggplot() +
  geom_area(aes(x=0:5, y=-2:3), fill='gray', color='black') +
  geom_hline(yintercept=0, linetype='dashed') +
  annotate('text', x=.5, y=-.5, size=2, 
           label=TeX("$A_1 = -\\frac{2^2}{2}$")) +
  annotate('text', x=4, y=1, size=2, 
           label=TeX("$A_2 = \\frac{3^2}{2}$")) +
  annotate('text', x=0, y=2, size=2.5 , hjust=0,
           label=TeX("Net: \\frac{3^2}{2} - \\frac{2^2}{2} = 2,5 $  a.u.")) +
  theme(axis.title.y=element_text(angle=0), 
        text = element_text(size=8)) +
  labs(x="x", y="y")
  
g_negative1
g_negative1 %>% ggsave(file="g_negative1.pdf", width=4, height=3)



##################################################################
## minus_x2

g_area_minusx2 <- ggplot(data=tibble(x=0:8, y=-x^2)) + 
  stat_function(fun=function(x) -x^2, xlim=c(0,8)) +
  geom_area(stat='function', fun=function(x) -x^2, xlim=c(3,6)) +
  theme(axis.title.y = element_text(angle=0), 
        text = element_text(size=8))
g_area_minusx2
g_area_minusx2 %>% ggsave(file="g_area_minusx2.pdf" , height=2.5, width=2.5)

##################################################################
## area 2 functions
g_area2func <- ggplot() + 
  stat_function(fun=function(x) -x + x^3 -x^2 +10, geom='ribbon', fill='gray', color='black', 
                aes(ymax=after_stat(-x + x^3 -x^2 +10),
                  ymin=after_stat(2 + 2*x -.5*x^2))) +
  scale_x_continuous(limits=c(0,3)) +
  theme(axis.title.y=element_text(angle=0), 
        text = element_text(size=8)) +
  labs(x="x",y="y") +
  annotate('text', x=1.5, y=7, size=2, 
           label=TeX("Area = $\\int^{3}_{0}  g(x) - h(x) dx$")) +
  annotate('text', x=2.5, y=20, hjust=1, size=2,
           label=TeX("$g(x) = - x + x^3 - x^2 + 10$")) +
  annotate('text', x=2, y=2.5, size=2, 
           label=TeX("$h(x) = 2 + 2x - 0,5x^2$"))

g_area2func
g_area2func %>% ggsave(file="g_area2func.pdf", width=4, height=3)


###############################################################################
## lorenz ex 1
lorenz_data <- tibble(pers=0:4,
                      x= pers / 4,
                      inc1=c(0,1,1,1,1), 
                      inc2=c(0,1,1,1,2),
                      pers_cs = cumsum(pers), 
                      inc1_cs = cumsum(inc1), 
                      inc2_cs = cumsum(inc2),
                      y1 = cumsum(inc1) / sum(inc1),
                      y2 = cumsum(inc2) / sum(inc2) )

ggplot(lorenz_data, aes(x=pers, y=inc1_cs)) +
  geom_point() + geom_line() +
  geom_col(aes(y=inc2_cs)) + geom_point(aes(y=inc2_cs)) + geom_line(aes(y=inc2_cs))

g_lorenz1 <- lorenz_data %>% 
ggplot() + 
  stat_function(fun=function(x) x) +
  geom_point(aes(x=x, y=y1)) +
  geom_line(aes(x=x, y=y2)) + geom_point(aes(x=x, y=y2)) +
  #geom_col(aes(x=x, y=y2), alpha=.5, width=.1) + 
  scale_y_continuous(breaks=seq(0,1,.2), limits=c(0,1), labels=scales::label_percent(suffix=" %")) +
  scale_x_continuous(breaks=seq(0,1,.25), limits=c(0,1.05), labels=scales::label_percent(suffix=" %")) +
  labs(x="Share of population", 
       y="Share of total income") +
  annotate('text', x=.25, y=.4, angle=45, size=2, 
           label="If all has\nthe same income") +
  annotate('text', x=.4, y=.2, angle=35, size=2, 
           label="If person 4 have\ntwice the income") +
  
  
  geom_segment(aes(x=0, xend=.75, y=.75, yend=.75), linetype='dashed') +
  annotate('text', x=0, y=.8, hjust=0, size=2,
           label="75% of total income goes to...") +
  
  geom_segment(aes(x=0, xend=.75, y=.6, yend=.6), linetype='dashed') +
  annotate('text', x=0, y=.65, hjust=0, size=2,
           label="60% of total income goes to...") +
  
  geom_segment(aes(x=.75, xend=.75, y=0, yend=.75), linetype='dashed') +
  annotate('text', x=.7, y=.2, angle=90, size=2,
           label="75% of the population have...") +
  coord_fixed() +
  theme(text=element_text(size=8))

g_lorenz1
g_lorenz1 %>% ggsave(file="g_lorenz1.pdf", width=4.5, height=3)
knitr::plot_crop("g_lorenz1.pdf")



###############################################################################
## gini
g_gini1 <- ggplot() +
  stat_function(fun=function(x) x, geom='area', fill='gray', color='black') +
  stat_function(fun=function(x) x^3, geom='area', fill='darkgray', color='black') +
  annotate('text', x=.8, y=.2, label="B", size=3) +
  annotate('text', x=.45, y=.3, label="A", size=3) +
  scale_y_continuous(breaks=seq(0,1,.25), limits=c(0,1), labels=scales::label_percent(suffix=" %")) +
  scale_x_continuous(breaks=seq(0,1,.25), limits=c(0,1), labels=scales::label_percent(suffix=" %")) +
  annotate('text', x=.1, y=.8, hjust=0, size=2.5,
           label="The Gini coefficient is calculated as\nG = A / (A + B) = 1 - 2B = 2A") +
  annotate('text', x=.25, y=.4, angle=45, size=2.5, hjust=0,
           label="If everybody have\nthe same income") +
  annotate('text', x=.7, y=.5, angle=59, size=2.5,
           label="A Lorenz curve") +
  coord_fixed() +
  labs(x="Share of population" , 
       y="Share of total income") +
  theme(text = element_text(size=8))
  
g_gini1
g_gini1 %>% ggsave(file="g_gini1.pdf", width=4.5, height=3)


###############################################################################
## lorenz ex 2
g_ginitheory <-  ggplot() +
  stat_function(fun=function(x) x) +
  stat_function(fun=function(x) x^2, geom='area', linetype='dashed', fill='lightgray', color='black') +
  stat_function(fun=function(x) x^3, geom='area', fill='gray', color='black') +
  coord_fixed() +
  annotate('label', x=.47, y=.26, size=1.7, 
           label=TeX("Distribution 2: $y = x^2$")) +
  annotate('label', x=.58, y=.1, size=1.7, 
           label=TeX("Distribution 1: $y = x^3$")) +
  annotate('text', x=.25, y=.4, angle=45, size=2, hjust=0,
           label="If everybody has\nthe same income") +
  coord_fixed() +
  scale_y_continuous(breaks=seq(0,1,.25), limits=c(0,1), labels=scales::label_percent(suffix=" %")) +
  scale_x_continuous(breaks=seq(0,1,.25), limits=c(0,1), labels=scales::label_percent(suffix=" %")) +
  labs(x="Share of population" , 
       y="Share of total income") +
  theme(text = element_text(size=8))




g_ginitheory
g_ginitheory %>% ggsave(file="g_ginitheory.pdf", width=4.5, height=3)
  
