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
procedure write_mfc(vimfc:float, flnm:string)
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

  delete(ncdf)
end

;----------------------------------------------------------------------
undef("write_dfc")
function cal_mfc(u:float, v:float, q:float, ps:float)
begin
  g = 9.80665          ; m/s2

 ;Vertical levels
  plev = q&lv_ISBL0                   ; [100000,...,30000] Pa [kg/(m-s2)]
  plev@units = "Pa"

  ptop = plev(1)
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
  uq@long_name = "Zonal Moisture Flux [uq]"
  uq@units = "["+u@units+"]["+q@units+"]"     ; [m/s][g/kg]     
  copy_VarCoords(u,uq)                        ; (level,lat,lon)

  vq = v*q
  vq@long_name = "Meridional Moisture Flux [vq]"
  vq@units = "["+v@units+"]["+q@units+"]" 
  copy_VarCoords(v,vq)                        ; (level,lat,lon)

 ;Integrated mass weighted moisture flux components

  uq_dpg = uq*dpg                ; mass weighted 'uq'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
  iuq    = dim_sum_n(uq_dpg, 0)
  iuq@long_name = "Integrated Zonal UQ [uq*dpg]" 
  iuq@LONG_NAME = "Sum: Mass Weighted Integrated Zonal Moisture Flux [uq*dpg]" 
  iuq@units     = "[m/s][g/kg]"
  copy_VarCoords(u(0,:,:), iuq); (lat,lon)
  delete(uq_dpg)

  vq_dpg = vq*dpg                ; mass weighted 'vq'; [m/s][g/kg][kg/m2]=>[m/s][g/kg] 
  ivq    = dim_sum_n(vq_dpg, 0)
  ivq@long_name = "Integrated Meridional VQ [vq*dpg]" 
  ivq@LONG_NAME = "Sum: Mass Weighted Integrated Meridional Moisture Flux [vq*dpg]" 
  ivq@units     = "[m/s][g/kg]"
  copy_VarCoords(v(0,:,:), ivq); (lat,lon)
  delete(vq_dpg)

 ;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

  duvq  = uv2dvF_Wrap(uq, vq)    ; (level,lat,lon)
  duvq@long_name = "Divergence of Moisture Flux"
  duvq@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
 
 ;Mass weighted integration [sum] of the divergence of moisture flux

  duvq_dpg = duvq*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
  iduvq    = dim_sum_n(duvq_dpg, 0)
  iduvq@long_name = "Integrated Mass Wgt MFC" 
  iduvq@LONG_NAME = "Integrated Mass Weighted Moisture Flux Convergence" 
  iduvq@units     = "g/(m2-s)"
  delete(duvq_dpg)

  VIMFC =  iduvq           ; keep meta data                         
  VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
  copy_VarCoords(u(0,:,:), VIMFC)      ; (lat,lon)
  VIMFC@long_name = "VIMFC"

  return VIMFC
end
