import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ApplicationWindow {
    width: 600
    height: 200
    visible: true

    ColumnLayout {
        anchors.fill: parent
        
        GridLayout {
            Layout.fillWidth: true
            columns: 5
            
            Repeater {
                model: 5
                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: 50
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: 44
                        height: 44
                        color: "red"
                    }
                }
            }
        }
    }
}
