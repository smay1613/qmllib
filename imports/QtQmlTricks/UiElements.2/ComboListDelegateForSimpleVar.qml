import QtQuick 2.1;
import QtQmlTricks.UiElements 2.0;

ComboListDelegate {
    id: base;
    key: base.modelData;
    value: (base.modelData ? base.modelData : "");
    implicitWidth: lbl.implicitWidth;
    implicitHeight: lbl.implicitHeight;

    readonly property alias label : lbl;

    TextLabel {
        id: lbl;
        text: base.value;
        emphasis: base.active;
        anchors.verticalCenter: (parent ? parent.verticalCenter : undefined);
    }
}
