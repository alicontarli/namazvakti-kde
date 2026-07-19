import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Rectangle {
    id: delegateRow
    
    property string prayerKey: ""
    property string prayerName: ""
    property string prayerTime: ""
    property string remainingTime: ""
    property bool isActive: false
    
    implicitHeight: Kirigami.Units.gridUnit * 1.35
    radius: Kirigami.Units.smallSpacing
    
    color: isActive ? Kirigami.Theme.highlightColor : "transparent"
    border.color: isActive ? Kirigami.Theme.activeTextColor : "transparent"
    border.width: isActive ? 1 : 0
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.smallSpacing * 1.5
        anchors.rightMargin: Kirigami.Units.smallSpacing * 1.5
        spacing: Kirigami.Units.smallSpacing
        
        Label {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            text: delegateRow.prayerName
            font.bold: delegateRow.isActive
            font.pointSize: Kirigami.Theme.defaultFont.pointSize
            color: delegateRow.isActive ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            elide: Text.ElideRight
        }
        
        Label {
            text: delegateRow.remainingTime ? ("(" + delegateRow.remainingTime + ")") : ""
            font.italic: true
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
            color: delegateRow.isActive ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
            visible: delegateRow.isActive && delegateRow.remainingTime !== ""
        }
        
        Label {
            text: delegateRow.prayerTime
            font.bold: delegateRow.isActive
            font.pointSize: Kirigami.Theme.defaultFont.pointSize
            color: delegateRow.isActive ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
        }
    }
}
