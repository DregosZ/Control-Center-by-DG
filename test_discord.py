import dbus
bus = dbus.SessionBus()
watcher = bus.get_object('org.kde.StatusNotifierWatcher', '/StatusNotifierWatcher')
props_iface = dbus.Interface(watcher, 'org.freedesktop.DBus.Properties')
items = props_iface.Get('org.kde.StatusNotifierWatcher', 'RegisteredStatusNotifierItems')
print("All items:", items)
for item in items:
    try:
        service, path = str(item).split('/', 1)
        path = '/' + path
        obj = bus.get_object(service, path)
        props = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
        print(f"[{item}]")
        for p in ['IconName', 'Title', 'Id']:
            try:
                print(f"  {p}: {props.Get('org.kde.StatusNotifierItem', p)}")
            except Exception as e:
                print(f"  {p}: ERROR {e}")
    except Exception as e:
        print(f"[{item}] ERROR {e}")
