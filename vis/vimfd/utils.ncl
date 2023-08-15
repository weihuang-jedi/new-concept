;----------------------------------------------------------------------
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
undef("write_mfc")
procedure write_mfc(vimfc:float, duvq:float, div:float, flnm:string)
begin
  system("/bin/rm -f " + flnm)   ; remove any pre-existing file
  ncdf = addfile(flnm, "c")  ; open output netCDF file

 ;===================================================================
 ; create global attributes of the file (optional)
 ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL calculated Moisture Flux Divergence"
  fAtt@source_file   = "Calculated from NCL script: cal-mfc-div"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( ncdf, fAtt )            ; copy file attributes

 ;===================================================================
 ; output variables directly; NCL will call appropriate functions
 ; to write the meta data associated with each variable
 ;===================================================================
  ncdf->vimfc = vimfc
  ncdf->duvq = duvq
  ncdf->div = div

  delete(ncdf)
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
  pvar := var
  plt = gsn_csm_contour_map(wks,pvar,res)
end

;----------------------------------------------------------------------
undef("cal_vimfd")
function cal_vimfd(u:float, v:float, q:float, ps:float)
begin
  g = 9.80665          ; m/s2

 ;Vertical levels
  plev = 100.0*q&level
  plev@units = "Pa"

  ptop = plev(0)
  ptop@units = "Pa"

 ;Change [kg/kg] to [g/kg]; not necessary: but common units for q

  q    = q*1000            
  q@units = "g/kg"

 ;Layer thickness: ; Pa=>[kg/(m-s2)], (level,lat,lon) 
 ;Mass weighting: (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
 ;Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

  dp = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness 

  dimdp = dimsizes(dp)

 ;print(dimdp)

  dpg  = dp/g    
  dpg@long_name = "Layer Mass Weighting"
  dpg@units     = "kg/m2"                     ; dp/g, Pa/(m s-2), reduce to kg m-2

 ;Moisture flux components at each pressure level

  uq = u*q
  vq = v*q

 ;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

  duvq  = uv2dvF_Wrap(uq, vq)    ; (level,lat,lon)
 
 ;Mass weighted integration [sum] of the divergence of moisture flux

  duvq_dpg = duvq*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
  iduvq    = dim_sum_n(duvq_dpg, 0)
  iduvq@long_name = "Integrated Mass Wgt MFC" 
  iduvq@units     = "g/(m2-s)"
  delete(duvq_dpg)

  VIMFC =  iduvq           ; keep meta data                         
  VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
  copy_VarCoords(u(0,:,:), VIMFC)      ; (lat,lon)
  VIMFC@long_name = "Vertical Integrated Mass Weighted Moisture Flux Convergence" 

  return VIMFC
end

;----------------------------------------------------------------------
undef("cal_mfd")
function cal_mfd(u:float, v:float, q:float)
begin
 ;Change [kg/kg] to [g/kg]; not necessary: but common units for q

  q    = q*1000            
  q@units = "g/kg"

 ;Moisture flux components at each pressure level

  uq = u*q
  vq = v*q

 ;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

  duvq  = uv2dvF_Wrap(uq, vq)    ; (level,lat,lon)
  duvq@long_name = "Divergence of Moisture Flux"
  duvq@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
  copy_VarCoords(u, duvq)
 
  return duvq
end

;----------------------------------------------------------------------
undef("cal_div")
function cal_div(u:float, v:float)
begin
  scale = 1.0e6
 ;Divergence

  div  = uv2dvF_Wrap(u, v)    ; (level,lat,lon)
  div@long_name = "Divergence"
  div@units     = "1/s"
  copy_VarCoords(u, div)
 
  div = scale*div

  return div
end
