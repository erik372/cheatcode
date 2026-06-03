rm(list=ls())

library("tidyverse")
library("igraph") 
library("ggraph")
library("patchwork")
library("latex2exp")
library("conflicted")
conflict_prefer("TeX", "latex2exp")
conflict_prefer("filter","dplyr")
conflict_prefer("lag","dplyr")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))




###################################################
### 2 vectors
g_vectors <- ggplot() + 
  geom_segment(aes(x=0,y=0, xend=1,yend=2), arrow=arrow(14, length = unit(4, "mm") )) +
  geom_segment(aes(x=0,y=0, xend=-2,yend=3), arrow=arrow(15, length = unit(4, "mm") )) +
  annotate('text', x=-1.3, y=3, label="(-2,3)", size=2.5) +
  annotate('text', x=.5, y=2, label="(1,2)", size=2.5) +
  geom_vline(xintercept=0, alpha=.3) +
  theme(axis.title.y=element_text(angle=0), 
        text=element_text(size=8))

g_vectors
g_vectors %>% ggsave(file="g_vectors.pdf", width=2.3, height=2.3)







#################################################################
## Leontief matrix , Industry A & B
library("matlib")
flow <- c(2,1,1,3) %>% matrix(ncol=2)
tot <- c(6,7)
y <- tot %>% matrix(ncol=1)
a <- flow %*% diag(1/tot)
# för att skriva ut reducerade bråk använder vi MASS::fractions
MASS::fractions(a)

a %*% y
i <- diag(2)
inv(i-a) %*% y
b <- inv(i-a)
MASS::fractions(b)


#######################################################################
### input-output graph
#######################################################################
library(digest)
library(devtools)
conflicts_prefer(ggraph::circle)
# Download d3SimpleNetwork
source_gist("5734624")

text_size <- 2

io_table <- data.frame(
  source=c("Industry A","Industry A","Industry B","Industry B"),
  target=c("Industry A","Industry B","Industry A","Industry B"),
  values=c(2,1,1,3), 
  sums=c(9,13)
)
sums <- c(9,13)
set.seed(300)
g_io_net <- io_table %>% 
  graph_from_data_frame()  %>% 
  ggraph() +
  geom_edge_arc(aes(alpha=values, label=values), label_size=text_size,
                arrow = arrow(length = unit(4, 'mm')), 
                start_cap = circle(8, 'mm'),
                end_cap = circle(8, 'mm'), 
                hjust=2.5) +
  
  geom_edge_loop(aes(alpha=values, 
                     label=values), hjust=-2, label_size=text_size,
                 arrow = arrow(length = unit(4, 'mm')), 
                 start_cap = circle(8, 'mm'),
                 end_cap = circle(8, 'mm')) +
  
  geom_node_point(aes(size=sums), color='darkgray') +
  geom_node_text(aes(label = name),
                     repel = TRUE, 
                 size=text_size,
                 hjust=-.5, 
                 vjust=1) +
  
  scale_size_continuous(range=c(7,14)) +
  scale_edge_alpha(range=c(.2,2)) +
  theme(legend.position ='none',
        text=element_text(size=text_size)) +
  annotate('text', x=.8, y=.4, size=text_size,
           label="Flows from \nA to B") +
  annotate('text', x=.22, y=.5, hjust=0, size=text_size,
           label="From firms in A\nto other firms in A") 
  

g_io_net
g_io_net %>% ggsave(file="g_io_net.pdf", width=3, height = 3)






#################################################################
### the social network
social_nw <- tibble(
  source=rep(c("Maria","Nushi","Mohammed","Jose"), 4), 
  target=c(rep("Maria",4),rep("Nushi",4), rep("Mohammed",4),rep("Jose",4)),
  values=c(0,2,3,1,
           5,0,1,7,
           1,2,0,0,
           3,6,1,0)
  ) %>% 
  group_by(target) %>% 
  mutate(sums= sum(values, na.rm=TRUE))

sums <- social_nw %>% distinct(sums)  

g_social_nw <- social_nw %>% 
  filter(values>0) %>% 
  graph_from_data_frame(directed=TRUE)  %>% 
  ggraph() +
  # linjerna + pilspetsar
  geom_edge_arc(aes(width=sums), 
                start_cap = circle(10, 'mm'),
                end_cap = circle(10, 'mm'),
                arrow = arrow(angle = 35,
                              length = unit(0.08, "inches"),
                              type='open'), alpha=.8) +
  # noderna
  geom_node_label(aes(label=name), 
                  size=1.7) +
  
  scale_edge_width(range=c(0,1.5)) +
  theme(legend.position = 'none', text=element_text(size=8)) +
  labs(caption="Arrows illustrate sent messages\nLine width show number of messages.")

g_social_nw
g_social_nw %>% ggsave(file="g_social_nw.pdf", width=3.3, height=3)

