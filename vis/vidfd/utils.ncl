undef("readinfo")
function readinfo(filename:string)
begin
 ;Read data into a one-dimensional string array of unknown length:
 ;filename = "datainfo.txt"
  info     = asciiread(filename,-1,"string")
  nlines   = dimsizes(info)

  print("The <" + filename + "> has " + nlines + " lines.")
  print("<" + info + ">")    ; Print the lines

  return info
end

;----------------------------------------------------------------------
undef("get_half_lat_3d_var")
function get_half_lat_3d_var(name:string, it:integer, f:file)
begin
  fv = short2flt(f->$name$(it,:,:,:))

 ;lev = fv&level
 ;lat = fv&latitude
 ;lon = fv&longitude

 ;dims = dimsizes(fv)
 ;nlev = dims(0)
 ;nlat = dims(1)
 ;nlon = dims(2)

 ;hv = 0.5*(fv(:,nlat-2:0:-1,:) + fv(:,nlat-1:1:-1,:))
 ;hlat = 0.5*(lat(nlat-2:0:-1) + lat(nlat-1:1:-1))

 ;hv@_FillValue = fv@_FillValue
 ;hv@missing_value = fv@missing_value
 ;hv@units = fv@units
 ;hv@long_name = fv@long_name
 ;hv@standard_name = fv@standard_name

 ;hv!0 = "level"
 ;hv!1 = "latitude"
 ;hv!2 = "longitude"

 ;hv&level = lev
 ;hv&latitude = hlat
 ;hv&longitude = lon

  hv = fv(:,::-1,:)

  return hv
end

;----------------------------------------------------------------------
undef("convert2halflatgrid")
function convert2halflatgrid(fv:float)
begin
 ;lat = fv&latitude
 ;lon = fv&longitude

 ;dims = dimsizes(fv)
 ;nlat = dims(0)
 ;nlon = dims(1)

 ;hv = 0.5*(fv(nlat-2:0:-1,:) + fv(nlat-1:1:-1,:))
 ;hlat = 0.5*(lat(nlat-2:0:-1) + lat(nlat-1:1:-1))

 ;printVarSummary(fv)
 ;printVarSummary(hv)

 ;hv@_FillValue = fv@_FillValue
 ;hv@missing_value = fv@missing_value
 ;hv@units = fv@units
 ;hv@long_name = fv@long_name

 ;hv!0 = "latitude"
 ;hv!1 = "longitude"

 ;hv@latitude = hlat
 ;hv@longitude = lon

 ;return hv
  
  fv = fv(:,::-1,:)
  return fv
end

;----------------------------------------------------------------------
undef("write_vidfd")
procedure write_vidfd(vidfd:float, flnm:string)
begin
  system("/bin/rm -f " + flnm)   ; remove any pre-existing file
  ncdf = addfile(flnm, "c")  ; open output netCDF file

 ;===================================================================
 ; create global attributes of the file (optional)
 ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL calculated Density Flux Divergence"
  fAtt@source_file   = "Calculated from NCL script: dfd-div"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( ncdf, fAtt )            ; copy file attributes

 ;===================================================================
 ; output variables directly; NCL will call appropriate functions
 ; to write the meta data associated with each variable
 ;===================================================================
  ncdf->vidfd = vidfd

  delete(ncdf)
end

;----------------------------------------------------------------------
undef("get_res")
function get_res(tstr:string)
begin
  title = "ERA5 VIDFD " + tstr

  res                   = True             ; plot mods desired
  res@gsnDraw           = True
  res@gsnFrame          = True
  res@lbLabelBarOn      = True        

  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnLineLabelsOn    = False            ; turn off contour lines
  res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  res@lbLabelBarOn      = True             ; turn off individual cb's
  res@mpFillOn          = False            ; turn off map fill
                                           ; Use a common scale
  res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
  res@cnMaxLevelValF       = 10.0                  ; min level
  res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
  res@cnLevelSpacingF      =  1.0                  ; contour interval

  res@tiMainString         = title

  return res
end

;----------------------------------------------------------------------
undef("get_default_res")
function get_default_res(title:string)
begin
  res                   = True             ; plot mods desired
  res@gsnDraw           = True
  res@gsnFrame          = True
  res@lbLabelBarOn      = True

  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnLineLabelsOn    = False            ; turn off contour lines
  res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  res@lbLabelBarOn      = True             ; turn off individual cb's
  res@mpFillOn          = False            ; turn off map fill
                                           ; Use a common scale
  res@cnLevelSelectionMode = "AutomaticLevels"

  res@tiMainString         = title

  return res
