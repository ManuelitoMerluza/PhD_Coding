# Function for interpolating to density coordinates

import xarray as xr
from scipy import io
import numpy as np
import pandas as pd
import seawater as sw
import gsw
from scipy.interpolate import interp1d

def interpolate_to_density(data, gamman, gamma_grid, axis=0):
    """
    Interpolate data onto gamma_n grid for each station

    Parameters:
    data: 2D array (depth × stations)
    gamman: 2D array (depth × stations)
    gamma_grid: 1D array of target gamma_n values
    axis: axis along which to interpolate (0 = depth, 1 = stations)

    Returns:
    data_gamma: 2D array (gamma_grid × stations)
    """
    n_stations = data.shape[1]
    data_gamma = np.full((len(gamma_grid), n_stations), np.nan)

    for i in range(n_stations):
        gamma_profile = gamman[:, i]
        data_profile = data[:, i]

        # Remove NaNs
        mask = ~np.isnan(gamma_profile) & ~np.isnan(data_profile)

        if np.sum(mask) > 2:
            gamma_valid = gamma_profile[mask]
            data_valid = data_profile[mask]

            # Sort by gamma_n
            sort_idx = np.argsort(gamma_valid)
            gamma_sorted = gamma_valid[sort_idx]
            data_sorted = data_valid[sort_idx]

            # Remove duplicates
            _, unique_idx = np.unique(gamma_sorted, return_index=True)
            gamma_unique = gamma_sorted[unique_idx]
            data_unique = data_sorted[unique_idx]

            if len(gamma_unique) > 1:
                # Interpolate
                f = interp1d(gamma_unique, data_unique, 
                            bounds_error=False, 
                            fill_value=np.nan,
                            kind='linear')
                data_gamma[:, i] = f(gamma_grid)

    return data_gamma