import QtQuick 2.1;
import QtQmlTricks.UiElements 2.0;

MouseArea {
    id: base;
    width: implicitWidth;
    height: implicitHeight;
    implicitWidth: 100;
    implicitHeight: (layout.height + layout.anchors.margins * 2);

    property alias image   : img.sourceComponent;
    property alias title   : lblTitle.text;
    property alias content : lblContent.text;

    PixelPerfectContainer {
        contentItem: rect;
        anchors.fill: parent;

        Rectangle {
            id: rect;
            width: Math.round (parent.width);
            height: Math.round (parent.height);
            color: Style.colorBubble;
            radius: Style.roundness;
            antialiasing: radius;
            border {
                width: Style.lineSize;
                color: Qt.darker (color);
            }
        }
    }
    StretchColumnContainer {
        id: layout;
        spacing: Style.spacingSmall;
        anchors.margins: Style.spacingNormal;
        ExtraAnchors.topDock: parent;

        TextLabel {
            id: lblTitle;
            visible: (text !== "");
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            horizontalAlignment: Text.AlignJustify;
            font {
                weight: Font.Bold;
                pixelSize: Style.fontSizeSmall;
            }
        }
        TextLabel {
            id: lblContent;
            visible: (text !== "");
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            horizontalAlignment: Text.AlignJustify;
            font.pixelSize: Style.fontSizeSmall;
        }
        Stretcher {
            visible: (img.item !== null);
            implicitHeight: img.implicitHeight;

            Loader {
                id: img;
                active: (sourceComponent !== null);
                enabled: base.enabled;
                anchors {
                    top: parent.top;
                    horizontalCenter: parent.horizontalCenter;
                }
            }
        }
    }
}
