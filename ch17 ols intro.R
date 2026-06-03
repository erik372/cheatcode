rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("lemon")
library("gghighlight")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))



################################################
### basic logic > happiness & gdp
################################################

df <- read_delim(file="data/gdp-vs-happiness2.csv", delim=";") %>% 
  filter(Year==2017) %>% 
  rename(gdp_cap = "GDP per capita, PPP (constant 2011 international $)"  , 
         happiness="Life satisfaction in Cantril Ladder (World Happiness Report 2019)",
         pop= "Total population (Gapminder, HYDE & UN)"
  )  

my_select_countries <- c("Sweden","Brazil","Congo","France","Jamaica","Haiti")

df %>% filter(Entity %in% my_select_countries) %>% 
  arrange(gdp_cap) %>% 
  mutate(gdp_cap = gdp_cap/1000,
         log_gdp = log10(gdp_cap)) %>% 
  mutate(across(where(is.numeric),~round(.,2))) %>%  
  
  writexl::write_xlsx("table 5.4 happiness gdp six countries.xlsx")

lm(data = df %>% filter(Entity %in% my_select_countries) , 
   happiness ~ gdp_cap)


g2_loggdphappy <- df %>% 
  ggplot(aes(log10(gdp_cap/1000), 
             happiness)) + 
  geom_point(aes(size=pop), show.legend = FALSE) +
  geom_text_repel(aes(label=Entity), size=2) + 
  geom_smooth(method='lm', se=FALSE, color='black', 
              size=.1, alpha=.1, linetype='longdash') +
  gghighlight(Entity %in% my_select_countries) +
  labs(x="log GDP per capita*", 
       y="Happiness*", 
       caption="*Life satisfaction 1-10.\nGDP per capita in $1,000 adjusted for cost of living.") +
  scale_x_continuous(breaks=log10(c(1,2,4,8,16,32,64,128)),
                     labels=c(1,2,4,8,16,32,64,128)
  ) +
  theme(text=element_text(size=6)) 

g2_loggdphappy
g2_loggdphappy %>% 
  ggsave(file="g_gdphappy_for_OLS.pdf", width=3, height=3)







################################################################################  
### the 4 data points we use for illustration
################################################################################  
t2 <- tibble(
  obs = 1:4,
  x = c(3,4,6,7),
  y = c(3,2,5,4), 
  label=paste0("(",x,",",y,")")
)
t2

################################################################################  
### first graph
################################################################################

  lm1 <- lm(y~x, t2)
  t2 <- t2 %>% mutate(yhat=fitted.values(lm1))
  g_ols <- t2 %>% ggplot(aes(x,y)) + 
    geom_point() + 
    geom_smooth(method="lm", se=F, color='black') +
    geom_segment(aes(xend=x, yend=yhat), alpha=.45, linetype='dashed') +
    geom_text_repel(aes(label=label), size=2.5, position="dodge") +    
    # förklaring predikterade linjen
    annotate('text', x=5.5, y=3, size=2.5, hjust=0,
             label="The line is drawn using\nthe equation") +
    annotate('text', x=5.5, y=2.7, size=2.5, hjust=0,
             label=TeX("$\\hat{y}_i = \\hat{a} + \\hat{b}x_i$")) +
    geom_curve(aes(x=5.45, y=3, xend=4.7, yend=3.3), 
               curvature=-.3, arrow=arrow(length=unit(.2,'cm'))) +
    # residual 3
    annotate('text', x=5.2, y=4.75, size=3, hjust=1,
             label=TeX("$\\hat{v}_3 = 5 - 4 = 1$")) +
    geom_curve(aes(x=5, y=4.6, xend=5.9, yend=4.4),
              curvature = .2, arrow=arrow(length=unit(.2, 'cm'))) +
    theme(axis.title.y = element_text(angle=0) , 
          text = element_text(size =8) )
  
