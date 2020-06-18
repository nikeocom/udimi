import QtQuick 2.14
import QtGraphicalEffects 1.14

Image {
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: circleMask
    }

    Rectangle {
        id: circleMask
        width: parent.width
        height: parent.height
        radius: width / 2
        visible: source == ""
        border.color: "black"
    }
}
