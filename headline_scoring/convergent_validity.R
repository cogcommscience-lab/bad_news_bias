# Automated Data QC
# This code looks at the relationships between automatically coded textual features

# The code follows these specific steps
  # Step 0: Load packages
  # Step 1: Read in the data
  # Step 2: Check Correlations between Automated Valence Scores
  # Step 3: Plot A Correlation Matrix For All Automatically Scored Text Features
  # Step 4: Make Boxplots for ANEW Arousal and Valence

## Note: For Lexicoder, following Young & Soroka, 2012 (https://doi.org/10.1080/10584609.2012.671234)
## lexicoder_net_tone = (# lexi_positive/num_words_ex_stopwords) - (# lexi_neg/num_words_ex_stopwords)
## The original Lexicoder validation paper showed a correlation
## between Lexicoder and ANEW valence of r = .5

# Dependencies
  # tidyverse
  # corrplot
  # ggplot2
  # tidyr



# Step 0: Load packages
library(tidyverse)
library(corrplot)
library(ggplot2)
library(tidyr)



# Step 1: Read in the data
scores = read.csv("headlines_convergent_validity.csv", stringsAsFactors=FALSE)



# Step 2: Check Correlations between Automated Valence Scores 
## Correlation between lexi_net_tone and anew_valence
correlation <- cor.test(scores$net_lexi_tone, scores$anew_valence, method = 'pearson')
print(correlation)

## Plot relationship
ggplot(data = scores, aes(x = net_lexi_tone, y = anew_valence)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Correlation Between Lexicoder and Anew on Valence",
       x = "Net Lexicoder Tone",
       y = "Anew Valence")



# Step 3: Plot A Correlation Matrix For All Automatically Scored Text Features

## Select Only Numeric Values For Correlation Matrix
corrmatrix <- scores[,c(8,9,11,12,13,14,15)]

## Make correlation matrix
M<-cor(corrmatrix)
head(round(M,2))

## Weite a function that will make a matrix of p-values
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


## Plot a big matrix
## Only results significant at p < .01 are displayed
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
title <- "Significant (p < .01) Correlations For Automated Textual Analysis"
corrplot(M, method="color", col=col(200),  
         type="upper", order="hclust", 
         title=title,
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         p.mat = p.mat, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=FALSE,
         mar=c(0,0,1,0)
)


# Step 4: Make Boxplots for ANEW Arousal and Valence

# Reshape the data from wide to long format
scores_long <- tidyr::gather(scores, key = "variable", value = "value", anew_valence, anew_arousal)

# Create a combined boxplot for anew_valence and anew_arousal
ggplot(scores_long, aes(x = variable, fill = variable, y = value)) +
  geom_boxplot() +
  scale_fill_manual(values = c("lightblue", "lightgreen"), 
                    labels = c("ANew Valence", "ANew Arousal")) +
  labs(x = "", y = "ANEW Score") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Perform a two-sample t-test
ttest <- t.test(scores$anew_valence, scores$anew_arousal)

# Print the results of the t-test
print(ttest)

# Calculate the mean for anew_valence and anew_arousal
valence_mean <- mean(scores$anew_valence)
arousal_mean <- mean(scores$anew_arousal)

# Print the mean values
cat("Mean for anew_valence:", valence_mean, "\n")
cat("Mean for anew_arousal:", arousal_mean, "\n")
