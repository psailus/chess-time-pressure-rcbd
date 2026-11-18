# ==============================================================================
# Time Pressure and Decision Quality in Chess Puzzle Solving
# Author: Sai Kadiyala
# Analysis Script: RCBD with Latin Square Counterbalancing
# ==============================================================================

# Load libraries
library(tidyverse)
library(emmeans)
library(car)

# 1. Load Data
data_path <- "data/chess_puzzle_data.csv"
chess_data <- read.csv(data_path)

# Format factors
chess_data$treatment <- factor(chess_data$treatment, levels = c("Blitz", "Rapid", "Unlimited"))
chess_data$subject   <- factor(chess_data$subject)
chess_data$period    <- factor(chess_data$period)

cat("--- Summary Statistics ---\n")
print(
  chess_data %>%
    group_by(treatment) %>%
    summarise(
      n = n(),
      mean_accuracy = mean(accuracy),
      sd_accuracy = sd(accuracy)
    )
)

# 2. Linear Model (RCBD + Latin Square)
# y_ijk = mu + tau_i (treatment) + beta_j (subject) + gamma_k (period) + error
model <- lm(accuracy ~ treatment + subject + period, data = chess_data)

cat("\n--- ANOVA Table (Type I SS) ---\n")
print(anova(model))

# 3. Post-Hoc Contrasts: Tukey HSD
cat("\n--- Tukey HSD Pairwise Comparisons ---\n")
emm <- emmeans(model, ~ treatment)
print(pairs(emm, adjust = "tukey"))

# 4. Assumption Checks
cat("\n--- Assumption Diagnostics ---\n")
# Normality
shapiro_res <- shapiro.test(residuals(model))
cat(sprintf("Shapiro-Wilk Normality Test: W = %.4f, p = %.4f\n", shapiro_res$statistic, shapiro_res$p.value))

# Homoscedasticity across treatments
levene_res <- leveneTest(accuracy ~ treatment, data = chess_data)
cat("Levene's Homoscedasticity Test:\n")
print(levene_res)
