import dbus
bus = dbus.SessionBus()
service, path = ':1.4976', '/StatusNotifierItem'
obj = bus.get_object(service, path)
props = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
print("All props:")
try:
    all_props = props.GetAll('org.kde.StatusNotifierItem')
    for k, v in all_props.items():
        print(f"  {k}: {type(v)}")
except Exception as e:
    print("GetAll error:", e)
    
# Let's try fetching just Id
print("Id:", props.Get('org.kde.StatusNotifierItem', 'Id'))
