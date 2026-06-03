library("tidyverse")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

###############################################################
# the number line
g_numberline <- 
  ggplot(tibble(x=-2:2, y=c(0,0,0,0,0)),
    aes(x=x, y=y)) + 
  geom_point(size = 5, shape=3) + 
  xlim(-2, 2) + 
  geom_hline(yintercept=0) +
  theme_void() +
  geom_text(aes(label=x), vjust=2)

g_numberline
g_numberline %>% ggsave(file="g_numberline.pdf", heigh=.6, width=2)
knitr::plot_crop("g_numberline.pdf")


#############################################################################
### false patterns
g_falsearrows <- ggplot() +
  # obj 1
  stat_function(fun=function(x) 5, xlim=c(0,2), 
                arrow=arrow(length=unit(.47, 'cm'), 
                            ends='both', 
                            type='open')) +
  # obj 2
  stat_function(fun=function(x) 7, xlim=c(.999999999 , 1),
                arrow=arrow(length=unit(.47, 'cm'),
                            ends='last',
                            type='open')) +
  stat_function(fun=function(x) 7, xlim=c(3 , 3.00000001),
                arrow=arrow(length=unit(.47,'cm'),
                            ends='first',
                            type='open')) +
  stat_function(fun=function(x) 7, xlim=c(1,3)) +
  # obj 3
  annotate('segment', x=7,xend=7,  y=4, yend=3.999999999999, 
           arrow=arrow(length=unit(.47, 'cm'), 
                       ends='last', type='open')) +
  annotate('segment', x=7,xend=7,  yend=2, y=1.9999999999999, 
           arrow=arrow(length=unit(.47, 'cm'), 
                       ends='last', type='open')) +
  # obj 4
  annotate('segment', y=5,yend=5.00000000001,  xend=6, x=6, 
           arrow=arrow(length=unit(.47, 'cm'), 
                       ends='first', type='open')) +
  annotate('segment', yend=7,y=7.00000000001,  xend=6, x=6, 
           arrow=arrow(length=unit(.47, 'cm'), 
                       ends='first', type='open')) +
  
  # layout
  scale_x_continuous(limits=c(0,10) , breaks=0:10) +
  scale_y_continuous(limits=c(0,10), breaks=0:10) +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank())

g_falsearrows
g_falsearrows %>% ggsave(file="g_falsearrows.pdf", width=3, height = 3)


### linjer utan pilar  
g_falselines <- ggplot() +
  annotate('segment', x=0,xend=2, y=5, yend=5) +
  annotate('segment', x=1,xend=3, y=7, yend=7) +
  annotate('segment', x=6,xend=6, y=7, yend=5) +
  annotate('segment', x=7,xend=7, y=4, yend=2) +
  # layout
  scale_x_continuous(limits=c(0,10) , breaks=0:10) +
  scale_y_continuous(limits=c(0,10), breaks=0:10) 





#############################################################################
## straigt line 1

g_line1 <- ggplot(tibble(x=0:2, y=2+x), aes(x,y)) + geom_line() + geom_point() +
  scale_x_continuous (breaks=0:2, labels=0:2) +
  scale_y_continuous(breaks=0:4, labels=0:4) +
  theme(axis.title.y =element_text(angle=0)) +
  labs(x="x: Money", y="y: Happiness")

g_line1
# g_line1 %>% ggsave(file="g_line1.pdf", width=3, height =3)



#############################################################################
###  optimization problem 1
g_max_problem1 <- ggplot() +
  stat_function(fun=function(x) x-x^2, xlim=0:2) +
  geom_point(aes(.5, .25), size=3) +
  annotate(geom='text', x=.5, y=.27, label="Maximal lycka") +
  scale_x_continuous(labels=NULL, breaks = NULL) +
  scale_y_continuous(labels=NULL, breaks = NULL) +
  labs(x=TeX(" \\leftarrow{}  More consumption. More leisure \\rightarrow"), 
       y="Lycka") +
  theme(axis.title.y = element_text(angle=0))

g_max_problem1
# g_max_problem1 %>% ggsave(file="g_max_problem1.pdf", width=3, height=3)



## function basics. draw circle & arrow
x_arrow_y <- ggplot(tibble(x=1, y=1), aes(x)) +
  geom_point(aes(x=0, y=1), data = NULL, shape = 1, 
             color = "black", size = 25) +
  geom_point(aes(x=10, y=1), data = NULL, shape = 1, 
             color = "black", size = 25) + 
  geom_segment(aes(x=0,y=1, 
                   xend=10,yend=1), arrow=arrow()) +
  geom_text(aes(x=0, y=1), label="X\nInkomst", vjust=-2) +
  geom_text(aes(x=10, y=1), label="Y\nLivslängd", vjust=-2)  +
  theme_void() + 
  xlim(-5,15) +
  ylim(.7,1.5)

