## simData.R ####

### Simulate multivariate ecology data

# set parameters
set.seed(123)
n_species <- 50 # how many species
n_samples <- 100 # how many samples
n_groups <- 2 # how many blocks are the data in

# Define parameter ranges
effect_sizes <- c(0.5, 1, 1.5)  # Effect size between groups
mean_abundances <- c(5, 10, 15)  # Mean abundances within groups
dispersion_parameters <- c(0.5, 1, 2)  # Dispersion parameters within groups

# Simulation study
results <- list()

# Function to simulate negative binomial data with effect size
simulate_neg_binomial <- function(n_samples,
                                  n_species,
                                  n_groups,
                                  mu,
                                  size,
                                  effect_size) {
  sim_data <- matrix(0,
                     nrow = n_samples * n_groups,
                     ncol = n_species)
  for (i in 1:(n_samples * n_groups)) {
    group_mean <- mu * (1 + ifelse(i <= n_samples * n_groups / 2,
                                   effect_size,
                                   -effect_size)
                        )
    sim_data[i, ] <- rnbinom(n_species,
                             mu = group_mean,
                             size = size)
  }
  return(sim_data)
}

