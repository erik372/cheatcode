rm(list=ls())
library("tidyverse")
library("patchwork")
library("conflicted")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# ej vetenskapligt format
options(scipen=999)

# använd komma som decimal
options(OutDec=",")

################################################################################
# global graph setting
th <- theme(axis.title.y = element_text(angle=0), 
            text = element_text(size =6))  

p <- ggplot(tibble(x=0:10), aes(x)) + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  scale_y_continuous(labels=function(x) format(x, big.mark = " ", scientific = FALSE))
  th

##################################################################  
## plot for y=x^2
the_g <-   ggplot(tibble(x=-5:5), aes(x)) + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  scale_x_continuous(breaks=-5:5) 
th <- theme(axis.title.y = element_text(angle=0), 
        text = element_text(size =6)) 

g_x2 <- the_g + 
  stat_function(fun=function(x) x^2, geom="line") +
  ggtitle(bquote("(a) y ="~x^2)) + th

g_x2_9 <- the_g +
  stat_function(fun=function(x) x^2 -9, geom="line") +
  ggtitle(bquote("(b) y ="~x^2-9)) + th

g_minus_x2 <- the_g +
  stat_function(fun=function(x) 4 -x^2, geom="line") +
  ggtitle(bquote("(c) y ="~4-x^2)) + th

g_mp_x2 <- the_g +
  stat_function(fun=function(x) x^2 + 9, geom="line") +
  ggtitle(bquote("(d) y ="~x^2 +9)) + th

g_xmin2  <- the_g +
  stat_function(fun=function(x) (2-x)^2, geom="line") +
  ggtitle(bquote("(e) y =" ~(2-x)^2)) + th

g_xplus2  <- the_g +
  stat_function(fun=function(x) (x+3)^2, geom="line") +
  ggtitle(bquote("(f) y =" ~(x+3)^2)) + th


g_x2_plots <- 
  (g_x2 + g_x2_9) / (g_minus_x2 + g_mp_x2)  / (g_xmin2 + g_xplus2)

g_x2_plots
g_x2_plots %>% ggsave(file="g_x2_plots.pdf", width=4.1, height=6)







###########################################################################
### 4 linjer  > fig 6.3
###########################################################################
gx2a <- p + 
  stat_function(fun=function(x) 75 -x^2  ) + xlim(-10,10) +
  labs(title="(a)")

gx2b <- p + 
  stat_function(fun=function(x) -10 +10*x^2 - x^3  ) + 
  xlim(-4,12) + ylim(-75,200) +
  labs(title="(b)")

gx2c <- p + 
  stat_function(fun=function(x) 100*x -100*x^2 + x^3  ) + 
  xlim(-50,125) +
  labs(title="(c)")

gx2d <- p + 
  stat_function(fun=function(x) 10*x^2 + 10*x^3 - x^4  ) + xlim(-4,12) +
  labs(title="(d)")

((gx2a + gx2b) / (gx2c + gx2d) )
((gx2a + gx2b) / (gx2c + gx2d) ) %>% ggsave(file="g_fig63_4lines.pdf", height=4.5, width=4.5)







p <- ggplot(tibble(x=-10:10), aes(x)) + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =6) ) +
  scale_y_continuous(labels=function(x) format(x, big.mark = " ", scientific = FALSE))


###########################################################################
### polynom of 3 and 4 degree

g_poly_1 <- p + stat_function(fun=function(x) 2*x^3 -x^2 +7) +
  labs(title=bquote("(a) y =" ~2*x^3 -x^2 +7))

g_poly_2 <- p + stat_function(fun=function(x) 10*x^2 + 5*x^3 - x^4) + 
  xlim(0,8) +
  labs(title=bquote("(b) y =" ~10*x^2 + 5*x^3 - x^4))

gpoly <- g_poly_1 + g_poly_2 
gpoly
gpoly %>% ggsave(file="gpoly.pdf", width=4, height=2.2)


