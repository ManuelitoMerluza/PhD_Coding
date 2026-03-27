"""
Oceanographic analysis functions
"""
# Import all functions available in this folder
from .interp2density import interpolate_to_density
from .bin2density import bin_to_density_grid
from .mov_mean import moving_average

# Version info
__version__ = '0.1'
__author__ = 'ManuelitoMerluza'

# Define what's available with "from ocean_function import *"
__all__ = [
    'interpolate_to_density',
    'bin_to_density_grid',
    'moving_average',
]