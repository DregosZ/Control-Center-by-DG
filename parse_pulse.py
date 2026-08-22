import subprocess
import sys

def get_sink_inputs_for_app(app_name):
    try:
        output = subprocess.check_output(['pactl', 'list', 'sink-inputs']).decode('utf-8')
    except Exception:
        return []

    sink_ids = []
    current_id = None
    
    for line in output.split('\n'):
        if line.startswith('Sink Input #'):
            current_id = line.split('#')[1].strip()
        elif 'application.name = ' in line or 'application.process.binary = ' in line:
            name = line.split('=')[1].strip().strip('"').lower()
            if app_name.lower() in name or name in app_name.lower():
                if current_id and current_id not in sink_ids:
                    sink_ids.append(current_id)
    return sink_ids

print(get_sink_inputs_for_app('brave'))
