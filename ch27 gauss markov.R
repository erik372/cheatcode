rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("tidydice")
library("scales")
library("ggrepel")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")
conflict_prefer("var", "stats")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

# # använd komma som decimal
# options(OutDec=",")


################################################################################
## heteroskedasticitet
################################################################################
## fejka lite data
set.seed(2)
g_heteroskedasticitet <- tibble(
  x=1:50, 
  y= 2 + x*runif(x)
) %>% 
  mutate(yhat = lm(y~x) %>% predict) %>% 
  ggplot(aes(x,y)) + geom_point() +
  geom_smooth(method="lm", se=FALSE, size=.5, color="black") + 
  geom_segment(aes(xend=x, yend= yhat), alpha=.45, size=.2, linetype='dashed') +
  theme(axis.title.y = element_text(angle=0), 
        text=element_text(size=7)) +
  annotate("text", x=5, y=37, hjust=0, size=2, 
           label="Further to the right in the graph, the distance\nbetween the points and the line is greater.")

g_heteroskedasticitet
g_heteroskedasticitet %>% 
  ggsave(filename="g_heteroskedasticitet.pdf", width=4, height = 3)







########################################################################
### 3d-graf för heteroskedasticitet + normalfördelningar
########################################################################

library("plotly")

### the graph stuff
min <- -300
max <- 300
y2 <- 60
y3 <- y2*2

# kurva 1
df1 <- tibble(x=1,
              y=min:max,
              z=dnorm(min:max, 0, 50))

# övergång
df1.1 <- tibble(x=c(1,1,1,1 ,   2), 
                y=c(min,0,0,0,   y2), 
                z=c(0,0,dnorm(0, 0,50),0, 0))

# kurva 2
df2 <- tibble(x=2,
              y=(min+y2):(max+y2),
              z=dnorm((min+y2):(max+y2), mean=y2, sd=100))

# övergång 2
df2.1 <- tibble(x=c(2,2,2, 3), 
                y=c(y2,y2,y2, y3),
                z=c(0,dnorm(y2,mean=y2,sd=100),0, 0))


# kurva 3
df3 <- tibble(x=3,
              y=(min+y3):(max+y3),
              z=dnorm((min+y3):(max+y3), mean=y3, sd=35))

# sista linjerna
df3.1 <- tibble(x=3, 
                y=c(y3,y3),
                z=c(0,dnorm(y3, y3, 35)) 
                )

# help(package="plotly")

g_heteronorm <- rbind(df1, df1.1,
      df2, df2.1,
      df3, df3.1) %>%  
  plot_ly(x= ~x,y= ~y,z= ~z,
          line=list(width=1, 
                    color="black"),
          type="scatter3d", 
          mode="lines", 
          showlegend=FALSE) %>% 
  
  plotly::layout(scene=list(zaxis=list(title="",
                               showbackground=TRUE,
                               backgroundcolor = "lightgray",
                               showname=FALSE,
                               showgrid=TRUE, 
                               zeroline=TRUE, 
                               showline=TRUE, 
                               showticklabels=FALSE, 
                               range=list(0,.014))
                            , 
                            xaxis=list(title="X",
                                       showgrid=TRUE,
                                       gridcolor="white",
                                       showline=TRUE, 
                                       showticklabels=FALSE)
                            ,
                            yaxis=list(title="Y",
                                       showgrid=TRUE,
                                       gridcolor="white",
                                       zeroline=FALSE, 
                                       showline=TRUE, 
                                       showticklabels=FALSE)
                            ,
                            camera = list(eye = list(x = -1.7, 
                                                     y = 1.3, 
                                                     z = .6) 
                                          )
                            ), 
                 annotations=list(x=20, y=60, z=2,
                                  xshift=-120, yshift=-140,
                                  text="Regression model:\nY = a + b X + V", 
                                  font=list(size=7))
                 # , paper_bgcolor="lightgray"
                 
                 )

