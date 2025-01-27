local m = {
  -- Required metadata fields
  name = "ms2kmk_manager",
  version = "4.0.0",
  author = "LudfisterSound",
  url = "https://github.com/LudfisterSound/ms2kmk_manager",
  
  -- Optional metadata fields
  description = [[
    Advanced patch manager and generator for Korg MS2000 and MicroKorg.
    Features mood-based patch generation, pattern sequencing,
    and real-time MIDI CC control.
  ]],
  
  -- Script requirements
  requirements = {
    norns = {
      version = "231006",  -- Required norns version
      engines = {},        -- No specific engine required
      libs = {
        "midi",
        "musicutil"
      }
    },
    hardware = {
      {
        type = "midi",
        description = "Korg MS2000 or MicroKorg synthesizer"
      }
    }
  },
  
  -- Additional tags for catalog searches
  tags = {
    "midi",
    "synth",
    "generative",
    "ms2000",
    "microkorg",
    "korg"
  },
  
  -- Default script options
  options = {
    {
      id = "default_synth",
      name = "Default Synth",
      type = "option",
      options = {"MS2000", "MicroKorg"},
      default = 1
    },
    {
      id = "midi_smoothing",
      name = "MIDI Smoothing",
      type = "option",
      options = {"On", "Off"},
      default = 1
    }
  },
  
  -- Release notes
  changelog = [[
    v4.0.0 - Added complex mood system and MicroKorg support
    v3.0.0 - Added pattern generation and modulation matrix
    v2.0.0 - Added patch generator and bank management
    v1.0.0 - Initial release with basic SysEx support
  ]]
}

return m
