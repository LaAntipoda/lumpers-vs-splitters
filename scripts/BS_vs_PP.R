
# Plot Bootstrap support an mPTP Posterior probabilities in the same tree

library("ape")
library("ggtree")
library("ggplot2")
library("dplyr")
library("ggrepel")
library("patchwork")

# ============================================================
# tree reading
# ============================================================

tree_bs <- read.tree("../IQ3_out/*_iqtree.contree")   # bootstrap values as node labels
tree_pp <- read.tree("../mPTP/*_mptp.combined.tree")   # posterior probabilities as node labels

# Root the bs tree
tree_bs <- root(tree_bs, outgroup = "Your_mptp_outgroup_here", resolve.root = TRUE)

# ============================================================
# extract node values
# ============================================================

bs_values <- as.numeric(tree_bs$node.label)  # bootstrap (e.g. 0–100)
pp_values <- as.numeric(tree_pp$node.label)  # posterior prob (e.g. 0–1)

# Normalize bootstrap to 0–1 if it's on a 0–100 scale
if (max(bs_values, na.rm = TRUE) > 1) {
  bs_values_norm <- bs_values / 100
} else {
  bs_values_norm <- bs_values
}

# Build a data frame
n_tips     <- length(tree_bs$tip.label)
node_ids   <- (n_tips + 1):(n_tips + tree_bs$Nnode)

support_df <- data.frame(
  node       = node_ids,
  bootstrap  = bs_values,
  bootstrap_norm = bs_values_norm,
  post_prob  = pp_values
) %>%
  filter(!is.na(bootstrap) & !is.na(post_prob))  # drop root / unlabelled nodes

cat("── Support value summary ──\n")
print(summary(support_df[, c("bootstrap", "post_prob")]))

# ============================================================
# correlation statistics 
# ============================================================

# Pearson correlation
cor_val  <- cor(support_df$bootstrap_norm, support_df$post_prob,
                use = "complete.obs", method = "pearson")
cor_text <- paste0("r = ", round(cor_val, 3))

cat("\n── Correlation ──\n")
cat("Pearson r :", round(cor_val, 4), "\n")

lm_fit <- lm(post_prob ~ bootstrap_norm, data = support_df)
cat("R²        :", round(summary(lm_fit)$r.squared, 4), "\n")
cat("p-value   :", format.pval(summary(lm_fit)$coefficients[2, 4], digits = 3), "\n")

cat("\n── Nodes with high discordance (|BS - PP| > 0.2) ──\n")
support_df %>%
  mutate(discordance = abs(bootstrap_norm - post_prob)) %>%
  filter(discordance > 0.2) %>%
  arrange(desc(discordance)) %>%
  print()


# ============================================================
# tree plot
# ============================================================
# Attach both support values to the bootstrap tree for plotting
# Build annotation data frame in ggtree format
annot_df <- support_df %>%
  mutate(
    label_text = paste0(bootstrap, "\n", round(post_prob, 2)),
    bs_cat = case_when(
      bootstrap_norm >  0.9 ~ "High (> 0.9)",
      bootstrap_norm >  0.7 ~ "Mid (> 0.7)",
      TRUE                  ~ "Low (≤ 0.7)"
    ) %>% factor(levels = c("High (> 0.9)", "Mid (> 0.7)", "Low (≤ 0.7)"))
  )

tree_plot <- ggtree(tree_bs, colour = "grey30", linewidth = 0.5) %<+% annot_df +
  
  # Node points sized by posterior probability, coloured by BS category
  geom_nodepoint(aes(size = post_prob, colour = bs_cat),
                 alpha = 0.85) +
  
# Dual label: bootstrap / PP Didnt really like the look
#  geom_nodelab(aes(label = label_text),
#               hjust = -0.15, vjust = 0.5,
#               size = 1.5, colour = "grey20") +
#  
  geom_tiplab(align = TRUE, linesize = 0.3, size = 1, colour = "grey15", offset = 0.002) +
  
  scale_colour_manual(
    values = c("High (> 0.9)" = "#27ae60",
               "Mid (> 0.7)"  = "#f39c12",
               "Low (≤ 0.7)"  = "#e74c3c"),
    name = "Bootstrap\nsupport",
    na.value = "grey70"
  ) +
  scale_size_continuous(
    name = "Posterior\nprobability",
    range = c(1, 6)
  ) +
  
  labs(title = "Phylogenetic tree",
       subtitle = "Node labels: bootstrap / posterior prob  |  Dot size = PP, colour = BS") +
  
  theme_tree2() +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 9, colour = "grey50"),
    legend.position = "right"
  ) +
  xlim(0, max(node.depth.edgelength(tree_bs)) * 1.5)  # extra space for labels

plot(tree_plot)
