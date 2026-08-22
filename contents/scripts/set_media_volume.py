#!/usr/bin/env python3
import sys
import subprocess
import os

CACHE_FILE = os.path.expanduser("~/.cache/kde_control_center_volume.txt")

if len(sys.argv) < 2:
    sys.exit(1)

vol_pct = float(sys.argv[1])
vol_str = f"{int(vol_pct * 100)}%"

# Helper to run shell commands
def run(cmd):
    return subprocess.check_output(cmd, shell=True).decode('utf-8').strip()

# Find the target player (prioritize spotify)
target_player = ""
try:
    if run("playerctl -p spotify status 2>/dev/null") != "":
        target_player = "spotify"
except:
    pass

if not target_player:
    try:
        players = run("playerctl -l 2>/dev/null").split()
        if players: target_player = players[0]
    except:
        pass

if target_player:
    # 1. Try setting via playerctl
    subprocess.run(f"playerctl -p {target_player} volume {vol_pct}", shell=True, stderr=subprocess.DEVNULL)
    
    # 2. Extract base name
    app_name = target_player.split('.')[0].lower()
    if app_name == "chrome": app_name = "chromium"
    
    # 3. Find and set PulseAudio sink input volume
    if app_name in ["chromium", "brave", "firefox", "vivaldi", "opera", "edge", "plasma-browser-integration"]:
        # Save to cache
        try:
            with open(CACHE_FILE, "w") as f:
                f.write(str(vol_pct))
        except:
            pass
            
        try:
            output = run("pactl list sink-inputs")
            current_id = None
            for line in output.split('\n'):
                line = line.strip()
                if line.startswith('Sink Input #'):
                    current_id = line.split('#')[1].strip()
                elif 'application.process.binary' in line or 'application.name' in line:
                    name = line.split('=')[1].strip().strip('"').lower()
                    if app_name in name or name in app_name:
                        if current_id:
                            subprocess.run(f"pactl set-sink-input-volume {current_id} {vol_str}", shell=True)
                            current_id = None
        except Exception:
            pass
