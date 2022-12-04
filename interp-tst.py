import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from scipy import interpolate

#---------------------------------------------------------
params = {'font.size'     : 14,
          'figure.figsize':(15.0, 8.0),
          'lines.linewidth': 2.,
          'lines.markersize': 15,}
matplotlib.rcParams.update(params)

#---------------------------------------------------------
#Let’s do it with Python
N = 10
xmin, xmax = 0., 1.5
xi = np.linspace(xmin, xmax, N)
yi = np.random.rand(N)

plt.plot(xi,yi, 'o', label = "$Pi$")
plt.grid()
plt.xlabel("x")
plt.ylabel("y")
plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
plt.show()

#---------------------------------------------------------
#Nearest (aka. piecewise) interpolation
#Function 𝑦(𝑥) takes the value 𝑦𝑖 of the nearest point 𝑃𝑖 on the 𝑥 direction.

x = np.linspace(xmin, xmax, 1000)
interp = interpolate.interp1d(xi, yi, kind = "nearest")
y_nearest = interp(x)

plt.plot(xi,yi, 'o', label = "$Pi$")
plt.plot(x, y_nearest, "-", label = "Nearest")
plt.grid()
plt.xlabel("x")
plt.ylabel("y")
plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
plt.show()

#Pros
#𝑦(𝑥) only takes values of existing 𝑦𝑖.
#Cons
#Discontinuous

#---------------------------------------------------------
#Linear interpolation
#Function 𝑦(𝑥) depends linearly on its closest neighbours.

x = np.linspace(xmin, xmax, 1000)
interp = interpolate.interp1d(xi, yi, kind = "linear")
y_linear = interp(x)

plt.plot(xi,yi, 'o', label = "$Pi$")
plt.plot(x, y_nearest, "-", label = "Nearest")
plt.plot(x, y_linear, "-", label = "Linear")
plt.grid()
plt.xlabel("x")
plt.ylabel("y")
plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
plt.show()

#Pros
#𝑦(𝑥) stays in the limits of 𝑦𝑖
#Continuous
#Cons
#Discontinuous first derivative.

#---------------------------------------------------------
#Spline interpolation

x = np.linspace(xmin, xmax, 1000)
interp2 = interpolate.interp1d(xi, yi, kind = "quadratic")
interp3 = interpolate.interp1d(xi, yi, kind = "cubic")
y_quad = interp2(x)
y_cubic = interp3(x)

plt.plot(xi,yi, 'o', label = "$Pi$")
plt.plot(x, y_nearest, "-", label = "Nearest")
plt.plot(x, y_linear,  "-", label = "Linear")
plt.plot(x, y_quad,    "-", label = "Quadratic")
plt.plot(x, y_cubic,   "-", label = "Cubic")
plt.grid()
plt.xlabel("x")
plt.ylabel("y")
plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
plt.show()

#Pros
#Smoother
#Cubic generally more reliable that quadratic
#Cons
#Less predictable values between points.

