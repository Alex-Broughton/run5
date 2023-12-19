import pickle
import numpy as np
import sys
from bfptc.ptcfit import symmetrize
import astropy.io.fits as pf

if __name__ == "__main__" :
    filename = sys.argv[1] if len(sys.argv)>1 else "allfits.pkl"
    f = pickle.load(open(filename,'br'))
    all_a = np.array([x.get_a() for x in f.values()])
    # complete to 4 quadrants, just for printout.
    print(" sum of average a", symmetrize(all_a.mean(axis=0)).sum())
    pf.writeto("a.fits", all_a.mean(axis=0))
    pf.writeto("siga.fits", all_a.std(axis=0))
