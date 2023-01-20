load "categorical.ncl"

;----------------------------------------------------------------------
 g = 9.80665          ; m/s2
 r = 287.0

 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 finame = "hl_gfs_4_20220116_0000_000.nc"
 foname = "dfc_20220116_00.nc"

 fi = diri+finame
 fo = diri+foname

 f = addfile(fi, "r")

 u = f->U(:,:,:)  ; m/s, (level,lat,lon)
 v = f->V(:,:,:)
 t = f->T(:,:,:)
 p = f->P(:,:,:)

;Vertical levels
 h = t&alt
 h@units = "M"

 ndh = toint(h(1) - h(0) + 0.5)

 dims = dimsizes(t)
 z = conform_dims(dims,h,0)
 rho = p / (287.01*t)

;printVarSummary(z)
;printMinMax(z,0)
;printVarSummary(rho)
;printMinMax(rho,0)

 dims(0) = dims(0) - 1
 ua = new(dims, typeof(u))
 va = new(dims, typeof(v))
 ra = new(dims, typeof(rho))
 dz = new(dims, typeof(h))

 ra@units = "kg/kg"

 delete(t)
 delete(p)

 malt = dims(0)

 alta = 0.5*(h(0:malt-1) + h(1:malt))
 lat = u&lat
 lon = u&lat

 ua(0:malt-1,:,:) = 0.5*(u(0:malt-1,:,:) + u(1:malt,:,:))
 va(0:malt-1,:,:) = 0.5*(v(0:malt-1,:,:) + v(1:malt,:,:))
 ra(0:malt-1,:,:) = 0.5*(rho(0:malt-1,:,:) + rho(1:malt,:,:))
 dz(0:malt-1,:,:) = z(1:malt,:,:) - z(0:malt-1,:,:)

;do n = 1, 1
;ua = smth9_Wrap(ua, 0.50, 0.25, True)
;va = smth9_Wrap(va, 0.50, 0.25, True)
;ta = smth9_Wrap(ta, 0.50, 0.25, True)
;ra = smth9_Wrap(ra, 0.50, 0.25, True)
;end do

 print("Density flux components at each height level")
;Density flux components at each height level
 ur = ua*ra
 vr = va*ra

 print("Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid")
;Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid

 duvr  = uv2dvF_Wrap(ur, vr)    ; (level,lat,lon)
 duvr@long_name = "Divergence of Density Flux"
 duvr@units     = "kg/(m2-s)"    ; (1/m)*[(m/s)(kg/m2)] => [kg/(m2-s)]
 duvr = 1.0e6*duvr
 copy_VarCoords(u(0:malt,:,:),duvr)                        ; (level,lat,lon)
 delete(ur)
 delete(vr)

 print("Mass weighted integration [sum] of the divergence of density flux")
;Mass weighted integration [sum] of the divergence of density flux

 duvr_dz = duvr*dz            ;  [kg/(m2-s)][m] => [kg/(m-s)]
 iduvr    = dim_sum_n(duvr_dz, 0)
 iduvr@long_name = "Integrated DFC" 
 iduvr@LONG_NAME = "Integrated Density Flux Convergence" 
 iduvr@units     = "kg/(m-s)"
 delete(duvr_dz)

 VIDFC =  1.0e6*iduvr           ; keep meta data                         
 VIDFC = -VIDFC           ; Note the preceding -1 [negative precedes integration] 
 VIDFC@long_name = "VIDFC"
 copy_VarCoords(u(0,:,:), VIDFC)      ; (lat,lon)

;-----------------------------------------------------------------------------------------
 duvr!0 = "alt"
 duvr!1 = "lat"
 duvr!2 = "lon"
 duvr&alt = alta
 duvr&lat = lat
 duvr&lon = lon

 printVarSummary(duvr)
 printVarSummary(VIDFC)
 write_dfc(duvr, VIDFC, fo)

