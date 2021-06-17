# Plot to make the Log2FC plot comparing DE genes. 
# Data for two DE comparisons is in the table "overlap", in long/tidy format. 
# "Comparison" is the column containing the DE list (e.g. LPSvsVehicle or LPSLPSvsVehicle).

ggplot(overlap, aes(Log2FC, gene, group = gene)) +
  geom_line(alpha = 0.5) +
  geom_point(aes(colour = Comparison), alpha = 0.8) +
  theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) +
  scale_colour_manual(values = c("firebrick", "springgreen4"))
