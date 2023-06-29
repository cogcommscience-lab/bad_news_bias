
# This package lets you read in the .dta file
library(haven)

# This package lets you read in the excel file
library(readxl)

# Read In Data
#df <- read_dta('News Bias Long w anew.dta')

df <- read_excel("prolific_merged_data.xlsx")

# Create anew_valence_label variable
df$anew_valence_label <- ifelse(df$anew_valence <= 5, "negative_valence", "positive_valence")

# Create anew_arousal_label variable
df$anew_arousal_label <- ifelse(df$anew_arousal <= 5, "low_arousal", "high_arousal")

# Load packages for summarizing data
library(dplyr)
library(tidyr)

# Make a dataframe that only encodes the headline number 
unique_doc_id <- df %>% distinct(doc_id)

# Group by doc_id, create a new dataframe with the average V and A scores, and confidence intervals
# Add the ANEW dictinary labels for arousal and valence
means_df <- df %>%
  group_by(doc_id) %>%
  summarize(
    mean_valence = V_Mean,
    mean_arousal = A_Mean,
    ci_valence = 1.96 * V_SD / sqrt(Obs),
    ci_arousal = 1.96 * A_SD / sqrt(Obs)
  ) %>%
  right_join(unique_doc_id, by = "doc_id") %>%
  left_join(df %>% distinct(doc_id, anew_valence_label, anew_arousal_label, headline), by = "doc_id")

# Concatenate "anew_valence_label" and "anew_arousal_label"
anew_scores <- paste(means_df$anew_valence_label, means_df$anew_arousal_label, sep = "-")

# Add the new column to the dataframe
means_df <- cbind(means_df, anew_scores)

# Load package for plotting
library(ggplot2)
library(viridis)

# Make a circumplex plot
ggplot(means_df, aes(x = mean_valence, y = mean_arousal, color = anew_scores)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_arousal - ci_arousal, ymax = mean_arousal + ci_arousal), width = 0.2) +
  geom_errorbarh(aes(xmin = mean_valence - ci_valence, xmax = mean_valence + ci_valence), height = 0.2) +
  labs(x = "SAM Valence", y = "SAM Arousal", color = "ANEW Labels") +
  theme_classic() +
  scale_color_viridis_d() +
  theme(legend.position = "bottom",
        legend.box = "horizontal") +
  guides(color = guide_legend(nrow = 2))

# Lets select the top/bottom 20 headlines on arousal/valence

library(dplyr)

# Select Headlines For each Cell

# Filter negative valence low arousal (NLA) where both mean_valence < 5 and mean_arousal < 5
nla_total <- means_df %>%
  filter(mean_valence < 5, mean_arousal < 5)

# Filter negative valence high arousal (NHA) where mean_valence < 5 and mean_arousal > 5
nha_total <- means_df %>%
  filter(mean_valence < 5, mean_arousal > 5)

# Filter positive valence low arousal (PLA) where mean_valence > 5 and mean_arousal < 5
pla_total <- means_df %>%
  filter(mean_valence > 5, mean_arousal < 5)

# Filter positive valence high arousal (PHA) where mean_valence > 5 and mean_arousal > 5
pha_total <- means_df %>%
  filter(mean_valence > 5, mean_arousal > 5)

# Select top 14 headlines for each cell
nla <- nla_total %>%
  arrange(mean_valence, mean_arousal)
nla <- head(nla,14)

nha <- nha_total %>%
  arrange(mean_arousal, mean_valence)
nha <- tail(nha,14)

pla <- pla_total %>%
  arrange(desc(mean_valence), mean_arousal)
pla <- head(pla,14)

pha <- pha_total %>%
  arrange(desc(mean_valence), desc(mean_arousal))
pha <- head(pha,14)

#combine subset data
cells_combo <- bind_rows(nla, nha, pla, pha) 

