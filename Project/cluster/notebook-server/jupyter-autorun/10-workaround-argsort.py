"""
This is a workaround for the argsort function in arkouda. 
As it will crash the server if it is called on a Strings array, 
this problem is already know and hopefully will be fixed in the future.

This has now been disabled as the version mismatch between the server and the client has been fixed,
in the deployment. But i will leave this here for as it has been described in the thesis.
"""

# import numpy as np
# import arkouda as ak


# original_argsort = ak.argsort

# def new_argsort(*args, **kwargs):
#     if isinstance(args[0], ak.Strings):
#         letters = args[0]  
#         return np.argsort(letters.to_ndarray())
#     else:
#         return original_argsort(*args, **kwargs)

# ak.argsort = new_argsort
