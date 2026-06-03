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

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)


#####################################################################
### uniform continuous
#####################################################################
g_unicont_pdf <- ggplot() +
  annotate("rect", xmin=0, xmax=1, ymax=1, ymin=0, fill="gray") +
  stat_function(fun=function(x) 1, xlim = c(0,1), color="black") +
  xlim(-.2,1.3) + 
  scale_y_continuous(breaks=seq(0,1,.25), labels=seq(0,1,.25), limits=c(0,1.1)) +
  annotate("text", x=1.15, y=1 , size=1.7 , 
           label="f(x)") + 
  theme(text=element_text(size=7)) +
  labs(y="Probability", 
       x="Values of X",
       title="Probability density function")
  
g_unicont_cdf <- ggplot() +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  stat_function(fun=function(x) x, xlim = c(0,1), fill="grey", geom="area") +
  stat_function(fun=function(x) x, xlim=c(0,1), color="black") +
  xlim(-.2,1.3) + 
  scale_y_continuous(breaks=seq(0,1,.25), labels=seq(0,1,.25), limits=c(0,1.1)) +
  annotate("text", x=.5, y=.8, label="F(x)", size=1.7) +
  annotate("text", x=0, y=1.05, size=1.7, hjust=0,
           label="100% cumulative probability") +
  theme(text=element_text(size=7)) +
  labs(y="Cumulative\nprobability", 
       x="Possible values of X", 
       title="Cumulative\ndistribution function")

(g_unicont_pdf + g_unicont_cdf)
(g_unicont_pdf + g_unicont_cdf) %>% 
  ggsave(filename="g_unicont.pdf", width=4.6, height=2.5)


#####################################################################
### exponential continous
#####################################################################
1-pexp(1, rate=3)

g_exponential_pdf <- ggplot() + 
  stat_function(fun=function(x) dexp(x,rate=3)) +
  stat_function(fun=function(x) dexp(x, rate=1), linetype="dashed") +
  xlim(0,5) +
  annotate("text", x=.5, y=2, size=1.7, hjust=0,
           label=TeX("$\\lambda = 3$, boss calls 3 times per hour.")) +
  annotate("text", x=1.5, y=.5, size=1.7, hjust=0,
         label=TeX("$\\lambda = 1$, boss calls 1 time per hour.")) +
  theme(text=element_text(size=8)) +
  labs(y="Probability", 
       x="Possible values of X", 
       title="Probability density function")

g_exponential_cdf <- ggplot() +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  stat_function(fun=function(x) pexp(x, rate=3)) +
  stat_function(fun=function(x) pexp(x, rate=1), linetype="dashed") +
  annotate("text", x=.2, y=.9, size=1.7, hjust=0,
           label=TeX("$\\lambda = 3$")) +
  annotate("text", x=1.5, y=.66, size=1.7, hjust=0,
           label=TeX("$\\lambda = 1$")) +
  annotate("text", x=0, y=1.05, size=1.7, hjust=0,
           label="100% cumulatrive probability") +
  xlim(0,5) + 
  scale_y_continuous(breaks=c(0,.25,.5,.75,1), labels=c(0,.25,.5,.75,1), limits=c(0,1.1)) +
  theme(text=element_text(size=8)) +
  labs(y="Cumulative\nprobability", 
       x="Possible values of X", 
       title="Cumulative distribution function")

(g_exponential_pdf / g_exponential_cdf)  
(g_exponential_pdf / g_exponential_cdf)  %>% 
  ggsave(filename="g_exponential.pdf", width=4.5, height=6)




################################################################################
###  gamma-funktionen
################################################################################
tibble(
  x=1:5,
  y=factorial(x), 
  label = paste0("(",x,",",y,")")
) %>% 
  ggplot(aes(x,y)) + geom_point() +
  geom_line() +
  geom_label_repel(aes(label=label))

