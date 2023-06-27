load "utils.ncl"

;----------------------------------------------------------------------
 pinfo = readinfo("varinfo.txt")
 phour = pinfo(0)
 pmonth = pinfo(1)
 pyear = pinfo(2)
 pvarname = pinfo(3)

 print("phour=" + phour)
 print("pmonth=" + pmonth)
 print("pyear=" + pyear)
 print("pvarname=" + pvarname)

;----------------------------------------------------------------------
 info = readinfo("datainfo.txt")

 plottype = info(0)
 dirname = info(1)
 sfcfile = info(2)
 prsfile = info(3)

;----------------------------------------------------------------------
 fiprs = dirname+prsfile

 fprs = addfile(fiprs, "r")
 prstime = fprs->time(:)
 prststr = get_tstr(prstime)

;print(prststr(0))

 prsidx = get_mean_index(prstime, phour, pmonth, pyear)
;print(prsidx)

 it = get_valid_index(prsidx)
 print(it)
 val = fprs->t(it,0,:,:)
 printVarSummary(val)
 prsvar = short2flt(val)
 printVarSummary(prsvar)

 tn = "monthly mean " + pvarname + " " + phour + " " + pmonth + " " + pyear
 imgname = "monthly_mean_" + pvarname + "_" + phour + "_" + pmonth + "_" + pyear
 plotit(prsvar, tn, "x11", imgname)

;----------------------------------------------------------------------
 fisfc = dirname+sfcfile

 fsfc = addfile(fisfc, "r")
 sfctime = fsfc->time(:)
 sfctstr = get_tstr(sfctime)

;print(sfctstr(0))

 sfcidx = get_mean_index(sfctime, phour, pmonth, pyear)
;print(sfcidx)
 sfcvar = get_monthly_mean(sfcidx, pvarname, fsfc)

 tn = "monthly mean " + pvarname + " " + phour + " " + pmonth + " " + pyear
 imgname = "monthly_mean_" + pvarname + "_" + phour + "_" + pmonth + "_" + pyear
 plotit(sfcvar, tn, "x11", imgname)

