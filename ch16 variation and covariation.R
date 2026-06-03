rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("lemon")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")
conflict_prefer("mean","base")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# använd komma som decimal
#options(OutDec=".")


################################################################################
### frekvensfördelning ex 1
################################################################################

g_frekvens_ex1 <- tibble(value = 4:6,
       freq = c(1,2,1)) %>% 
  ggplot(aes(y=freq, x=value)) + geom_col() +
  labs(x="Value", y="Frequency") +
  theme(axis.text.y=element_text(angle=0), 
        text=element_text(size=7)) +
  scale_y_continuous(breaks=1:2) 

g_frekvens_ex1
g_frekvens_ex1 %>%   
  ggsave(file="g_frekvens_ex1.pdf", width=2, height=2)







################################################################################
## stapeldiagram
################################################################################

g_stapel_1 <- ggplot(tibble(x=c(3,4,6,7)), aes(x=x)) + 
  geom_bar(color="black") +  
  scale_y_continuous(breaks=0:3, labels=0:3, limits=c(0,3)) +
  scale_x_continuous(breaks=2:8, labels=2:8, limits=c(2,8)) +
  labs(x="Value of x",
       y="Number of observations") +
  theme(axis.text.y=element_text(angle=0), 
        text=element_text(size=7))

g_stapel_2 <- ggplot(tibble(x=c(3,4,6,7)), aes(x=x)) + 
  geom_histogram(bins=2, color="black") +
  labs(x="Value of x",
       y="Number of observations") +
  theme(axis.text.y=element_text(angle=0), 
        text=element_text(size=7))

(g_stapel_1 + g_stapel_2) 
(g_stapel_1 + g_stapel_2) %>% ggsave(file="g_stapeldiagram_1.pdf", width=3.5, height=2)








################################################################################
# varians och standardavvikelse
################################################################################
## samma data som första exempel med OLS 
t2 <- tibble(
  obs = 1:4,
  x = c(3,4,6,7),
  y = c(3,2,5,4), 
  label=paste0("(",x,",",y,")")
)
t2

# population variance 
# * (n-1) / n

g_varians1 <- t2 %>% 
  mutate(order=1:4) %>% 
  pivot_longer(x:y) %>% 
  group_by(name) %>% 
  mutate(name=case_when(
    name=='x' ~paste0("Variable x\nmean ", round(mean(value),1),"\nvariance ", round(var(value) *(3/4) , 1) ),
    name=='y' ~paste0("Variable y\nmean ", round(mean(value),1),"\nvariance ", round(var(value) *(3/4) , 2) )
  )) %>% 
  
  ggplot(aes(x=value -mean(value), y=order)) + 
  geom_point() +
  geom_segment(aes(xend=0, yend=order)) +
  geom_vline(xintercept=0, alpha=.25) +
  facet_wrap(~name) +
  labs(x="Deviation from mean", 
       y="Observations") +
  theme(text=element_text(size=8))

g_varians1
g_varians1 %>% ggsave(file="g_varians1.pdf", height = 3, width=4.5)

sqrt(5/3) 
sqrt(10/3)

var(t2$y)
sd(t2$y)
sqrt(1.7)


################################################################################
### struket exempel >  Bessels korrigering, varians
################################################################################
pop <- c(1,2,3,4)
s1 <- c(1,2,3)
s2 <- c(1,2,4)
s3 <- c(2,3,4)
s4 <- c(1,3,4)

# population variance 
# * (n-1) / n
var(s1) * (3-1)/3

# sample variance
mean(
c(var(s1),
var(s2),
var(s3),
var(s4))
)



################################################################################
# läges- och spridningsmått
# tabell med ex
################################################################################
sif <- c(12,27,35,38,53,53,55,57,66,69,74,89,98)
mean(sif, na.rm=FALSE) %>% round(1)
median(sif)
quantile(sif, .25)
quantile(sif, .75)
quantile(sif, .2)
quantile(sif, .8)
myvar <- (var(sif) *(length(sif)-1)/length(sif)) %>% round(1)
sqrt(myvar) %>% round(1)
min(sif)
max(sif)