x_arrow_y
# x_arrow_y %>% ggsave(file="x_arrow_y.pdf", width=2, height=2)
#knitr::plot_crop("x_arrow_y.pdf")






################################################################################
### sec 3.4 > 2 time series
################################################################################
ts <- tibble(
  year = 2007:2015,
  A=c(123	,234,	336,	207,	252,	199, NA, NA, NA), 
  B=c(NA, NA, NA, 2,4,5,4,7,6.3) )

g_ts1 <- ts %>% pivot_longer(A:B) %>% 
  ggplot(aes(x=year, y=value, lty=name)) + 
  geom_line(show.legend=FALSE) +
  scale_x_continuous(breaks=2007:2015) +
  labs(x=element_blank(), y=element_blank(),
       title="Time series\nvalue") +
  theme(text=element_text(size=8), 
        axis.text.x=element_text(angle=90))

g_ts2 <- ts %>% 
  mutate(ind_A = A/A[1] * 100, ind_B=B/B[4] * 100, 
         ind_B=lead(ind_B,3)) %>% 
  select(-A,-B) %>% drop_na %>% 
  mutate(year=1:6) %>% 
  pivot_longer(ind_A:ind_B)  %>% 
  ggplot(aes(x=year, y=value, lty=name)) + geom_line() + 
  scale_linetype(name=element_blank(), labels=c("A","B")) + 
  scale_x_continuous(breaks=1:6) +
  scale_y_continuous(breaks=seq(100,600,100)) +
  labs(x="Index year", y=element_blank(),
       title="Index\nvalue") +
  theme(text=element_text(size=8))

(g_ts1 + g_ts2)
(g_ts1 + g_ts2) %>% ggsave(filename="g_timeseriesindex.pdf", width=4.2, height=3)


################################################################################
### illustrate y=f(x)
df1 <- tibble(x= 0:5, y= 10*x, y2= x^2, 
              label = paste0("(",x,",",y,")"))
g_plot1a <- 
  ggplot(df1, aes(x,y)) + geom_point() + geom_line() +
  geom_text_repel(aes(label=label), hjust=1, size=2) +
  annotate('text', x=5, y=54, hjust=0, size=2,
           label=TeX("$y = 10x$")) +
  scale_y_continuous(breaks=c(0,10,20,30,40,50), limits=c(0,55)) +
  scale_x_continuous(breaks=0:5 , limits=c(0,6)) +
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =8) )

g_plot1a
g_plot1a %>%  ggsave(file="plot_1a.pdf", height=2.6, width=2.6)



#################################################
## 2 functions in the same graph
#################################################
g_2functions <- ggplot() + 
  stat_function(fun=function(x) 5-.1*x) +
  stat_function(fun=function(x) x-3, linetype='dashed') +
  scale_x_continuous(breaks=0:15, labels=0:15, limits=c(0,15)) +
  scale_y_continuous(breaks=-3:12) +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  annotate('label', x=13, y=2, size=2, 
           label=TeX("$k(x) = 5 - 0,1x$")) +
  annotate('label', x=12, y=10, size=2,
           label=TeX("$u(x) = x - 3$")) +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=7))

g_2functions  
g_2functions %>% ggsave(file="g_2functions.pdf", width=3, height=2.5)


#################################################
### pos, neg, null
#################################################
g_pos_neg_slopes <- 
  ggplot() +
  stat_function(fun=function(x) -25 +1*x, linetype="dashed") +
  stat_function(fun=function(x) 10 -8*x) +
  geom_hline(yintercept=-10, linetype="dotted") +
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  scale_x_continuous(limits=c(-5,5)) +
  annotate('label', x=-3.5, y=40, size=2, 
           label="Negative slope") +
  annotate('label', x=-3.5, y=-25, size=2, 
           label="Positive slope") +
  annotate('label', x=-3.5, y=-10, size=2, 
           label="No slope") +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=7))

g_pos_neg_slopes
g_pos_neg_slopes %>% ggsave(file="g_pos_neg_slopes.pdf", width=3, height=2.5)



#################################################
# fler exempel på grafer
#################################################
df <- tibble(
  x=c(10,20,30),
  y=c(20,10,30), 
  the_label=paste0("(",x,",",y,")")
)
theg <- df %>% ggplot(aes(x,y)) + 
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=7)) +
  ylim(0,40)

gx1 <- theg + geom_point() + geom_label_repel(aes(label=the_label), size=2)
gx2 <- theg + geom_line() + geom_label_repel(aes(label=the_label), size=2)
gx3 <- theg + geom_col() + geom_label_repel(aes(label=the_label), size=2)
gx4 <- theg + geom_area() + geom_label_repel(aes(label=the_label), size=2)
g_moreexemples <- (gx1 + gx2) / (gx3 + gx4)
g_moreexemples
# g_moreexemples %>% ggsave(file="g_moreexemples.pdf", width=4, height=3)

