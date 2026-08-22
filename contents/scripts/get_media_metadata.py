#!/usr/bin/env python3
import subprocess
import os

CACHE_FILE = os.path.expanduser("~/.cache/kde_control_center_volume.txt")

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True).decode('utf-8').strip()
    except:
        return ""

# Try to get metadata from spotify first, else default player
target = "spotify"
if run("playerctl -p spotify status 2>/dev/null") == "":
    target = ""
    players = run("playerctl -l 2>/dev/null").split()
    if players: target = players[0]

if not target:
    print("Stopped")
    exit(0)

player_arg = f"-p {target}"
metadata = run(f"playerctl {player_arg} metadata --format '{{{{status}}}}%|%{{{{title}}}}%|%{{{{artist}}}}%|%{{{{mpris:artUrl}}}}%|%{{{{volume}}}}'")

if not metadata or metadata == "":
    print("Stopped")
    exit(0)

# Extract volume and try to override with PulseAudio if applicable
parts = metadata.split("%|%")
if len(parts) >= 5:
    app_name = target.split('.')[0].lower()
    if app_name == "chrome": app_name = "chromium"
    
    # Browsers return 1.0 or broken volume via MPRIS. We should query PulseAudio instead.
    if app_name in ["chromium", "brave", "firefox", "vivaldi", "opera", "edge", "plasma-browser-integration"]:
        current_vol = None
        
        # Get pulse volume
        try:
            output = run("pactl list sink-inputs")
            current_id = None
            for line in output.split('\n'):
                line = line.strip()
                if line.startswith('Sink Input #'):
                    current_id = line.split('#')[1].strip()
                    current_vol = None
                elif line.startswith('Volume:'):
                    vol_str = line.split('/')[1].strip().replace('%', '')
                    current_vol = float(vol_str) / 100.0
                elif 'application.process.binary' in line or 'application.name' in line:
                    name = line.split('=')[1].strip().strip('"').lower()
                    if app_name in name or name in app_name:
                        if current_vol is not None:
                            # Save to cache
                            with open(CACHE_FILE, "w") as f:
                                f.write(str(current_vol))
                            parts[4] = str(current_vol)
                            break
                        else:
                            current_vol = None
        except Exception:
            pass
            
        # If no active sink-input (e.g. paused), read from cache
        if current_vol is None:
            try:
                if os.path.exists(CACHE_FILE):
                    with open(CACHE_FILE, "r") as f:
                        parts[4] = f.read().strip()
            except:
                pass

print("%|%".join(parts))