################################################################################
### gammafördelningen
# shape = händelse nr k som vi vill beräkna sannolikheten för 
# scale eller rate = theta = genomsnittlig väntetid, i uttrycket beta = 1/theta, 
################################################################################
# pgamma: P( X<x ).
# 1 - pgamma: P( X>x )

1 - pgamma(q=2, scale=1/3, shape=3)


tibble(
  x = 1:3,
  alfa = 3,
  beta = 1/3,
  dgamma=  dgamma(x=x, shape=alfa, scale = beta), 
  pgamma = pgamma(q=alfa, shape=x)
) %>% 

  ggplot(aes(x=x, y=pgamma)) + geom_point() + geom_line()


dgamma(x=1:4, shape=3, rate=1/3)


textsize <- 1.7
  
## pdf gamma
g_gamma_pdf <- ggplot() + 
  stat_function(fun=function(x) dgamma(x=x, shape=3, scale=1/3)) + 
  stat_function(fun=function(x) dgamma(x=x, shape=3, scale=1), linetype="dotted") + 
  stat_function(fun=function(x) dgamma(x=x, shape=3, scale=2), linetype="longdash") + 
  
  annotate("text", x=10, y=.4, size=textsize, hjust=0,
           label=TeX("All lines are drawn with the function $f(x; k, \\theta)$")) +
  annotate("text", x=10, y=.35, size=textsize, hjust=0,
           label=TeX("where $k = 3$ for all lines.")) +
  
  annotate("label", x=4, y=.7, size=textsize,
           label=TeX("$f(x, k, \\theta) = f \\left(x, 3, \\frac{1}{3}\\right)$")) +
  annotate("label", x=5, y=.22, size=textsize, 
           label=TeX("$f(x,3,1)$")) +
  annotate("label", x=10, y=.09, size=textsize, 
           label=TeX("$f(x,3,2)$")) +
  
  ylim(0,.85) +
  scale_x_continuous(breaks=c(0,2,5,10,15,20), labels=c(0,2,5,10,15,20), limits=c(-2,20)) +
  labs(y="Proability", 
       x="Possible values of x, given k = 3", 
       title="Täthetsfunktionen") +
  theme(text=element_text(size=8)) 
  
## cdf gamma
g_gamma_cdf <- ggplot() + 
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  annotate("text", x=-.1, y=1.05, size=1.7, hjust=0,
           label="100 % kumulativ sannolikhet") +
  
  stat_function(fun=function(x) pgamma(q=x, shape=3, scale=1/3)) + 
  stat_function(fun=function(x) pgamma(q=x, shape=3, scale=1), linetype="dotted") + 
  stat_function(fun=function(x) pgamma(q=x, shape=3, scale=2), linetype="longdash") +
  scale_x_continuous(breaks=c(0,2,5,10,15,20), labels=c(0,2,5,10,15,20), limits=c(-2,20)) +
  scale_y_continuous(breaks=seq(0,1,.2), labels=seq(0,1,.2), limits=c(0,1.1)) +
  
  annotate("text", x=10, y=.34, size=textsize, hjust=0,
           label=TeX("All lines are drawn with the function $F(x; k, \\theta)$")) +
  annotate("text", x=10, y=.28, size=textsize, hjust=0,
           label=TeX("where $k = 3$ for all lines.")) +
  
  annotate("label", x=0, y=.8, size=textsize,
           label=TeX("$F\\left(x, 3, \\frac{1}{3}\\right)$")) +
  annotate("label", x=5, y=.75, size=textsize, 
           label=TeX("$F(x, 3, 1)$")) +
  annotate("label", x=7, y=.56, size=textsize, 
           label=TeX("$F(x, 3, 2)$")) +
  
  labs(y="Cumulative\nprobability", 
       x="Possible values of x, given k = 3", 
       title="Cumulative distribution function") +
  theme(text=element_text(size=8))


(g_gamma_pdf/ g_gamma_cdf)
(g_gamma_pdf/ g_gamma_cdf) %>% 
  ggsave(filename="g_gamma.pdf", width=4.5, height=6)




