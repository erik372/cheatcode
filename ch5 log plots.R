rm(list=ls())
library("tidyverse")
library("patchwork")
library("readxl")
library("conflicted")
library("gghighlight")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

# använd komma som decimal
options(OutDec=",")

################################################
### gdp, nominal and log >> see R script "gdp examples"
################################################






################################################
### happiness & gdp
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



g1_gdphappy <- df %>% 
  ggplot(aes(x=gdp_cap/1000, 
             y=happiness)) + 
  geom_point(aes(size=pop), show.legend = FALSE) +
  geom_text_repel(aes(label=Entity), size=2) + 
  geom_smooth(method='lm' , alpha=.1, size=.1, linetype='longdash',
              formula = y ~log(x),
              se=FALSE, color='black') +
  gghighlight(Entity %in% my_select_countries) +
  labs(x="GDP per capita*", 
       y="Happiness*") +
  xlim(0,100) +
  theme(text=element_text(size=6))

g1_gdphappy

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

(g1_gdphappy + g2_loggdphappy)
(g1_gdphappy + g2_loggdphappy) %>% 
  ggsave(file="g_gdphappy.pdf", width=4.5, height=3)







################################################
# Swe pop log_10
################################################

tibble(
  pop=2:10, 
  year=c(1760,1835,1863,1889,
         1925,1950,1970,2005,2017),
  logpop=log10(pop)
) %>% 
  pivot_longer(c('pop','logpop')) %>% 
  ggplot(aes(x=year, y=value)) +
    geom_line() + 
  geom_smooth(method='lm', se=FALSE) +
    facet_wrap(~name, scales='free')

###########################################################################
# world pop, billions
tibble(year=c(1804,1927,1960,1974,1987,1999,2011),
       pop=1:7,
       logpop=log10(pop)) %>% 
  pivot_longer(c('pop','logpop')) %>% 
  ggplot(aes(x=year, y=value)) +
  geom_line() + 
  geom_smooth(method='lm', se=FALSE) +
  facet_wrap(~name, scales='free')




###########################################################################
### log-log graphs
exp_df <- tibble(x=1:10, x2=x^2, lnx=log(x), lnx2=log(x2))

th <- ggplot() + theme(axis.title.y = element_text(angle=0), 
            text = element_text(size =7) ) 
lnp1 <- th+ stat_function(fun=function(x) x^2) + 
  scale_x_continuous(limits=c(1,8), breaks=c(1,2,4,8)) +
  labs(title="(a)", x="x", y=expression(x^2))
lnp2 <- th+ stat_function(fun=function(x) log(x^2), xlim=c(.001,10)) +
  scale_x_continuous(limits=c(1,8), breaks=c(1,2,4,8)) +
  scale_y_continuous(limits=c(0,5)) +
  labs(title="(b)", x="x", y=expression(ln(x^2)))

lnp3 <- th+ stat_function(fun=function(x) x^2) + 
  labs(title="(c)", x=expression(ln(x)), y=expression(x^2))+
  scale_x_continuous(trans="log", limits=c(1,8), 
                     breaks=c(1,2,4,8))
lnp4 <- th+ stat_function(fun=function(x) log(x^2)) + 
  labs(title="(d)", x=expression(ln(x)), y=expression(ln(x^2)))+
  scale_x_continuous(trans="log", limits=c(1,8), 
                     breaks=c(1,2,4,8))

ln_plots <- (lnp1 + lnp2) / (lnp3 + lnp4) 
ln_plots
ln_plots %>% ggsave(file="ln_plots.pdf", height=4, width=4)


