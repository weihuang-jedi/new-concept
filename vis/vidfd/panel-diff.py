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
  
# reading images
hlist = ['00Z', '06Z', '12Z', '18Z', '00Z']
namelist = []
for n in range(len(hlist)-1):
  iname = 'monthly_mean_gfs_vidfd_%s-%s_Dec_2021.png' %(hlist[n+1], hlist[n])
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
  
imgname = 'panel_monthly_mean_GFS_VIDFD_6h_diff_Dec_2021.png'
plt.tight_layout()
plt.savefig(imgname)
plt.show()