end

;----------------------------------------------------------------------
undef("plot_vidfc")
procedure plot_vidfc(VIDFD:float, plottype:string, tstr:string)
begin
  ntstr = str_sub_str(tstr, " ", "_")
  ntstr = str_sub_str(ntstr, " ", "_")
  imgname = "vidfd_" + ntstr
  wks = gsn_open_wks(plottype, imgname)
  res = get_res(tstr)

 ;--------------------------------------------------------------------------------------
 ;Integrated Divergence of Density Flux Convergence [no scaling]
 ;print("-----")
 ;print("VIDFD")
 ;printVarSummary(VIDFD)
  printMinMax(VIDFD, 0)

  VIDFD = 1000.0*VIDFD
  VIDFD@units = "g/(m2-s)"

 ;--------------------------------------------------------------------------------------
  pvar := VIDFD(::4,::4)
  plt = gsn_csm_contour_map(wks,pvar,res)

 ;--------------------------------------------------------------------------------------
  pvar := VIDFD(::2,::2)
  plt = gsn_csm_contour_map(wks,pvar,res)

 ;--------------------------------------------------------------------------------------
  pvar := VIDFD
  plt = gsn_csm_contour_map(wks,pvar,res)
end

;----------------------------------------------------------------------
undef("plotit")
procedure plotit(var:float, name:string, plottype:string, imgname:string)
begin
  wks = gsn_open_wks(plottype, imgname)
  res = get_default_res(name)

 ;--------------------------------------------------------------------------------------
 ;Integrated Divergence of Density Flux Convergence [no scaling]
  printMinMax(var, 0)

 ;--------------------------------------------------------------------------------------
  pvar := var(::4,::4)
  plt = gsn_csm_contour_map(wks,pvar,res)

 ;--------------------------------------------------------------------------------------
  pvar := var(::2,::2)
  plt = gsn_csm_contour_map(wks,pvar,res)

 ;--------------------------------------------------------------------------------------
  pvar := var
  plt = gsn_csm_contour_map(wks,pvar,res)
end

;----------------------------------------------------------------------
undef("get_tstr")
function get_tstr(time:integer)
begin
 ;Convert to UTC time.
  utc_date = cd_calendar(time, 0)

 ;Store return information into more meaningful variables.

  year   = tointeger(utc_date(:,0))    ; Convert to integer for
  month  = tointeger(utc_date(:,1))    ; use sprinti
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
 ;minute = tointeger(utc_date(:,4))
 ;second = utc_date(:,5)

 ;Array to hold month abbreviations. Don't store anything in index
 ;'0' (i.e. let index 1=Jan, 2=Feb, ..., index 12=Dec).
  month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun", \
                 "Jul","Aug","Sep","Oct","Nov","Dec"/)

 ;Write out strings in the format "hhZ mmm yyyy".

  date_str = sprinti("%0.2iZ ", hour) + \
             month_abbr(month) + " "  + sprinti("%0.4i", year)

 ;print(date_str)

  return date_str
end

;----------------------------------------------------------------------
undef("get_mean_index")
function get_mean_index(time:integer, hname:string, mname:string, yname:string)
begin
  index = time
  nt = dimsizes(time)
  
 ;Convert to UTC time.
  utc_date = cd_calendar(time, 0)

 ;Store return information into more meaningful variables.

  year   = tointeger(utc_date(:,0))    ; Convert to integer for
  month  = tointeger(utc_date(:,1))    ; use sprinti 
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
 ;minute = tointeger(utc_date(:,4))
 ;second = utc_date(:,5)

 ;Array to hold month abbreviations. Don't store anything in index
 ;'0' (i.e. let index 1=Jan, 2=Feb, ..., index 12=Dec).
  month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun", \
                 "Jul","Aug","Sep","Oct","Nov","Dec"/)

 ;Write out strings in the format "hhZ dd mmm yyyy".

 ;date_str = sprinti("%0.2iZ ", hour) + \
 ;           month_abbr(month) + " "  + sprinti("%0.4i", year)
 
 ;print(date_str) 

  hstr = sprinti("%0.2iZ", hour)
  ystr = sprinti("%0.4i", year)
 
  do n = 0, nt - 1
    index(n) = 0
    mstr = month_abbr(month(n))
    if(hname .eq. hstr(n)) then
      if(mname .eq. mstr) then
        if(yname .eq. ystr(n)) then
          index(n) = 1
         ;print("hmy = <" + hname + "> <" + mname + "> <" + yname + ">")
         ;print("No. " +  n + ": <" + hstr(n) + "> <" + mstr + "> <" + ystr(n) + ">")
         ;print("index(" + n + ") = " + index(n))
        end if
      end if
    end if

   ;print("hmy = <" + hname + "> <" + mname + "> <" + yname + ">")
   ;print("No. " +  n + ": <" + hstr(n) + "> <" + mstr + "> <" + ystr(n) + ">")
   ;print("index(" + n + ") = " + index(n))
  end do

  return index
