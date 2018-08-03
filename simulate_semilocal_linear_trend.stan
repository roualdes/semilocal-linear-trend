data {
  int T;
  real eta_mean;
}
parameters {
  real<lower=0> sigma_y;
  vector[T] gamma;
  vector[T] zeta;
  real eta;
  real<lower=-1, upper=1> phi;
}
transformed parameters {
  vector[T] mu;
  vector[T] nu;

  mu[1] = gamma[1];
  nu[1] = zeta[1];
  for (t in 2:T) {
    mu[t] = mu[t-1] + nu[t-1] + gamma[t];
    nu[t] = eta + phi * (nu[t-1] - eta) + zeta[t];
  }
}
model {
  // priors
  sigma_y ~ normal(0, 100);
  gamma ~ normal(0, 100);
  zeta ~ normal(0, 100);
  eta ~ normal(eta_mean, 1);
  phi ~ normal(-0.5, 0.25);
}
generated quantities {
  vector[T] y_pred;
  for (t in 1:T)
    y_pred[t] = normal_rng(mu[t], sigma_y);
}
