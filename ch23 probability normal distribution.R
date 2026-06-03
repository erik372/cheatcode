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

options(scipen=999)

# # använd komma som decimal
# options(OutDec=",")



############################################################################
### illustrera 4 exempel på verkliga variabler
############################################################################

############################################################################
### NBA poäng per match
#install.packages("devtools")
# devtools::install_github("abresler/nbastatR", force=TRUE)
# install.packages("nbastatR")
library("nbastatR")
# help(package="nbastatR")

nba_raw <- game_logs(seasons=2000:2019, result_types="team", nest_data=TRUE)

# summera poäng per match
nba_raw <- nba_raw %>% 
  group_by(idGame) %>% 
  mutate(gamescore = sum(ptsTeam)) 
  
nba_raw %>% filter(gamescore>320)

# ta bort 1 inställd match
nba_df <- nba_raw %>% 
  filter(gamescore>0) %>% 
  select(gamescore) %>% 
  unique 

nba_df %>% summary
nba_df <- nba_df %>% ungroup %>% select(gamescore)

g_nba_normal <- nba_df %>% 
  ggplot(aes(x=gamescore)) + 
  geom_histogram(aes(y = ..density..), fill="gray45") +
  stat_function(fun=function(x) dnorm(x, mean=mean(nba_df$gamescore), sd=sd(nba_df$gamescore))) +
  annotate("text", x=329, y=.0066, size=1, angle=90, 
           label="Trae Young\n49 points") +
  geom_segment(x=329, xend=329, y=.004, yend=.002, 
              size=.1,
               arrow=arrow(length=unit(.1,'cm')) )  +
  theme(text=element_text(size=7)) +
  labs(x="Points per games", 
       y="Share of games,\n1999/2000 - 2018/2019")

g_nba_normal





###############################################################################
## Fångar i Students dataset
library("datasets")
# help(package="datasets")
criminals <- datasets::crimtab %>% 
  colSums %>% 
  as_tibble(rownames="length") %>% 
  mutate(length = as.numeric(length)) %>% 
  rename(n_prisoners = value)


library("vcdExtra")
c_df <- criminals %>% expand.dft(freq="n_prisoners")  
  # expand... använder comma som output
  # mutate(length = as.numeric(str_replace(length, ",",".")))


g_criminals_normal <- c_df %>% 
  ggplot(aes(x=length)) + 
  geom_histogram(aes(y=..density..), 
                 bins=22, 
                 fill="gray61") +
  stat_function(fun=function(x) dnorm(x, mean=mean(c_df$length, na.rm=TRUE), sd=sd(c_df$length, na.rm=TRUE))) +
  labs(x="Length, cm", 
       y="Share of prisoners") +
  theme(text=element_text(size=7))
        

g_criminals_normal        

###############################################################################        
### Kolada  
# library("remotes")
# remotes::install_github("LCHansson/rKolada")
library("rKolada")
library("ggrepel") # AWESOME!!! ggrepel::geom_text_repel

## kolada livslängd & inkomst
# medellivslängd: N00923,N00925
# inkomst: N00905
kolada_data <- 
  get_values(kpi=c("N00905","N00923","N00925"), period=2019) %>% 
  filter(municipality_type=="K") %>% 
  mutate(variable= case_when(
    kpi=="N00923" ~ "lifelength_male",
    kpi=="N00925" ~ "lifelength_female",
    kpi=="N00905" ~ "income"
  ))

# ej normalfördelad
# kolada_data %>% filter(variable=="income", gender=="T") %>% ggplot(aes(x=value)) + geom_histogram()


### livslängd kvinnor och män
kolada_graf_df <- kolada_data %>% 
  filter(variable!="income") %>%
  group_by(variable) %>% 
  mutate(groupmean = mean(value), 
         groupsd = sd(value)) %>% ungroup 

the_means <- kolada_graf_df %>% select(groupmean) %>% unique %>%  pull
the_sd <- kolada_graf_df %>% select(groupsd) %>% unique %>% pull  

the_means ; the_sd

temp_df <- kolada_data %>% filter(variable!="income") %>%
  select(value, variable, municipality) %>% 
  pivot_wider(names_from=variable)

life_male <- temp_df$lifelength_male
life_female <- temp_df$lifelength_female

library("BSDA")

