  script_title = "Add stretch marker to every spectrum rise"  
  reaper.Undo_BeginBlock()
    
  width = 1000
  heigtht = 200
  fft_size = 256*4
  gfx.init("test", width, heigtht)
--[[function run()  
  position = reaper.GetPlayPosition()]]
  
  step = 0.05
  
  item = reaper.GetSelectedMediaItem(0, 0)
  if item ~= nil then 
    item_pos = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
    item_len = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
    take = reaper.GetActiveTake(item)
    if take ~= nil then
      is_midi = reaper.TakeIsMIDI(take)      
      if is_midi == false then
        x = 0
        y = 0
        for read_pos = 0, item_len, step do
          src = reaper.GetMediaItemTake_Source(take)
          num_ch = reaper.GetMediaSourceNumChannels(src)
          rate = reaper.GetMediaSourceSampleRate(src)
          audio_accessor = reaper.CreateTakeAudioAccessor(take)
          audio_accessor_buffer = reaper.new_array(fft_size*2)
          reaper.GetAudioAccessorSamples(audio_accessor, rate, 1, read_pos, fft_size*2, audio_accessor_buffer)
          audio_accessor_buffer.fft(fft_size, true, 1)        
          audio_accessor_buffer_fft_t = {}
          audio_accessor_buffer_fft_t = audio_accessor_buffer.table(1,fft_size)  
          reaper.DestroyAudioAccessor(audio_accessor)
          fft_sum = 0
          for i = 1, fft_size do
            audio_accessor_buffer_fft_value = audio_accessor_buffer_fft_t[i]
            gfx.x = i/4 
            gfx.y = 200
            --gfx.lineto(i/4,200- math.abs(audio_accessor_buffer_fft_value))
            fft_sum = fft_sum +  math.abs(audio_accessor_buffer_fft_value)
          end
          fft_sum = fft_sum/20
          
          gfx.x = x
          gfx.y = heigtht
          gfx.lineto(x,heigtht-fft_sum)
          x = x+10
       end         
      end
    end
  end
  
  
  
--[[    gfx.update() 
  reaper.defer(run)
 end
 run() ]]
  

  reaper.Undo_EndBlock(script_title, 1)