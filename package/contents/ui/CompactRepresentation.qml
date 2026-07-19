import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "../code/Constants.js" as Constants
import "../code/Formatter.js" as Formatter

Control {
    id: control
    
    focus: true
    
    // Explicit sizing for layout calculations in the Plasma panel
    implicitWidth: textLabel.implicitWidth + Kirigami.Units.smallSpacing * 4
    implicitHeight: textLabel.implicitHeight + Kirigami.Units.smallSpacing * 2
    
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.expanded = !root.expanded;
        }
    }
    
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
            root.expanded = !root.expanded;
            event.accepted = true;
        }
    }


    Label {
        id: textLabel
        anchors.centerIn: parent
        
        text: {
            if (!root.todayTimings || !root.nextPrayerResult) {
                return root.isLoading ? "..." : root.translate("Offline");
            }
            
            var labels = Constants.getPrayerLabels(root.translate);
            var prayerLabel = labels[root.nextPrayerResult.key] || "";
            var remainingStr = Formatter.formatRemainingTime(root.translate, root.nextPrayerResult.remainingMinutes, Plasmoid.configuration.showHhMm);
            
            if (Plasmoid.formFactor === PlasmaCore.Types.Vertical) {
                return prayerLabel + "\n" + remainingStr;
            } else {
                if (Plasmoid.configuration.viewMode === "time-only") {
                    return remainingStr;
                } else {
                    return prayerLabel + " · " + remainingStr;
                }
            }
        }
        
        font.pointSize: Kirigami.Theme.defaultFont.pointSize
        color: Kirigami.Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        lineHeight: 0.95
        maximumLineCount: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? 2 : 1
        wrapMode: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? Text.Wrap : Text.NoWrap
        elide: Text.ElideRight
    }
}
