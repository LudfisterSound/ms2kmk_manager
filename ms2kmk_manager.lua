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

-- Global UI variables
local pages = {"MAIN", "MOOD", "SETTINGS"}
local current_page = 1
local selected_param = 1
local show_menu = false

-- Initialize UI components
local main_menu = UI.ScrollingList.new(0, 0, 1, {})
local mood_menu = UI.ScrollingList.new(0, 0, 1, {})
local settings_menu = UI.ScrollingList.new(0, 0, 1, {})

-- Rest of your existing code remains the same until the UI-related functions...

-- Initialize the script
function init()
  -- Previous init code remains...
  
  -- Initialize UI lists
  update_menu_lists()
  
  -- Start UI redraw clock
  clock.run(function()
    while true do
      clock.sleep(1/15) -- 15 FPS refresh rate
      redraw()
    end
  end)
  
  -- Initialize grid redraw metro
  screen_dirty = true
  screen_metro = metro.init()
  screen_metro.time = 1/15
  screen_metro.event = function()
    if screen_dirty then
      redraw()
      screen_dirty = false
    end
  end
  screen_metro:start()
end

-- Update all menu lists
function update_menu_lists()
  -- Main menu items
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
  
  -- Mood menu items
  mood_menu.entries = {
    "Base Mood: " .. MOOD_MATRIX.base_moods[params:get("base_mood")],
    "Modifier: " .. MOOD_MATRIX.modifiers[params:get("mood_modifier")],
    "Evolution: " .. (MOOD_EVOLUTION.evolution_clock and "ON" or "OFF")
  }
  
  -- Settings menu items
  settings_menu.entries = {
    "Synth Model: " .. current_synth_model,
    "CC Smoothing: " .. (MIDI_CC_SYSTEM.cc_smoothing and "ON" or "OFF"),
    "MIDI Channel: 1"
  }
end

-- UI input handling
function enc(n, d)
  if n == 1 then
    -- Navigate pages
    current_page = util.clamp(current_page + d, 1, #pages)
    screen_dirty = true
  elseif n == 2 then
    -- Navigate items within page
    if pages[current_page] == "MAIN" then
      main_menu:set_index_delta(d)
    elseif pages[current_page] == "MOOD" then
      mood_menu:set_index_delta(d)
    elseif pages[current_page] == "SETTINGS" then
      settings_menu:set_index_delta(d)
    end
    screen_dirty = true
  elseif n == 3 then
    -- Adjust selected parameter
    handle_value_change(d)
    screen_dirty = true
  end
end

function key(n, z)
  if z == 1 then
    if n == 1 then
      -- Toggle menu
      show_menu = not show_menu
    elseif n == 2 then
      -- Save/Load functionality
      if pages[current_page] == "MAIN" then
        -- Implement save functionality
      end
    elseif n == 3 then
      -- Generate/Send functionality
      if pages[current_page] == "MOOD" then
        trigger_mood_generation()
      end
    end
    screen_dirty = true
  end
end

-- Handle parameter value changes
function handle_value_change(delta)
  local current_menu
  if pages[current_page] == "MAIN" then
    current_menu = main_menu
    local param_names = {"cutoff", "resonance", "eg_attack", "eg_decay", "eg_sustain", "eg_release", "lfo1_rate", "lfo2_rate"}
    local param_name = param_names[current_menu.index]
    if param_name then
      local current_value = params:get(param_name)
      params:set(param_name, util.clamp(current_value + delta, 0, 127))
    end
  elseif pages[current_page] == "MOOD" then
    current_menu = mood_menu
    if current_menu.index == 1 then
      params:delta("base_mood", delta)
    elseif current_menu.index == 2 then
      params:delta("mood_modifier", delta)
    end
  end
  update_menu_lists()
end

-- Draw function
function redraw()
  screen.clear()
  screen.aa(1)
  screen.font_face(1)
  screen.font_size(8)
  
  -- Draw page header
  screen.level(15)
  screen.move(2, 10)
  screen.text(pages[current_page])
  screen.move(128, 10)
  screen.text_right(current_synth_model)
  screen.line_width(1)
  screen.move(0, 12)
  screen.line(128, 12)
  screen.stroke()
  
  -- Draw current page content
  if pages[current_page] == "MAIN" then
    main_menu:redraw()
  elseif pages[current_page] == "MOOD" then
    mood_menu:redraw()
  elseif pages[current_page] == "SETTINGS" then
    settings_menu:redraw()
  end
  
  -- Draw navigation hints
  screen.level(1)
  screen.move(0, 62)
  screen.text("E1: PAGE  E2: SELECT  E3: ADJUST")
  
  screen.update()
end

-- Previous cleanup function remains the same...
