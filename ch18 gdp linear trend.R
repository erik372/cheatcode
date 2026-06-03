rm(list=ls())
library("tidyverse")
library("jsonlite")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)


#####################################################
### sec 18.3. nominal GDP vs ln GDP  
#####################################################

df1 <- read_csv("data/measuring worth USGDP_1790-2020.csv", skip=1) %>% 
  filter(Year %in% c(1800,1850,1900,1950,2000)) %>% 
  rename(gdp_musd = `Nominal GDP (million of Dollars)`) %>% 
  mutate(gdp = gdp_musd / 1000,   # billions USD
         ln_gdp = log(gdp)) %>% 
  select(-gdp_musd)

#####################################################
### table 18.5
#####################################################
df1 %>% 
  select(G = gdp, T = Year) %>%
  relocate(G,
           T) %>% 
  mutate(G_tilde = G - mean(G),
         T_tilde = T - mean(T), 
         T_tilde2 = T_tilde^2 , 
         TtGt = G_tilde * T_tilde,
         lnG = log(G),
         lnG_tilde = lnG - mean(lnG),
         Tt_lnGt = T_tilde* lnG_tilde
         ) %>% 
  # mutate(meanG = mean(G), meanT=mean(T), 
  #        sTt = sum(T_tilde), sTtGt = sum(TtGt), 
  #        sTt_lnGt = sum(Tt_lnGt)
  #        ) %>% 
  # mutate(across(where(is.numeric), ~round(.,2))) %>% 
  writexl::write_xlsx("table 18.5 G and T reg.xlsx")
  



#####################################################
### ols 2 models
#####################################################
df1
lm(gdp ~Year, df1) 

1039905.15 / 25000

lm(ln_gdp ~Year, df1)
1231.986 / 25000

exp(-89.98148)
exp(-89.98)
exp(89.98148)

round(1198009432536814286584824042286222444224/ 1e39)

10^40
10^23


#####################################################
### tab 18.6
#####################################################
df1 %>% 
  select(G=gdp, T=Year) %>% 
  relocate(G,T) %>% 
  mutate(Gpred = predict(lm(G~T)),
         Gres = residuals(lm(G~T)), 
         lnG = log(G), 
         lnGpred = predict(lm(lnG~T)), 
         lnGres = residuals(lm(lnG~T)), 
         explnG = exp(lnGpred)
         ) %>%
  mutate(sumGres = sum(Gres^2), 
         sumlnGres = sum(lnGres^2)) %>% 
  mutate(across(where(is.numeric), ~round(.,2))) %>% 
  writexl::write_xlsx("table 18.6 G lnG pred.xlsx")

exp(1.31)


#####################################################
### figur 18.6
#####################################################
g_gdp_lngdp_reg <- df1 %>% 
  # mutate(Gpred = predict(lm(gdp~Year)), 
  #        lnGpred = predict(lm(ln_gdp~Year))
  #        ) %>% 
  pivot_longer(-1)  %>% 
  group_by(name) %>% 
  mutate(Gpred = predict(lm(value~Year))) %>% 

  ggplot(aes(y=value, x=Year)) +
  facet_wrap(~name, scales="free", 
             labeller=labeller(name=c("gdp"="GDP, bn USD", "ln_gdp"="ln GDP"))) +
  geom_point() + geom_line() +
  geom_smooth(method="lm", se=FALSE, linetype="dashed", color="black") +
  geom_segment(aes(yend= Gpred) ,
               linetype=2, 
               linewidth=.5, 
               alpha=.5) +
  labs(x="Year", y="Variable values") +
  scale_y_continuous(labels=scales::comma) +   ### SÅ JÄVLA BRA FUNKTION!
  theme(text=element_text(size=8))

g_gdp_lngdp_reg
g_gdp_lngdp_reg %>% ggsave(filename="g_gdp_lngdp_reg.pdf", width=4, height=3)



#####################################################
### table 18.7
#####################################################

df187 <- df1 %>% 
  rename(G=gdp, lnG = ln_gdp) %>% 
  mutate(lnGpred = predict(lm(lnG~Year)), 
         exp_lnGpred = exp(lnGpred),
         lnGresiduals = residuals(lm(lnG~Year)),
         d = G - exp_lnGpred,
         p = G / exp_lnGpred * 100
         ) 

df187 %>% 
  mutate(across(where(is.numeric), ~round(.,2))) %>% 
  writexl::write_xlsx("table 18.7 trend deviations.xlsx")

myt <- theme(text=element_text(size=7))

## regular regression line 
g1 <- df187 %>% 
  ggplot(aes(y=lnG, x=Year)) +
  geom_line() + geom_point() +
  geom_smooth(method="lm", se=FALSE, linetype="dashed", color="black") +
  labs(title="(a) ln GDP and trend", x=element_blank() , y="ln G") +
  myt

## regular residuals
g2 <- df187 %>% 
  ggplot(aes(x=Year, y=lnGresiduals)) +
  geom_point() +
  geom_segment(aes(yend=0), linetype=2, color="gray") +
  geom_hline(yintercept=0, linetype="dashed", linewidth=1) +
  labs(title="(b) Residuals", x=element_blank() , y="ln residual value" ) +
  myt

## difference G - Ghat (predicted from ln regression)
g3 <- df187 %>%
  ggplot(aes(x=Year, y=d) ) +
  geom_point() +
  geom_segment(aes(yend=0), linetype=2, color="gray") +
  geom_hline(yintercept=0, linetype="dashed", linewidth=1) +
  labs(title=TeX("(c) Variable d = $G - \\exp(\\hat{G})$"), 
       x=element_blank() , 
       y=TeX("$G - \\exp(\\hat{G})$")) +
  myt +
  scale_y_continuous(labels=scales::comma)   ### SÅ JÄVLA BRA FUNKTION!
  

g4 <- df187 %>% 
  ggplot(aes(x=Year, y=p )) +
  geom_point() +
  geom_segment(aes(yend=0), linetype=2, color="gray") +
  geom_hline(yintercept=0, linetype="dashed", linewidth=1) +
  labs(title=TeX("(d) Variable p = $\\frac{G}{exp(\\hat{G})}*100$"), x=element_blank() , y="Variable p") +
  myt


(g1 + g2) / (g3 + g4)

((g1 + g2) / (g3 + g4)) %>% ggsave(filename="fig 18.7 gdp deviations from trend.pdf", width=4, height=4)

#####################################################
### fig 18.7
#####################################################


