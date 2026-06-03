# our world in data
# gdp and happiness
rm(list=ls())
library("ggrepel")
library("tidyverse")
library("patchwork")
library("gghighlight")
library("stargazer")
library("latex2exp")

library("conflicted")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##############################################################
### get data 
##############################################################

df <- read_delim(file="data/gdp-vs-happiness2.csv", delim=";") %>% 
  filter(Year==2017) %>% 
  rename(country = Entity,
    gdp_cap = "GDP per capita, PPP (constant 2011 international $)"  , 
         happiness="Life satisfaction in Cantril Ladder (World Happiness Report 2019)",
         pop= "Total population (Gapminder, HYDE & UN)"
  ) 


df
my_select_countries <- c("Sweden",
                         "Brazil",
                         "Congo",
                         "France",
                         "Jamaica",
                         "Haiti"
                         # "Luxembourg", 
                         #   "Central African Republic",
                         #"United States"
                         )

##############################################################
### table 18.8
##############################################################


tab188 <- df %>% filter(country %in% my_select_countries ) %>% 
  arrange(gdp_cap) %>% 
  mutate(gdp_cap = gdp_cap/1000,       # obs 1000
         log_gdp = log10(gdp_cap)) %>% 
  select(country, happiness, gdp_cap, log_gdp) %>% 
  mutate(across(where(is.numeric), ~round(.,3)))

tab188
tab188 %>% writexl::write_xlsx("table 18.8 happiness gdp six countries.xlsx")

tab188
lm(happiness~gdp_cap, data=tab188) %>% summary
lm(happiness~log_gdp, data=tab188) %>% summary

##############################################################
### fig 18.8
##############################################################
g_188_gdp_happy <- tab188 %>% 
  mutate(gdp_pred = predict(lm(happiness~gdp_cap)), 
         loggdp_pred = predict(lm(happiness ~log_gdp))
         ) %>% 
  pivot_longer(c(gdp_cap, log_gdp), names_to="gdp_name", values_to="gdp_values")  %>% 
  pivot_longer(c(gdp_pred, loggdp_pred), names_to="gdp_pred_name", values_to="pred_values") %>% 
  filter(gdp_name=="gdp_cap" & gdp_pred_name=="gdp_pred" | gdp_name=="log_gdp" & gdp_pred_name=="loggdp_pred")  %>% 
  
  ggplot(aes(y=happiness, x=gdp_values, group=gdp_name)) +
  geom_point() + 
  geom_smooth(method="lm", se=FALSE, linetype="dashed", color="black") +
  geom_segment(aes(yend=pred_values, group=gdp_name), linewidth=.5, linetype="dashed") +
  facet_wrap(~gdp_name, 
             scales="free", 
             labeller=labeller(gdp_name=c("gdp_cap"="GDP per capita", 
                                          "log_gdp"="log GDP per capita"))) +
  labs(y="Hapiness", x="GDP values") +
  theme(text=element_text(size=8))

g_188_gdp_happy
g_188_gdp_happy %>% ggsave(filename="g_188_gdp_happy.pdf", width=4, height=3)


##############################################################
### R2
##############################################################
tab188 %>% 
  rename(H=happiness, Y=gdp_cap, logY = log_gdp) %>% 
  mutate(Hhat = predict(lm(H~Y)),
         hh_tilde_sq = (H - Hhat)^2,
         h_tilde_sq = (H - mean(H))^2,
         Hloghat = predict(lm(H~logY)),
         hlog_tilde_sq = (H - Hloghat)^2,
         R2a = 1 - sum(hh_tilde_sq) / sum(h_tilde_sq), 
         R2b = 1 - sum(hlog_tilde_sq) / sum(h_tilde_sq)
         )