################################################################################
### chi2
# pdf & cdf
################################################################################
g_chi2_pdf <- ggplot() + 
  stat_function(fun=function(x) dchisq(x=x, df=1), aes(linetype="solid")) +
  stat_function(fun=function(x) dchisq(x=x, df=3), aes(linetype="dotted")) +
  stat_function(fun=function(x) dchisq(x=x, df=5), aes(linetype="dashed")) +
  scale_x_continuous(limits=c(0,15)) +
  ylim(0,.5) + 
  scale_linetype_manual("Value for r", 
                        values = c("solid","dotted","dashed"), 
                        breaks = c("solid","dotted","dashed"), 
                        labels = c(1,3,5)) +
  labs(y="Probability", 
       x="Possible values of X", 
       title="Probability density function") +
  theme(text=element_text(size=8), 
        legend.position = c(.7,.7))  

g_chi2_cdf <- ggplot() +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  scale_y_continuous(breaks=c(0,.25,.5,.75,1), labels=c(0,.25,.5,.75,1), limits=c(0,1.1)) +
  annotate("text", x=0, y=1.05, hjust=0, size=1.7, 
           label="100% cumulative probability") +
  
  stat_function(fun=function(x) pchisq(q=x, df=1), aes(linetype="solid")) +
  stat_function(fun=function(x) pchisq(q=x, df=3), aes(linetype="dotted")) +
  stat_function(fun=function(x) pchisq(q=x, df=5), aes(linetype="dashed")) +
  scale_x_continuous(limits=c(0,15)) +
  scale_linetype_manual("Value for r", 
                        values = c("solid","dotted","dashed"), 
                        breaks = c("solid","dotted","dashed"), 
                        labels = c(1,3,5)) +
  labs(y="Cumulative\nprobability", 
       x="Possible values of X", 
       title="Cumulative distribution function") +
  theme(text=element_text(size=8), 
        legend.position = c(.7,.3))

(g_chi2_pdf / g_chi2_cdf)
(g_chi2_pdf / g_chi2_cdf) %>% ggsave(filename="g_chi2.pdf", width=4.5, height=6)

####
qchisq(.05, df=6)
pchisq(1.64, df=6)

pgamma(1.64, shape=3, scale=2)
qgamma(.05, shape=3, scale=2)
####





################################################################################
### chi2 tabell
################################################################################
# Set p-values
p_values <- c(.999, .99, .95, .9, .1, .05, .01, .001) %>% sort
# Set degrees of freedom
the_df_sequence <- seq(1,30)

# Calculate a matrix of chisq statistics
m <- outer( p_values, 
            the_df_sequence, 
            function(x,y) qchisq(x,y)
            )

# Transpose for a better view
m <- t(m)

# Set column and row names
colnames(m) <- p_values
rownames(m) <- the_df_sequence

# Fixa rubriker
library("xtable")
addtorow <- list()
addtorow$pos <- list()
addtorow$pos[[1]] <- 0
addtorow$pos[[2]] <- 0
addtorow$command <- c("\\multicolumn{9}{c}{Proability $P(X \\leq x)$  } \\\\\n",
                      "r & 0.1\\% & 1\\% & 5\\% & 10\\% & 90\\% & 95\\% & 99\\% & 99.9\\% \\\\\n")

# export to latex, and to file
m %>% 
  # align = vertikala linjer
  xtable(
    align = "ll|l|l|l|l|l|l|l",
    digits=c(0,3,3,3,3,3,3,3,3)
    ) %>% 
  # lägg till rubrikerna vi skapade ovan
  print(
    add.to.row = addtorow, 
    include.rownames = TRUE,
    include.colnames = FALSE, 
    #only.contents = TRUE,
    floating=FALSE,
    latex.environments=NULL,
    hline.after=c(-1,0,30),
    file="chi2tabell.tex")







