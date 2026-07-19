import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

import "../code/Constants.js" as Constants
import "../code/Schedule.js" as Schedule
import "../code/Formatter.js" as Formatter

ColumnLayout {
    id: prayerListLayout
    spacing: Kirigami.Units.smallSpacing
    
    property var adjustedTimes: {
        if (!root.todayTimings) return null;
        var settings = root.getSettingsObj();
        return Schedule.getAdjustedPrayerTimes(root.todayTimings, settings);
    }
    
    Repeater {
        model: Constants.PRAYERS
        
        delegate: PrayerTimeDelegate {
            Layout.fillWidth: true
            
            prayerKey: modelData
            
            isActive: root.nextPrayerResult ? (root.nextPrayerResult.key === modelData && !root.nextPrayerResult.isTomorrow) : false
            
            prayerName: Constants.getPrayerLabels(root.translate)[modelData] || ""
            
            prayerTime: {
                if (!prayerListLayout.adjustedTimes) return "--:--";
                var minutes = prayerListLayout.adjustedTimes[modelData];
                return Formatter.formatTime(minutes, Plasmoid.configuration.use24h);
            }
            
            remainingTime: {
                if (isActive && root.nextPrayerResult) {
                    return Formatter.formatRemainingTime(root.translate, root.nextPrayerResult.remainingMinutes, Plasmoid.configuration.showHhMm);
                }
                return "";
            }
        }
    }
}