g_heteronorm

# Reinstall latest development version which includes the bugfix
devtools::install_github("quinten-goens/plotly.R@fix/kaleido-export-bug")
library("plotly")
library("reticulate")

conda_create("r-reticulate")
use_condaenv("r-reticulate")


# reticulate::py_run_string("import sys")
# Simulate a conda environment to use Kaleido
reticulate::install_miniconda(force=TRUE)
reticulate::conda_install('r-reticulate', 'python-kaleido')
reticulate::conda_install('r-reticulate', 'plotly', channel = 'plotly')
g_heteronorm %>% save_image(file="g_heteronorm.pdf", width=400, height=350)
knitr::plot_crop("g_hetero_normal.pdf")


#install.packages('reticulate')
# reticulate::install_miniconda(force=TRUE)
# reticulate::py_run_string("import sys")
# reticulate::conda_create('r-reticulate', packages = 'python-kaleido')
# reticulate::conda_create('r-reticulate', 'plotly', channel = 'plotly')
#library("reticulate")



################################################################################
### autokorrelation, ex tidsserie bnp
################################################################################
g_residuals <- gdp_historical_data %>% 
  ggplot(aes(y=lny_res, x=year)) + 
  geom_point(size=1) +
  geom_hline(yintercept=0) +
  geom_segment(aes(xend=year, yend=0), alpha=.45, size=.2, linetype='dashed') +
  theme(text=element_text(size=8)) +
  labs(x=element_blank(), 
       y=TeX("Residual $\\hat{e}_t$")) +
  annotate("text", x=1890, y=.9, size=1.8, 
           label="Regressionslinjen för") +
  annotate("text", x=1890, y=.75, size=1.8, 
           label=TeX("$\\ln y = a + b* \\textrm{år}_t +e$")) +
  geom_curve(x=1900, xend=1910, y=.62, yend=.15, curvature=-.2, 
             size=.1,
             arrow = arrow(length=unit(.1, "cm")))


g_rescorr <- gdp_historical_data %>% 
  ggplot(aes(x=lag(lny_res), y=lny_res )) + 
  geom_point(size=1) +
  geom_text_repel(aes(label=year), size=1.8, max.overlaps = 3) +
  geom_smooth(method="lm", se=FALSE, color="black", size=.2, linetype="dashed") +
  labs(x=TeX("Residual $\\hat{e}_t$"), 
       y=TeX("Residual $\\hat{e}_{t-1}$")) +
  annotate("text", x=-.75, y=1.25, size=1.8, hjust=0,
           label=TeX("Årtal för \\hat{e}_t") ) +
  annotate("text", x=-.75, y=1.1, size=1.8, hjust=0,
           label="Regressionslinjen för modell") +
  annotate("text", x=-.75, y=.95, size=1.8, hjust=0,
           label=TeX("$e_t = \\beta e_{t-1} + v_t")) +
    theme(text=element_text(size=8))

(g_residuals + g_rescorr)
(g_residuals + g_rescorr) %>% 
  ggsave(filename = "g_autocorrelation.pdf", width=4.7, height=3)
knitr::plot_crop("g_autocorrelation.pdf")


################################################################################
## acf plot & Durbin Watson test
################################################################################
acf(gdp_historical_data$lny_res, type="correlation")

## durbin watson test
lmtest::dwtest(lm(ln_gdp~year , gdp_historical_data))






################################################################################
### autokorrelation i grupper: exempel Kolada män och kvinnor
################################################################################
### kolada livslängd & inkomst
# medellivslängd: N00923,N00925
# inkomst: N00905

library("rKolada")
library("ggrepel") # AWESOME!!! ggrepel::geom_text_repel