g_ols
g_ols %>% ggsave(file="g_ols.pdf", width=3.5, height=3)


################################################################################  
## false lines
g_falseols <- 
  t2 %>% ggplot(aes(x,y)) + geom_point() + 
  geom_text_repel(aes(label=label), 
                  size=2, 
                  position="dodge") +    
    geom_smooth(method="lm", se=F, color='black', size=.2, linetype='dashed') +
    geom_hline(yintercept = 3.5, color='black', size=.2, linetype='dashed') +
    stat_function(fun=function(x) 9/4 + .25*x, color='black', size=.2, linetype='dashed') +
    annotate('label', x=6,y=4.1,   label="A") +
    annotate('label', x=6,y=3.7,   label="C") +
    annotate('label', x=3.5,y=3.5,   label="B")+
    theme(axis.title.y = element_text(angle=0) , 
        text = element_text(size =8) )

g_falseols
g_falseols %>% ggsave(file="g_falseols.pdf", width=3, height=2.5)
  
  

################################################################################  
### konstiga linjer med OLS: Anscombes exempel
library("datasets")
help(package="datasets")
help(package="patchwork")
anscombe <- datasets::anscombe

g1 <- geom_point(size=1.2) 
g2 <- geom_smooth(method='lm', se=FALSE, color='black', size=.5) 
g3 <- geom_segment(aes(xend=xi, yend=ypred), alpha=.25, linetype='dashed') 
g4 <- theme(axis.title.y = element_text(angle=0), 
            text=element_text(size=7), 
            axis.ticks = element_blank(), 
            axis.text = element_blank())
g5 <- scale_x_continuous(labels=NULL)
#g5 <- scale_x_continuous(limits=c(4,20))
#g6 <- scale_y_continuous(limits=c(3,13))

####################################
g_anscombe1 <- anscombe %>% 
  # lm pred
  mutate(ypred = predict(lm(y1~x1)), xi=x1) %>%
  # graf
  ggplot(aes(x1, y1)) + g1 + g2 + g3 + g4 
g_anscombe2 <- anscombe %>% 
  # lm pred
  mutate(ypred = predict(lm(y2~x2)), xi=x2) %>%
  # graf
  ggplot(aes(x2, y2)) + g1 + g2 + g3 + g4 
g_anscombe3 <- anscombe %>% 
  # lm pred
  mutate(ypred = predict(lm(y3~x3)), xi=x3) %>%
  # graf
  ggplot(aes(x3, y3)) + g1 + g2 + g3 + g4 
g_anscombe4 <- anscombe %>% 
  # lm pred
  mutate(ypred = predict(lm(y4~x4)), xi=x4) %>%
  # graf
  ggplot(aes(x4, y4)) + g1 + g2 + g3 + g4 

g_anscombe <- (g_anscombe1 + g_anscombe2) / (g_anscombe3 + g_anscombe4) + 
  plot_annotation(theme=theme(text=element_text()))
g_anscombe
g_anscombe %>% 
  ggsave(filename="g_anscombe.pdf", width=4.5, height=3.1)

knitr::plot_crop("g_anscombe.pdf")



################################################################################  
### weird straight line examples
################################################################################  

### weird ols, b=0
g_weirdols_ex3 <- 
  tibble(
    x=0:11,
    y=if_else(x<=5, .945+x, -7+x)
  ) %>% 
  # add y lm pred
  mutate(ypred = predict(lm(y~x))) %>% 
  # graph it
  ggplot(aes(x=x, y=y)) + 
  geom_point() +
  geom_point(size=2) +
  geom_smooth(method='lm', se=FALSE, color='black', size=.5) +
  geom_segment(aes(xend=x, yend=ypred), alpha=.3, linetype='dashed') +
  theme(axis.title.y = element_text(angle=0), 
        text=element_text(size=8),
        axis.ticks = element_blank()) +
  scale_x_continuous(labels=NULL) +
  scale_y_continuous(labels=NULL) 


