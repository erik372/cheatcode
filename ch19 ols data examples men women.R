rm(list=ls())
library("tidyverse")
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
### earnings, ILO stat
#####################################################
read_csv("data/ilostat earnings sex.csv") %>% 
  distinct(classif1.label)

earnings_df <- read_csv("data/ilostat earnings sex.csv") %>% 
  filter(ref_area.label %in% c("Sweden", 
                               "United Kingdom of Great Britain and Northern Ireland", 
                               "France", 
                               "Germany"), 
         sex.label %in% c("Male","Female", "Total"), 
         classif1.label=="Currency: 2021 PPP $"
         ) %>%
  filter(time==2020) %>%
  select(country = ref_area.label, earn = obs_value, gender = sex.label)  %>% 
  mutate(country = if_else(country=="United Kingdom of Great Britain and Northern Ireland", "United Kingdom", country)) 

earnings_df

earn_sex <- earnings_df %>% 
  filter(gender!="Total") %>% 
  arrange(desc(gender)) %>% 
  mutate(W = earn,
         G = if_else(gender=="Male",0,1), 
         W_tilde = W - mean(W), 
         G_tilde = G - mean(G),
         G_t_sq = G_tilde ^2, 
         W_tG_t = W_tilde * G_tilde, 
         sum_WtGt = sum(W_tG_t), 
         sum_Gtsq = sum(G_t_sq),
         mean_w = mean(W), 
         mean_G = mean(G)
         ) 

beta = earn_sex$sum_WtGt[1] / 1.5
alfa = mean(earn_sex$W)  - beta*.5
beta
alfa

lm(W ~ as.factor(G), 
   data=earn_sex %>% 
     filter(gender!="Total") %>% 
     mutate(W = earn,
            G = if_else(gender=="Male",0,1)
            )
   )  

19.445 +2.53*.5

### make graph
g_earnings_gender <- earn_sex %>% 
  select(W,G) %>% 
  mutate(pred_W = predict(lm(W~G))) %>% 
  
  ggplot(aes(y=W, 
             x=G)) + 
  geom_point() + 
  geom_smooth(method="lm", se=FALSE, color="black") +
  geom_segment(aes(y = W, yend=pred_W, x=G, xend=G), linetype="dashed") +
  labs(y="Hourly earnings, USD PPP", x=element_blank()) +
  scale_x_continuous(breaks=c(0,1), labels=c("0\nMen","1\nWomen"), limits=c(0,1)) +
  theme(text=element_text(size=8))

g_earnings_gender
g_earnings_gender %>% 
  ggsave(file="g_earnings_gender.pdf", width=3, height=3)


#####################################################
### compare income for countries (gender = total)
#####################################################

d <- earnings_df %>% 
  filter(gender=="Total") %>% 
  select(-gender) %>% 
  mutate(W= earn, 
         K_gb = if_else(country=="United Kingdom",1,0), 
         K_swe = if_else(country=="Sweden",1,0))

d
18.763-1.97
18.763+4.086

lm(W ~ K_gb + K_swe, data=d)  




#####################################################
### lifespan
#####################################################
life <- read_csv("data/life-expectancy-of-women-vs-life-expectancy-of-men.csv") %>% 
  select(year=Year, 
         country = Entity,
         life_exp_female = "Life expectancy - Sex: female - Age: 0 - Variant: estimates", 
         life_exp_male = "Life expectancy - Sex: male - Age: 0 - Variant: estimates") %>% 
  pivot_longer(life_exp_female:life_exp_male) %>% 
  mutate(gender = case_when(name=="life_exp_male" ~ "Male", 
                            name=="life_exp_female" ~ "Female")) %>% 
  filter(year==2020) %>% 
  select(-name, -year) %>% rename(life_exp = value) 

life
life %>% distinct(country) %>% pull
life %>% colnames



#####################################################
### join earnings & lifespan 
#####################################################
mydf <- life %>% 
  right_join(earn_sex)

mydf$life_exp %>% mean()
mydf$earn %>% mean

