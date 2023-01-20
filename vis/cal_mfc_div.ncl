load "categorical.ncl"

;----------------------------------------------------------------------
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 flnm = "monthly_mean_gfs_4_202201.nc"

 dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 finame = "monthly_mean_gfs_4_202201.nc"
 foname = "monthly_mean_mfc_202201.nc"

 info = readinfo("datainfo.txt")

 dirname = info(0)
 finame = info(1)
 foname = info(2)

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

 ptop = 1
 ptop@units = "hPa"
 g    = 9.80665          ; m/s2

 path = diri+flnm      

 f = addfile(path, "r")

 u = f->UGRD_P0_L100_GLL0(:,:,:)  ; m/s, (level,lat,lon)
 v = f->VGRD_P0_L100_GLL0(:,:,:)
 q = f->SPFH_P0_L100_GLL0(:,:,:)
 ps = f->PRMSL_P0_L101_GLL0(:,:)

;Vertical levels
 ptop@units = "Pa"

 plev = q&lv_ISBL0                   ; [100000,...,30000] Pa [kg/(m-s2)]
 plev@units = "Pa"

;Change [kg/kg] to [g/kg]; not necessary: but common units for q

 q    = q*1000            
 q@units = "g/kg"

;Divergence function [used later] requires S->N grid order

 u  = u(:,::-1,:)  
 v  = v(:,::-1,:)
 q  = q(:,::-1,:)     
 ps =ps(  ::-1,:)       

;Layer thickness: ; Pa=>[kg/(m-s2)], (level,lat,lon) 
;Mass weighting: (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
;Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

 dp = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness 

 dimdp = dimsizes(dp)

 print(dimdp)

 dpg  = dp/g    
 dpg@long_name = "Layer Mass Weighting"
 dpg@units     = "kg/m2"                     ; dp/g, Pa/(m s-2), reduce to kg m-2

;Moisture flux components at each pressure level

 uq = u*q
 vq = v*q

;Integrated mass weighted moisture flux components
;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

 duvq  = uv2dvF_Wrap(uq, vq)    ; (level,lat,lon)
 duvq@long_name = "Divergence of Moisture Flux"
 duvq@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
 copy_VarCoords(u, duvq)        ; (lat,lon)

;Mass weighted integration [sum] of the divergence of moisture flux

 duvq_dpg = duvq*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
 iduvq    = dim_sum_n(duvq_dpg, 0)
 iduvq@long_name = "Integrated Mass Wgt MFC" 
 iduvq@LONG_NAME = "Integrated Mass Weighted Moisture Flux Convergence" 
 iduvq@units     = "g/(m2-s)"
 copy_VarCoords(u(0,:,:), iduvq)      ; (lat,lon)
 delete(duvq_dpg)

 VIMFC =  iduvq           ; keep meta data                         
 VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
 VIMFC@long_name = "VIMFC"

;-----------------------------------------------------------------------------------------
 write_mfc(duvq, VIMFC, f)