z.test( x=life_male, 
        y=life_female, 
        sigma.x=sd(life_male), 
        sigma.y=sd(life_female), 
        alternative="two.sided")

(mean(life_male) - mean(life_female)) /
    sqrt((var(life_male) / length(life_male))+(var(life_female)/length(life_female))
  )

1.289 ^ 2

g_lifelength_normal <- kolada_graf_df %>%  
  # graf
  ggplot(aes(x=value, fill=variable)) + 
  geom_histogram(aes(y=..density..), position = "identity", alpha = .8) + 
  scale_fill_manual(values=c("gray50",
                             "gray75"))  +
  #  * 110 
  # * 114 
  stat_function(fun=function(x) dnorm(x, mean=the_means[1], sd=the_sd[1] ), xlim=c(76,85) ) +
  stat_function(fun=function(x) dnorm(x, mean=the_means[2], sd=the_sd[2] ), xlim=c(80,88) ) +
  
  annotate('text', x=78, y=.36, size=2, hjust=0,
           label="Men") +
  annotate('text', x=86.6, y=.36, size=2, hjust=1,
           label="Women") +
  theme(text=element_text(size=7), 
        legend.position = 'none') +
  scale_x_continuous(breaks=seq(74,88,2), labels=seq(74,88,2)) +
  labs(x="Life expectancy,\nmean per municipality", 
       y="Share of Swedish\nmunicipalities")
  
g_lifelength_normal



kolada_graf_df %>%  
  # graf
  ggplot(aes(x=value, fill=variable)) + 
  geom_histogram(aes(y=..density..), position = "identity", alpha = .8) + 
  scale_fill_manual(values=c("gray50",
                                     "gray75"))  +
  stat_function(fun=function(x) dnorm(x, mean=the_means[1], sd=the_sd[1] ), xlim=c(76,85) ) +
  stat_function(fun=function(x) dnorm(x, mean=the_means[2], sd=the_sd[2] ), xlim=c(80,88) ) 
  


###############################################################################
### böcker i biblioteken: N09802
kolada_books <- 
  get_values(kpi="N09802", period=2019) %>% 
  filter(municipality_type=="K") %>% 
  mutate(variable="n books per capita") 

g_koladabooks_normal <- kolada_books %>% 
  filter(value!=0) %>% 
  ggplot(aes(x=log(value))) + 
  geom_histogram(aes(y=..density..)) +
  labs(x="Number of books per citizen,\nlog values", 
       y="Share of Swedish municipalities") +
  stat_function(fun=function(x) dnorm(x, 
                                      mean=mean(log(kolada_books$value), na.rm=TRUE),
                                      #  * 30
                                      sd=sd(log(kolada_books$value), na.rm=TRUE) ) , xlim=c( 0,3)) +
  theme(text=element_text(size=7), 
        legend.position = 'none') 
  



###############################################################################
###### De fyra diagrammen
###############################################################################
g_normala <- (((g_criminals_normal +ggtitle("Prisoner length")) + 
                 (g_nba_normal + ggtitle("NBA scores"))) / 
                ((g_lifelength_normal + ggtitle("Life expectancy per municipality")) + 
                   (g_koladabooks_normal + ggtitle("Books on library"))))
g_normala
g_normala %>% 
  ggsave(filename="g_normala_exempel.pdf", width=4.5, height = 5.2)

knitr::plot_crop("g_normala_exempel.pdf")





############################################################################
### illustrera 3 teoretiska exempel
############################################################################
g_pdf_3_normal <- ggplot() + 
  stat_function(fun=dnorm, linetype='dotted') +
  stat_function(fun=dnorm, args=list(mean=.5, sd=.6)) +
  stat_function(fun=dnorm, args=list(mean=-1, sd=1.5), linetype='dashed') +
  xlim(-5,5) +
  annotate('text', x=2, y=.62, size=2, hjust=0,
           label="Mean: 0.5\nStandard deviation: 0,6") +
  annotate('text', x=-1.5, y=.47, size=2, hjust=1,
           label="Mean: 0\nStandard deviation: 1") +
  annotate('text', x=-2.5, y=.32, size=2, hjust=1,
           label="Mean: -1\nStandard deviation: 1.5") +
  geom_curve(aes(x=-3.2, y=.26, xend=-2.6, yend=.2), 
             curvature=.3, arrow=arrow(length=unit(.2,'cm'))) +
  geom_curve(aes(x=-1.8, y=.42, xend=-1.1, yend=.35), 
             curvature=.3, arrow=arrow(length=unit(.2,'cm'))) +
  geom_curve(aes(x=2.5, y=.57, xend=1.6, yend=.5), 
             curvature=-.3, arrow=arrow(length=unit(.2,'cm'))) +
  labs(x=NULL, 
       y="Proability",
       title="Probability density function") +
  theme(text=element_text(size=7))

