import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../code/LocationData.js" as LocationData

Item {
    id: root

    property string text: ""
    property string placeholderText: ""
    property var candidates: []
    property bool isObjectList: false
    property string textRole: "name"
    property string valueRole: "id"

    signal committed(string value)

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Layout.fillWidth: true

    onTextChanged: {
        if (textField.text !== root.text) {
            textField.text = root.text;
        }
    }

    function commitBestMatch() {
        var currentInput = textField.text;
        var best = LocationData.getBestMatch(currentInput, root.candidates);
        if (best !== undefined && best !== null) {
            textField.text = best;
            root.text = best;
            root.committed(best);
        }
        popup.close();
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        TextField {
            id: textField
            Layout.fillWidth: true
            placeholderText: root.placeholderText
            text: root.text
            selectByMouse: true

            onTextEdited: {
                root.text = text;
                var filtered = LocationData.filterCandidates(text, root.candidates);
                if (filtered.length > 0) {
                    popup.open();
                } else {
                    popup.close();
                }
            }

            onAccepted: {
                root.commitBestMatch();
            }

            onActiveFocusChanged: {
                if (!activeFocus) {
                    root.commitBestMatch();
                }
            }
        }

        ToolButton {
            icon.name: popup.visible ? "arrow-up" : "arrow-down"
            display: AbstractButton.IconOnly
            onClicked: {
                if (popup.visible) {
                    popup.close();
                } else {
                    textField.forceActiveFocus();
                    popup.open();
                }
            }
        }
    }

    Popup {
        id: popup
        y: textField.height + Kirigami.Units.smallSpacing
        width: Math.max(textField.width, Kirigami.Units.gridUnit * 12)
        height: Math.min(listView.contentHeight + Kirigami.Units.smallSpacing * 2, Kirigami.Units.gridUnit * 12)
        padding: Kirigami.Units.smallSpacing
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.focusColor
            border.width: 1
            radius: Kirigami.Units.smallSpacing
        }

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: listView
                model: LocationData.filterCandidates(textField.text, root.candidates)
                clip: true
                spacing: 2

                delegate: Rectangle {
                    width: listView.width
                    height: Kirigami.Units.gridUnit * 1.5
                    color: mouseArea.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
                    radius: Kirigami.Units.smallSpacing * 0.5

                    property var itemData: modelData
                    property string displayStr: {
                        if (typeof itemData === 'object' && itemData !== null) {
                            return itemData[root.textRole] || itemData.name || itemData.id || "";
                        }
                        return itemData ? itemData.toString() : "";
                    }
                    property string valueStr: {
                        if (typeof itemData === 'object' && itemData !== null) {
                            return itemData[root.valueRole] || itemData.id || itemData.name || "";
                        }
                        return itemData ? itemData.toString() : "";
                    }

                    Label {
                        anchors.fill: parent
                        anchors.leftMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: Kirigami.Units.smallSpacing
                        verticalAlignment: Text.AlignVCenter
                        text: parent.displayStr
                        color: mouseArea.containsMouse ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var val = parent.valueStr;
                            textField.text = val;
                            root.text = val;
                            root.committed(val);
                            popup.close();
                        }
                    }
                }
            }
        }
    }
}
