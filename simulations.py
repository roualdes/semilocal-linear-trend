import pystan
import bplot as bp
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc

rc('text', usetex=True)

sm_sim = pystan.StanModel(file = 'simulate_semilocal_linear_trend.stan')
sm_fit = pystan.StanModel(file = 'semilocal_linear_trend.stan')

T = 50
x = np.arange(T)

sfit = sm_sim.sampling(data = {'T': T, 'eta_mean': 1})
posterior_sim01 = sfit.extract()
y01 = posterior_sim01['y_pred'].mean(0)
sfit01 = sm_fit.sampling(data = {'T': T, 'y': y01})
posterior_fit01 = sfit01.extract()
ci01 = np.percentile(posterior_fit01['y_pred'], [2.5, 97.5], 0)

sfit = sm_sim.sampling(data = {'T': T, 'eta_mean': 0.1})
posterior_sim02 = sfit.extract()
y02 = posterior_sim02['y_pred'].mean(0)
sfit02 = sm_fit.sampling(data = {'T': T, 'y': y02})
posterior_fit02 = sfit02.extract()
ci02 = np.percentile(posterior_fit02['y_pred'], [2.5, 97.5], 0)

sfit = sm_sim.sampling(data = {'T': T, 'eta_mean': -1})
posterior_sim03 = sfit.extract()
y03 = posterior_sim03['y_pred'].mean(0)
sfit03 = sm_fit.sampling(data = {'T': T, 'y': y03})
posterior_fit03 = sfit03.extract()
ci03 = np.percentile(posterior_fit03['y_pred'], [2.5, 97.5], 0)

fig, ax = plt.subplots(1, 1, figsize=(7, 5))

ax.cla()
bp.curve(x, y01, color=bp.colors[0])
bp.curve(x, ci01[0], ls='dashed', color=bp.colors[0])
bp.curve(x, ci01[1], ls='dashed', color=bp.colors[0])
bp.curve(x, y02, color=bp.colors[1])
bp.curve(x, ci02[0], ls='dashed', color=bp.colors[1])
bp.curve(x, ci02[1], ls='dashed', color=bp.colors[1])
bp.curve(x, y03, color=bp.colors[3])
bp.curve(x, ci03[0], ls='dashed', color=bp.colors[3])
bp.curve(x, ci03[1], ls='dashed', color=bp.colors[3])
plt.title('Simulated trends', fontsize=18)
plt.xlabel('$t$', fontsize=18); plt.ylabel('$y_t$', fontsize=18)
plt.tight_layout()
plt.savefig('simulated_trends.pdf')

fig, ax = plt.subplots(1, 1, figsize=(7, 5))

ax.cla()
bp.density(posterior_sim01['eta'], color=bp.colors[0])
bp.density(posterior_sim02['eta'], color=bp.colors[1])
bp.density(posterior_sim03['eta'], color=bp.colors[3])
bp.rug(x=np.asarray([1]), color=bp.colors[0], markersize=20)
bp.rug(x=np.asarray([0.1]), color=bp.colors[1], markersize=20)
bp.rug(x=np.asarray([-1]), color=bp.colors[3], markersize=20)
plt.xlabel('$\eta$', fontsize=18); plt.ylabel('density', fontsize=18)
plt.tight_layout()
plt.savefig('posterior_densities_eta.pdf')
