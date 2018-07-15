data {
  int <lower=1> T;
  vector[T] x;
  vector[T] y;
}
transformed data {
  real sd_y = sd(y);
  real sd_x = sd(x);
}
parameters {
  real<lower=0> sigma_y;
  vector[T] gamma;
  real<lower=0> sigma_gamma;
  vector[T] zeta;
  real<lower=0> sigma_zeta;
  real eta;
  real<lower=-1, upper=1> phi;
}
transformed parameters {
  vector[T] mu;
  vector[T] nu;

  mu[1] = y[1] + sigma_gamma * gamma[1];
  nu[1] = zeta[1];
  for (t in 2:T) {
    mu[t] = mu[t-1] + nu[t-1] + sigma_gamma * gamma[t];
    nu[t] = eta + phi * (nu[t-1] - eta) + sigma_zeta * zeta[t];
  }
}
model {
  // likelihood
  y ~ normal(mu, sigma_y);

  // priors
  sigma_y ~ exponential(1 / sd_y);
  gamma ~ normal(0, 1);
  sigma_gamma ~ gamma(2, 1 / sd_y);
  zeta ~ normal(0, 1);
  sigma_zeta ~ gamma(2, 1 / sd_y);
  eta ~ student_t(3, 0, sd_y / sd_x);
  phi ~ normal(0, 0.5);
}
generated quantities {
  vector[T] y_pred;
  for (t in 1:T)
    y_pred[t] = normal_rng(mu[t], sigma_y);
}
