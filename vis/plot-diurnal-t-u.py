
# importing package
import matplotlib.pyplot as plt
import numpy as np
  
npt = 2881
w = 2.0*np.pi/1440.0

# create data
x = np.zeros((npt,))
t1 = np.zeros((npt,))
t2 = np.zeros((npt,))
T = np.zeros((npt,))
U = np.zeros((npt,))

print('x = ', x)
print('w = ', w)

for n in range(npt):
  x[n] = float(n)
  t1[n] = w*x[n]
  t2[n] = 0.5*w*x[n]
  T[n] = np.sin(t1[n])
  U[n] = np.sin(t2[n])
  
# plot lines
plt.plot(x, T, label = "T")
plt.plot(x, U, label = "U")
plt.legend()
plt.grid()
plt.show()