g_barlinedot <- ggplot(tibble(x=1:4, y=c(4,5,3,7)), aes(x,y)) +
  geom_point() + geom_col(alpha=.5) + geom_line() +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=7))


g_barlinedot




################################################################## 
### straight line example
################################################################## 
g1 <- ggplot(tibble(x=-10:10), aes(x)) + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =8) ) + 
  stat_function(fun=function(x) 5 + .5*x, geom="point", n=7) + 
  stat_function(fun=function(x) 5 + .5*x, geom="line") +
  xlim(-20,10) + ylim(-7,10) +
  geom_hline(yintercept=5, linetype='dashed') +
  annotate("text",x=-11,y=6, size=2.5,
           label="a = y-intercept") +
  annotate("text", x=5,y=8.8, size=2.5, 
           angle=40, label="b = slope")  

g1
g1 %>% ggsave(file="g_straight_line_example1.pdf", width=2.6, height=2.6)



###########################################################################
p <- ggplot(tibble(x=-10:10), aes(x)) + 
  geom_vline(xintercept=0, alpha=.3) + 
  geom_hline(yintercept=0, alpha=.3) +
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =6) )
###########################################################################
p




###########################################################################
### straight line exercise 1
### 4 equations
g_exercise1 <- 
  p + 
  stat_function(fun=function(x) 0 -.5*x ,linetype="dotted" ) + xlim(0,20) + ylim(-5,15) +
  stat_function(fun=function(x) 0 +.5*x ,linetype="dashed" ) +
  stat_function(fun=function(x) 15 -2*x ,linetype="longdash" ) + 
  stat_function(fun=function(x) 5 + .25*x ) 

g_exercise1
g_exercise1 %>% ggsave(file="g_straight_exercise1.pdf", 
                       height=3, width=3)

##################################################################  
### six examples of straight lines
##################################################################  
g1 <- p + stat_function(fun=function(x) 10-.5*x) + xlim(0,20) + ylim(-5,15) +
  labs(title="(a) y = 10 - 0,5x")

g2 <- p + stat_function(fun=function(x) 3+20*x) + xlim(-3,5) + ylim(-5,15) +
  labs(title="(b) y = 3 + 20x")

g3 <- p + stat_function(fun=function(x) -3-x) + xlim(-5,5) + ylim(-10,5) +
  labs(title="(c) y = -3 - x")

g4 <- p + stat_function(fun=function(x) 100+2*x) + xlim(-100,100) +
  labs(title="(d) y = 100 + 20x")

g5 <- p + stat_function(fun=function(x) 10 + 0*x) + xlim(-10,10) + ylim(-2,12) +
  labs(title="(e) y = 10")

g6 <- p + stat_function(fun=function(x) -10 + 3*x) + xlim(-10,10) + ylim(-20,5) +
  labs(title="(f) y = -10 + 3x")


g_straigthlines <- (g1 + g2) / (g3 + g4) / (g5 + g6)
g_straigthlines
g_straigthlines %>% ggsave(file="g_straigthlines.pdf", 
                           height=6, width=4.5)


###########################################################################
### discontinous function
g_discontinous <- ggplot() +
  stat_function(fun=function(x) 1+x, xlim=c(-2,4.65) ) +
  geom_point(aes(5,6), size=3, shape=21) +
  stat_function(fun=function(x) 20-x, xlim=c(5,15)) +
  geom_point(aes(5,15), size=3) +
  annotate('text', x=3, y=1, hjust=0, size=2,
           label=TeX( r'($h(x)  \;  \forall x \in (- \infty ,5)$)' )) +
  annotate('text', x=8, y=16, hjust=0, size=2, 
           label=TeX( r'($h(x) \;  \forall x \in \[5, \infty )$)' )) +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=7))


g_discontinous
g_discontinous %>% ggsave(file="g_discontinous.pdf", height = 2.5, width=2.5)






###########################################################################
### icke-linjärt exempel
g_nonlinear_ex <- ggplot() + 
  stat_function(fun=function(x) 3+ x^2) + 
  xlim(-1,2) + ylim(0,10) +
  theme(axis.title.y = element_text(angle=0), 
        text=element_text(size=8)) +
  labs(x="x",y="y") +
  annotate("text", x=.5, y=5, size=2, 
           label=TeX("$y=3+x^2$"))

g_nonlinear_ex
g_nonlinear_ex %>% 
  ggsave(filename="g_nonlinear_ex.pdf", height=2.7, width=3)


