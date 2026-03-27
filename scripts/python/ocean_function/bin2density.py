# Function for binning data to density coordinates

import xarray as xr
from scipy import io
import numpy as np
import pandas as pd
import seawater as sw
import gsw
from scipy.interpolate import interp1d

def bin_to_density_grid(data, gamman, gamma_bins):
    """
    Bin data into regular gamma_n bins by averaging

    Parameters:
    data: 2D array (depth × stations)
    gamman: 2D array (depth × stations)
    gamma_bins: 1D array of bin edges

    Returns:
    data_binned: 2D array (len(gamma_bins)-1 × stations)
    """
    n_stations = data.shape[1]
    n_bins = len(gamma_bins) - 1
    data_binned = np.full((n_bins, n_stations), np.nan)

    for i in range(n_stations):
        gamma_profile = gamman[:, i]
        data_profile = data[:, i]

        # Remove NaNs
        mask = ~np.isnan(gamma_profile) & ~np.isnan(data_profile)
        gamma_valid = gamma_profile[mask]
        data_valid = data_profile[mask]

        # Bin the data
        bin_indices = np.digitize(gamma_valid, gamma_bins) - 1

        # Average within each bin
        for bin_idx in range(n_bins):
            # Get data in this bin
            in_bin = (bin_indices == bin_idx)
            if np.any(in_bin):
                data_binned[bin_idx, i] = np.mean(data_valid[in_bin])

    return data_binned, gamma_bins