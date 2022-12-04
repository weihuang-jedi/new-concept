from scipy import interpolate
x = np.linspace(xmin, xmax, 1000)
interp = interpolate.interp1d(xi, yi, kind = "linear")
y_linear = interp(x)

