import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    color: "#F4F4F4"

    implicitHeight: __layout.implicitHeight + 40

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
            }

            TextField {
                id: passwordField
                width: parent.width
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password

            }

            Button {
                text: qsTr("LOGIN")
                enabled: loginField.text != "" && passwordField.text != ""

                onClicked: {
                    client.login(loginField.text, passwordField.text)
                }
            }
        }
    }
}
