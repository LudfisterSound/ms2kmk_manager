-- ms2kmk_manager
-- v4.0.0 @LudfisterSound
-- llllllll.co/t/ms2kmk-manager
--
-- Advanced MS2000/MicroKorg
-- Manager with Complex
-- Mood System
--
-- E1: navigate menus
-- E2: change values
-- E3: fine tune/select
-- K1: back/menu
-- K2: save/load
-- K3: generate/send

local musicutil = require 'musicutil'
local UI = require 'ui'

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
      -- MS2000 specific CCs
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
      -- MicroKorg specific CCs
      arp_gate = 92,
      arp_speed = 91,
      mod_type = 93
    }
  }
}

-- Enhanced Mood System with Complex Interactions
local MOOD_MATRIX = {
  base_moods = {
    "Aggressive", "Mellow", "Ethereal", "Dark", 
    "Bright", "Weird", "Classic", "Future"
  },
  
  modifiers = {
    "Unstable", "Evolving", "Glitchy", "Warm", 
    "Cold", "Organic", "Digital", "Raw"
  },
  
  combinations = {
    -- Complex mood combinations with specific parameter affects
    Aggressive = {
      Unstable = {
        filter = {cutoff = 100, resonance = 90},
        mod = {rate = "fast", depth = "high"},
        eg = {attack = "fast", decay = "medium"},
        probability = {
          distortion = 0.9,
          pitch_drift = 0.7
        }
      },
      Evolving = {
        filter = {cutoff = "sweep", resonance = "sweep"},
        mod = {rate = "variable", depth = "increasing"},
        eg = {attack = "variable", release = "long"},
        probability = {
          filter_mod = 0.8,
          pan_motion = 0.6
        }
      }
    },
    Mellow = {
      Warm = {
        filter = {cutoff = 60, resonance = 30},
        mod = {rate = "slow", depth = "medium"},
        eg = {attack = "medium", release = "long"},
        probability = {
          chorus = 0.7,
          delay = 0.5
        }
      },
      Organic = {
        filter = {cutoff = "breathing", resonance = "subtle"},
        mod = {rate = "natural", depth = "varying"},
        eg = {attack = "soft", release = "natural"},
        probability = {
          filter_env = 0.8,
          amplitude_mod = 0.6
        }
      }
    }
    -- Add more combinations as needed
  },
  
  -- Time-based evolution parameters
  evolution = {
    slow = {
      period = 8,  -- in beats
      depth = 0.3
    },
    medium = {
      period = 4,
      depth = 0.5
    },
    fast = {
      period = 2,
      depth = 0.7
    }
  }
}

-- Real-time MIDI CC control system
local MIDI_CC_SYSTEM = {
  active_ccs = {},
  cc_smoothing = true,
  smoothing_amount = 0.3,
  
  -- CC Processing functions
  process_cc = function(self, cc_num, value)
    if self.cc_smoothing then
      value = self:smooth_value(cc_num, value)
    end
    self:update_parameter(cc_num, value)
  end,
  
  -- Value smoothing to prevent jumps
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
  
  -- Parameter updating based on CC
  update_parameter = function(self, cc_num, value)
    local synth = current_synth_model
    local cc_map = SYNTH_MODELS[synth].cc_map
    
    -- Find parameter associated with CC
    for param, cc in pairs(cc_map) do
      if cc == cc_num then
        params:set(param, value)
        return
      end
    end
  end
}

