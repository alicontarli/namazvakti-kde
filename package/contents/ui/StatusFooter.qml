import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Formatter.js" as Formatter

RowLayout {
    spacing: Kirigami.Units.smallSpacing
    
    Label {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.85
        color: root.isOffline ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.disabledTextColor
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        
        text: {
            if (root.isLoading && !root.todayTimings) {
                return root.translate("Loading...");
            }
            if (!root.todayTimings) {
                return root.translate("Error - Failed to load data");
            }
            if (root.isOffline) {
                return root.translate("Offline — using cached timings");
            }
            if (root.lastSuccessfulUpdate) {
                var h = root.lastSuccessfulUpdate.getHours();
                var m = root.lastSuccessfulUpdate.getMinutes();
                var timeStr = Formatter.formatTime(h * 60 + m, Plasmoid.configuration.use24h);
                return Formatter.formatString(root.translate("Last update: %1$s"), timeStr);
            }
            return "";
        }
    }
    
    BusyIndicator {
        id: busyInd
        implicitWidth: Kirigami.Units.gridUnit
        implicitHeight: Kirigami.Units.gridUnit
        running: root.isLoading
        visible: root.isLoading
    }
}