mydf <- mydf %>% 
  select(country, gender, life_exp, earn, G) %>% 
  mutate(L = life_exp, 
         I = earn,
         I_t = I - mean(I), 
         L_t = L - mean(L), 
         G_t = G - mean(G),
         ItLt = I_t * L_t, 
         LtGt = L_t * G_t, 
         ItGt = I_t * G_t,
         sum_ItLt = sum(ItLt),
         sum_LtGt = sum(LtGt), 
         sum_ItGt = sum(ItGt),
         It_sq = I_t^2 , 
         Gt_sq = G_t^2 , 
         sum_It_sq = sum(It_sq), 
         sum_Gt_sq = sum(Gt_sq),
         sumItGt_sq = sum(ItGt) ^2
         )

mydf %>% 
  select(starts_with("sum"))

mydf %>% select(L, I, G) %>% map(mean) 

lm(L ~I + G, data= mydf %>% select(L,I,G))

81.66-0.3*19.44-5.33*0.5


a_2 = sum(mydf$ItLt) / sum(mydf$It_sq)
a_1 = mean(mydf$L) - a_2*mean(mydf$I)
a_2
a_1



#####################################################
###### 2 graphs on LifeExp ~ Income
#####################################################

est <- lm(L ~I + G, data= mydf %>% select(L,I,G))
est$coefficients

g_life_inc_gender_1 <- mydf %>% 
  ggplot(aes(y=L, x=I)) + 
  geom_point(aes(shape=as.factor(G)), size=2.5, show.legend = FALSE) + 
  geom_smooth(method="lm", se=FALSE, color="black", linetype="dashed") + 
  labs(y="Life expectancy", x="Earnings, USD PPP") +
  annotate("text", x=c(22,16), y=c(78,85), label=c("Men","Women"), size=3) +
  theme(text=element_text(size=8))

xmin_male= min(mydf %>% filter(G==0) %>% select(I))
xmax_male=max(mydf %>% filter(G==0) %>% select(I))
xmin_women=min(mydf %>% filter(G==1) %>% select(I))
xmax_women= max(mydf %>% filter(G==1) %>% select(I))

g_life_inc_gender_2 <- mydf %>% 
  ggplot(aes(y=L, x=I)) + 
  geom_point(aes(shape=as.factor(G)), size=2.5, show.legend = FALSE) + 
  # reg line men
  geom_function(fun=function(x) est$coefficients[1] + est$coefficients[2]*x, linetype="dashed", linewidth=1, xlim=c(xmin_male, xmax_male)) +
  # reg line women
  geom_function(fun=function(x) est$coefficients[1] + est$coefficients[2]*x + est$coefficients[3], linetype="dashed", linewidth=1, xlim=c(xmin_women, xmax_women)) +
  labs(y="Life expectancy", x="Earnings, USD PPP") +
  annotate("text", x=c(22,16), y=c(78,85), label=c("Men","Women"), size=3) +
  theme(text=element_text(size=8))


(g_life_inc_gender_1 + g_life_inc_gender_2)
(g_life_inc_gender_1 + g_life_inc_gender_2) %>% 
  ggsave(filename="g_life_inc_gender.pdf", width=5, height=3)



#####################################################
### section 19.6
#####################################################
intdf <- mydf %>% 
  select(country, L=life_exp, I=earn, gender) %>% 
  mutate(
    G = if_else(gender=="Male",0,1),
    GI = G*I) %>% 
  select(-gender)

intdf
lm(L~I+G+GI, intdf)


0.3818-0.1427
(0.3818-0.1427) * 365
87.3 / 30



#####################################################
### figure 19.4
#####################################################
lm(L~I, data = intdf %>% filter(G==1))
lm(L~I, data = intdf %>% filter(G==0))


g_194_life_earning_gender_ols <- intdf %>% 
  ggplot(aes(x=I, y=L, group=as.factor(G), shape=as.factor(G))) +
  geom_point(show.legend = FALSE) + 
  geom_smooth(method="lm", se=FALSE, linetype=2, color="black", size=.7) +
  labs(x="Earnings", y="Life expectancy") +
  theme(text=element_text(size=8)) +
  annotate("text", x=c(18,21), y=c(83,80), size=3, 
           label=c("Women","Men"))

g_194_life_earning_gender_ols
g_194_life_earning_gender_ols %>% ggsave(filename="g_194_life_earning_gender_ols.pdf", height=3, width=3)


lm(L~I+G+GI, data=intdf)
lm(L~I, data = intdf %>% filter(G==1))
lm(L~I, data = intdf %>% filter(G==0))
# c1 + c3
71.4732 + 8.1211
# c2 + c4
0.3818 - 0.1427

# diff b and d
0.2391 - 0.3818
