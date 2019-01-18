import QtQuick 2.1;
import QtQmlTricks.UiElements 2.0;

ComboListDelegate {
    id: base;
    key: (base.model ? base.model [base.roleKey] : undefined);
    value: (base.model ? base.model [base.roleValue] : "");
    implicitWidth: lbl.implicitWidth;
    implicitHeight: lbl.implicitHeight;

    property string roleKey   : "key";
    property string roleValue : "value";

    readonly property alias label : lbl;

    TextLabel {
        id: lbl;
        text: base.value;
        emphasis: base.active;
        anchors.verticalCenter: (parent ? parent.verticalCenter : undefined);
    }
}