kolada_data <- get_values(kpi=c("N00905","N00923","N00925"), period=2019) %>% 
  filter(municipality_type=="K") %>% 
  mutate(variable= case_when(
    kpi=="N00923" ~ "lifelength_male",
    kpi=="N00925" ~ "lifelength_female",
    kpi=="N00905" ~ "income"
  )) %>% 
  select(-kpi) %>% 

  filter(gender=='T') %>% 
  pivot_wider(names_from=variable, values_from=value) %>% 
  drop_na(income, lifelength_male, lifelength_female) %>% 
  
  mutate(lifelength = (lifelength_male + lifelength_female) /2 ) %>% 
  
  select(year, municipality, income, lifelength) %>% 
  mutate(income = income/1000) %>% 
  
  # pred
  mutate(ypred = lm(lifelength ~ income) %>% predict , 
         est_res = lm(lifelength ~ income) %>% residuals ) 


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
  )


kolada_reg_data  




################################################################################
### Variance-covariance matrix: cov()
################################################################################
mydf <- tibble(
  obs = 1:4,
  y = c(3,2,5,4),
  intercept = c(1,1,1,1),
  x = c(3,4,6,7),
  z = c(1,4,0,1)
  )
mydf

library("sandwich")
lm_3 <- lm(y~x+z, data=mydf)
res1 <- lm_3 %>% residuals
# manuell beräkning av residualerna och varians
y <- c(3,2,5,4)
sum( ((y-predict(lm_3))^2) )

# Varians
var_res <- sum(res1^2)


### Olika versioner av var-kovar-matrisen
# min manuella
X <- mydf %>% select(intercept, x,z) %>% as.matrix
tX <- t(X)
X
tX

X1 <- matrix(1:1, nrow=4, byrow=TRUE)
X1t <- t(X1)
# solve() = inversmatrisen
var_res * solve(tX %*% X)  


### 2 kommandon som båda beräknar samma sak som min manuella
vcov(lm_3)
vcovHC(lm_3, type="const")
# HC0, Whites grundform
vcovHC(lm_3, type="HC0") * 4
# Hc1, Whites justerade 1
vcovHC(lm_3, type="HC1")



### ¨Denna beräkning från SO funkar: 
# https://stackoverflow.com/questions/69406663/how-is-the-result-of-the-vcov-function-in-r-computed
mod    = lm(y ~ x+z, mydf)
#X      = cbind(1, as.matrix(mydf[, -1:3]))
invXtX = solve(crossprod(X))
coef   = invXtX %*% t(X) %*% mydf$y
resid  = mydf$y - (X %*% coef)
df.res = nrow(X) - ncol(X)
manual = invXtX * sum(resid^2)

#n <- nrow(X1)
#varcov1 <- (( t(X-(X1%*% ( (X1t%*%X)/n) )))%*%(X-(X1%*%((X1t%*%X)/n))))/n






### OLS 2 modeller
lm_inc <- lm(lifelength ~ income , data=kolada_reg_data)
lm_inc_gend <- lm(lifelength ~ income + gender, data= kolada_reg_data)

vcov(lm_inc_gend)
vcovHC(lm_inc_gend)









################################################################################
# ols 2: livslängd ~ inkomst + kön
mycofs <- coef(lm(lifelength ~ income + gender , data=kolada_reg_data)) 

kolada_reg_data %>% 
  ggplot(aes(x=income, 
             y=lifelength, 
             label=municipality)) +
  #geom_label() +
  geom_point(aes(shape=gender)) +
  stat_function(fun=function(x) mycofs[[1]] + mycofs[[2]]*x , linetype="dashed") +
  stat_function(fun=function(x) mycofs[[1]] + mycofs[[2]]*x + mycofs[[3]])





################################################################################
## acf plot & Durbin Watson test
################################################################################
# acf( INFOGA RESIDUALERNA HÄR ,  type="correlation")

## durbin watson test
library("lmtest")
dwtest(lm_inc)
dwtest(lm_inc_gend)

the_res <- lm_inc_gend %>% residuals 

