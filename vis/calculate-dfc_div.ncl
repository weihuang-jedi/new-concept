load "categorical.ncl"

;----------------------------------------------------------------------
undef("add_coordinate")
procedure add_coordinate(alt:integer, lat:float, lon:float, var:double)
begin
  var!0 = "alt"
  var!1 = "lat"
  var!2 = "lon"
  var&alt = alt
  var&lat = lat
  var&lon = lon
  var@coordinate = "alt lat lon"
end

;----------------------------------------------------------------------
 g = 9.80665          ; m/s2
 r = 287.0

 diri = "/work2/noaa/gsienkf/weihuang/era5/data/"
 flnm = "monthly-mean-dec2021-height-level.nc"
 ofile = "monthly_mean_dec2021_densityFluxConvergence.nc"
;flnm = "hl_uvtp.nc"
;ofile = "df.nc"

 path = diri+flnm      

 f = addfile(path, "r")

 u = f->u(0,:,:,:)  ; m/s, (level,lat,lon)
 v = f->v(0,:,:,:)
 t = f->t(0,:,:,:)
 p = f->p(0,:,:,:)

;Vertical levels
 h = t&alt
 h@units = "M"
 alt = h
 lat = t&lat
 lon = t&lon

 ndh = toint(h(1) - h(0) + 0.5)

 dims = dimsizes(t)
 nalt = dims(0)
 z = conform_dims(dims,h,0)
 rho = p / (287.01*t)

;printVarSummary(z)
;printMinMax(z,0)
;printVarSummary(rho)
;printMinMax(rho,0)

 rho@units = "kg/kg"

 dims(0) = dims(0) - 1
 ua = new(dims, typeof(u))
 va = new(dims, typeof(v))
 dz = new(dims, typeof(h))
 ra = new(dims, typeof(rho))

 ra@units = "kg/kg"

 delete(t)
 delete(p)

 malt = dims(0)

 alta = 0.5*(alt(0:malt-1) + alt(1:malt))
 ua(0:malt-1,:,:) = 0.5*(u(0:malt-1,:,:) + u(1:malt,:,:))
 va(0:malt-1,:,:) = 0.5*(v(0:malt-1,:,:) + v(1:malt,:,:))
 ra(0:malt-1,:,:) = 0.5*(rho(0:malt-1,:,:) + rho(1:malt,:,:))
 dz(0:malt-1,:,:) = z(1:malt,:,:) - z(0:malt-1,:,:)

;ua = smth9_Wrap(ua, 0.50, 0.25, True)
;ua = smth9_Wrap(ua, 0.50, 0.25, True)

;va = smth9_Wrap(va, 0.50, 0.25, True)
;va = smth9_Wrap(va, 0.50, 0.25, True)

;ra = smth9_Wrap(ra, 0.50, 0.25, True)
;ra = smth9_Wrap(ra, 0.50, 0.25, True)

;printVarSummary(ua)
;printVarSummary(va)
;printVarSummary(ra)
;printVarSummary(dz)

;print(dz(::100,1,1))

 ialta = toint(alta)

 add_coordinate(ialta, lat, lon, ua)
 add_coordinate(ialta, lat, lon, va)
 add_coordinate(ialta, lat, lon, ra)
 add_coordinate(ialta, lat, lon, dz)

 print("Density flux components at each height level")
;Density flux components at each height level
 ur = ua*ra
 ur@long_name = "Zonal Density Flux [ur]"
 ur@units = "["+u@units+"]["+ra@units+"]"     ; [m/s][kg/m3]     
 copy_VarCoords(u(0:malt,:,:),ur)                        ; (level,lat,lon)

 vr = va*ra
 vr@long_name = "Meridional Density Flux [vr]"
 vr@units = "["+v@units+"]["+ra@units+"]" 
 copy_VarCoords(v(0:malt,:,:),vr)                        ; (level,lat,lon)

 print("-----")
 printVarSummary(ur)                         ; (level,lat,lon); (m/s)(kg/m3)
 printMinMax(ur,0)
 print("-----")
 printVarSummary(vr)
 printMinMax(vr,0)
 print("-----")

 print("Integrated mass weighted density flux components")
;Integrated mass weighted density flux components

 ur_dz = ur*dz                ; mass weighted 'ur'; [m/s][kg/m3][m]=>[m/s][kg/m2]
 iur    = dim_sum_n(ur_dz, 0)
 iur@long_name = "Integrated Zonal URho [ur*dz]" 
 iur@LONG_NAME = "Sum: Mass Weighted Integrated Zonal Density Flux [ur*dz]" 
 iur@units     = "[m2/s][kg/kg]"
 copy_VarCoords(u(0,:,:), iur); (lat,lon)
 delete(ur_dz)

 vr_dz = vr*dz                ; mass weighted 'vr'; [m/s][kg/m3][m]=>[m/s][kg/m2] 
 ivr    = dim_sum_n(vr_dz, 0)
 ivr@long_name = "Integrated Meridional VRho [vr*dz]" 
 ivr@LONG_NAME = "Sum: Mass Weighted Integrated Meridional Density Flux [vr*dz]" 
 ivr@units     = "[m2/s][kg/kg]"
 copy_VarCoords(v(0,:,:), ivr); (lat,lon)
 delete(vr_dz)

 print("Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid")
;Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid

 duvr  = uv2dvF_Wrap(ur, vr)    ; (level,lat,lon)
 add_coordinate(ialta, lat, lon, duvr)
 duvr@long_name = "Divergence of Density Flux"
 duvr@units     = "kg/(m2-s)"    ; (1/m)*[(m/s)(kg/m2)] => [kg/(m2-s)]

 print("Mass weighted integration [sum] of the divergence of density flux")
;Mass weighted integration [sum] of the divergence of density flux

 duvr_dz = duvr*dz            ;  [kg/(m2-s)][m] => [kg/(m-s)]
 add_coordinate(ialta, lat, lon, duvr_dz)
 iduvr    = dim_sum_n(duvr_dz, 0)
 iduvr@long_name = "Integrated Mass Wgt MFC" 
 iduvr@LONG_NAME = "Integrated Mass Weighted Density Flux Convergence" 
 iduvr@units     = "kg/(m-s)"
 copy_VarCoords(u(0,:,:), iduvr)      ; (lat,lon)

 VIMFC =  iduvr           ; keep meta data                         
 VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
 VIMFC@long_name = "VIMFC"

 oflnm = diri+ofile
 write_dfc_div(ialta, lat, lon, VIMFC, duvr_dz, oflnm)

