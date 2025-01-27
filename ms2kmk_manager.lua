-- ms2kmk_manager
-- v0.0.4 @LudfisterSound
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
local midi_device
local current_synth_model = "MS2000"
local screen_dirty = true
local pages = {"MAIN", "MOOD", "SETTINGS"}
local current_page = 1
local selected_param = 1
local show_menu = false

-- Initialize UI components
local main_menu = UI.ScrollingList.new(0, 15, 1, {})
local mood_menu = UI.ScrollingList.new(0, 15, 1, {})
local settings_menu = UI.ScrollingList.new(0, 15, 1, {})

-- Synth Models and Their CC Maps
local SYNTH_MODELS = {
  MS2000 = {
    cc_map = {
      cutoff = 74,
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
      cutoff = 74,
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

-- MIDI CC control system
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
    
    for param, cc in pairs(cc_map) do
      if cc == cc_num then
        params:set(param, value)
        break
      end
    end
  end
}

-- Parameter initialization
local function init_params()
  -- Synth parameters
  params:add_separator("Synthesis")
  
  -- Basic parameters
  local param_names = {"cutoff", "resonance", "eg_attack", "eg_decay", "eg_sustain", "eg_release", "lfo1_rate", "lfo2_rate"}
  for _, name in ipairs(param_names) do
    params:add_control(
      name,
      name:gsub("_", " "):gsub("^%l", string.upper),
      controlspec.new(0, 127, 'lin', 1, 64, "")
    )
  end
  
  -- Synth model selection
  params:add_option("synth_model", "Synth Model", {"MS2000", "MicroKorg"}, 1)
  params:set_action("synth_model", function(x)
    current_synth_model = x == 1 and "MS2000" or "MicroKorg"
    init_cc_mappings()
  end)
end

-- Initialize CC mappings
function init_cc_mappings()
  local model = SYNTH_MODELS[current_synth_model]
  if not model then return end
  
  MIDI_CC_SYSTEM.active_ccs = {}
  for param, cc in pairs(model.cc_map) do
    MIDI_CC_SYSTEM.active_ccs[cc] = 0
  end
end

-- Update menu lists
function update_menu_lists()
  main_menu.entries = {
    "Cutoff: " .. params:get("cutoff"),
    "Resonance: " .. params:get("resonance"),
    "EG Attack: " .. params:get("eg_attack"),
    "EG Decay: " .. params:get("eg_decay"),
    "EG Sustain: " .. params:get("eg_sustain"),
    "EG Release: " .. params:get("eg_release"),
    "LFO1 Rate: " .. params:get("lfo1_rate"),
    "LFO2 Rate: " .. params:get("lfo2_rate")
  }
  
  settings_menu.entries = {
    "Synth Model: " .. current_synth_model,
    "CC Smoothing: " .. (MIDI_CC_SYSTEM.cc_smoothing and "ON" or "OFF"),
    "MIDI Channel: 1"
  }
end

-- Initialize script
function init()
  -- Initialize MIDI
  midi_device = midi.connect(1)
  midi_device.event = function(data)
    local msg = midi.to_msg(data)
    if msg.type == "cc" then
      MIDI_CC_SYSTEM:process_cc(msg.cc, msg.val)
    end
  end
  
  -- Initialize parameters
  init_params()
  init_cc_mappings()
  update_menu_lists()
  
  -- Start UI redraw clock
  local screen_metro = metro.init()
  screen_metro.time = 1/15
  screen_metro.event = function()
    if screen_dirty then
      redraw()
      screen_dirty = false
    end
  end
  screen_metro:start()
end

-- UI input handling
function enc(n, d)
  if n == 1 then
    current_page = util.clamp(current_page + d, 1, #pages)
  elseif n == 2 then
    if pages[current_page] == "MAIN" then
      main_menu:set_index_delta(d)
    elseif pages[current_page] == "SETTINGS" then
      settings_menu:set_index_delta(d)
    end
  elseif n == 3 then
    handle_value_change(d)
  end
  screen_dirty = true
end

function key(n, z)
  if z == 1 then
    if n == 1 then
      show_menu = not show_menu
    end
  end
  screen_dirty = true
end

-- Handle parameter value changes
function handle_value_change(delta)
  if pages[current_page] == "MAIN" then
    local param_names = {"cutoff", "resonance", "eg_attack", "eg_decay", "eg_sustain", "eg_release", "lfo1_rate", "lfo2_rate"}
    local param_name = param_names[main_menu.index]
    if param_name then
      local current_value = params:get(param_name)
      params:set(param_name, util.clamp(current_value + delta, 0, 127))
    end
  end
  update_menu_lists()
end

-- Draw function
function redraw()
  screen.clear()
  
  -- Draw page header
  screen.level(15)
  screen.move(2, 10)
  screen.text(pages[current_page])
  screen.move(128, 10)
  screen.text_right(current_synth_model)
  
  -- Draw current page content
  if pages[current_page] == "MAIN" then
    main_menu:redraw()
  elseif pages[current_page] == "SETTINGS" then
    settings_menu:redraw()
  end
  
  -- Draw footer
  screen.level(1)
  screen.move(0, 62)
  screen.text("E1: PAGE  E2: SELECT  E3: ADJUST")
  
  screen.update()
end

-- Cleanup
function cleanup()
  -- Nothing specific needed
end
