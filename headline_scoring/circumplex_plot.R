
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
library(ggrepel)

# Make a circumplex plot
# internal keys (from interaction) -> colors
key_vals <- c(
  "low_arousal, negative_valence"  = "#7f3b08",
  "low_arousal, positive_valence"  = "#fdb863",
  "high_arousal, negative_valence" = "#b2abd2",
  "high_arousal, positive_valence" = "#2d004b"
)

# pretty legend labels
label_map <- c(
  "low_arousal, negative_valence"  = "Negative Valence Low Arousal",
  "low_arousal, positive_valence"  = "Positive Valence Low Arousal",
  "high_arousal, negative_valence" = "Negative Valence High Arousal",
  "high_arousal, positive_valence" = "Positive Valence High Arousal"
)

# plot
ggplot(
  means_df,
  aes(
    x = mean_valence,
    y = mean_arousal,
    color = interaction(anew_arousal_label, anew_valence_label, sep = ", ")
  )
) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_arousal - ci_arousal, ymax = mean_arousal + ci_arousal), width = 0.2) +
  geom_errorbarh(aes(xmin = mean_valence - ci_valence, xmax = mean_valence + ci_valence), height = 0.2) +
  labs(x = "SAM Valence", y = "SAM Arousal", color = "ANEW Labels") +
  theme_classic() +
  scale_color_manual(
    values = key_vals,
    breaks = names(label_map),   # ensure legend order
    labels = label_map,
    drop = FALSE                 # keep all four in legend even if absent
  ) +
  theme(legend.position = "bottom", legend.box = "horizontal") +
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
anew_circumplex_plot <- ggplot(
  cells_combo,
  aes(
    x = mean_valence,
    y = mean_arousal,
    color = interaction(anew_arousal_label, anew_valence_label, sep = ", ")
  )
) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_arousal - ci_arousal, ymax = mean_arousal + ci_arousal), width = 0.2) +
  geom_errorbarh(aes(xmin = mean_valence - ci_valence, xmax = mean_valence + ci_valence), height = 0.2) +
  labs(x = "SAM Valence", y = "SAM Arousal", color = "ANEW Labels") +
  theme_classic() +
  scale_color_manual(
    values = key_vals,
    breaks = names(label_map),  # keep legend order consistent
    labels = label_map,
    drop = FALSE                # show all four in legend even if absent
  ) +
  scale_x_continuous(limits = c(1, 9), breaks = 1:9) +
  scale_y_continuous(limits = c(1, 9), breaks = 1:9) +
  theme(
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.text = element_text(size = 15),   # legend entries
    legend.title = element_text(size = 17),  # legend title
    axis.title = element_text(size = 17),    # axis labels
    axis.text = element_text(size = 15)      # axis tick labels
  ) +
  guides(color = guide_legend(nrow = 2))

plot(anew_circumplex_plot)

# Save as PNG
ggsave(
  filename = "anew_sam_circumplex.png",
  plot = anew_circumplex_plot,
  width = 8.5,
  height = 8.5,
  units = "in",
  dpi = 300
)

# Save as EPS
ggsave(
  filename = "anew_sam_circumplex.eps",
  plot = anew_circumplex_plot,
  width = 8.5,
  height = 8.5,
  units = "in",
  dpi = 300,
  device = cairo_ps   # ensures high-quality EPS export
)


# Now lets make a circumplex plot for cells_combo
# This plot labels each data point using the SAM values
sam_key_vals <- c(
  "NLA"  = "#7f3b08",
  "PLA"  = "#fdb863",
  "NHA" = "#b2abd2",
  "PHA" = "#2d004b"
)

sam_circumplex_plot <- ggplot(cells_combo, aes(x = mean_valence, y = mean_arousal, color = sam_scores_short)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = mean_arousal - ci_arousal, ymax = mean_arousal + ci_arousal), width = 0.2, size = 1) +
  geom_errorbarh(aes(xmin = mean_valence - ci_valence, xmax = mean_valence + ci_valence), height = 0.2, size = 1) +
  labs(x = "Valence", y = "Arousal", color = "") +
  theme_classic() +
  scale_color_manual(
    values = sam_key_vals,
    breaks = names(sam_key_vals),
    drop = FALSE
  ) +
