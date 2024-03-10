simulate_abundance_data <- function(distribution = "negative.binomial", n_species = 20, n_groups = 2, samples_per_group = 10,
                                    mean_taxon_richness_difference = 0, mean_abundance_difference = 0, dispersion = 1,
                                    zero_proportion = 0.5) {
  # Initialize an empty matrix to store abundance data
  abundance_data <- matrix(0, nrow = n_groups * samples_per_group, ncol = n_species)
  
  # Pre-allocate a character vector to store row names
  row_names <- character(n_groups * samples_per_group)
  
  sample_counter <- 1  # Counter to keep track of samples within a group
  
  # Create informative species names (modify format if needed)
  species_names <- paste0("Spp_", formatC(1:n_species, width = 2, format = "d", flag = "0"))
  
  for (group in 1:n_groups) {
    # Calculate group mean richness and abundance based on the group index and specified differences
    group_mean_richness <- sample(1:n_species, 1) + mean_taxon_richness_difference * (group - (n_groups - 1) / 2)
    group_mean_abundance <- 1 + mean_abundance_difference * (group - (n_groups - 1) / 2)
    
    for (sample in 1:samples_per_group) {
      if (distribution == "negative.binomial") {
        # Simulate abundances from negative binomial distribution
        group_abundances <- rnbinom(n_species, mu = group_mean_richness, size = dispersion * group_mean_abundance)
      } else if (distribution == "poisson") {
        # Simulate abundances from Poisson distribution
        group_abundances <- rpois(n_species, lambda = group_mean_richness)
      } else {
        stop("Invalid distribution. Please choose either 'negative.binomial' or 'poisson'.")
      }
      
      # Introduce zeros based on the specified proportion
      num_zeros <- round(zero_proportion * length(group_abundances))
      zero_indices <- sample(length(group_abundances), num_zeros)
      group_abundances[zero_indices] <- 0
      
      # Store simulated abundances and update row names with unique sample numbers
      abundance_data[(group - 1) * samples_per_group + sample, ] <- group_abundances
      row_names[(group - 1) * samples_per_group + sample] <- paste0("Group_", group, "_sample_", sample_counter)
      sample_counter <- sample_counter + 1  # Increment counter for next sample
    }
    
    # Reset sample counter for the next group
    sample_counter <- 1
  }
  
  # Assign row and column names
  rownames(abundance_data) <- row_names
  colnames(abundance_data) <- species_names
  
  return(abundance_data)
}

# Example usage:
set.seed(123)  # For reproducibility
abundance_data <- simulate_abundance_data(n_species = 10,
                                          n_groups = 2,
                                          samples_per_group = 5,
                                          mean_abundance_difference = 300,
                                          dispersion = 1,
                                          zero_proportion = 0.5)
print(abundance_data)
