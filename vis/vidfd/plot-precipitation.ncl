load "utils.ncl"
;----------------------------------------------------------------------
 pinfo = readinfo("varinfo.txt")
 phour = pinfo(0)
 pmonth = pinfo(1)
 pyear = pinfo(2)
;pvarname = pinfo(3)
 pvarname = "tp"

 print("phour=" + phour)
 print("pmonth=" + pmonth)
 print("pyear=" + pyear)
 print("pvarname=" + pvarname)

;----------------------------------------------------------------------
 info = readinfo("datainfo.txt")

 plottype = info(0)
 dirname = info(1)
 sfcfile = info(2)
 prefile = info(3)

;----------------------------------------------------------------------
 fisfc = dirname+sfcfile
 fipre = dirname+prefile

 fsfc = addfile(fisfc, "r")
 time = fsfc->time(:)
 tstr = get_tstr(time)

;print(tstr(0))

;----------------------------------------------------------------------
 idx = get_mean_index(time, phour, pmonth, pyear)
;print(idx)
 var = get_monthly_mean(idx, pvarname, fsfc)

 tn = "monthly mean " + pvarname + " " + phour + " " + pmonth + " " + pyear
 imgname = "monthly_mean_" + pvarname + "_" + phour + "_" + pmonth + "_" + pyear
 var = 1000.0*var
 plot_precipitation(var, tn, plottype, imgname)

