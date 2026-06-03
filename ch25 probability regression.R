rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("ggrepel")
library("lemon")
library("conflicted")
library("writexl")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

# # använd komma som decimal
# options(OutDec=",")


################################################################################
### Illustrera population  + 3 regressionslinjer
################################################################################
#set.seed(862)
set.seed(111111)
the_data <- tibble(
  x = rnorm(1000, 500, 350), 
  y = 5 + 1*x + rnorm(1000, mean=0, sd=1000)
  )
s1 <- sample_n(the_data, size=10) %>% mutate(grupp=1)
s2 <- sample_n(the_data, size=10) %>% mutate(grupp=2)
s3 <- sample_n(the_data, size=5)

#lm(y~x, the_data)$resid %>% hist

g_regression_population_illustration <- the_data %>% 
  ggplot(aes(x,y)) + geom_point(alpha=.1) + 
  geom_smooth(method="lm", se=FALSE, color="black", size=.5) +
  geom_point(data=s1, aes(x,y,shape=as.factor(grupp))) + geom_smooth(data=s1, method="lm", se=FALSE, linetype="dashed",  color="black", size=.5) +
  geom_point(data=s2, aes(x,y,shape=as.factor(grupp))) + geom_smooth(data=s2, method="lm", se=FALSE, linetype="dotted",  color="black", size=.5) +
  scale_shape_manual(name="Sample", breaks=c(1,2), labels=c(1,2), values=c(18,0)) +
  theme(text=element_text(size=7), 
        axis.title.y = element_text(angle=0)) +
  xlim(-300,1400) +
  scale_y_continuous(breaks=seq(-2000,3000,1000), 
                     labels=function(x) format(x, big.mark = ",", big.interval=3, scientific = FALSE)) +
  scale_x_continuous(labels=function(x) format(x, big.mark = ",", big.interval=3, scientific = FALSE)) +
  annotate("label", 
           x=c(1250, -250, 0), 
           y=c(1300, 900, -1500), 
           size=1.7, 
           #hjust=0,
           label=c("Population", "Sample 1","Sample 2"))

g_regression_population_illustration
g_regression_population_illustration %>% 
  ggsave(filename="g_regression_population_illustration.pdf", width=4.7, height =3)
    





################################################################################
### räkna på statistisk styrka i regressionsanalys
# använd samma data som i inledningen av kapitlet
################################################################################
# skapa 1000 observationer
set.seed(9)
antal_obs <- 45000
the_data <- tibble(
  x = rnorm(antal_obs, mean=50, sd=5), 
  y = .15*x + rnorm(antal_obs, mean=100, sd=20)
)
the_data %>% 
  ggplot(aes(y,x)) + geom_point() + geom_smooth(method="lm",se=FALSE)

lm_res <- lm(y~x, data = the_data) 
lm_res$residuals %>% hist

# loop: ta urval, regression, spara resultat
mysamplefunction <- function(sample_size) {
  map_dfr(1:2000, ~{
    lmres <- lm(y~x, data=slice_sample(the_data, n=sample_size) ) %>% summary()
    tibble(calculation = .x,
           beta = lmres$coefficients[2,1],
           p_value = lmres$coefficients[2,4]
    ) %>% 
      return()
  })
}

# Ta fram urvalen och beräkna regressionerna
results_df_big <- mysamplefunction(5000)
results_df_small <- mysamplefunction(100)

# Visa resultat i 2 histogram
big_df <- list("Stort urval"=results_df_big, "Litet urval"=results_df_small) %>% 
  bind_rows(.id="sample") %>% 
  mutate(sample = fct_relevel(sample,"Stort urval"))


g_styrka_regression <- big_df %>% 
  ggplot(aes(x=beta, 
             fill=if_else(p_value<.05, "sign", "nosign"))) + 
  geom_histogram(bins=50) +
  scale_x_continuous(breaks=c(-1, -.5, .15, .5,1), 
                     labels=c("-1","-0,5", "0,15", "0,5", "1")) +
  scale_fill_manual(breaks=c("sign","nosign"), 
                    values=c("black","gray"), 
                    labels=c("Ja","Nej"),
                    name="Statistiskt \nsignifikant") +
  facet_wrap(~sample, ncol = 1, scale="free_y") +
  labs(x="Lutningskoefficienten för x", 
       y="Antal resultat") +
  theme(text=element_text(size=7))

