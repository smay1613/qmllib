import QtQuick 2.1;
import QtQmlTricks.UiElements 2.0;

ComboListDelegate {
    id: base;
    key: (base.modelData ? base.modelData [base.attributeKey] : undefined);
    value: (base.modelData ? base.modelData [base.attributeValue] : "");
    implicitWidth: lbl.implicitWidth;
    implicitHeight: lbl.implicitHeight;

    property string attributeKey   : "key";
    property string attributeValue : "value";

    readonly property alias label : lbl;

    TextLabel {
        id: lbl;
        text: base.value;
        emphasis: base.active;
        anchors.verticalCenter: (parent ? parent.verticalCenter : undefined);
    }
}