################################################################################
### F-fördelningen
################################################################################
g_pdf_fdistro <- ggplot()+
  stat_function(fun=function(x) df(x, df1=1,df2=10), aes(linetype="solid")) +
  stat_function(fun=function(x) df(x, df1=3,df2=15), aes(linetype="dotted")) +
  stat_function(fun=function(x) df(x, df1=6,df2=40), aes(linetype="dashed")) +
  xlim(0,10) + ylim(0,1) +
  scale_linetype_manual(name=NULL,
                        values = c("solid","dotted","dashed"), 
                        breaks = c("solid","dotted","dashed"), 
                        labels = c("F(1,10)","F(3,15)","F(6,40)")) +
  labs(x="Possible values of X", 
       y="Probability", 
       title="Probability density function" 
       ) +
  theme(text=element_text(size=8), 
        legend.position = c(.7,.7))

g_cdf_fdistro <- ggplot()+
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  scale_y_continuous(breaks=c(0,.25,.5,.75,1), labels=c(0,.25,.5,.75,1), limits=c(0,1.1)) +
  annotate("text", x=0, y=1.05, hjust=0, size=1.7, 
           label="100% cumulative proability") +
  stat_function(fun=function(x) pf(x, df1=1,df2=10), aes(linetype="solid")) +
  stat_function(fun=function(x) pf(x, df1=3,df2=15), aes(linetype="dotted")) +
  stat_function(fun=function(x) pf(x, df1=6,df2=40), aes(linetype="dashed")) +
  xlim(0,10) + 

  scale_linetype_manual(name=NULL,
                        values = c("solid","dotted","dashed"), 
                        breaks = c("solid","dotted","dashed"), 
                        labels = c("F(1,10)","F(3,15)","F(6,40)")) +
  labs(x="Possible values of X", 
       y="Cumulative\nprobability", 
       title="Cumulative distribution function") +
  theme(text=element_text(size=8), 
        legend.position = c(.7,.4))

(g_pdf_fdistro / g_cdf_fdistro)
(g_pdf_fdistro / g_cdf_fdistro) %>% 
  ggsave(filename="g_fdistro.pdf", width=4.5, height=6)



################################################################################
### F-fördelning tabell
################################################################################
p_values <- c(.95,.99)
# Bestäm frihetsgrader 1 och 2
df_1_values <- 1:6 
#%>% c(12,15,20,24,30, 40, 60,120)
df_2_values <- 1:15 %>% c(40,60,120)
  
# Calculate a matrix of  statistics
f_tabell <- df_1_values %>% map_dfr(~{
  # .x <- 1
  column_df <- .x
  df_2_values %>% map_dfr(~{
    row_df <- .x
    tibble(
      df_1 = column_df,
      df_2 = row_df,
      p = p_values, 
      a = c(
      qf(.95 ,column_df,row_df),
      qf(.99 ,column_df,row_df)
      )) %>% 
    return()
  }) %>% return()
}) %>% 
  pivot_wider(names_from=df_1, values_from=a) 


# Fixa rubriker
library("xtable")
addtorow <- list()
addtorow$pos <- list()
addtorow$pos[[1]] <- 0
addtorow$pos[[2]] <- 0
addtorow$command <- c("\\multicolumn{8}{c}{ df 1  } \\\\\n",
                      " df 2 & $P(X \\leq x)$ & 1 & 2 & 3 & 4 & 5 & 6  \\\\\n")
#addtorow$pos[[1]] <- c(5,8,11,14)
#addtorow$command <- "\\\\ \n"

# export to latex, and to file
f_tabell %>% 
  group_by(df_2) %>% 
  mutate(df_2 = if_else(row_number()==2, NA_real_, df_2)) %>% 
  # align = vertikala linjer
  xtable(align = "ll|l|l|l|l|l|l|l", 
         digits=c(0, 0,2, 1,1,1,1,1,1)) %>% 
  # lägg till rubrikerna vi skapade ovan
  print(
    add.to.row = addtorow, 
    include.rownames = FALSE,
    include.colnames = FALSE, 
    #only.contents = TRUE,
    floating=FALSE,
    latex.environments=NULL,
    hline.after=c(-1,0,36),
    file="f_tabell.tex")

