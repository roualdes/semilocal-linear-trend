data {
  int <lower=1> T;
  vector[T] y;
}
transformed data {
  real sd_y = sd(y);
  real auto_scale_error = 100 * sd_y;
  real auto_scale_slope = 2.5 * sd_y;
}
parameters {
  real<lower=0> sigma_y_z;
  vector[T] gamma;
  real<lower=0> sigma_gamma_z;
  vector[T] zeta;
  real<lower=0> sigma_zeta_z;
  real eta_z;
  real<lower=-1, upper=1> phi;
}
transformed parameters {
  vector[T] mu;
  vector[T] nu;

  real sigma_y = auto_scale_error * sigma_y_z;
  real sigma_gamma = auto_scale_error * sigma_gamma_z;
  real sigma_zeta = auto_scale_error * sigma_zeta_z;
  real eta = auto_scale_slope * eta_z;

  mu[1] = y[1] + sigma_gamma * gamma[1];
  nu[1] = sigma_zeta * zeta[1];
  for (t in 2:T) {
    mu[t] = mu[t-1] + nu[t-1] + sigma_gamma * gamma[t];
    nu[t] = eta + phi * (nu[t-1] - eta) + sigma_zeta * zeta[t];
  }
}
model {
  // priors
  sigma_y_z ~ normal(0, 1);
  gamma ~ normal(0, 1);
  sigma_gamma_z ~ normal(0, 1);
  zeta ~ normal(0, 1);
  sigma_zeta_z ~ normal(0, 1);
  eta_z ~ normal(0, 1);
  phi ~ normal(0, 0.5);

  // likelihood
  y ~ normal(mu, sigma_y);
}
generated quantities {
  vector[T] y_pred;
  for (t in 1:T)
    y_pred[t] = normal_rng(mu[t], sigma_y);
}
