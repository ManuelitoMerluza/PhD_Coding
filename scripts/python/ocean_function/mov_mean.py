# Running mean function

import xarray as xr
from scipy import io
import numpy as np
import pandas as pd
import seawater as sw
import gsw
from scipy.interpolate import interp1d

def moving_average(x, n, window="flat"):
    if n % 2 == 0:
        n += 1
    N = x.size
    cx = np.full(x.size, np.nan)
    for i in range(N):
        ii = np.arange(i-n//2, i+n//2+1,1)
        if window == "flat":
            ww = np.ones(ii.size)
        elif window == "gauss":
            xx = ii - i
            ww = np.exp(- xx**2/(float(n)/4)**2 )
        elif window == "hanning":
            ww = np.hanning(ii.size)
        ww = ww[(ii >= 0) & (ii < N)]
        ii = ii[(ii >= 0) & (ii < N)]
        kk = np.isfinite(x[ii])
        if np.sum(kk) < 0.25*ii.size:
            continue
        cx[i] = np.sum(x[ii[kk]]*ww[kk])/np.sum(ww[kk])
    return cx