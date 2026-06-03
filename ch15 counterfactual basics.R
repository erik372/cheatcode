rm(list=ls())
library("tidyverse")
library("patchwork")
library("latex2exp")
library("tidydice")
library("scales")
library("ggrepel")
#install.packages("devtools")
# devtools::install_github("nicolash2/ggbrace")
library("ggbrace")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(scipen=999)

################################################################################
## kontrafaktisk
################################################################################
g_kontrafaktisk <- ggplot() +
  geom_point(aes(x=c(1,2,2),
                 y=c(1,1.1,1.2)), size=2) +
  
  # före A
  annotate("segment", x=.8, y=.98, xend=1, yend=1) +
  
  # streckad
  annotate("segment", x=1,y=1,xend=2, yend=1.1, linetype="dashed") +
  # observerad
  annotate("segment", x=1,y=1,xend=2, yend=1.2) +
  # grå 
  annotate("segment", x=1,y=1,xend=2, yend=1, alpha=.33) +
  
  # klammer + effekt
  stat_brace(data=tibble(x=c(2.05,2.1), y=c(1.11,1.2)), aes(x,y), rotate = 90) +
  annotate("text", x=2.15, y=1.157, size=2, hjust=0, 
           label="Effect") +
  
  # klammer + kontrafaktisk
  stat_brace(data=tibble(x=c(2.05,2.1), y=c(1,1.09)), aes(x,y), rotate = 90, alpha=.33) +
  annotate("text", x=2.15, y=1.05, size=2, hjust=0, 
           label="Expected change\nif A never happend") +
  
  # text 1 och 2
  annotate("text", x=1, y=1.08, size=2, 
           label="Event A\n(the cause) occurs") +
  # pil
  annotate('segment', x=1 , xend=1,  y=1.052, yend=1.02, size=.2,
           arrow=arrow(length=unit(.1, 'cm'), 
                       ends='last', type='open')) +
  
  xlim(.8,2.5) +
  theme(
    axis.text=element_blank(),
    axis.ticks=element_blank(),
    axis.line = element_line(arrow=arrow(length=unit(.15,"cm"))), 
    axis.title.y=element_text(angle=0), 
    panel.background=element_blank(), 
    text=element_text(size=7)
  ) +
  labs(y="Phenomenon B\nwhich we want\nto study", 
       x="Time")

g_kontrafaktisk
g_kontrafaktisk %>% ggsave(filename="g_kontrafaktisk.pdf", width=4.2, height=2.3)
  




