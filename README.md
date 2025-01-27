# ms2kmk_manager
Advanced patch generator and librarian for KORG MS2000 and microKorg on Norns.

Does not work at all, don't install it. 

# MS2000/MicroKorg Manager

A Monome Norns script for managing, generating, and controlling Korg MS2000 and MicroKorg synthesizers. Features mood-based patch generation, pattern sequencing, and real-time MIDI CC control.

## Requirements

- Monome Norns (latest version recommended)
- Korg MS2000 or MicroKorg synthesizer
- MIDI interface/cables

## Installation

From Maiden:
```
;install https://github.com/LudfisterSound/ms2kmk_manager
```

Manual installation:
1. Clone this repository
2. Copy contents to `~/dust/code/ms2kmk_manager/`
3. Restart Norns

## Hardware Setup

1. Connect your MS2000 or MicroKorg to Norns via MIDI
2. Set your synth to receive MIDI on channel 1 (default)
3. Enable SysEx reception on your synth

## Controls

### Global Controls
- E1: Navigate menus
- E2: Change values
- E3: Fine tune/select
- K1: Back/menu
- K2: Save/load
- K3: Generate/send

### Page-Specific Controls

#### Main Page
- E1: Change page
- E2: Select program
- E3: Select bank
- K2: Load program
- K3: Send program

#### Generate Page
- E2: Select category
- E3: Select mood
- K2: Generate new patch
- K3: Save generated patch

#### Modulation Page
- E2: Select modulation slot
- E3: Adjust amount
- K2: Enable/disable route
- K3: Send changes

## Features

### Patch Generation
Generate new patches based on:
- Sound categories (Bass, Lead, Pad, Percussion, Arpeggio, SFX)
- Mood settings (Aggressive, Mellow, Ethereal, Dark, Bright, Weird, Classic)
- Sub-categories for detailed sound design

### Mood System
Complex mood interactions featuring:
- Base moods and modifiers
- Time-based evolution
- Probability-based effects
- Smooth transitions

### MIDI Control
Real-time MIDI CC control with:
- Parameter smoothing
- Synth-specific CC mapping
- Clock-synchronized evolution
- Automatic synth detection

### Pattern Generation
Generate patterns with:
- Category-specific templates
- Rhythmic constraints
- Scale-aware note generation
- Mood-influenced variations

## Parameters

### Synthesis
- Oscillator settings
- Filter parameters
- Envelope controls
- LFO settings
- Effects parameters

### Modulation
- Multiple modulation routes
- Depth control
- Time-based modulation
- Complex routing options

### Pattern
- Step sequencer
- Rhythm patterns
- Note probability
- Gate time

## Tips & Tricks

1. Mood Evolution
- Combine different moods and modifiers for complex evolution
- Use slower evolution rates for subtle changes
- Experiment with probability settings

2. Pattern Generation
- Start with basic categories and gradually add complexity
- Use constraints for more musical results
- Combine different rhythm patterns

3. MIDI Control
- Enable parameter smoothing for gradual changes
- Use modulation for dynamic sound design
- Sync to external clock for rhythmic evolution

## Saving & Loading

- Programs are saved in `~/dust/data/ms2kmk_manager/`
- Bank information is preserved between sessions
- Pattern data is saved with patches
- Mood settings can be saved as presets

## Troubleshooting

1. No MIDI Communication
- Check MIDI cables and connections
- Verify MIDI channel settings
- Ensure SysEx is enabled on your synth

2. Parameter Issues
- Reset to default settings
- Check synth model selection
- Verify CC mappings

3. Pattern Sync
- Check MIDI clock settings
- Reset pattern position
- Verify tempo settings

## Quick Start Guide

### 1. First Time Setup
```
1. Connect MIDI
   - Connect MIDI OUT from Norns to MIDI IN on your synth
   - Connect MIDI IN on Norns to MIDI OUT on your synth

2. Power Up
   - Turn on your synth first
   - Start your Norns
   - Launch the script from the Norns menu

3. Initial Configuration
   - Select your synth model (MS2000 or MicroKorg)
   - Set MIDI channel (default: 1)
```

### 2. Generate Your First Patch
```
1. From the main screen:
   - Press K1 to access menu
   - Turn E1 to select "GENERATE"
   - Press K1 to enter generate mode

2. Select sound type:
   - Turn E2 to choose category (e.g., "Bass")
   - Turn E3 to select mood (e.g., "Aggressive")

3. Generate and send:
   - Press K2 to generate patch
   - Press K3 to send to synth
```

### 3. Real-time Control
```
1. Access MIDI control:
   - Press K1 twice to return to main page
   - Turn E1 to select "CONTROL"

2. Control parameters:
   - E2 selects parameter
   - E3 adjusts value
   - Changes are sent in real-time
```

### 4. Save Your Work
```
1. Store current patch:
   - From any page, hold K2
   - Select save slot with E2
   - Press K3 to confirm save

2. Name your patch (optional):
   - After saving, press K1
   - Use E2/E3 to enter name
   - Press K3 to confirm
```

### Common Operations

#### Quick Pattern Generation
```
Generate > Select Category > Press K2 twice
```

#### Fast Sound Design
```
1. Start with a category (E2)
2. Select a mood (E3)
3. Generate (K2)
4. If you like it: Save (hold K2)
5. If not: Generate again (K2)
```

#### Mood Evolution
```
1. Select base mood (E2)
2. Add modifier (E3)
3. Evolution starts automatically
4. Adjust depth with E3
```

### Tips for Best Results

1. Sound Design
   - Start with basic categories before experimenting
   - Use mood modifiers to add complexity
   - Save variations you like immediately

2. Performance
   - Keep evolution depth low for subtle changes
   - Use pattern sync for rhythmic patches
   - Combine moods for complex sounds

3. Troubleshooting
   - No sound? Check MIDI channel
   - Weird patterns? Reset clock sync
   - Lost patch? Check last saved slot

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our GitHub repository.

## Credits

Created by LudfisterSound
Special thanks to the Monome community

## License

MIT License - see LICENSE.md for details

