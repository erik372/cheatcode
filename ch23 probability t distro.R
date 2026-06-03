rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("tidydice")
library("scales")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# ej vetenskapligt format
options(scipen=999)

# # använd komma som decimal
# options(OutDec=".")


################################################################################
### pdf cdf t-fördelningen
################################################################################
g_pdf_tdistro <- ggplot() + 
  stat_function(fun=function(x) dt(x,1), aes(linetype="solid")) +
  stat_function(fun=function(x) dt(x,3), aes(linetype="dashed")) +
  stat_function(fun=function(x) dt(x,10), aes(linetype="dotted")) +
  scale_x_continuous(breaks=-4:4, 
                     labels=-4:4,
                       limits = c(-4,4)) +
  scale_linetype_manual(name=NULL,
                          breaks = c("solid","dashed","dotted"), 
                          values = c("solid","dashed","dotted"), 
                          labels = c("t(1)","t(3)","t(10)")) +
  labs(x="Standard deviations from mean 0", 
       y="Probability", 
       title="Probability density function") +
  theme(text=element_text(size=7), 
        axis.title.y=element_text(angle=0), 
        legend.position = c(.8,.8))

g_cdf_tdistro <- ggplot()+
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  scale_y_continuous(breaks=c(0,.25,.5,.75,1), labels=c(0,.25,.5,.75,1), limits=c(0,1.1)) +
  annotate("text", x=-10, y=1.05, hjust=0, size=1.7, 
           label="100% probability") +
  stat_function(fun=function(x) pt(x,1), aes(linetype="solid")) +
  stat_function(fun=function(x) pt(x,3), aes(linetype="dotted")) +
  stat_function(fun=function(x) pt(x,10), aes(linetype="dashed")) +
  scale_x_continuous(breaks=-4:4, 
                     labels=-4:4, 
                     limits = c(-4,4)) +
  
  scale_linetype_manual(name=NULL,
                        breaks = c("solid","dashed","dotted"), 
                        values = c("solid","dashed","dotted"), 
                        labels = c("t(1)","t(3)","t(10)")) +
  labs(x="Standard deviations from mean 0", 
       y="Cumulative\nprobability", 
       title="Cumulative distribution function") +
  theme(text=element_text(size=7), 
        axis.title.y=element_text(angle=0), 
        legend.position = c(.8,.4))

(g_pdf_tdistro / g_cdf_tdistro)

(g_pdf_tdistro / g_cdf_tdistro) %>% 
  ggsave(filename="g_t_distro.pdf",  width=4.5, height=6)

################################################################################
### t-fördelning tabell
################################################################################
# Set p-values
p_values <- c(.1, .075, .05, .025, .01, .001)
# Set degrees of freedom
the_dfs <- seq(1,30)
the_dfs <- the_dfs %>% c(40,80,120, Inf)


# Calculate a matrix 
m_1sided <- outer( p_values, the_dfs, 
                   function(x,y) qt(1- x,y) )
m_2sided <- outer( p_values, the_dfs, 
                   function(x,y) qt(1- x/2,y) )


# Transpose for a better view
m_1sided <- t(m_1sided)
m_2sided <- t(m_2sided)

# Set column and row names
colnames(m_1sided) <- p_values
the_dfs <- the_dfs %>% as.character()
the_dfs[34] <- "$\\infty$"
rownames(m_1sided) <- the_dfs
colnames(m_2sided) <- p_values
rownames(m_2sided) <- the_dfs

m_1sided
m_2sided

# Fixa rubriker
library("xtable")
addtorow <- list()
addtorow$pos <- list()
addtorow$pos[[1]] <- 0
addtorow$pos[[2]] <- 0
addtorow$command <- c("\\multicolumn{7}{c}{Probability $P(X \\leq x)$} \\\\\n",
                      "k & 90\\% & 92.5\\% &  95\\% &  97.5\\% &  99\\% &  99.9 \\% \\\\\n")

# export to latex, and to file
m_1sided %>% 
  # align = vertikala linjer
  xtable(align = "ll|l|l|l|l|l") %>% 
  # lägg till rubrikerna vi skapade ovan
  print(
    add.to.row = addtorow, 
    include.rownames = TRUE,
    include.colnames = FALSE, 
    #only.contents = TRUE,
    floating=FALSE,
    latex.environments=NULL,
    hline.after=c(-1,0,34),
    sanitize.text.function = function(x) {x},
    file="t_1sided_tabell.tex")

# export to latex, and to file
m_2sided %>% 
  # align = vertikala linjer
  xtable(align = "ll|l|l|l|l|l") %>% 
  # lägg till rubrikerna vi skapade ovan
  print(
    add.to.row = addtorow, 
    include.rownames = TRUE,
    include.colnames = FALSE, 
    #only.contents = TRUE,
    floating=FALSE,
    latex.environments=NULL,
    hline.after=c(-1,0,33),
    file="t_2sided_tabell.tex")


################################################################################
### t-test
################################################################################
  men=c(435,275, 279)
  women=c(313,219,211)
x <- men - women
x
mean(x)
sqrt(sum((x-mean(x))^2)/2)
sd(x)

82/(sd(x)/sqrt(3))
t.test(x)


## lite annat grejs
x <- c(3,4,6,7)
y <- c(3,2,5,4)
sd(x)
sd(y)
cov(
(x - mean(x)) / sd(x),
(y - mean(y)) / sd(y)
)



x <- c(435,275,279)
y <- c(313,219,211)
t.test(x, mu=mean(y))



################################################################################
### t-test, 2-sidigt
################################################################################
g_t_2side <- ggplot() +
  stat_function(fun=function(x) dt(x, df=5), xlim = c(-4,-2.02), fill="grey", geom="area") +
  stat_function(fun=function(x) dt(x, df=5), xlim = c(2.02,4), fill="grey", geom="area") +
  stat_function(fun=function(x) dt(x, df=5)) +
  annotate("text", x=c(-2.1,2.1), y=0.11, size=1.6, hjust=c(1,0),
           label="5% of\nthe distribution") +
  geom_segment(aes(x=c(-2,2), xend=c(-2,2), y=0, yend=.1), linetype="dashed") +
  
  geom_segment(aes(x=c(-2.2,2.2), xend=c(-3,3), y=.08, yend=.08), size=.1,
               arrow=arrow(length=unit(.1, 'cm'))) +
  geom_segment(aes(x=0, xend=0, y=0, yend=dt(0, df=5)), linetype="dashed") +
  
  annotate("text",x=1.3, y=.35, size=1.6, hjust=0, 
           label="The line describes the probability density function f(x)\nfor the t-distribution with 5 degrees of freedom t(5)") +
    
  scale_x_continuous(breaks=c(-4,-3, -2.02, -1, 0, 1, 2.02, 3,4), 
                     labels=c(-4,-3, -2.02, -1, 0, 1, 2.02, 3,4), limits=c(-4,4)) +
  ylim(0,.4) +
  theme(text=element_text(size=7)) +
  labs(x="x", 
       y="Probability")

g_t_2side
g_t_2side %>% 
  ggsave(filename="g_t_2side.pdf", width=4.5, height=3)


################################################################################
#### konfidensintervall
################################################################################
conf <- 2.13*(3.546 / sqrt(5))
6-conf
6+conf

konf <- 2.92*(35.157/sqrt(3))
82 - konf
82 + konf
