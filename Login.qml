import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    color: "#F4F4F4"

    implicitHeight: __layout.implicitHeight + 40

    Connections {
        target: client
        onAuthFailed: {
            busyIndicator.running = false
            loginButton.visible = true
            errorString.text = error
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 600
        height: __layout.height + 40
        color: "#FFFFFF"
        border.color: "lightgray"
        Column {
            id: __layout
            anchors.centerIn: parent

            width: parent.width - 40

            spacing: 10
            Label {
                text: qsTr("Login")
                font.pixelSize: 13
                font.bold: true
                color: "black"
            }

            TextField {
                id: loginField
                width: parent.width
                inputMethodHints: Qt.ImhEmailCharactersOnly
                placeholderText: qsTr("Email")
                selectByMouse: true
            }

            TextField {
                id: passwordField
                width: parent.width
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password
                selectByMouse: true
            }

            Row {
                spacing: 5
                Button {
                    id: loginButton
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("LOGIN")
                    enabled: loginField.text != "" && passwordField.text != ""

                    onClicked: {
                        visible = false
                        errorString.text = ""
                        busyIndicator.running = true
                        client.login(loginField.text, passwordField.text)

                    }
                }

                Label {
                    id: errorString
                    anchors.verticalCenter: parent.verticalCenter
                    color: "red"
                    font.pixelSize: 10
                }
            }

            BusyIndicator {
                id: busyIndicator
                anchors.left: parent.left
                anchors.leftMargin: 20
                width: 30
                height: 30
                visible: running
                running: false
            }
        }
    }
}
