import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: __impl
    color: "#F4F4F4"

    property int projectId: -1

    onProjectIdChanged: {
        if (projectId != -1) {
            client.getProjectInfo(projectId)
        }
    }

    property var project: null

    Connections {
        target: client
        onProjectUpdated: {
            timer.start()
        }

        onProjectInfoReceived: {
            if (__impl.projectId == projectId) {
                project = projectInfo.project
                activeSwitch.checked = project.is_active === 1
                namefield.text = project.name
                avatarImage.source = project.logo_url ? project.logo_url : ""
                asWatcherSwitch.checked = project.is_owner_watcher === 1
                usersRepeater.model = project.users
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 50
        Button {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Back")

            onClicked: {
                rootController.pop();
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 600
        height: __layout.implicitHeight + 40
        border.color: "lightgray"
        Column {
            id: __layout
            anchors.centerIn: parent
            width: parent.width - 20
            spacing: 10
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -10

                Column {
                    width: __layout.width - avatarImage.width - 20

                    Row {
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 80
                            text: qsTr("Active")
                        }

                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 1
                        }

                        Switch {
                            id: activeSwitch
                            anchors.verticalCenter: parent.verticalCenter
                            indicator: Rectangle {
                                implicitWidth: 32
                                implicitHeight: 16
                                x: activeSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 13
                                color: activeSwitch.checked ? "#17a81a" : "#ffffff"
                                border.color: "#cccccc"

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: activeSwitch.checked ? parent.width - width - 2 : 2
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: activeSwitch.down ? "#cccccc" : "#ffffff"
                                    border.color: "#999999"
                                }
                            }
                        } // Switch
                    } // Row
                    Row {
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 80
                            text: qsTr("Name")
                        }

                        Item {
                            width: 20
                            height: 1
                        }

                        TextField {
                            anchors.verticalCenter: parent.verticalCenter
                            id: namefield
                            width: 200
                            height: 30
                            selectByMouse: true
                        }

                        Item {
                            width: 5
                            height: 1
                        }

                        Button {
                            id: okButton
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: !!project ? project.name != namefield.text : false
                            text: qsTr("OK")

                            onClicked: {
                                client.updateProjectName(__impl.projectId, namefield.text)
                            }

                            background: Rectangle {
                                color: "#3E5375"
                            }

                            contentItem: Label {
                                color: "#FFFFFF"
                                text: okButton.text
                            }
                        }
                    } // Row
                } // Column

                CircularImage {
                    id: avatarImage
                    anchors.verticalCenter: parent.verticalCenter
                    width: 80
                    height: 80
                }

            } // Row

            Row {
                id: usersColumn
                visible: !!__impl.project ? __impl.project.users.length > 0 : false
                spacing: 20
                Text {
                    anchors.top: parent.top
                    width: 80
                    text: qsTr("Users")
                }
                Flow {
                    anchors.top: parent.top
                    width: __layout.width - 100
                    spacing: 10
                    Repeater {
                        id: usersRepeater
                        delegate: CheckBox {
                            id: userCheckbox
                            text: modelData.name
                            property url image: modelData.avatar_url ? modelData.avatar_url : ""

                            indicator: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 12
                                height: 12
                                radius: 2
                                border.color: "#161616"
                                color: "transparent"

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 8
                                    height: 8
                                    radius: 2
                                    color: userCheckbox.checked ? "lightgray" : "transparent"
                                }

                            } // Rectangle

                            contentItem: Row {
                                spacing: 5
                                Item {
                                    width: 5
                                    height: 1
                                }
                                Item {
                                    width: 20
                                    height: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    CircularImage {
                                        anchors.fill: parent
                                        source: userCheckbox.image
                                    }
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.right: parent.right
                                        radius: 5
                                        width: 10
                                        height: 10
                                        color: modelData.is_online ? "green" : "red"
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: userCheckbox.text
                                }
                            }
                        } // Checkbox
                    } // Repeater

                } // Flow
            } // Row

            Row {
                spacing: 20
                Switch {
                    id: asWatcherSwitch
                    anchors.verticalCenter: parent.verticalCenter
                    indicator: Rectangle {
                        implicitWidth: 32
                        implicitHeight: 16
                        x: asWatcherSwitch.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 13
                        color: asWatcherSwitch.checked ? "#17a81a" : "#ffffff"
                        border.color: "#cccccc"

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: asWatcherSwitch.checked ? parent.width - width - 2 : 2
                            width: 12
                            height: 12
                            radius: 6
                            color: asWatcherSwitch.down ? "#cccccc" : "#ffffff"
                            border.color: "#999999"
                        }
                    }
                } // Switch
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Add me as watcher to tickets created by others")
                }

            } // Row

            Text {
                id: status
                color: "green"
                opacity: timer.running ? 1.0 : 0.0

                text: qsTr("Project successfully saved")

                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        } // Column
    }
    Timer {
        id: timer
        interval: 3*1000
    }
} // Rectangle
