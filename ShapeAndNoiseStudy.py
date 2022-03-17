import galsim
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.pyplot import cm

# generate multiple of the same star (stochastic variation)
stars = []
for i in range(390):
    print(i)
    # random seed
    rng = galsim.BaseDeviate(i)

    # add 4.5 microns sigma of Gaussian to model diffusion
    # convert 4.5 microns to arcsec with factor 0.2"/10micron 
    pixscale = 0.2/10.e-6
    dprof = galsim.Gaussian(sigma=(9.0e-6)*pixscale)

    # Airy function to simulate diffraction through mask
    lam_over_diam = 0.00000491  # radians
    lam_over_diam *= 206265  # Convert to arcsec
    airy = galsim.Airy(lam_over_diam)


    # aadd shear term
    sprof = galsim.Shear(g1=0.05, g2=0.03)
    
    # add foreground light in photons/cm^2/s
    fprof = galsim.Box(66,66,flux=60000)

    # convolve these terms
    prof = galsim.Convolve([dprof,airy]).withFlux(10000+(i*5000))
    prof = galsim.Add([prof,fprof])

    # draw image
    blank_image = galsim.Image(66,66,scale=0.2,xmin=0,ymin=0,dtype=np.float64)  
    star_image = prof.drawImage(image=blank_image, scale=0.2, method="phot", save_photons=True)

    # add BF effect
    sensor = galsim.SiliconSensor(strength = 1., diffusion_factor=1., nrecalc=1000)
    photons = galsim.PhotonArray.makeFromImage(star_image)

    # generate noise and add to image
    noise = galsim.CCDNoise(rng, gain=1.5, read_noise=11.3, sky_level=0.0)
    star_image.addNoise(noise)
    
    stars.append(star_image)

# generate multiple stars with different noise levels
moments_sigma = [] # sigma
moments_amp = [] # flux
observed_shape = [] # shear
moments_centroid = [] # centroid
peak_signal = []
read_noise = []

for i,star in enumerate(stars):
    # calculate HSM moments (these are in pixel coordinates) for each star
    mom = star.FindAdaptiveMom(weight=None, strict=False)
    moments_sigma.append(mom.moments_sigma)
    moments_amp.append(mom.moments_amp)
    observed_shape.append(mom.observed_shape)
    moments_centroid.append(mom.moments_centroid)
    peak_signal.append(np.max(stars[i].array))
    read_noise.append(11.3)

    
# plot it
f,ax = plt.subplots(1,1)
print(np.mean(moments_sigma[-10:-1]))
im = ax.scatter(peak_signal,moments_sigma, s=4)
plt.ylabel("HSM sigma")
plt.xlabel("Peak signal [e-]")
plt.savefig("bf-simulation.png")
