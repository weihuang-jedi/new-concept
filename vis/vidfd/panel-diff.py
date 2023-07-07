# code for displaying multiple images in one figure
  
#import libraries
import imageio.v2 as imageio
from matplotlib import pyplot as plt
  
import tkinter
import matplotlib
matplotlib.use('TkAgg')

# create figure
fig = plt.figure(figsize=(10, 7))
  
# setting values to rows and column variables
rows = 4
columns = 1

#varname='MSL'
#varname='Temperature'
#varname='Specific_humidity'
varname='U-component_of_wind'
  
# reading images
hlist = ['00', '06', '12', '18', '00']
namelist = []
for n in range(len(hlist)-1):
  iname = 'images/trim_%sZ-%sZ_Monthly_Mean_%s.png' %(hlist[n+1], hlist[n], varname)
  print('iname: ', iname)
  namelist.append(iname)

imglist = []
for mn in namelist:
  img = imageio.imread(mn)
  imglist.append(img)

for n in range(rows*columns):
  imgnum = n + 1
 #Adds a subplot at postion imgnum
  fig.add_subplot(rows, columns, imgnum)
  
 #showing image
  plt.imshow(imglist[n])
  plt.axis('off')
 #plt.title(monthlist[n])
  
imgname = 'panel_Monthly_Mean_%s.png' %(varname)
plt.tight_layout()
plt.savefig(imgname)
plt.show()

