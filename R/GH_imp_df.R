# GH_imp_df.R
### import & analyse GarrockHead data

### set metadata
source("R/metadata.R")

#### load packages ####
ld_pkgs <- c("tidyverse","lubridate","vegan","mvabund","gllvm")
vapply(ld_pkgs, library, logical(1L),
       character.only = TRUE, logical.return = TRUE);rm(ld_pkgs)

### load data
df0 <- read.csv("inData/outGarrochHead.csv")

df0$Flag[is.na(df0$Flag)] <- "None"

df0$Flag <- factor(df0$Flag, levels=c("Outfall","Ref","None"))

dford <- df0 %>% 
  dplyr::select(.,-c(Flag,SiteCode))

ptm <- Sys.time()###
set.seed(pi);ord <-   vegan::metaMDS(dford,trymax = 500)
saveRDS(ord, file="outData/ordination.Rdat")
Sys.time() - ptm;rm(ptm)

plot(ord)

# mvabund ####
mvdford <- mvabund::mvabund(dford)
mvfit <- manyglm(mvdford ~ df0$Flag, family="negative.binomial")
summary(mvfit)
ptm <- Sys.time()###
mvfit_anova <- mvabund::anova.manyglm(mvfit,p.uni = "adjusted")
saveRDS(mvfit_anova, file="outData/mvfit_anova_out.Rdat")
Sys.time() - ptm;rm(ptm)
mvfit_anova <- readRDS("outData/mvfit_anova_out.Rdat")

# gllvm ####
ptm <- Sys.time()###
glfit <- gllvm::gllvm(dford, family = "negative.binomial")
saveRDS(glfit, file="outData/glfit_unconstrained.Rdat")
Sys.time() - ptm;rm(ptm)
glfit <- readRDS("outData/glfit_unconstrained.Rdat")

ordiplot(glfit, biplot = TRUE)
##### TO DO ######


# TO DO ######
#### plot in ggplot2 ####
df0 %>% 
  dplyr::select(c(1:2)) -> scores_site

tmp_sites <- as.data.frame(scores(ord,display = "site"))  #Using the scores function from vegan to extract the site scores and convert to a data.frame
scores_site$NMDS1 <- tmp_sites$NMDS1 #location of individual samples in NMDS space
scores_site$NMDS2 <- tmp_sites$NMDS2 #location of individual samples in NMDS space
scores_site$yymm <- as.factor(format(scores_site$sample.date, "%Y-%m"))
rm(tmp_sites)

# Using the scores function from vegan to extract the species scores and
# convert to a data.frame
scores_species <- as.data.frame(scores(ord,display = "species"))
scores_species$lb0 <-  make.cepnames(row.names(scores_species))#shorten names
scores_species$lb <-  row.names(scores_species)

#### generate mean centroids by WB and Region ####
scores_site %>%
  group_by(Flag) %>%
  summarise(mn_ax1_Flag=mean(NMDS1),mn_ax2_Flag=mean(NMDS2)) %>%
  ungroup() -> centr

scores_site <- left_join(scores_site,centr,by="Flag");rm(centr)

pl <- ggplot()+
  geom_hline(colour="grey",yintercept = 0, lty=2)+
  geom_vline(colour="grey",xintercept = 0, lty=2)+
  geom_text(data=scores_species, aes(x = NMDS1, y=NMDS2, label=lb0),
            size=3,
            alpha=0.2)+
geom_segment(data=scores_site,aes(x=NMDS1,y=NMDS2,
                                  colour=Flag,
                                  xend=mn_ax1_Flag,yend=mn_ax2_Flag),
             show.legend = FALSE)+
  geom_point(data=scores_site, show.legend=TRUE,
             aes(x=NMDS1, y=NMDS2,
                 fill = Flag,
                 shape = Flag),
             size=3)+
  scale_fill_manual(values=c(cbPalette))+
  scale_colour_manual(values=c(cbPalette))+
  scale_shape_manual(values = rep(c(24,25,23),each=2))+
  coord_equal()+
  labs(title="Non-metric Multidimensional Scaling of benthic invertebrate assemblages in the vicinity of Garroch Head",
       # subtitle="Colours & shapes indicate region",
       caption=paste0("Stress = ",round(ord$stress,3)))+
  theme(legend.title = element_blank(),
        axis.title = element_text(face="bold"));pl
# 
# ggsave(filename = "figs/nmds_by_Region_Traits.pdf",width = 12,height = 12,units = "in",
#        plot=pl);rm(pl)