#  scale_x_continuous(limits = c(1, 9), breaks = 1:9) +
#  scale_y_continuous(limits = c(1, 9), breaks = 1:9) +
  theme(
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.text = element_text(size = 30),   # legend entries
    legend.title = element_text(size = 36),  # legend title
    axis.title = element_text(size = 36),    # axis labels
    axis.text = element_text(size = 30)      # axis tick labels
  ) +
  guides(color = guide_legend(nrow = 2))

plot(sam_circumplex_plot)

# Save as PNG
ggsave(
  filename = "sam_sam_circumplex.png",
  plot = sam_circumplex_plot,
  width = 8.5,
  height = 8.5,
  units = "in",
  dpi = 300
)

# Save as EPS
ggsave(
  filename = "sam_sam_circumplex.eps",
  plot = sam_circumplex_plot,
  width = 8.5,
  height = 8.5,
  units = "in",
  dpi = 300,
  device = cairo_ps   # ensures high-quality EPS export
)


# Same plot, but now publication ready

sam_key_vals <- c(
  "Negative Valence Low Arousal"  = "#7f3b08",
  "Positive Valence Low Arousal"  = "#fdb863",
  "Negative Valence High Arousal" = "#b2abd2",
  "Positive Valence High Arousal" = "#2d004b"
)

