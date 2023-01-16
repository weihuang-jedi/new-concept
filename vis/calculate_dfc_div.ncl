;----------------------------------------------------------------------
undef("write2file")
procedure write2file(duvr:float, iduvr:float, flnm:string)
begin
  system("/bin/rm -f " + flnm)   ; remove any pre-existing file
  ncdf = addfile(flnm, "c")  ; open output netCDF file

 ;===================================================================
 ; create global attributes of the file (optional)
 ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL Write Divergence of Density Flux file"
  fAtt@source_file   = "Calculated from NCL script"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( ncdf, fAtt )            ; copy file attributes

 ;===================================================================
 ; output variables directly; NCL will call appropriate functions
 ; to write the meta data associated with each variable
 ;===================================================================
  ncdf->duvr = duvr
  ncdf->iduvr = iduvr

 ;delete(ncdf)
end

;===================================================================
 g = 9.80665          ; m/s2
 r = 287.0

 diri = "/work2/noaa/gsienkf/weihuang/era5/data/"
 flnm = "hl_monthly_mean_uvtp.nc"

 path = diri+flnm      

 print("path: " + path)

 f = addfile(path, "r")

 u = f->u(0,:,:,:)  ; m/s, (level,lat,lon)
 v = f->v(0,:,:,:)
 t = f->t(0,:,:,:)
 p = f->p(0,:,:,:)
 rho = p / (287.01*t)

 printVarSummary(u)
 printVarSummary(v)
 printVarSummary(t)
 printVarSummary(p)
 printVarSummary(rho)
 printMinMax(rho,0)

;Vertical levels
 h = t&alt
 h@units = "M"

 ndh = toint(h(1) - h(0) + 0.5)

 dims = dimsizes(t)
 nalt = dims(0)
 z = conform_dims(dims,h,0)

 printVarSummary(z)
 printMinMax(z,0)

 rho@units = "kg/kg"

 dims(0) = dims(0) - 1
 ua = new(dims, typeof(u))
 va = new(dims, typeof(v))
 ta = new(dims, typeof(t))
 ra = new(dims, typeof(rho))
 dz = new(dims, typeof(h))

 hh = new((/dims(0)/), typeof(h))

 ra@units = "kg/kg"

 malt = dims(0)

 print("malt = " + tostring(malt))

 ua(0:malt-1,:,:) = 0.5*(u(0:malt-1,:,:) + u(1:malt,:,:))
 printVarSummary(ua)
 va(0:malt-1,:,:) = 0.5*(v(0:malt-1,:,:) + v(1:malt,:,:))
 ta(0:malt-1,:,:) = 0.5*(t(0:malt-1,:,:) + t(1:malt,:,:))
 ra(0:malt-1,:,:) = 0.5*(rho(0:malt-1,:,:) + rho(1:malt,:,:))
 dz(0:malt-1,:,:) = z(1:malt,:,:) - z(0:malt-1,:,:)
 hh(0:malt-1) = 0.5*(h(1:malt) + h(0:malt-1))

 ua = smth9_Wrap(ua, 0.50, 0.25, True)
 ua = smth9_Wrap(ua, 0.50, 0.25, True)

 va = smth9_Wrap(va, 0.50, 0.25, True)
 va = smth9_Wrap(va, 0.50, 0.25, True)

 ta = smth9_Wrap(ta, 0.50, 0.25, True)
 ta = smth9_Wrap(ta, 0.50, 0.25, True)

 ra = smth9_Wrap(ra, 0.50, 0.25, True)
 ra = smth9_Wrap(ra, 0.50, 0.25, True)

 printVarSummary(ua)
 printVarSummary(va)
 printVarSummary(ta)
 printVarSummary(ra)
 printVarSummary(dz)

 print("Density flux components at each height level")
;Density flux components at each height level
 ur = ua*ra
 vr = va*ra

;print("-----")
;printVarSummary(ur)                         ; (level,lat,lon); (m/s)(kg/m3)
;printMinMax(ur,0)
;print("-----")
;printVarSummary(vr)
;printMinMax(vr,0)
;print("-----")

 print("Integrated mass weighted density flux components")
;Integrated mass weighted density flux components

 print("Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid")
;Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid

 duvr  = uv2dvF_Wrap(ur, vr)    ; (level,lat,lon)
 duvr@long_name = "Divergence of Density Flux"
 duvr@units     = "kg/(m2-s)"    ; (1/m)*[(m/s)(kg/m2)] => [kg/(m2-s)]

 duvr!0 = "alt"
 duvr!1 = "lat"
 duvr!2 = "lon"
 duvr&alt = hh
 duvr&lat = u&lat
 duvr&lon = u&lon

 print("Mass weighted integration [sum] of the divergence of density flux")
;Mass weighted integration [sum] of the divergence of density flux

 duvr_dz = duvr*dz            ;  [kg/(m2-s)][m] => [kg/(m-s)]
 iduvr    = dim_sum_n(duvr_dz, 0)
 iduvr@long_name = "Integrated Mass Wgt MFC" 
 iduvr@LONG_NAME = "Integrated Mass Weighted Density Flux Convergence" 
 iduvr@units     = "kg/(m-s)"
 copy_VarCoords(u(0,:,:), iduvr)      ; (lat,lon)
 delete(duvr_dz)

 VIDDF =  iduvr           ; keep meta data                         
 VIDDF = -VIDDF           ; Note the preceding -1 [negative precedes integration] 
 VIDDF@long_name = "VIDDF"

 path = diri+"monthly_mean_divergence_of_density_flux_202201.nc"
 write2file(duvr, VIDDF, path)

