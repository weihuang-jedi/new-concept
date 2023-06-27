 load "panel_ddf.ncl"

;===================================================================
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 flnm = "monthly_mean_divergence_of_density_flux_202201.nc"
 path = diri+flnm      
 f = addfile(path, "r")

 iduvr = f->iduvr(:, :)

 iduvr = smth9_Wrap(iduvr, 0.50, 0.25, True)
 iduvr = smth9_Wrap(iduvr, 0.50, 0.25, True)
 iduvr = smth9_Wrap(iduvr, 0.50, 0.25, True)
 iduvr = smth9_Wrap(iduvr, 0.50, 0.25, True)

 printVarSummary(iduvr)
 printMinMax(iduvr,0)

;plottype = "x11"
 plottype = "png"
 imgname = "viddf"

 plot_div_density_flux(iduvr, plottype, imgname)

