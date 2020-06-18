import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: __impl

    color: "#F4F4F4"

    StackView.onActivated: {
        projectRepeater.model = []
        client.getProjects()
    }

    Connections {
        target: client
        onProjectsReceived: {
            projectRepeater.model = projects.projects
        }
    }

    function secondsToTime(secs)
    {
        secs = Math.round(secs);
        var hours = Math.floor(secs / (60 * 60));

        var divisor_for_minutes = secs % (60 * 60);
        var minutes = Math.floor(divisor_for_minutes / 60);

        var divisor_for_seconds = divisor_for_minutes % 60;
        var seconds = Math.ceil(divisor_for_seconds);

        return [
                    hours > 9 ?  hours : '0' + hours,
                    minutes > 9 ? minutes: '0' + minutes,
                    seconds > 9 ? seconds: '0' + seconds
                ].join(":");
    }

    Column {
        id: __rootLayout
        width: parent.width

        Rectangle {
            id: header
            width: parent.width
            height: 50
            color: "#FFFFFF"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40
                text: qsTr("Q")
                font.pixelSize: 20
                font.bold: true
            }

            Text {
                id: name
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40
                text: qsTr("PROJECTS")
                color: "#818785"
            }
        }

        ScrollView {
            id: __scroll
            width: parent.width
            height: __impl.height - header.height

            topPadding: 10
            bottomPadding: 10

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: __impl.width
                spacing: 10

                Repeater {
                    id: projectRepeater
                    delegate: Rectangle {
                        color: sensor.containsMouse ? "lightgray" : "#FFFFFF"
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 600
                        height: 100
                        radius: 2
                        border.color: "lightgray"

                        MouseArea {
                            id: sensor
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                rootController.push(projectInfoComponent, { "projectId" : modelData.id })
                            }
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            spacing: 20
                            CircularImage {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 50
                                height: width
                                source: modelData.logo_url ? modelData.logo_url : ""
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                color: "black"
                                font.bold: true
                                font.pixelSize: 14
                            }
                        }

                        Text {
                            text: modelData.is_active == 1 ? qsTr("Active") : qsTr("Not active")
                            color: "green"
                            font.bold: true
                            font.pixelSize: 15
                            anchors.centerIn: parent
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            width: 160

                            Repeater {
                                model: [
                                    { "name": qsTr("time this week: "), "value": secondsToTime(modelData.spent_time_week) },
                                    { "name": qsTr("this month: "), "value": secondsToTime(modelData.spent_time_month)},
                                    { "name": qsTr("total: "), "value": secondsToTime(modelData.spent_time_all)}]

                                delegate: Item {
                                    width: parent.width
                                    height: timeLabel.height
                                    Text {
                                        anchors.left: parent.left
                                        text: modelData.name
                                    }

                                    Text {
                                        id: timeLabel
                                        anchors.right: parent.right
                                        text: modelData.value
                                        font.bold: true
                                    }

                                }
                            } // Repeater
                        } // Column
                    } // Rectangle
                } // Repeater
            } // Column
        } // ScrollView
    } // Column
} // Rectangle
