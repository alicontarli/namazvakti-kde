import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Translations.js" as Translations
import "../code/LocationData.js" as LocationData
import "../code/PrayerTimesProvider.js" as PrayerTimesProvider
import "../code/Formatter.js" as Formatter
import "../code/Constants.js" as Constants

ScrollView {
    id: root
    
    property string cfg_locationMode: Plasmoid.configuration.locationMode
    property string cfg_city: Plasmoid.configuration.city
    property string cfg_country: Plasmoid.configuration.country
    property real cfg_latitude: Plasmoid.configuration.latitude
    property real cfg_longitude: Plasmoid.configuration.longitude

    // Test state
    property bool isTesting: false
    property string testStatus: "" // "success" | "error" | ""
    property string testMessage: ""
    property var testTimings: null

    readonly property string currentLanguage: Plasmoid.configuration.language
    function translate(str) {
        return Translations.translate(str, currentLanguage);
    }

    onCfg_latitudeChanged: {
        var val = parseFloat(latitudeField.text);
        if (isNaN(val) || Math.abs(val - cfg_latitude) > 0.00001) {
            latitudeField.text = cfg_latitude.toString();
        }
    }
    
    onCfg_longitudeChanged: {
        var val = parseFloat(longitudeField.text);
        if (isNaN(val) || Math.abs(val - cfg_longitude) > 0.00001) {
            longitudeField.text = cfg_longitude.toString();
        }
    }

    onCfg_locationModeChanged: {
        locationModeCombo.syncFromConfig();
    }

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    Pane {
        id: container
        width: root.width - (root.ScrollBar.vertical.visible ? root.ScrollBar.vertical.width : 0)
        implicitHeight: formLayout.implicitHeight
        background: null
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0

        Kirigami.FormLayout {
            id: formLayout
            anchors.fill: parent
            
            ComboBox {
                id: locationModeCombo
                Kirigami.FormData.label: translate("Location Determination Method")
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: translate("City and Country"), value: "city" },
                    { text: translate("Geographic Coordinates (Latitude / Longitude)"), value: "coords" }
                ]

                function syncFromConfig() {
                    if (root.cfg_locationMode === "coords") {
                        if (currentIndex !== 1) currentIndex = 1;
                    } else {
                        if (currentIndex !== 0) currentIndex = 0;
                    }
                }

                onActivated: function(index) {
                    root.cfg_locationMode = (index === 1) ? "coords" : "city";
                }

                Component.onCompleted: syncFromConfig()
            }
            
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: translate("Location Settings")
            }

            // Searchable Country Field (Typeahead + Dropdown + Best-Match Auto-complete)
            AutoCompleteField {
                id: countryField
                Kirigami.FormData.label: translate("Country")
                visible: root.cfg_locationMode === "city"
                placeholderText: "e.g. Turkey"
                text: root.cfg_country
                candidates: LocationData.getCountries(root.translate)
                textRole: "name"
                valueRole: "id"

                onCommitted: function(newCountry) {
                    root.cfg_country = newCountry;
                    // Update city candidates for the newly selected country
                    var cities = LocationData.getCitiesForCountry(newCountry, root.translate);
                    cityField.candidates = cities;
                    // If current city is empty or not matching, select first city
                    if (cities.length > 0 && (!root.cfg_city || cities.indexOf(root.cfg_city) === -1)) {
                        var firstCity = (typeof cities[0] === 'object') ? cities[0].name : cities[0];
                        if (firstCity && firstCity.indexOf("...") === -1) {
                            root.cfg_city = firstCity;
                        }
                    }
                }
            }

            // Searchable City Field (Typeahead + Dropdown + Best-Match Auto-complete)
            AutoCompleteField {
                id: cityField
                Kirigami.FormData.label: translate("City")
                visible: root.cfg_locationMode === "city"
                placeholderText: "e.g. İstanbul"
                text: root.cfg_city
                candidates: LocationData.getCitiesForCountry(root.cfg_country, root.translate)

                onCommitted: function(newCity) {
                    root.cfg_city = newCity;
                }
            }

            // Coordinates section
            TextField {
                id: latitudeField
                Kirigami.FormData.label: translate("Latitude")
                visible: root.cfg_locationMode === "coords"
                placeholderText: "e.g. 41.0082"
                text: root.cfg_latitude.toString()
                validator: DoubleValidator { bottom: -90.0; top: 90.0; decimals: 6 }
                onTextChanged: {
                    var val = parseFloat(text);
                    if (!isNaN(val) && val >= -90.0 && val <= 90.0) {
                        root.cfg_latitude = val;
                    }
                }
            }

            TextField {
                id: longitudeField
                Kirigami.FormData.label: translate("Longitude")
                visible: root.cfg_locationMode === "coords"
                placeholderText: "e.g. 28.9784"
                text: root.cfg_longitude.toString()
                validator: DoubleValidator { bottom: -180.0; top: 180.0; decimals: 6 }
                onTextChanged: {
                    var val = parseFloat(text);
                    if (!isNaN(val) && val >= -180.0 && val <= 180.0) {
                        root.cfg_longitude = val;
                    }
                }
            }

            // --- LOCATION TEST SECTION ---
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: translate("Location Test")
            }

            Label {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.italic: true
                color: Kirigami.Theme.disabledTextColor
                text: translate("Performs a connection test to the AlAdhan API server using chosen settings")
            }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                Button {
                    text: root.isTesting ? translate("Verifying...") : translate("Verify Location and Refresh")
                    icon.name: root.isTesting ? "" : "view-refresh-symbolic"
                    enabled: !root.isTesting

                    onClicked: {
                        root.isTesting = true;
                        root.testStatus = "";
                        root.testMessage = "";
                        root.testTimings = null;

                        var testSettings = {
                            locationMode: root.cfg_locationMode,
                            city: root.cfg_city,
                            country: root.cfg_country,
                            latitude: root.cfg_latitude,
                            longitude: root.cfg_longitude,
                            calculationMethod: Plasmoid.configuration.calculationMethod,
                            school: Plasmoid.configuration.school
                        };

                        var now = new Date();
                        PrayerTimesProvider.getTimingsForDate(now, testSettings, true, function(err, timings) {
                            root.isTesting = false;
                            if (err) {
                                root.testStatus = "error";
                                root.testMessage = translate("Verification Failed") + " (" + (err.message || translate("Error: Connection Issue")) + ")";
                            } else {
                                root.testStatus = "success";
                                root.testMessage = translate("Verified and Refreshed!");
                                root.testTimings = timings;
                            }
                        });
                    }
                }

                BusyIndicator {
                    running: root.isTesting
                    visible: root.isTesting
                    implicitWidth: Kirigami.Units.gridUnit * 1.2
                    implicitHeight: Kirigami.Units.gridUnit * 1.2
                }
            }

            // Test Result Banner
            Label {
                visible: root.testStatus !== ""
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.bold: true
                color: root.testStatus === "success" ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                text: (root.testStatus === "success" ? "✓ " : "✗ ") + root.testMessage
            }

            // Test Timings Preview Card
            Rectangle {
                visible: root.testStatus === "success" && root.testTimings !== null
                Layout.fillWidth: true
                implicitHeight: previewLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
                color: Kirigami.Theme.alternateBackgroundColor
                radius: Kirigami.Units.smallSpacing
                border.color: Kirigami.Theme.focusColor
                border.width: 1

                ColumnLayout {
                    id: previewLayout
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing * 0.5

                    Label {
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
                        color: Kirigami.Theme.textColor
                        text: root.translate("Today's Prayer Times (Preview)") + " — " + (root.cfg_locationMode === "city" ? (root.cfg_city + ", " + root.cfg_country) : (root.cfg_latitude.toFixed(4) + ", " + root.cfg_longitude.toFixed(4)))
                    }

                    GridLayout {
                        columns: 3
                        rowSpacing: Kirigami.Units.smallSpacing * 0.5
                        columnSpacing: Kirigami.Units.largeSpacing

                        Label { text: root.translate("Imsak") + ":"; font.bold: true; color: Kirigami.Theme.disabledTextColor }
                        Label { text: root.testTimings ? (root.testTimings.Fajr ? root.testTimings.Fajr.split(' ')[0] : "--:--") : "--:--"; color: Kirigami.Theme.textColor }
                        Item { Layout.fillWidth: true }

                        Label { text: root.translate("Sunrise") + ":"; font.bold: true; color: Kirigami.Theme.disabledTextColor }
                        Label { text: root.testTimings ? (root.testTimings.Sunrise ? root.testTimings.Sunrise.split(' ')[0] : "--:--") : "--:--"; color: Kirigami.Theme.textColor }
                        Item { Layout.fillWidth: true }

                        Label { text: root.translate("Dhuhr") + ":"; font.bold: true; color: Kirigami.Theme.disabledTextColor }
                        Label { text: root.testTimings ? (root.testTimings.Dhuhr ? root.testTimings.Dhuhr.split(' ')[0] : "--:--") : "--:--"; color: Kirigami.Theme.textColor }
                        Item { Layout.fillWidth: true }

                        Label { text: root.translate("Asr") + ":"; font.bold: true; color: Kirigami.Theme.disabledTextColor }
                        Label { text: root.testTimings ? (root.testTimings.Asr ? root.testTimings.Asr.split(' ')[0] : "--:--") : "--:--"; color: Kirigami.Theme.textColor }
                        Item { Layout.fillWidth: true }

                        Label { text: root.translate("Maghrib") + ":"; font.bold: true; color: Kirigami.Theme.disabledTextColor }
                        Label { text: root.testTimings ? (root.testTimings.Maghrib ? root.testTimings.Maghrib.split(' ')[0] : "--:--") : "--:--"; color: Kirigami.Theme.textColor }
                        Item { Layout.fillWidth: true }

                        Label { text: root.translate("Isha") + ":"; font.bold: true; color: Kirigami.Theme.disabledTextColor }
                        Label { text: root.testTimings ? (root.testTimings.Isha ? root.testTimings.Isha.split(' ')[0] : "--:--") : "--:--"; color: Kirigami.Theme.textColor }
                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
    }
}