g_cdf_3_normal <- ggplot() +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  annotate("text", x=-4, y=1.05, hjust=0, size=1.7, 
           label="100% cumulative probability") +
  stat_function(fun=pnorm, linetype='dotted') +
  stat_function(fun=pnorm, args=list(mean=.5, sd=.6)) +
  stat_function(fun=pnorm, args=list(mean=-1, sd=1.5), linetype='dashed') +
  xlim(-5,5) +
  annotate('text', x=2, y=.66, size=2, hjust=0,
           label="Mean: 0.5\nStandard deviation: 0.6") +
  annotate('text', x=-1.5, y=.5, size=2, hjust=1,
           label="Mean: 0\nStandard deviation: 1") +
  annotate('text', x=-2.5, y=.35, size=2, hjust=1,
           label="Mean: -1\nStandard deviation: 1.5") +
  geom_curve(aes(x=-3.2, y=.26, xend=-2.6, yend=.2), 
             curvature=.3, arrow=arrow(length=unit(.2,'cm'))) +
  geom_curve(aes(x=-1.8, y=.42, xend=-1.1, yend=.35), 
             curvature=.3, arrow=arrow(length=unit(.2,'cm'))) +
  geom_curve(aes(x=2.5, y=.57, xend=1.6, yend=.5), 
             curvature=-.3, arrow=arrow(length=unit(.2,'cm'))) +
  labs(x=NULL, 
       y="Cumulative\nprobability",
       title="Cumulative distribution function") +
  theme(text=element_text(size=7))


(g_pdf_3_normal / g_cdf_3_normal)

(g_pdf_3_normal / g_cdf_3_normal) %>% 
  ggsave(file="g_normal_1.pdf", width=4.5, height = 6)




################################################################################
### standard normal, med std.dev
################################################################################
x_values_for_sd <- seq(-4,4,1)
no_x_values <- length(x_values_for_sd)

g_pdf_standardnormal <- ggplot() +
  stat_function(fun=dnorm) + 
  ylim(0,.5) +
  scale_x_continuous(breaks=-4:4, labels=-4:4, limits=c(-4,4)) +
  
  # vertikala linjer
  geom_segment(aes(y=dnorm(x=x_values_for_sd, mean=0, sd=1) , 
                   yend=rep(0,each= no_x_values), 
                   x=x_values_for_sd, 
                   xend=x_values_for_sd), 
               linetype="dotted"
               ) +
  
  annotate('text', x=0, y=.45, size=2,  
           label="Mean") +
  
  # pil 1
  geom_segment(aes(x=-1, xend=1, y=.13, yend=.13), size=.1,
               arrow=arrow(length=unit(.1, 'cm'), ends="both")) +
  annotate('label', x=0, y=.13, size=1.7, 
           label=paste0(round((pnorm(1)-pnorm(-1))*100,1), "%")) +
  # pil 2
  geom_segment(aes(x=-2, xend=2, y=.05, yend=.05), size=.1,
               arrow=arrow(length=unit(.1, 'cm'), ends="both")) +
  annotate('label', x=0, y=.05, size=1.7, 
           label=paste0(round((pnorm(2)-pnorm(-2))*100,1), "%")) +
  # pil 3
  geom_segment(aes(x=-3, xend=3, y=.005, yend=.005), size=.1,
               arrow=arrow(length=unit(.1, 'cm'), ends="both")) +
  annotate('label', x=0, y=.005, size=1.7, 
           label=paste0(round((pnorm(3)-pnorm(-3))*100,1), "%")) +
  
  theme(text=element_text(size=7)) +
  labs(y="Probability", 
       x="Standard deviations from mean 0", 
       title="Probability density function") 

  
pnorm(1) - pnorm(-1)