g_weirdols_ex4 <- 
  tibble(
    x=0:10,
    y=10*x-x^2 + runif(1)) %>% 
  # add y lm pred
  mutate(ypred = predict(lm(y~x))) %>% 
  # graph it
  ggplot(aes(x=x, y=y)) + 
  geom_point(size=2) +
  geom_smooth(method='lm', se=FALSE, color='black', size=.5) +
  geom_segment(aes(xend=x, yend=ypred), alpha=.3, linetype='dashed') +
  theme(axis.title.y = element_text(angle=0), 
        text=element_text(size=8), 
        axis.ticks = element_blank()) +
  scale_x_continuous(labels=NULL) +
  scale_y_continuous(labels=NULL) 

(g_weirdols_ex3 + g_weirdols_ex4) 
(g_weirdols_ex3 + g_weirdols_ex4) %>% 
  ggsave(file="g_weirdols_ex2.pdf", width=4.5, height=2.3)

knitr::plot_crop("g_weirdols_ex2.pdf")




### weird, b < 0
g_weirdols_ex1 <- 
  tibble(
    x = c(2,2,2,2,2, 1,1,1,1,1),
    y = c(3,3.7,4,5.2,6, 4.5,4.9,5.1,6.5,7)
    ) %>% 
    # add y lm pred
    mutate(ypred = predict(lm(y~x))) %>%
    # graph it
    ggplot(aes(x=x,y=y)) + 
    geom_point(size=2) + 
    geom_smooth(method='lm', se=FALSE, color='black') +
    geom_segment(aes(xend=x, yend=ypred), alpha=.25, linetype='dashed') +
  theme(axis.title.y = element_text(angle=0), 
        text=element_text(size=8), 
        axis.ticks = element_blank()) +
  scale_x_continuous(labels=NULL) +
    scale_y_continuous(labels=NULL) 

g_weirdols_ex2 <- 
  tibble(
      x=0:10,
      y=-x+ 10*x-x^2 + runif(1)
      ) %>% 
  # add y lm pred
  mutate(ypred = predict(lm(y~x))) %>% 
  # graph it
  ggplot(aes(x=x, y=y)) + 
  geom_point(size=2) +
  geom_smooth(method='lm', se=FALSE, color='black') +
  geom_segment(aes(xend=x, yend=ypred), alpha=.3, linetype='dashed') +
  theme(axis.title.y = element_text(angle=0), 
        text=element_text(size=8), 
        axis.ticks = element_blank()) +
  scale_x_continuous(labels=NULL) +
  scale_y_continuous(labels=NULL) 

(g_weirdols_ex1 + g_weirdols_ex2)
(g_weirdols_ex1 + g_weirdols_ex2) %>% 
  ggsave(file="g_weirdols_ex1.pdf",  width=4.5, height=1.8)
knitr::plot_crop("g_weirdols_ex1.pdf")















tibble(
  x=0:10,
  y=10*x-x^2 + runif(1))  %>% 
  ggplot(aes(x, y)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE, color='black',
              formula= as.formula( y~ x +x^2) )





########################################################################
## swe population, ols linear, ols log linear
pop_df <- 
  tibble(year=c(1750,1800,1850,1900,1950,2000),
         pop=c(1.8,2.3,3.5,5.1,7,8.9),
         logpop=log10(pop))
pop_df %>% 
  ggplot(aes(year, logpop)) + 
  geom_point() + geom_line() +
  geom_smooth(method='lm', linetype='dotted', se=FALSE, color='black')



