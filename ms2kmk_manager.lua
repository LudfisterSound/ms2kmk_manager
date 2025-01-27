-- ms2kmk_manager
-- v4.0.0 @LudfisterSound
-- llllllll.co/t/ms2kmk-manager
--
-- Advanced MS2000/MicroKorg Manager
-- with Complex Mood System
--
-- E1: navigate menus
-- E2: change values
-- E3: fine tune/select
-- K1: back/menu
-- K2: save/load
-- K3: generate/send

local musicutil = require 'musicutil'
local UI = require 'ui'

-- Global variables
local current_synth_model = "MS2000"  -- Default model
local midi_device

-- Synth Models and Their CC Maps
local SYNTH_MODELS = {
  MS2000 = {
    cc_map = {
      filter_cutoff = 74,  -- Changed from cutoff to filter_cutoff for consistency
      resonance = 71,
      eg_attack = 73,
      eg_decay = 75,
      eg_sustain = 70,
      eg_release = 72,
      lfo1_rate = 76,
      lfo2_rate = 77,
      mod_wheel = 1,
      vocoder = 90,
      mod_fx_speed = 93,
      delay_time = 94
    }
  },
  MicroKorg = {
    cc_map = {
      filter_cutoff = 74,  -- Changed for consistency
      resonance = 71,
      eg_attack = 73,
      eg_decay = 75,
      eg_sustain = 70,
      eg_release = 72,
      lfo1_rate = 76,
      lfo2_rate = 77,
      mod_wheel = 1,
      arp_gate = 92,
      arp_speed = 91,
      mod_type = 93
    }
  }
}

-- Initialize extended parameters
local function init_extended_params()
  -- Add basic synth parameters
  params:add_group("Synthesis", 10)
  
  params:add_control("filter_cutoff", "Filter Cutoff", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("resonance", "Resonance", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("eg_attack", "EG Attack", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("eg_decay", "EG Decay", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("eg_sustain", "EG Sustain", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("eg_release", "EG Release", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("lfo1_rate", "LFO1 Rate", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("lfo2_rate", "LFO2 Rate", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("mod_fx_speed", "Mod FX Speed", controlspec.new(0, 127, 'lin', 1, 64, ""))
  params:add_control("filter_env_amount", "Filter Env Amount", controlspec.new(0, 127, 'lin', 1, 64, ""))
end

-- MIDI CC System implementation
local MIDI_CC_SYSTEM = {
  active_ccs = {},
  cc_smoothing = true,
  smoothing_amount = 0.3,
  
  process_cc = function(self, cc_num, value)
    if self.cc_smoothing then
      value = self:smooth_value(cc_num, value)
    end
    self:update_parameter(cc_num, value)
  end,
  
  smooth_value = function(self, cc_num, new_value)
    if not self.active_ccs[cc_num] then
      self.active_ccs[cc_num] = new_value
      return new_value
    end
    
    local current = self.active_ccs[cc_num]
    local smoothed = current + (new_value - current) * self.smoothing_amount
    self.active_ccs[cc_num] = smoothed
    return math.floor(smoothed)
  end,
  
  update_parameter = function(self, cc_num, value)
    local cc_map = SYNTH_MODELS[current_synth_model].cc_map
    
    -- Find parameter associated with CC
    for param, cc in pairs(cc_map) do
      if cc == cc_num then
        params:set(param, value)
        break
      end
    end
  end
}

-- Initialize the script
function init()
  -- Initialize MIDI devices
  midi_device = midi.connect(1)
  midi_device.event = function(data)
    local msg = midi.to_msg(data)
    if msg.type == "cc" then
      MIDI_CC_SYSTEM:process_cc(msg.cc, msg.val)
    end
  end
  
  -- Initialize parameters
  init_extended_params()
  
  -- Add synth model selection
  params:add_option("synth_model", "Synth Model", {"MS2000", "MicroKorg"}, 1)
  params:set_action("synth_model", function(x)
    current_synth_model = x == 1 and "MS2000" or "MicroKorg"
    init_cc_mappings()
  end)
  
  -- Initialize CC mappings
  init_cc_mappings()
  
  -- Start UI redraw clock
  clock.run(function()
    while true do
      clock.sleep(1/15) -- 15 FPS refresh rate
      redraw()
    end
  end)
end

function init_cc_mappings()
  local model = SYNTH_MODELS[current_synth_model]
  if not model then return end
  
  -- Clear existing CC mappings
  MIDI_CC_SYSTEM.active_ccs = {}
  
  -- Initialize new CC mappings
  for param, cc in pairs(model.cc_map) do
    MIDI_CC_SYSTEM.active_ccs[cc] = 0
  end
end

-- Basic UI drawing function
function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0, 10)
  screen.text(current_synth_model .. " Manager")
  screen.move(0, 20)
  screen.text("Filter: " .. params:get("filter_cutoff"))
  screen.update()
end

-- Clean up function
function cleanup()
  -- Nothing specific needed for cleanup in this version
end
