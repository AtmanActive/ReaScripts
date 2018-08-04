-- @description WiredChain_obj
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @noindex
  
  
  ---------------------------------------------------
  function OBJ_init(obj)  
    -- globals
    obj.reapervrs = tonumber(GetAppVersion():match('[%d%.]+')) 
    obj.offs = 5 
    obj.grad_sz = 200 
    obj.module_h = 12
    
    -- module
    obj.module_a_frame = 0.1   
    obj.module_alpha_back = 0.05
        
    -- topline
    obj.menu_w = 50
    obj.topline_h = 20
    obj.trackname_w = 150
    
    -- tr IO
    obj.trIO_x_offset = 10
    obj.trIO_y = 30
    obj.trIO_w = 15
    obj.trIO_h = obj.module_h
    
    -- fx
    obj.fx_x_space = 60 -- defautf offset from IO when generating FX positions
    obj.fx_y_shift = 0 -- defautf shoft from IO when generating FX positions
    obj.fxmod_w = 110
    
    -- wire
    obj.audiowire_col = 'green'
    obj.audiowire_a = 0.3
    
    -- font
    obj.GUI_font = 'Calibri'
    obj.GUI_fontsz = 20  -- 
    obj.GUI_fontsz2 = 15 -- 
    obj.GUI_fontsz3 = 13-- 
    if GetOS():find("OSX") then 
      obj.GUI_fontsz = obj.GUI_fontsz - 6 
      obj.GUI_fontsz2 = obj.GUI_fontsz2 - 5 
      obj.GUI_fontsz3 = obj.GUI_fontsz3 - 4
    end 
    
    -- colors    
    obj.GUIcol = { grey =    {0.5, 0.5,  0.5 },
                   white =   {1,   1,    1   },
                   red =     {1,   0,    0   },
                   green =   {0.3,   0.9,    0.3   },
                   black =   {0,0,0 }
                   }    
    
    -- other
  end
  ---------------------------------------------------
  function OBJ_Update(conf, obj, data, refresh, mouse) 
    for key in pairs(obj) do if type(obj[key]) == 'table' and obj[key].clear then obj[key] = {} end end  

    if not data.tr then return end

                   
        obj.menu = { clear = true,
                    x = 0,
                    y = 0,
                    w = obj.menu_w,
                    h = obj.topline_h,
                    col = 'white',
                    state = fale,
                    txt= '>',
                    show = true,
                    fontsz = obj.GUI_fontsz,
                    a_frame = 0,
                    func =  function() 
                              Menu(mouse,               
{
  { str = conf.mb_title..' '..conf.vrs,
    hidden = true
  },
  { str = '|#Links / Info'},
  { str = 'Donate to MPL',
    func = function() Open_URL('http://www.paypal.me/donate2mpl') end }  ,
  { str = 'Cockos Forum thread|',
    func = function() Open_URL('http://forum.cockos.com/showthread.php?t=188335') end  } , 
    
  { str = '#Options'},    
  { str = 'Snap FX on drag|',  
    func =  function() conf.snapFX = math.abs(1-conf.snapFX)  end,
    state = conf.snapFX == 1,
  } , 
  
  { str = 'Dock '..'MPL '..conf.mb_title..' '..conf.vrs,
    func = function() 
              conf.dock2 = math.abs(1-conf.dock2) 
              gfx.quit() 
              gfx.init('MPL '..conf.mb_title..' '..conf.vrs,
                        conf.wind_w, 
                        conf.wind_h, 
                        conf.dock2, conf.wind_x, conf.wind_y)
          end ,
    state = conf.dock2 == 1},                                                                            
}
)
                              refresh.conf = true 
                              refresh.GUI = true
                              refresh.GUI_onStart = true
                              refresh.data = true
                            end}  
                         
                            
                            
                            
        obj.trackname = { clear = true,
                    x = obj.menu_w+1,
                    y = 0,
                    w = gfx.w -obj.menu_w-1,--obj.trackname_w,
                    h = obj.topline_h,
                    col = 'white',
                    txt= data.trname,
                    show = true,
                    fontsz = obj.GUI_fontsz,
                    a_frame = 0,
                    func =  function() 
                              
                            end
                   }                              
    Obj_FormTrackIO(conf, obj, data, refresh, mouse) 
    Obj_FormFX(conf, obj, data, refresh, mouse) 
    Obj_FormWires(conf, obj, data, refresh, mouse) 
    for key in pairs(obj) do if type(obj[key]) == 'table' then obj[key].context = key end end    
  end
  ---------------------------------------------------  
  function Obj_MarkConnections(conf, obj, data, refresh, mouse, mark_output) 
    for key in pairs(obj) do 
      if type(obj[key]) == 'table' then 
        if mark_output then
          if key:match('_I_') then
            obj[key].is_marked_pin = true
          end 
        end
      end 
    end
  end
  ---------------------------------------------------
  function Obj_FormTrackIO(conf, obj, data, refresh, mouse) 
    for i = 1, data.trchancnt do
      local pkey = 'mod_tr_0_O_'..i
      obj[pkey] ={ clear = true,
                    x = obj.trIO_x_offset,
                    y = obj.trIO_y + (i-1)*(obj.trIO_h+1),
                    w = obj.trIO_w,
                    h = obj.trIO_h,
                    col = 'white',
                    txt= i,
                    show = true,
                    fontsz = obj.GUI_fontsz3,
                    a_frame =obj.module_a_frame,
                    alpha_back = obj.module_alpha_back,
                    func =  function() 
                              Obj_MarkConnections(conf, obj, data, refresh, mouse, true) 
                              if not obj[pkey].wire then obj[pkey].wire = {} end
                              local temp_t = obj[pkey].wire
                              temp_t[#temp_t+1] = { wiretype = 0, dest = 'mouse'}
                            end ,                   
                    func_LD =  function() 
                              Obj_MarkConnections(conf, obj, data, refresh, mouse, true) 
                              refresh.GUI_minor = true
                            end,
                   }  
      local pkey = 'mod_tr_0_I_'..i
      obj[pkey] ={ clear = true,
                    x = gfx.w - obj.trIO_x_offset - obj.trIO_w,
                    y = obj.trIO_y + (i-1)*(obj.trIO_h+1),
                    w = obj.trIO_w,
                    h = obj.trIO_h,
                    col = 'white',
                    txt= i,
                    show = true,
                    fontsz = obj.GUI_fontsz3,
                    a_frame =obj.module_a_frame,
                    alpha_back = obj.module_alpha_back,
                    onrelease_L = function() Data_BuildRouting(conf, obj, data, refresh, mouse, { routingtype = 0,
                                                                                                  dest = pkey,
                                                                                                  src = mouse.context_latch
                                                                                                  })  end                            
                   }                    
    end
    obj.trIO_setcntup ={ clear = true,
                  x = obj.trIO_x_offset,
                  y = obj.trIO_y + data.trchancnt*(obj.trIO_h+1),
                  w = obj.trIO_w,
                  h = obj.trIO_h,
                  col = 'white',
                  txt= '+',
                  show = true,
                  fontsz = obj.GUI_fontsz3,
                  a_frame = 0,
                  func =  function() 
                            SetMediaTrackInfo_Value( data.tr, 'I_NCHAN', lim(data.trchancnt+2,2,conf.chan_limit ))
                            refresh.GUI = true
                            refresh.data = true
                          end
                 } 
    obj.trIO_setcntdown ={ clear = true,
                  x = obj.trIO_x_offset,
                  y = obj.trIO_y + (data.trchancnt+1)*(obj.trIO_h+1),
                  w = obj.trIO_w,
                  h = obj.trIO_h,
                  col = 'white',
                  txt= '-',
                  show = true,
                  fontsz = obj.GUI_fontsz3,
                  a_frame = 0,
                  func =  function() 
                            SetMediaTrackInfo_Value( data.tr, 'I_NCHAN', lim(data.trchancnt-2,2,conf.chan_limit ))
                            refresh.GUI = true
                            refresh.data = true
                          end
                 }                  
  end
  ---------------------------------------------------
  function Obj_FormFX(conf, obj, data, refresh, mouse) 
    if not data.fx then return end
    
    -- default position
      local x = obj.trIO_x_offset + obj.trIO_w + obj.fx_x_space
      local y = obj.trIO_y
    
    for i = 1, #data.fx do
      local xFX = x + (obj.fx_x_space + obj.fxmod_w)* (i-1)
      local yFX = y + obj.fx_y_shift*((i-1)%2)
      if data.ext_data 
        and data.ext_data[data.GUID]
        and data.ext_data[data.GUID][data.fx[i].GUID] then
        xFX = data.ext_data[data.GUID][data.fx[i].GUID].x
        yFX = data.ext_data[data.GUID][data.fx[i].GUID].y
      end
      local hFX = (obj.module_h+1)*math.max(data.fx[i].inpins, data.fx[i].outpins)-1
      obj['fx_'..i] ={ clear = true,
                    x = xFX,
                    y = yFX,
                    w = obj.fxmod_w,
                    h = hFX,
                    col = 'white',
                    txt= data.fx[i].reducedname,
                    show = true,
                    fontsz = obj.GUI_fontsz3,
                    a_frame =obj.module_a_frame,
                    alpha_back = obj.module_alpha_back,
                    func =  function() 
                              mouse.drag_obj = CopyTable(obj['fx_'..i])
                            end,
                    func_LD2 =  function()
                                  local newpos_x = mouse.drag_obj.x + mouse.dx
                                  local newpos_y = mouse.drag_obj.y + mouse.dy
                                  
                                  if conf.snapFX == 1 then
                                    local multx = math.modf(newpos_x/conf.snap_px)
                                    newpos_x = conf.snap_px * multx
                                    local multy = math.modf(newpos_y/conf.snap_px)
                                    newpos_y = conf.snap_px * multy
                                  end
                                  
                                  -- temporary limits before scroll/middle drag implemented
                                    local lim_edge = 60
                                    newpos_x = lim(newpos_x, lim_edge, gfx.w - obj.fxmod_w-lim_edge)
                                    newpos_y = lim(newpos_y, obj.topline_h, gfx.h - hFX)
                                    
                                  obj['fx_'..i].x = newpos_x
                                  obj['fx_'..i].y = newpos_y
                                  Obj_FormFXPins(conf, obj, data, refresh, mouse, i, true) 
                                  
                                  if not data.ext_data then data.ext_data = {} end
                                  if not data.ext_data[data.GUID] then data.ext_data[data.GUID] = {} end
                                  if not data.ext_data[data.GUID][data.fx[i].GUID] then data.ext_data[data.GUID][data.fx[i].GUID] = {} end
                                  data.ext_data[data.GUID][data.fx[i].GUID].x = newpos_x
                                  data.ext_data[data.GUID][data.fx[i].GUID].y = newpos_y
                                  
                                  refresh.GUI_minor = true
                                  
                                end,
                    onrelease_L = function()
                                    refresh.conf = true
                                  end
                   } 
      Obj_FormFXPins(conf, obj, data, refresh, mouse, i) 
                       
    end
  end
  ---------------------------------------------------
  function Obj_FormFXPins(conf, obj, data, refresh, mouse, fx_id, refresh_pos_only) 
      for inpin = 1,  data.fx[fx_id].inpins do
        if refresh_pos_only then
          obj['mod_fx_'..fx_id..'_I_'..inpin].x = obj['fx_'..fx_id].x-obj.trIO_w-1
          obj['mod_fx_'..fx_id..'_I_'..inpin].y = obj['fx_'..fx_id].y + (inpin-1)*(obj.trIO_h+1)
         else
          local pkey = 'mod_fx_'..fx_id..'_I_'..inpin
          obj[pkey] ={ clear = true,
                      x = obj['fx_'..fx_id].x-obj.trIO_w-1,
                      y = obj['fx_'..fx_id].y + (inpin-1)*(obj.trIO_h+1),
                      w = obj.trIO_w,
                      h = obj.trIO_h,
                      col = 'white',
                      txt= inpin,
                      show = true,
                      fontsz = obj.GUI_fontsz3,
                      a_frame =obj.module_a_frame,
                      alpha_back = obj.module_alpha_back,
                      func =  function() 
                      
                              end,
                      onrelease_L = function() Data_BuildRouting(conf, obj, data, refresh, mouse, { routingtype = 0,
                                                                                                  dest = pkey,
                                                                                                  src = mouse.context_latch
                                                                                                  })  end                               
                     }  
        end 
      end   
      
      for outpin = 1,  data.fx[fx_id].outpins do
        if refresh_pos_only then
          obj['mod_fx_'..fx_id..'_O_'..outpin].x = obj['fx_'..fx_id].x+obj['fx_'..fx_id].w+1
          obj['mod_fx_'..fx_id..'_O_'..outpin].y = obj['fx_'..fx_id].y + (outpin-1)*(obj.trIO_h+1)
         else
          local pkey = 'mod_fx_'..fx_id..'_O_'..outpin
          obj[pkey] ={ clear = true,
                      x = obj['fx_'..fx_id].x+obj['fx_'..fx_id].w+1,
                      y = obj['fx_'..fx_id].y + (outpin-1)*(obj.trIO_h+1),
                      w = obj.trIO_w,
                      h = obj.trIO_h,
                      col = 'white',
                      txt= outpin,
                      show = true,
                      fontsz = obj.GUI_fontsz3,
                      a_frame =obj.module_a_frame,
                      alpha_back = obj.module_alpha_back,
                      func =  function() 
                                Obj_MarkConnections(conf, obj, data, refresh, mouse, true) 
                                if not obj[pkey].wire then obj[pkey].wire = {} end
                                local temp_t = obj[pkey].wire
                                temp_t[#temp_t+1] = { wiretype = 0, dest = 'mouse'}
                              end
                     }   
        end
      end    
  end
  ---------------------------------------------------
  function Obj_FormWires(conf, obj, data, refresh, mouse) 
    -- scan channels for trO
    for chan = 1, data.trchancnt do
      local has_linked_to_fx = false
      for fx = #data.fx, 1, -1 do
          if    data.fx[fx].chantopins[chan] 
            and data.fx[fx].chantopins[chan].O  then 
              for pin = 1, #data.fx[fx].chantopins[chan].O do
                local pinid = data.fx[fx].chantopins[chan].O[pin]
                if not obj['mod_fx_'..fx..'_O_'..pinid].wire then obj['mod_fx_'..fx..'_O_'..pinid].wire = {} end
                local temp_t = obj['mod_fx_'..fx..'_O_'..pinid].wire
                temp_t[#temp_t+1] =  { wiretype = 0, dest = 'mod_tr_0_I_'..chan}
              end
            has_linked_to_fx = true
            break
          end
      end
      if not has_linked_to_fx then
        obj['mod_tr_0_O_'..chan].wire =  {   { wiretype = 0, dest = 'mod_tr_0_I_'..chan}       }
      end
    end


  -- scan plugins in reversed order
    for fx = #data.fx, 1, -1 do
      for chan = 1, data.trchancnt do
        if    data.fx[fx].chantopins[chan] 
          and data.fx[fx].chantopins[chan].I   then
          
          for pin = 1, #data.fx[fx].chantopins[chan].I do
            local pinid = data.fx[fx].chantopins[chan].I[pin] -- to which pin  incoming current channel
            local has_signal_coming_from_fx = false
            for fx_seek = fx-1, 1, -1 do
              if    data.fx[fx_seek].chantopins[chan] 
                and data.fx[fx_seek].chantopins[chan].O then
                local temp_t = data.fx[fx_seek].chantopins[chan].O
                for outpin = 1, #temp_t do
                  local pin_outid = temp_t[outpin]
                  if not obj['mod_fx_'..fx_seek..'_O_'..pin_outid].wire then obj['mod_fx_'..fx_seek..'_O_'..pin_outid].wire = {} end
                  local tempt2 = obj['mod_fx_'..fx_seek..'_O_'..pin_outid].wire
                  tempt2[#tempt2+1] = { wiretype = 0, dest = 'mod_fx_'..fx..'_I_'..pinid}
                  has_signal_coming_from_fx = true
                end
                break
              end
            end
            if not has_signal_coming_from_fx  then
              if not obj['mod_tr_0_O_'..chan].wire then obj['mod_tr_0_O_'..chan].wire = {} end
              local temp_t = obj['mod_tr_0_O_'..chan].wire
              temp_t[#temp_t+1]={ wiretype = 0, dest = 'mod_fx_'..fx..'_I_'..pinid}  
            end
          end
          
        end
      end
    end
    
  end