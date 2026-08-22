#!/usr/bin/env python3
import sys
import json
import dbus

def get_menu_items(bus, service, menu_path):
    try:
        menu_obj = bus.get_object(service, menu_path)
        menu_iface = dbus.Interface(menu_obj, 'com.canonical.dbusmenu')
        layout = menu_iface.GetLayout(0, 1, ["label"])
        
        # layout[1] contains the actual menu tree. 
        # Format: (id, {properties}, [children])
        items = []
        if len(layout) > 1 and len(layout[1]) > 2:
            children = layout[1][2]
            for child in children:
                item_id = int(child[0])
                props = child[1]
                label = str(props.get('label', '')).lower()
                items.append({'id': item_id, 'label': label})
        return items
    except Exception:
        return []

def list_snis():
    bus = dbus.SessionBus()
    try:
        watcher = bus.get_object('org.kde.StatusNotifierWatcher', '/StatusNotifierWatcher')
        props_iface = dbus.Interface(watcher, 'org.freedesktop.DBus.Properties')
        items = props_iface.Get('org.kde.StatusNotifierWatcher', 'RegisteredStatusNotifierItems')
    except Exception:
        print(json.dumps([]))
        return

    results = []
    for item in items:
        try:
            item_str = str(item)
            if '/' not in item_str: continue
            service, path = item_str.split('/', 1)
            path = '/' + path
            
            obj = bus.get_object(service, path)
            props_iface = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
            all_props = props_iface.GetAll('org.kde.StatusNotifierItem')
            
            # Extract safely
            icon = str(all_props.get('IconName', ''))
            title = str(all_props.get('Title', ''))
            menu_path = str(all_props.get('Menu', ''))
            item_id = str(all_props.get('Id', ''))
            
            # Fallbacks for Electron apps like Discord that omit IconName/Title
            if not icon:
                # Try to guess from Id (e.g., 'discord_status_icon_1' -> 'discord')
                icon = item_id.split('_')[0].lower() if item_id else 'application-x-executable'
            if not title:
                title = item_id.split('_')[0].capitalize() if item_id else 'Unknown App'
                
            results.append({
                'service': service,
                'path': path,
                'menu_path': menu_path,
                'icon': icon,
                'title': title
            })
        except Exception:
            continue
            
    print(json.dumps(results))

def action_sni(service, path, action_type):
    bus = dbus.SessionBus()
    try:
        obj = bus.get_object(service, path)
        props = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
        menu_path = str(props.Get('org.kde.StatusNotifierItem', 'Menu'))
        
        menu_items = get_menu_items(bus, service, menu_path)
        
        target_id = None
        if action_type == "show":
            # Try to find 'show', 'open', 'restore'
            for item in menu_items:
                if 'show' in item['label'] or 'open' in item['label'] or 'restore' in item['label']:
                    target_id = item['id']
                    break
        elif action_type == "quit":
            # Try to find 'exit', 'quit', 'close'
            for item in menu_items:
                if 'exit' in item['label'] or 'quit' in item['label'] or 'close' in item['label']:
                    target_id = item['id']
                    break
                    
        if target_id is not None:
            menu_obj = bus.get_object(service, menu_path)
            menu_iface = dbus.Interface(menu_obj, 'com.canonical.dbusmenu')
            menu_iface.Event(target_id, "clicked", dbus.String("", variant_level=1), 0)
        else:
            # Fallback for 'show'
            if action_type == "show":
                sni_iface = dbus.Interface(obj, 'org.kde.StatusNotifierItem')
                sni_iface.SecondaryActivate(0, 0)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        list_snis()
    elif sys.argv[1] == 'list':
        list_snis()
    elif sys.argv[1] == 'show' and len(sys.argv) == 4:
        action_sni(sys.argv[2], sys.argv[3], "show")
    elif sys.argv[1] == 'quit' and len(sys.argv) == 4:
        action_sni(sys.argv[2], sys.argv[3], "quit")