g_cdf_standardnormal <- ggplot() +
  geom_hline(yintercept = 1, size=.3, alpha=.2) +
  # grå yta
  stat_function(fun=function(x) pnorm(x,0,1), xlim=c(-4,1), geom="area", fill="gray") +
  # cdf-linjen
  stat_function(fun=pnorm) + 
  scale_y_continuous(breaks=seq(0,1,.1), labels=seq(0,1,.1), limits=c(0,1.1)) +
  scale_x_continuous(breaks=-4:4, labels=-4:4, limits=c(-4,4)) +
  
  # vertikala linjer
  geom_segment(aes(y=pnorm(q=x_values_for_sd %>% setdiff(1), mean=0, sd=1) , 
                   yend=rep(0,each= no_x_values-1 ), 
                   x=x_values_for_sd %>% setdiff(1), 
                   xend=x_values_for_sd %>% setdiff(1)), 
               linetype="dotted"
  ) +
  geom_segment(aes(y=pnorm(1,0,1) +.05, yend=0, x=1, xend=1), linetype="dashed") +
  
  annotate("text", x=.8, y=.9, hjust=1, size=1.7, 
             label=paste0("F(x) at 1 standard deviation 
             over mean = " ,round(pnorm(1)*100, 1) , " %
                          = cumulative probability.")) +
  annotate("text", x=-4, y=1.05, hjust=0, size=1.7, 
           label="100% cumulative probability") +
  
  theme(text=element_text(size=7)) +
  labs(y="Cumulative\nproability", 
       x="Standard deviations from mean 0", 
       title="Cumulative distribution function") 


(g_pdf_standardnormal / g_cdf_standardnormal)

(g_pdf_standardnormal / g_cdf_standardnormal) %>% 
  ggsave(file="g_standardnormal.pdf", width=4.5, height=6)







################################################################################
### normalfördelningens tabell
################################################################################
# alla decimaler för z
z_values <-  seq(0,3.09,by=0.01)
# p-värdena
p <- pnorm(z_values)
# matris
normal_matrix <- matrix(p, ncol=10, byrow=TRUE) 
rownames(normal_matrix)=seq(0,3,b=.1)
colnames(normal_matrix)=seq(0,.09,by=.01)

# Fixa rubriker
library("xtable")
addtorow <- list()
addtorow$pos <- list()
addtorow$pos[[1]] <- 0
addtorow$pos[[2]] <- 0
addtorow$command <- c("\\multicolumn{11}{c}{Second decimal of z} \\\\\n",
                      "z & 0 & 0,01 & 0,02 & 0,03 & 0,04 & 0,05 & 0,06 & 0,07 & 0,08 & 0,09 \\\\\n")

# export to latex, and to file
normal_matrix %>% 
  # align = vertikala linjer, lika många som kolumner
  xtable(align = "ll|l|l|l|l|l|l|l|l|l", 
         digits=4) %>% 
  # lägg till rubrikerna vi skapade ovan
  print(
    add.to.row = addtorow, 
    include.rownames = TRUE,
    include.colnames = FALSE, 
    #only.contents = TRUE,
    floating=FALSE,
    latex.environments=NULL,
    hline.after=c(-1,0,31),
    file="normal_tabell.tex")



################################################################################
### central limit theorem
### centrala gränsvärdessatsen
### simulering
################################################################################
set.seed(3)
pop1 <- c(runif(3333),  
          runif(3333, 1,4),
          runif(3334,4,5)) 
pop2 <- rchisq(10000, 1)
pop3 <- rbeta(10000, 50,1)
pop4 <- c(runif(3333, 0.8,1), 
          runif(3333, 3.5,3.6), 
          runif(3334,11.4,11.45))


# samples
n <- 10000
sampsize <- 300
xbar1 <- xbar2 <- xbar3 <- xbar4 <- rep(NA, n)
for(i in 1:n) {
  xbar1[i] <- sample(pop1, size=sampsize) %>% mean()
  xbar2[i] <- sample(pop2, size=sampsize) %>% mean()
  xbar3[i] <- sample(pop3, size=sampsize) %>% mean()
  xbar4[i] <- sample(pop4, size=sampsize) %>% mean()
}

g_pops <- tibble(pop1,pop2,pop3,pop4) %>% 
  pivot_longer(everything()) %>% 
  ggplot(aes(x=value, fill=name)) + 
  geom_histogram(bins=50, color="gray35") +
  labs(x="Value", 
       y="Number of values") + 
  theme(text=element_text(size=7), legend.position = "none") +
  facet_wrap(~name, scales='free', ncol=1, 
             labeller = labeller(name=c(pop1="Population X", 
                                        pop2="Population Y", 
                                        pop3="Population Z", 
                                        pop4="Population W"))) +
  scale_fill_manual(values=c("gray20","gray40","gray60","gray80")) +
  scale_y_continuous(labels=function(x) format(x, big.mark=",", big.interval=3, scientific = FALSE))

g_sampl  <- tibble(xbar1, xbar2, xbar3, xbar4) %>% 
  pivot_longer(everything()) %>% 
  ggplot(aes(x=value, fill=name)) + 
  geom_histogram(bins=50, color="gray35") + 
  labs(x="Value",
       y="Number of values") +
  theme(text=element_text(size=7), legend.position = "none") +
  facet_wrap(~name, scales="free", ncol=1, 
             labeller = labeller(name=c(xbar1="Sample X", 
                                        xbar2="Sample Y", 
                                        xbar3="Sample Z", 
                                        xbar4="Sample W"))) +
  scale_fill_manual(values=c("gray20","gray40","gray60","gray80")) +
  scale_y_continuous(labels=function(x) format(x, big.mark = ",", big.interval=3, scientific = FALSE)) 

(g_pops + g_sampl)
(g_pops + g_sampl) %>% 
  ggsave(filename="g_clt_simulation.pdf", height=6.1, width=4.5)

  



# leka med tärningar
set.seed(3)
replicate(5, sample(1:6, size=2, replace=TRUE) %>% sum() ) %>% sum
pchisq(30/7, df=4)
pchisq(33/7, df=4)

replicate(30, sample(1:6, size=2, replace=TRUE) %>% sum() ) %>% sum
pchisq(409/7, df=30)


#####################################################################
### central limit theorem
#####################################################################
### CLT COIN TOSS
set.seed(3)

clt_coins <- function(n_coins, n_reps)  {
  replicate(n_reps , sample(0:1, size = n_coins, replace=TRUE) %>% mean) %>% table %>% 
    data.frame %>% 
    ggplot(aes(., Freq)) + geom_col(width=.3) + 
    theme(text=element_text(size=7)) +
    scale_x_discrete(breaks=seq(0,1,.1),
                     labels=seq(0,1,.1) ) +
    scale_y_continuous(labels=scales::comma ) +
    labs(y="Number of results")
}

g_clt_1coin <- clt_coins(1,100000) +
  labs(x="Heads (0) or tails (1)",
       subtitle="1 value per result")

g_clt_4coins <- clt_coins(4,100000) +
  labs(x="Mean",
       subtitle="4 values per mean")

g_clt_20coins <- clt_coins(20,100000) +
  labs(x="Mean",
       subtitle="20 values per mean")

g_clt_100coins <- clt_coins(200,100000)+
  labs(x="Mean",
       subtitle="200 values per mean")

((g_clt_1coin + g_clt_4coins) / (g_clt_20coins + g_clt_100coins) )

((g_clt_1coin + g_clt_4coins) / (g_clt_20coins + g_clt_100coins) ) %>% 
  ggsave(file="g_clt_100coins.pdf",  width=4.5, height=5)


#####################################################################
### CLT DICES 
#####################################################################
set.seed(3)
rolldice <- function(n_dices){
  #n_dices <- 8
  replicate(100000, 
            sample(1:6, size=n_dices, replace=TRUE) %>% sum()
            ) %>% table() %>% as_tibble() %>% 
    rename(Results =".", 
           Frequency ="n") %>% 
    mutate(Results = as.numeric(Results)) %>% 
    
    ggplot(aes(x=Results, y=Frequency)) + 
    geom_col() +
    scale_x_continuous(n.breaks=8
                       #breaks=seq(n_dices, n_dices*6, 6)
                       ) +
    scale_y_continuous(labels=function(x) format(x, big.mark = " ", scientific = FALSE)) +
    theme(text=element_text(size=6)) +
    labs(title=paste0(n_dices, " dices"))
}



#for(i in 1:10) {
#  rolldice(i) %>% ggsave(file=paste0("g_clt_",i,"dices.pdf"), width=2.5, height=2.5)
#}  

g_clt_dices <- 
  ((rolldice(1) + ggtitle("1 dice")) + rolldice(2)) / 
  (rolldice(4) + rolldice(8))

g_clt_dices
g_clt_dices %>% ggsave(file="g_clt_dices.pdf",  width=4.5, height=5)






#####################################################################
### NORMALFÖRDELNINGENS ANVÄNDBARTHET 2
#####################################################################
### central limit theorem
### CLT COIN TOSS
#####################################################################
set.seed(3)

clt_coins <- function(n_coins, n_reps)
{
  replicate(n_reps , sample(0:1, size = n_coins, replace=TRUE) %>% mean) %>% table %>% 
    data.frame %>% 
    ggplot(aes(., Freq)) + geom_col(width=.3) + 
    theme(text=element_text(size=7)) +
    scale_x_discrete(breaks=seq(0,1,.1),
                     labels=seq(0,1,.1)) +
    scale_y_continuous(labels=function(x) format(x, big.mark = ",", big.interval=3, scientific = FALSE)) +
    labs(y="Number of results")
}

g_clt_1coin <- clt_coins(1,100000) +
  labs(x="Heads (0) or tails (1)",
       subtitle="1 value per result")

g_clt_4coins <- clt_coins(4,100000) +
  labs(x="Mean",
       subtitle="4 values per mean")

g_clt_20coins <- clt_coins(20,100000) +
  labs(x="Mean",
       subtitle="20 values per mean")

g_clt_100coins <- clt_coins(200,100000)+
  labs(x="Mean",
       subtitle="200 values per mean")

( (g_clt_1coin + g_clt_4coins) / (g_clt_20coins + g_clt_100coins) )

( (g_clt_1coin + g_clt_4coins) / (g_clt_20coins + g_clt_100coins) ) %>% 
  ggsave(file="g_clt_100coins.pdf",  width=4.5, height=5)




#####################################################################
### CLT DICES 
#####################################################################
set.seed(3)
rolldice <- function(n_dices){
  #n_dices <- 8
  replicate(100000, 
            sample(1:6, size=n_dices, replace=TRUE) %>% sum()
  ) %>% table() %>% as_tibble() %>% 
    rename(Results =".", 
           Frequency ="n") %>% 
    mutate(Results = as.numeric(Results)) %>% 
    
    ggplot(aes(x=Results, y=Frequency)) + 
    geom_col() +
    scale_x_continuous(n.breaks=8
                       #breaks=seq(n_dices, n_dices*6, 6)
                       ) + 
    scale_y_continuous(labels=function(x) format(x, big.mark=",", big.interval=3, scientific = FALSE)) +
    theme(text=element_text(size=6)) +
    labs(title=paste0(n_dices, " dices"), 
         x="Sum of points", 
         y="Number of results")
}



#for(i in 1:10) {
#  rolldice(i) %>% ggsave(file=paste0("g_clt_",i,"dices.pdf"), width=2.5, height=2.5)
#}  

g_clt_dices <- 
  ((rolldice(1) + ggtitle("1 dice")) + rolldice(2)) / 
  (rolldice(4) + rolldice(8))

g_clt_dices
g_clt_dices %>% ggsave(file="g_clt_dices.pdf",  width=4.5, height=5)







########################################################################
### 3d graf för bivariat normalfördelning
########################################################################
y <- x <- seq(-3,3,length=25)
fun <- function(x,y) { return(dnorm(x) * dnorm(y)) }
z <- outer(x,y,fun)
# graf
pdf(file="g_xy_norm1.pdf", width=4, height=4)
persp(x,y,z, zlim=c(0,.3),
      xlab="\n\nx,\nstandardized\nnormal distribution", 
      ylab="\n\ny,\nstandardized\nnormal distribution", 
      zlab="\n\nz = P(X=x,Y=y) = f(x,y)", 
      theta=45, cex.lab=.5,
      # phi=45,
      r=3)
dev.off()
pdf(file="g_xy_norm2.pdf", width=4, height=4)
persp(x,y,z, zlim=c(0,.3),
      xlab="\n\nx,\nstandardized\nnormal distribution", 
      ylab="\n\n\n\ny", 
      zlab="\n\nz = P(X=x,Y=y) = f(x,y)", 
      theta=0, phi=0, 
      cex.lab=.5,
      r=13)
dev.off()
knitr::plot_crop("g_xy_norm1.pdf")
knitr::plot_crop("g_xy_norm2.pdf")
