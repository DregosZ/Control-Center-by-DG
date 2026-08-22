import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.systemtray as SysTray

Item {
    SysTray.StatusNotifierModel {
        id: snModel
    }
    
    Component.onCompleted: {
        console.log("Tray loaded, count: " + snModel.count)
    }
}