# Centroids + multi-line labels (same as you have)
label_df <- cells_combo %>%
  group_by(sam_scores) %>%
  summarise(
    mean_valence = mean(mean_valence, na.rm = TRUE),
    mean_arousal = mean(mean_arousal, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    sam_label_multiline = sub(" Valence ", " Valence\n", sam_scores, fixed = TRUE)
  )

sam_circumplex_plot <- ggplot(cells_combo, aes(x = mean_valence, y = mean_arousal, color = sam_scores)) +
  # make the data a bit lighter so labels pop
  geom_point(size = 4, alpha = 0.6) +
  geom_errorbar(aes(ymin = mean_arousal - ci_arousal, ymax = mean_arousal + ci_arousal),
                width = 0.2, size = 1, alpha = 0.95) +
  geom_errorbarh(aes(xmin = mean_valence - ci_valence, xmax = mean_valence + ci_valence),
                 height = 0.2, size = 1, alpha = 0.95) +
  
  # REPELLED LABELS with white background
  geom_label_repel(
    data = label_df,
    aes(x = mean_valence, y = mean_arousal,
        label = sam_label_multiline),
    fill = alpha("white", 0.65),           # white box behind text
    label.size = 0,           # no border line (use >0 to draw border)
#    fontface = "bold",
    size = 12,                 # mm; adjust to taste
    lineheight = 0.9,
    box.padding = 0.35,       # more padding -> more separation from points
    point.padding = 0.5,
    force = 1.2,              # increase if labels still collide
    max.overlaps = Inf,
    segment.color = NA,       # hide leader lines; remove this to show them
    seed = 123,               # reproducible placement
    inherit.aes = FALSE,
    show.legend = FALSE
  ) +
  
  labs(x = "Valence", y = "Arousal") +
  theme_classic() +
  scale_color_manual(values = sam_key_vals,
                     breaks = names(sam_key_vals),
                     drop = FALSE) +
  theme(
    legend.position = "none",
    axis.title = element_text(size = 36),
    axis.text  = element_text(size = 30)
  )

plot(sam_circumplex_plot)


# Save as PNG
ggsave(
  filename = "circumplex_pub.png",
  plot = sam_circumplex_plot,
  width = 8.5,
  height = 8.5,
  units = "in",
  dpi = 300
)

# Save as EPS
ggsave(
  filename = "circumplex_pub.eps",
  plot = sam_circumplex_plot,
  width = 8.5,
  height = 8.5,
  units = "in",
  dpi = 300,
  device = cairo_ps   # ensures high-quality EPS export
)


# Inferential Statistics on selected headlines
library(effectsize)

# Set relevant variables as factor:
cells_combo$sam_valence_label_short <- factor(cells_combo$sam_valence_label_short,
                                              levels = c("N", "P"))

cells_combo$sam_arousak_label_short <- factor(cells_combo$sam_arousal_label_short,
                                              levels = c("LA", "HA"))


# Independent samples t-test for valence
t_test_valence <- t.test(mean_valence ~ sam_valence_label_short, data = cells_combo, var.equal = TRUE)
print(t_test_valence)

# Compute Cohen's d for valence
cohen_d_valence <- cohens_d(mean_valence ~ sam_valence_label_short, data = cells_combo)
print(cohen_d_valence)

# Calculate group means, SD for valence
mean(cells_combo$mean_valence[cells_combo$sam_valence_label_short == "N"], na.rm = TRUE)
mean(cells_combo$mean_valence[cells_combo$sam_valence_label_short == "P"], na.rm = TRUE)
sd(cells_combo$mean_valence[cells_combo$sam_valence_label_short == "N"], na.rm = TRUE)
sd(cells_combo$mean_valence[cells_combo$sam_valence_label_short == "P"], na.rm = TRUE)

# Independent samples t-test for arousal
t_test_arousal <- t.test(mean_arousal ~ sam_arousal_label_short, data = cells_combo, var.equal = TRUE)
print(t_test_arousal)

# Compute Cohen's d for arousal
cohen_d_arousal <- cohens_d(mean_arousal ~ sam_arousal_label_short, data = cells_combo)
print(cohen_d_arousal)

# Calculate group means, SD for arousal
mean(cells_combo$mean_arousal[cells_combo$sam_arousal_label_short == "LA"], na.rm = TRUE)
mean(cells_combo$mean_arousal[cells_combo$sam_arousal_label_short == "HA"], na.rm = TRUE)
sd(cells_combo$mean_arousal[cells_combo$sam_arousal_label_short == "LA"], na.rm = TRUE)
sd(cells_combo$mean_arousal[cells_combo$sam_arousal_label_short == "HA"], na.rm = TRUE)


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

# Mapping from original variable names to human-readable names
var_labels <- c(
  "V_Mean"                = "SAM Valence",
  "L_Mean"                = "Liking",
  "net_lexi_tone"         = "Lexicoder Net Tone",
  "anew_valence"          = "ANEW Valence",
  "anew_dominance"        = "ANEW Dominance",
  "flesch_score"          = "Flesch Reading Ease",
  "num_words_ex_stopwords"= "Number of Words Excluding Stopwords",
  "num_words_inc_stopwords"= "Number of Words Including Stopwords",
  "anew_arousal"          = "ANEW Arousal",
  "A_Mean"                = "SAM Arousal",
  "D_Mean"                = "SAM Dominance",
  "C_Mean"                = "Comprehension",
  "F_Mean"                = "Familiarity",
  "S_Mean"                = "Seen Before"
)

# Apply new labels to correlation matrix and p-value matrix
rownames(M) <- var_labels[rownames(M)]
colnames(M) <- var_labels[colnames(M)]
rownames(p.mat) <- var_labels[rownames(p.mat)]
colnames(p.mat) <- var_labels[colnames(p.mat)]

## Plot a big matrix
## Only results significant at p < .00059 are displayed (Bonferroni correction)
col <- colorRampPalette(c("#7f3b08", "#fdb863", "#f7f7f7", "#b2abd2", "#2d004b"))
title <- "Bonferroni Corrected (p < .00059) Correlations For Automated Textual Analysis & Self-Report Data"

# Save as PNG
png("cormatrix.png", width = 12, height = 12, units = "in", res = 300)
corrplot(M, method="color", col=col(200),  
         type="upper", order="hclust", 
         title=title,
         addCoef.col = "black",
         tl.col="black", tl.srt=45,
         p.mat = p.mat, sig.level = 0.00059, insig = "blank", 
         diag=FALSE,
         mar=c(0,0,1,0))
dev.off()

# Save as EPS
setEPS()
postscript("cormatrix.eps", width = 12, height = 12, horizontal = FALSE,
           onefile = FALSE, paper = "special")
corrplot(M, method="color", col=col(200),  
         type="upper", order="hclust", 
         title=title,
         addCoef.col = "black",
         tl.col="black", tl.srt=45,
         p.mat = p.mat, sig.level = 0.00059, insig = "blank", 
         diag=FALSE,
         mar=c(0,0,1,0))
dev.off()


# Do some diagnostics on the final dataset
sam_valence_model <- aov(mean_valence ~ sam_scores_short, data = cells_combo)
summary(sam_valence_model)
pairwise.t.test(cells_combo$mean_valence, cells_combo$sam_scores_short, p.adjust.methods = bonferroni)

sam_arousal_model <- aov(mean_arousal ~ sam_scores_short, data = cells_combo)
summary(sam_arousal_model)
pairwise.t.test(cells_combo$mean_arousal, cells_combo$sam_scores_short, p.adjust.methods = bonferroni)