################################################################################
## ols w/o alfa, origo line
g_ols_origo <- 
  tibble(x = c(0,1,3,3),
         y = c(.4737,0,3.5,1) ,
         label=paste0("(",x,",",y,")")
         ) %>%
  mutate(ypred = predict(lm(y~x-1)), 
         label=ifelse(row_number()==1, NA, label )) %>% 
  
  ggplot(aes(x=x,y=y)) + geom_point() + 
  geom_text_repel(aes(label=label), size=3, position="dodge") +    
  geom_smooth(method='lm', se=FALSE, formula="y~x-1", color='black') +
  geom_segment(aes(xend=x, yend=ypred), alpha=.3, linetype='dashed') +
  theme(axis.title.y = element_text(angle=0), text=element_text(size=8)) +
  xlim(0,3) + ylim(0,4) +
  annotate('text', x=0, y=1.5, hjust=0, size=2, 
           label="The line passes through the origin") +
  geom_curve(aes(x=.25, y=1.2, xend=.1, yend=.25), 
             curvature=-.3, arrow=arrow(length=unit(.2,'cm')))

g_ols_origo
g_ols_origo %>% ggsave(file="g_ols_origo.pdf", width=3, height=3)





################################################################################
### ols, ett till exempel
g_ols_ex2 <- 
  tibble(Z=c(1,4,0,1),
       K=c(0,0,4,4), 
       label=paste0("(",K,",",Z,")")) %>% 
  mutate(zpred  =predict(lm(Z ~ K))) %>% 
  
  ggplot(aes(x=K, y=Z)) + geom_point() +
  
  geom_text_repel(aes(label=label), size=2, nudge_x=.1) +
  
  geom_smooth(method='lm', se=FALSE, color='black', size=.5) +
  geom_segment(aes(xend= K, yend=zpred), alpha=.3, linetype='dashed') +
  
  theme(axis.title.y = element_text(angle=0), text=element_text(size=8)) +
  
  xlim(0,5) + ylim(0,5) +
  # förklaring predikterade linjen
  annotate('text', x=2, y=3, size=3, hjust=0,
           label="The line is drawn with the equation") +
  annotate('text', x=2, y=2.6, size=3, hjust=0,
           label=TeX("$\\hat{Z}_i = \\hat{\\alpha} + \\hat{\\beta} K_i$")) 
  
g_ols_ex2
g_ols_ex2 %>% ggsave(filename = "g_ols_ex2.pdf", height = 3, width=3)


################################################################################
### RSS ESS TSS illustration
################################################################################
library("ggbrace")

g_rssesstss <- t2 %>% ggplot(aes(x,y)) + 
  geom_point() + 
  geom_smooth(method="lm", se=F, color='black', size=.5) +
  
  geom_segment(aes(xend=x, yend=yhat), alpha=.45, linetype='dotted') +
  
  theme(axis.title.y = element_text(angle=0), text=element_text(size=8)) +
  
  geom_hline(yintercept=3.5, linetype="longdash") +
  # Tre y
  annotate("label", 
           y=c(3.5,
               2.6,
               2), 
           x=c(3,
               3.2,
               3.8), 
           size=2, 
           label=c(TeX("\\bar{y}"), 
                   TeX("\\hat{y}"), 
                   TeX("$y_i$")
                   )) +
  # Avstånden
  stat_brace(data=tibble(x=c(4,4.2), y=c(2,3)), aes(x,y), rotate = 90) +
  stat_brace(data=tibble(x=c(3.8,4), y=c(3,3.5)), aes(x,y), rotate = 270) +
  stat_brace(data=tibble(x=c(5.3,5.5), y=c(2,3.5)), aes(x,y), rotate = 90) +
  
  # Beskrivning av avstånden
  annotate("text", 
           x=c(3.5 , 4.5 , 5.8), 
           y=c(3.25 , 2.5 , 2.75), 
           size=2, 
           label=c(TeX("$\\hat{y} - \\bar{y}$"),
                   TeX("$y_i - \\hat{y}$"),
                   TeX("$y_i - \\bar{y}$")))
  
g_rssesstss
g_rssesstss %>% 
  ggsave(filename="g_rssesstss.pdf", width=3.6, height=2.6)

