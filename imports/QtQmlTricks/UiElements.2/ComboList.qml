import QtQuick 2.1;
import QtQmlTricks.UiElements 2.0;

Item {
    id: base;
    width: implicitWidth;
    height: implicitHeight;
    implicitWidth: (dumbLayout.width + arrow.width + padding * 3);
    implicitHeight: (dumbLayout.height / count + padding * 2);

    property int    padding     : Style.spacingNormal;
    property bool   filterable  : false;
    property alias  rounding    : rect.radius;
    property alias  backColor   : rect.color;
    property string placeholder : "";

    property var       model      : undefined;
    property Component delegate   : ComboListDelegateForModelWithRoles { }

    property int currentIdx : -1;

    readonly property int count : repeater.count;

    readonly property var currentValue : ((currentIdx >= 0 && currentIdx < repeater.count)
                                          ? repeater.itemAt (currentIdx) ["value"]
                                          : undefined);

    readonly property var currentKey   : ((currentIdx >= 0 && currentIdx < repeater.count)
                                          ? repeater.itemAt (currentIdx) ["key"]
                                          : undefined);

    function selectByKey (key) {
        var ret = false;
        for (var idx = 0; idx < repeater.count; ++idx) {
            var item = repeater.itemAt (idx);
            if (item ["key"] === key) {
                currentIdx = idx;
                ret = true;
                break;
            }
        }
        return ret;
    }

    Rectangle {
        id: rect;
        radius: Style.roundness;
        enabled: base.enabled;
        antialiasing: radius;
        gradient: (enabled
                   ? (clicker.pressed ||
                      clicker.dropdownItem
                      ? Style.gradientPressed ()
                      : Style.gradientIdle (Qt.lighter (Style.colorClickable, clicker.containsMouse ? 1.15 : 1.0)))
                   : Style.gradientDisabled ());
        border {
            width: Style.lineSize;
            color: Style.colorBorder;
        }
        anchors.fill: parent;
    }
    StretchColumnContainer {
        id: dumbLayout;
        opacity: 0;

        Repeater {
            id: repeater;
            model: base.model;
            delegate: Loader {
                id: loaderDumb;
                sourceComponent: base.delegate;
                onInstanceChanged: {
                    if (instance !== null) {
                        instance.active    = true;
                        instance.model     = model;
                        instance.modelData = model.modelData;
                        instance.index     = Qt.binding (function () { return loaderDumb.idx; });
                    }
                }

                readonly property ComboListDelegate instance : item;

                readonly property var idx   : model.index;
                readonly property var value : (instance ? instance.value : undefined);
                readonly property var key   : (instance ? instance.key   : undefined);
            }
        }
    }
    MouseArea {
        id: clicker;
        enabled: base.enabled;
        hoverEnabled: Style.useHovering;
        anchors.fill: parent;
        onClicked: {
            if (dropdownItem) {
                destroyDropdown ();
            }
            else {
                createDropdown ();
            }
        }
        Component.onDestruction: { destroyDropdown (); }

        property Item dropdownItem : null;

        function createDropdown () {
            dropdownItem = compoDropdown.createObject (Introspector.window (base), { });
        }

        function destroyDropdown () {
            if (dropdownItem) {
                dropdownItem.destroy ();
                dropdownItem = null;
            }
        }
    }
    Loader {
        id: loaderCurrent;
        clip: true;
        enabled: base.enabled;
        sourceComponent: base.delegate;
        anchors {
            left: (parent ? parent.left : undefined);
            right: arrow.left;
            margins: padding;
            verticalCenter: (parent ? parent.verticalCenter : undefined);
        }
        onInstanceChanged: {
            if (instance !== null) {
                instance.active  = false;
                instance.index   = Qt.binding (function () { return base.currentIdx; });
                instance.key     = Qt.binding (function () { return base.currentKey; });
                instance.value   = Qt.binding (function () { return (base.currentValue || base.placeholder); });
                instance.opacity = Qt.binding (function () { return (base.currentKey !== undefined ? 1.0 : 0.65); });
            }
        }

        readonly property ComboListDelegate instance : item;
    }
    SymbolLoader {
        id: arrow;
        size: Style.fontSizeNormal;
        color: (enabled ? Style.colorForeground : Style.colorBorder);
        symbol: Style.symbolArrowDown;
        enabled: base.enabled;
        anchors {
            right: (parent ? parent.right : undefined);
            margins: padding;
            verticalCenter: (parent ? parent.verticalCenter : undefined);
        }
    }
    Component {
        id: compoDropdown;

        MouseArea {
            id: dimmer;
            z: 999999999;
            anchors.fill: parent;
            onWheel: { }
            onPressed: { clicker.destroyDropdown (); }
            onReleased: { }

            Item {
                id: mirror;
                x:      ref ["x"];
                y:      ref ["y"];
                width:  ref ["width"];
                height: ref ["height"];

                readonly property rect ref : (dimmer.width && dimmer.height
                                              ? base.mapToItem (parent, 0, 0, base.width, base.height)
                                              : Qt.rect (0,0,0,0));
            }
            Item {
                id: placeholderAbove;
                anchors {
                    top: dimmer.top;
                    left: mirror.left;
                    right: mirror.right;
                    bottom: mirror.top;
                    topMargin: Style.spacingNormal;
                    bottomMargin: -Style.lineSize;
                }
            }
            Item {
                id: placeholderUnder;
                anchors {
                    top: mirror.bottom;
                    left: mirror.left;
                    right: mirror.right;
                    bottom: dimmer.bottom;
                    topMargin: -Style.lineSize;
                    bottomMargin: Style.spacingNormal;
                }
            }
            Item {
                anchors.fill: frame.place;

                ScrollContainer {
                    id: frame;
                    y: (place === placeholderAbove ? (parent.height - (height * scale)) : 0);
                    width: Math.ceil (base.width);
                    height: (parent.height >= actualSize ? actualSize : parent.height);
                    scale: (mirror.width / base.width);
                    showBorder: true;
                    background: Style.colorWindow;
                    headerItem: (filterable ? compoFilter : null);
                    placeholder: (!repeaterDropdown.count ? qsTr ("Nothing here") : "");
                    transformOrigin: Item.TopLeft;

                    property string filter : "";

                    readonly property int itemSize    : (Style.fontSizeNormal + padding * 2);
                    readonly property int contentSize : (layout.height  + Style.lineSize * 2);
                    readonly property int minimumSize : ((itemSize * 3) + Style.lineSize * 2);
                    readonly property int actualSize  : Math.max (contentSize, minimumSize);

                    readonly property Item place : {
                        if (placeholderUnder.height >= actualSize) {
                            return placeholderUnder;
                        }
                        else if (placeholderAbove.height >= actualSize) {
                            return placeholderAbove;
                        }
                        else if (placeholderUnder.height >= minimumSize) {
                            return placeholderUnder;
                        }
                        else if (placeholderAbove.height >= minimumSize) {
                            return placeholderAbove;
                        }
                        else {
                            return placeholderUnder;
                        }
                    }

                    function matches (str) {
                        return (filter === "" || (str.toLowerCase ().indexOf (filter) >= 0));
                    }

                    Component {
                        id: compoFilter;

                        TextBox {
                            id: inputFilter;
                            hasClear: true;
                            textHolder: qsTr ("Filter...");
                            ExtraAnchors.horizontalFill: parent;
                            Component.onCompleted: { forceActiveFocus (); }

                            Binding {
                                target: frame;
                                property: "filter";
                                value: inputFilter.text.toLowerCase ();
                            }
                        }
                    }
                    Flickable {
                        contentHeight: layout.height;
                        flickableDirection: Flickable.VerticalFlick;

                        StretchColumnContainer {
                            id: layout;
                            ExtraAnchors.topDock: parent;

                            Repeater {
                                id: repeaterDropdown;
                                model: base.model;
                                delegate: MouseArea {
                                    id: dlg;
                                    visible: frame.matches (loader.instance.value);
                                    hoverEnabled: Style.useHovering;
                                    implicitWidth: (loader.implicitWidth + padding * 2);
                                    implicitHeight: (loader.implicitHeight + padding * 2);
                                    onClicked: {
                                        currentIdx = idx;
                                        clicker.destroyDropdown ();
                                    }
                                    ExtraAnchors.horizontalFill: parent;

                                    readonly property var  idx  : model.index;
                                    readonly property bool curr : (idx === base.currentIdx);

                                    Rectangle {
                                        color: Style.colorHighlight;
                                        opacity: 0.65;
                                        visible: parent.containsMouse;
                                        anchors.fill: parent;
                                        anchors.margins: Style.lineSize;
                                    }
                                    Loader {
                                        id: loader;
                                        clip: true;
                                        sourceComponent: base.delegate;
                                        anchors {
                                            margins: padding;
                                            verticalCenter: (parent ? parent.verticalCenter : undefined);
                                        }
                                        ExtraAnchors.horizontalFill: parent;
                                        onInstanceChanged: {
                                            if (instance !== null) {
                                                instance.index     = Qt.binding (function () { return dlg.idx; });
                                                instance.active    = Qt.binding (function () { return dlg.curr; });
                                                instance.model     = model;
                                                instance.modelData = model.modelData;
                                            }
                                        }

                                        readonly property ComboListDelegate instance : item;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