tibble(the_res,lag_res = lag(the_res)) %>% 
  ggplot(aes(the_res, lag_res)) + geom_point() + geom_smooth(method="lm")

plot(the_res, lag(the_res))





####### grafer över livslängd = inkomst + kön

# ols 1: livslängd ~ ink
kolada_reg_data %>% 
  ggplot(aes(x=income, 
             y=lifelength)) +
  geom_point(aes(shape=gender)) +
  geom_smooth(method="lm", se=FALSE)












################################################################################
### normalfördelad felterm
################################################################################
### EXEMPEL: Kolada
### kolada livslängd & inkomst
# medellivslängd: N00923,N00925
# inkomst: N00905
library("rKolada")
library("ggrepel") # AWESOME!!! ggrepel::geom_text_repel

kolada_data <- get_values(kpi=c("N00905","N00923","N00925"), period=2019) %>% 
  filter(municipality_type=="K") %>% 
  mutate(variable= case_when(
    kpi=="N00923" ~ "lifelength_male",
    kpi=="N00925" ~ "lifelength_female",
    kpi=="N00905" ~ "income"
  )) %>% 
  select(-kpi) %>% 
  filter(gender=='T') %>% 
  pivot_wider(names_from=variable, values_from=value) %>% 
  drop_na(income, lifelength_male, lifelength_female) %>% 
  
  mutate(lifelength = (lifelength_male + lifelength_female) /2 ) %>% 
  
  select(year, municipality, income, lifelength) %>% 
  mutate(income = income/1000) %>% 
  
  # pred
  mutate(ypred = lm(lifelength ~ income) %>% predict , 
         est_res = lm(lifelength ~ income) %>% residuals ) 



kolada_data %>% arrange(income)

### 2 diagram för kolada
g_gm_kolada1 <- kolada_data %>% 
  
  ggplot(aes(y=lifelength, x=income)) + 
  geom_point(size=.8) +
  geom_smooth(method="lm", se=FALSE, 
              size=.1, 
              color="black"
              ) +
  geom_segment(aes(xend=income, yend= ypred), alpha=.45, size=.2, linetype='dashed') +
  geom_text_repel(aes(label=if_else(income>350 | est_res <= -2, 
                                    municipality  ,  "")), size=2, 
                  max.overlaps = 3,
                  nudge_y=-.5 , 
                  nudge_x=20,
                  point.padding = .2) +
  labs(x="Livslängd", 
       y="Inkomst") +
  theme(text=element_text(size=8)) +
  annotate("text", x=200, y=85.5, size=1.8, hjust=0,
           label="Samvariationen mellan inkomst\noch livslängd i Sveriges 290 kommuner"
           )


g_gm_kolada2 <- kolada_data %>% 
  ggplot(aes(x=est_res)) + 
  geom_histogram(aes(y=..density..), 
                 fill="gray", color="black") +
  labs(x=TeX("Residual $\\hat{e}_t$"), 
       y="Andel") +
  theme(text=element_text(size=8)) +
  stat_function(fun=dnorm, args=c(0,var(kolada_data$est_res)))

var(kolada_data$est_res)


(g_gm_kolada1 + g_gm_kolada2)
(g_gm_kolada1 + g_gm_kolada2) %>% 
  ggsave(filename="g_gm_kolada.pdf", width=4.7, height=3)
knitr::plot_crop("g_gm_kolada.pdf")







################################################################################
### Generalized least squares, GLS
################################################################################
library("nlme")
# gls()
# lm()
mydf <- tibble(
  y = c(3,2,5,4),
  x = c(3,4,6,7)
)
mydf

g1 <- lm(y~x , mydf) 
g2 <- gls(y~x, mydf, weights= ~x) 
stargazer(g1, g2, type="text")






"kolada_data
lm(lifelength ~income, kolada_data) %>% summary
gls(lifelength ~income, data=kolada_data, 
    weights= ~income) %>% summary
"