end

;----------------------------------------------------------------------
undef("get_monthly_mean")
function get_monthly_mean(index:integer, name:string, f:file)
begin
  nt = dimsizes(index)

  val = f->$name$(0,:,:)
  fval = short2flt(val)
  buf = new(dimsizes(fval),typeof(fval),fval@_FillValue)
  buf = 0.0
  wgt = 0.0

  do n = 0, nt - 1
    if(1 .eq. index(n)) then
      val = f->$name$(n,:,:)
      fval = short2flt(val)
      wgt = wgt + 1.0
      buf = buf + fval
    end if
  end do

 ;print(wgt)

  buf = buf/wgt

  copy_VarAtts(val, buf)
  copy_VarCoords(val, buf)

 ;printVarSummary(buf)

  return buf
end


;----------------------------------------------------------------------
undef("get_valid_index")
function get_valid_index(index:integer)
begin
  id = -1
  nt = dimsizes(index)
  do n = 0, nt - 1
    if(1 .eq. index(n)) then
      id = n
      break
    end if
  end do

  return id
end
 
;----------------------------------------------------------------------
undef("get_vidfd")
function get_vidfd(u:float, v:float, t:float, ps:float)
begin
  rho = t
  copy_VarCoords(t,rho)
  rho@units = "kg/kg"

  plev = 100.0*tofloat(t&level)
  plev@units = "Pa"

  ptop = plev(0)

  g = 9.80665          ; m/s2
  R = 287.0
  dims = dimsizes(t)
  do k = 0, dims(0)-1
    rho(k,:,:) = plev(k)/(R*t(k,:,:))
  end do

 ;----------------------------------------------------------------------
 ;Layer thickness: ; Pa=>[kg/(m-s2)], (level,lat,lon) 
 ;Mass weighting: (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
 ;Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

  dp = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness 

  dimdp = dimsizes(dp)

 ;print(dimdp)

  dpg  = dp/g    
  dpg@long_name = "Layer Mass Weighting"
  dpg@units     = "kg/m2"                     ; dp/g, Pa/(m s-2), reduce to kg m-2

 ;----------------------------------------------------------------------
 ;Density flux components at each pressure level

  urho = u*rho
  urho@long_name = "Zonal Density Flux [urho]"
  urho@units = "["+u@units+"]["+rho@units+"]"     ; [m/s][kg/kg]     
 ;copy_VarCoords(u,urho)                        ; (level,lat,lon)

  vrho = v*rho
  vrho@long_name = "Meridional Density Flux [vrho]"
  vrho@units = "["+v@units+"]["+rho@units+"]" 
 ;copy_VarCoords(v,vrho)                        ; (level,lat,lon)

 ;----------------------------------------------------------------------
 ;Integrated mass weighted moisture flux components

  urho_dpg = urho*dpg                ; mass weighted 'urho'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
  iurho    = dim_sum_n(urho_dpg, 0)
  iurho@long_name = "Integrated Zonal URho [urho*dpg]" 
  iurho@LONG_NAME = "Sum: Mass Weighted Integrated Zonal Density Flux [urho*dpg]" 
  iurho@units     = "[m/s][g/kg]"
 ;copy_VarCoords(u(0,:,:), iurho); (lat,lon)
  delete(urho_dpg)

  vrho_dpg = vrho*dpg                ; mass weighted 'vrho'; [m/s][g/kg][kg/m2]=>[m/s][g/kg] 
  ivrho    = dim_sum_n(vrho_dpg, 0)
  ivrho@long_name = "Integrated Meridional VRho [vrho*dpg]" 
  ivrho@LONG_NAME = "Sum: Mass Weighted Integrated Meridional Density Flux [vrho*dpg]" 
  ivrho@units     = "[m/s][g/kg]"
 ;copy_VarCoords(v(0,:,:), ivrho); (lat,lon)
  delete(vrho_dpg)

 ;----------------------------------------------------------------------
 ;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

  duvrho  = uv2dvF_Wrap(urho, vrho)    ; (level,lat,lon)
  duvrho@long_name = "Divergence of Density Flux"
  duvrho@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
  delete(urho)
  delete(vrho)

 ;----------------------------------------------------------------------
 ;Mass weighted integration [sum] of the divergence of moisture flux
 
  duvrho_dpg = duvrho*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
  iduvrho    = dim_sum_n(duvrho_dpg, 0)
  iduvrho@long_name = "Integrated Mass Wgt DFC" 
  iduvrho@LONG_NAME = "Integrated Mass Weighted Density Flux Convergence" 
  iduvrho@units     = "g/(m2-s)"
  copy_VarCoords(u(0,:,:), iduvrho)      ; (lat,lon)
  delete(duvrho_dpg)

  VIDFD =  iduvrho           ; keep meta data                         
  VIDFD = -1000.0*VIDFD           ; Note the preceding -1 [negative precedes integration] 
  VIDFD@long_name = "VIDFD"
  VIDFD@units     = "g/(m2-s)"
  delete(iduvrho)

  return VIDFD
end

;----------------------------------------------------------------------
undef("get_tstr")
function get_tstr(time:integer)
begin
 ;Convert to UTC time.
  utc_date = cd_calendar(time, 0)

 ;Store return information into more meaningful variables.

  year   = tointeger(utc_date(:,0))    ; Convert to integer for
  month  = tointeger(utc_date(:,1))    ; use sprinti
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
 ;minute = tointeger(utc_date(:,4))
 ;second = utc_date(:,5)

 ;Array to hold month abbreviations. Don't store anything in index
 ;'0' (i.e. let index 1=Jan, 2=Feb, ..., index 12=Dec).
  month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun", \
                 "Jul","Aug","Sep","Oct","Nov","Dec"/)

 ;Write out strings in the format "hhZ mmm yyyy".

  date_str = sprinti("%0.2iZ ", hour) + \
             month_abbr(month) + " "  + sprinti("%0.4i", year)

 ;print(date_str)

  return date_str
end

;----------------------------------------------------------------------
undef("get_res4evaporation")
function get_res4evaporation(title:string)
begin
  res                   = True             ; plot mods desired
  res@gsnDraw           = True
  res@gsnFrame          = True
  res@lbLabelBarOn      = True

  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnLineLabelsOn    = False            ; turn off contour lines
  res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  res@lbLabelBarOn      = True             ; turn off individual cb's
  res@mpFillOn          = False            ; turn off map fill
                                           ; Use a common scale
 ;res@lbOrientation        = "Vertical"     ; vertical label bar
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-0.5, -0.2, -0.1, -0.05, -0.02, -0.01, -0.005, 0.005/)
  res@cnFillColors         = (/"navyblue", "blue", "royalblue", "skyblue", \
                               "cyan", "springgreen", "green", "white", "yellow"/)
  res@tiMainString         = title

  return res
end

;----------------------------------------------------------------------
undef("plot_evaporation")
procedure plot_evaporation(var:float, name:string, plottype:string, imgname:string)
begin
  wks = gsn_open_wks(plottype, imgname)
  res = get_res4evaporation(name)

 ;--------------------------------------------------------------------------------------
 ;Integrated Divergence of Density Flux Convergence [no scaling]
  printMinMax(var, 0)

 ;--------------------------------------------------------------------------------------
  pvar := var(::4,::4)
  plt = gsn_csm_contour_map(wks,pvar,res)

 ;--------------------------------------------------------------------------------------
  pvar := var(::2,::2)
  plt = gsn_csm_contour_map(wks,pvar,res)

 ;--------------------------------------------------------------------------------------
  pvar := var
  plt = gsn_csm_contour_map(wks,pvar,res)
end