g_styrka_regression
g_styrka_regression %>% 
  ggsave(filename="g_styrka_regression.pdf", width=4.5, height=6)











################################################################################
### Linjär sannolikhetsmodell, linear probability model, LPM 
### Kön = f( inkomst ), Kolada kommunerna
################################################################################
kolada_reg_data <- kolada_data %>%
  filter(variable=="income", 
         gender!="T") %>% 
  pivot_wider(values_from=value, names_from=gender) %>% 
  rename(income_female=K, 
         income_male=M) %>% 
  select(year, municipality, income_male, income_female) %>%
  pivot_longer(starts_with("income"), 
               values_to="income", names_prefix="income_", names_to="gender") %>% 
  left_join(   kolada_data %>% 
                 filter(variable!="income" ) %>%
                 select(year, municipality, value, variable) %>% 
                 pivot_wider(values_from=value, names_from=variable) %>% 
                 arrange(municipality) %>% 
                 pivot_longer(starts_with("life"), 
                              values_to="lifelength", names_to="gender", names_prefix = "lifelength_")
  ) %>% 
  mutate(genderdummy = ifelse(gender=="male",0,1))


## lm
lm(genderdummy ~ income, data=kolada_reg_data)
lm_res <- lm(genderdummy ~ income, data=kolada_reg_data %>% mutate(income=income/1000)) %>% summary

### manuell beräkning av t-värden
lm_res
lm_res$coefficients[1,1] / lm_res$coefficients[1,2]
lm_res$coefficients[2,1] / lm_res$coefficients[2,2]




## graf
g_lpm1 <- kolada_reg_data %>% 
  ggplot(aes(y=genderdummy, 
             x=income/1000)) + 
  geom_text_repel(aes(label=if_else(municipality=="Danderyd",municipality, NULL)), size=2, nudge_y=-.1) +
  geom_point(alpha=.4) + 
  geom_smooth(method="lm", se=FALSE, color="black", size=.5, linetype="dashed") +
  geom_hline(yintercept=c(0,1), size=.05, color="black") +
  labs(x="Genomsnittlig inkomst\n1 000-tals kr", 
       y=NULL, 
       caption="Medianinkomst disponibel inkomst.\nData från Kolada") +
  scale_y_continuous(breaks = c(0,1), labels=c("Män (0)",
                                               "Kvinnor (1)"), limits=c(-.5,1.5)) +
  theme(text=element_text(size=8))

g_lpm1
g_lpm1 %>% 
  ggsave(filename="g_lpm1.pdf", width=4, height = 3)








################################################################################
### konfidensintervall regressionslinjen
################################################################################

df <- tibble(x = c(3,4,6,7), 
             y = c(3,2,5,4))

lmest <- lm(y~ x, df) 
lmest %>% summary
sumsqres <- (base::sum((lmest$residuals)^2)/ 2) 

## y + t * se(y)
2.5 + qt(.975, df=2) * sqrt(sumsqres * (1/4 + 4/10))
2.5 - qt(.975, df=2) * sqrt(sumsqres * (1/4 + 4/10))

df <- predict(lm(y ~x, data=df), data=df, interval = "confidence", level = 0.95) %>% 
  cbind(df)
df
# beräkna konfidensintervall
g_ci_regline <-
  df %>%  

  ggplot(aes(x, y)) +
  geom_point() +
  geom_smooth(method="lm", color="black", linewidth=.5, se=TRUE) +
  #geom_line(aes(y=lwr), lty=2, color="darkgray") +
  #geom_line(aes(y=upr), lty=2, color="darkgray") +
  theme(text=element_text(size=8), 
        axis.title.y=element_text(angle=0)) +
  labs(x="X",y="Y") 

g_ci_regline
g_ci_regline %>% ggsave(filename="g_ci_regline.pdf", width=3, height=2.5)