################################################################################
### Pearsons r
################################################################################
t2
1.25 / (
sqrt(2.5) * 
sqrt(1.25)
)
cor(t2$x,t2$y, method="pearson")


################################################################################
# cov standardiserade värden
################################################################################
t2
t2norm <- t2 %>% 
  mutate(nx=scale(x)[,1], ny=scale(y)[,1])

cov(t2norm$nx, t2norm$ny)

################################################################################
### Exempel på Pearsons r och rangkorrelation
################################################################################
set.seed(12)
x <- rnorm(10, 6, 4)
y <- x^4 + rnorm(10,1, 100)
plot(x,y)

cor(x,y, method="pearson")
cor(x,y, method="spearman")

therankdata <- tibble(x,y, rank_x = rank(x), rank_y= rank(y))
therankdata %>% write_csv2("rankdata.csv")

g_rankdata_1 <- therankdata %>% 
  ggplot(aes(x,y)) + geom_point() +
  labs(title="Variables x and y") +
  theme(text=element_text(size=8), 
        axis.title.y=element_text(angle=0)) 

g_rankdata_2 <- therankdata %>% 
  ggplot(aes(rank_x, rank_y)) + geom_point() + 
  labs(title="Rangordnade värden av x och y", 
       x="x rangordnad", y="y rangordnad") +
  theme(text=element_text(size=8)) +
  scale_x_continuous(labels=seq(1,10,2), breaks=seq(1,10,2)) +
  scale_y_continuous(labels=seq(1,10,2), breaks=seq(1,10,2)) 
  

(g_rankdata_1 / g_rankdata_2)
# (g_rankdata_1 / g_rankdata_2) %>%   ggsave(filename="g_rankdata.pdf", width=4, height=6)





################################################################################
### Första enkla exemplet på samvariation
################################################################################
set.seed(1)
g_samvariation_ex1 <- tibble(
  x1 = rnorm(1000, 500, 1),
  x2 = rnorm(1000, 500, 250),
  x3 = rnorm(1000, 500, 500)) %>% 
  pivot_longer(x1:x3, names_prefix="x", names_to="series", values_to="x") %>% 
  mutate(y = 
    case_when(
      series=="1" ~ 5 + 1*x + rnorm(1000, mean=0, sd=.5),
      series=="2" ~ 5 + 1*x + rnorm(1000, mean=0, sd=500),
      series=="3" ~ 5 + 1*x + rnorm(1000, mean=0, sd=3000)
      )
    ) %>% 
  ggplot(aes(x, y)) + 
  geom_point(alpha=.3) +
  # geom_smooth() +
  facet_wrap(~series, scales="free", ncol=1) +
  theme(axis.text=element_blank(), 
        axis.ticks=element_blank(), 
        axis.title.y=element_text(angle=0)) +
  labs(x="X", y="Y")

g_samvariation_ex1
g_samvariation_ex1 %>% 
  ggsave(filename="g_samvariation_ex1.pdf", width=4, height=6)




########################################################################
## before OLS - we show the 4 ols data points
t2 <- tibble(
  obs = 1:4,
  x = c(3,4,6,7),
  y = c(3,2,5,4), 
  label=paste0("(",x,",",y,")")
)
t2
########################################################################

g_olspoints <-   t2 %>% 
  ggplot(aes(x,y)) + geom_point() +
  geom_text_repel(aes(label=label), size=3, position="dodge") +    
  theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =8) ) +
  annotate('text', x=3, y=4.1, hjust=0, size=3,
           label="This is\nobservation 1") +
  geom_curve(aes(x=3.5, y=3.8, xend=3.2, yend=3.2), 
             curvature=-.3, arrow=arrow(length=unit(.2,'cm')))


g_olspoints
g_olspoints %>% ggsave(file="g_olspoints.pdf", width=2.5, height=2.5)
