import QtQuick
import QtQuick.Dialogs

Item {
    FileDialog {
        id: fd
        Component.onCompleted: {
            console.log("FileDialog keys: ", Object.keys(fd).join(", "))
            Qt.quit()
        }
    }
}