# Add SAM labels
# N = Negative Valence, P = Positive Valence
# LA = Low Arousal, HA = High Arousal
cells_combo$sam_valence_label <- ifelse(cells_combo$mean_valence <= 5, "Negative Valence", "Positive Valence")
cells_combo$sam_valence_label_short <- ifelse(cells_combo$mean_valence <= 5, "N", "P")
cells_combo$sam_arousal_label <- ifelse(cells_combo$mean_arousal <= 5, "Low Arousal", "High Arousal")
cells_combo$sam_arousal_label_short <- ifelse(cells_combo$mean_arousal <= 5, "LA", "HA")
# Concatenate "anew_valence_label" and "anew_arousal_label"
cells_combo$sam_scores <- paste(cells_combo$sam_valence_label, cells_combo$sam_arousal_label, sep = " ")
cells_combo$sam_scores_short <- paste(cells_combo$sam_valence_label_short, cells_combo$sam_arousal_label_short, sep = "")

## Write out cells_combo
write.csv(cells_combo,"testing_headlines.csv", row.names = TRUE)

# Now lets make a circumplex plot for cells_combo
# This plot labels each data point using the ANEW values
ggplot(cells_combo, aes(x = mean_valence, y = mean_arousal, color = anew_scores)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_arousal - ci_arousal, ymax = mean_arousal + ci_arousal), width = 0.2) +
  geom_errorbarh(aes(xmin = mean_valence - ci_valence, xmax = mean_valence + ci_valence), height = 0.2) +
  labs(x = "SAM Valence", y = "SAM Arousal", color = "ANEW Labels") +
  theme_classic() +
  scale_color_viridis_d() +
  theme(legend.position = "bottom",
        legend.box = "horizontal") +
  guides(color = guide_legend(nrow = 2))


# Now lets make a circumplex plot for cells_combo
# This plot labels each data point using the SAM values
ggplot(cells_combo, aes(x = mean_valence, y = mean_arousal, color = sam_scores)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_arousal - ci_arousal, ymax = mean_arousal + ci_arousal), width = 0.2) +
  geom_errorbarh(aes(xmin = mean_valence - ci_valence, xmax = mean_valence + ci_valence), height = 0.2) +
  labs(x = "SAM Valence", y = "SAM Arousal", color = "SAM Labels") +
  theme_classic() +
  scale_color_viridis_d() +
  theme(legend.position = "bottom",
        legend.box = "horizontal") +
  guides(color = guide_legend(nrow = 2))

# Look at correlation between ANEW and self-reports
corrmatrix <- df[,c(3,7,11,15,19,23,27,37,38,40,41,42,43,44)]

## Make correlation matrix
M<-cor(corrmatrix)
head(round(M,2))


## Write a function that will make a matrix of p-values
### mat : is a matrix of data
### ... : further arguments to pass to the native R cor.test function
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}

## Get matrix of correlation p-values
p.mat <- cor.mtest(corrmatrix)
head(p.mat[, 1:7])

library(corrplot)

## Plot a big matrix
## Only results significant at p < .00059 are displayed (Bonferroni correction)
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
title <- "Significant (p < .00059) Correlations For Automated Textual Analysis & Self-Report Data"
corrplot(M, method="color", col=col(200),  
         type="upper", order="hclust", 
         title=title,
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         p.mat = p.mat, sig.level = 0.00059, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=FALSE,
         mar=c(0,0,1,0)
)

# Do some diagnostics on the final dataset
sam_valence_model <- aov(mean_valence ~ sam_scores_short, data = cells_combo)
summary(sam_valence_model)
pairwise.t.test(cells_combo$mean_valence, cells_combo$sam_scores_short, p.adjust.methods = bonferroni)

sam_arousal_model <- aov(mean_arousal ~ sam_scores_short, data = cells_combo)
summary(sam_arousal_model)
pairwise.t.test(cells_combo$mean_arousal, cells_combo$sam_scores_short, p.adjust.methods = bonferroni)
