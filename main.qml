import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Window 2.14

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Connections {
        target: client
        onAuthSuccess: {
            rootController.replace(projectsComponent)
        }
    }

    StackView {
        id: rootController
        anchors.fill: parent
        initialItem: loginComponent
    }


    Component {
        id: loginComponent
        Login {}
    }

    Component {
        id: projectsComponent
        Projects {}
    }

    Component {
        id: projectInfoComponent
        ProjectInfo {}
    }
}
