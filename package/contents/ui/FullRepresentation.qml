import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Constants.js" as Constants
import "../code/Formatter.js" as Formatter

Item {
    id: fullRep
    
    implicitWidth: Kirigami.Units.gridUnit * 18
    implicitHeight: mainLayout.implicitHeight + Kirigami.Units.gridUnit * 0.6
    
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    
    property string locationText: {
        if (Plasmoid.configuration.locationMode === 'city') {
            return Plasmoid.configuration.city + ", " + Plasmoid.configuration.country;
        } else {
            return Plasmoid.configuration.latitude.toFixed(4) + ", " + Plasmoid.configuration.longitude.toFixed(4);
        }
    }
    
    property string dateText: {
        var now = new Date();
        var lang = Plasmoid.configuration.language;
        var localeCode = undefined;
        if (lang !== 'auto') {
            var langLocales = {
                en: 'en-US', tr: 'tr-TR', ar: 'ar-SA', es: 'es-ES',
                fr: 'fr-FR', de: 'de-DE', ru: 'ru-RU', fa: 'fa-IR',
                ur: 'ur-PK', id: 'id-ID', bn: 'bn-BD'
            };
            localeCode = langLocales[lang];
        }
        
        try {
            var locale = localeCode ? Qt.locale(localeCode) : Qt.locale();
            return now.toLocaleDateString(locale, "dd MMMM yyyy dddd");
        } catch(e) {
            return now.toDateString();
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit * 0.6
        spacing: Kirigami.Units.smallSpacing
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            
            Label {
                Layout.fillWidth: true
                text: fullRep.locationText
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                font.bold: true
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            
            Label {
                Layout.fillWidth: true
                text: fullRep.dateText
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                color: Kirigami.Theme.disabledTextColor
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }
        
        Kirigami.Separator {
            Layout.fillWidth: true
        }
        
        PrayerTimesList {
            id: prayerList
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        
        Kirigami.Separator {
            Layout.fillWidth: true
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            Button {
                Layout.fillWidth: true
                text: root.translate("Refresh now")
                icon.name: "view-refresh-symbolic"
                enabled: !root.isLoading
                
                onClicked: {
                    root.updateData(true);
                }
            }
            
            Button {
                Layout.fillWidth: true
                text: root.translate("Settings")
                icon.name: "preferences-system-symbolic"
                
                onClicked: {
                    var action = Plasmoid.internalAction("configure");
                    if (action) {
                        action.trigger();
                    }
                    root.expanded = false;
                }
            }
        }
        
        StatusFooter {
            Layout.fillWidth: true
        }
    }
}