-- Mood evolution system
local MOOD_EVOLUTION = {
  current_mood = nil,
  current_modifier = nil,
  evolution_clock = nil,
  evolution_stage = 1,
  
  -- Initialize mood evolution
  init = function(self, mood, modifier)
    self.current_mood = mood
    self.current_modifier = modifier
    
    -- Stop existing clock if running
    if self.evolution_clock then
      clock.cancel(self.evolution_clock)
    end
    
    -- Start evolution clock
    self.evolution_clock = clock.run(function()
      while true do
        clock.sync(1/4)  -- Sync to clock
        self:evolve()
      end
    end)
  end,
  
  -- Evolution process
  evolve = function(self)
    local combo = MOOD_MATRIX.combinations[self.current_mood][self.current_modifier]
    if not combo then return end
    
    -- Calculate evolution parameters
    local stage = self.evolution_stage
    local period = MOOD_MATRIX.evolution[combo.mod.rate].period
    local depth = MOOD_MATRIX.evolution[combo.mod.rate].depth
    
    -- Apply evolution
    self:apply_evolution(combo, stage, period, depth)
    
    -- Increment evolution stage
    self.evolution_stage = (self.evolution_stage % period) + 1
  end,
  
  -- Apply evolution to parameters
  apply_evolution = function(self, combo, stage, period, depth)
    -- Calculate evolution amount
    local phase = (stage - 1) / period
    local evolution = math.sin(phase * math.pi * 2) * depth
    
    -- Apply to filter
    if combo.filter.cutoff == "sweep" then
      local cutoff = 64 + (evolution * 63)
      params:set("filter_cutoff", cutoff)
    end
    
    -- Apply to modulation
    if combo.mod.rate == "variable" then
      local rate = 64 + (evolution * 63)
      params:set("lfo1_rate", rate)
    end
    
    -- Apply probability-based changes
    for effect, prob in pairs(combo.probability) do
      if math.random() < prob * (1 + evolution) then
        self:trigger_effect(effect)
      end
    end
  end,
  
  -- Trigger probability-based effects
  trigger_effect = function(self, effect)
    if effect == "filter_mod" then
      -- Trigger filter modulation
      local amount = math.random(30, 100)
      params:set("filter_env_amount", amount)
    elseif effect == "pan_motion" then
      -- Trigger panning modulation
      local speed = math.random(40, 80)
      params:set("mod_fx_speed", speed)
    end
  end
}

-- Initialize the script
function init()
  -- Initialize MIDI devices
  midi_device = midi.connect(1)
  if not midi_device then
    print("Failed to connect to MIDI device")
    return
  end)
    
  -- Add synth model selection
  params:add_option("synth_model", "Synth Model", {"MS2000", "MicroKorg"}, 1)
  params:set_action("synth_model", function(x)
    current_synth_model = x == 1 and "MS2000" or "MicroKorg"
    init_cc_mappings()
  end)
  
  -- Initialize parameters
  init_extended_params()
  end)
  
  -- Initialize mood system
  init_mood_system()
  end)
  
  -- Start the main clock
  clock.run(function()
    while true do
      clock.sync(1/24)  -- MIDI clock resolution
      update_evolution()
    end
  end)
end

-- MIDI input handling
midi_device.event = function(data)
  local msg = midi.to_msg(data)
  if msg.type == "cc" then
    MIDI_CC_SYSTEM:process_cc(msg.cc, msg.val)
  end
end

-- Add more supporting functions here...
-- (Previous functions from the last version remain unchanged)

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

function init_mood_system()
  -- Initialize base mood
  params:add_option("base_mood", "Base Mood", MOOD_MATRIX.base_moods, 1)
  params:add_option("mood_modifier", "Mood Modifier", MOOD_MATRIX.modifiers, 1)
  
  -- Set up mood evolution
  params:set_action("base_mood", function(x)
    MOOD_EVOLUTION:init(
      MOOD_MATRIX.base_moods[x],
      MOOD_MATRIX.modifiers[params:get("mood_modifier")]
    )
  end)
end

function update_evolution()
  if MOOD_EVOLUTION.evolution_clock then
    MOOD_EVOLUTION:evolve()
  end
end

-- Enhanced cleanup function
function cleanup()
  -- Stop all clocks
  if MOOD_EVOLUTION.evolution_clock then
    clock.cancel(MOOD_EVOLUTION.evolution_clock)
  end
  
  -- Save current state
  save_current_state()
end
