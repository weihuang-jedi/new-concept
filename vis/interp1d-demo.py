import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from scipy import interpolate

#---------------------------------------------------------
def interp1d(xi, yi, x, interp_method="linear"):
  if(interp_method == "nearest"):
   #Nearest (aka. piecewise) interpolation
   #takes the value of the nearest point
    interp = interpolate.interp1d(xi, yi, kind = "nearest")
    y = interp(x)
   #Pros
   #only takes values of existing yi.
   #Cons
   #Discontinuous
  elif(interp_method == "linear"):
   #Linear interpolation
   #depends linearly on its closest neighbours.
    interp = interpolate.interp1d(xi, yi, kind = "linear")
    y = interp(x)
   #Pros
   #stays in the limits of yi
   #Continuous
   #Cons
   #Discontinuous first derivative.
  elif(interp_method == "quadratic"):
   #Spline interpolation
    interp = interpolate.interp1d(xi, yi, kind = "quadratic")
    y = interp(x)
   #Pros
   #Smoother
   #Cons
   #Less predictable values between points.
  elif(interp_method == "cubic"):
   #Spline interpolation
    interp = interpolate.interp1d(xi, yi, kind = "cubic")
    y = interp(x)
   #Pros
   #Smoother
   #Cubic generally more reliable than quadratic
   #Cons
   #Less predictable values between points.

  return y

#---------------------------------------------------------
params = {'font.size'     : 14,
          'figure.figsize':(15.0, 8.0),
          'lines.linewidth': 2.,
          'lines.markersize': 15,}
matplotlib.rcParams.update(params)

#---------------------------------------------------------
#Let’s do it with Python
N = 10
xmin, xmax = 0., 2.0
xi = np.linspace(xmin, xmax, N)
yi = np.random.rand(N)

x = np.linspace(xmin, xmax, 1000)
y_nearest = interp1d(xi, yi, x, interp_method="nearest")
y_linear = interp1d(xi, yi, x, interp_method="linear")
y_quad = interp1d(xi, yi, x, interp_method="quadratic")
y_cubic = interp1d(xi, yi, x, interp_method="cubic")

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

