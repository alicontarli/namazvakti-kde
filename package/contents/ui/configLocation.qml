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

    onCfg_countryChanged: {
        syncDropdownsFromConfig();
    }

    onCfg_cityChanged: {
        syncDropdownsFromConfig();
    }

    function syncDropdownsFromConfig() {
        var cIdx = LocationData.findCountryIndex(root.cfg_country);
        if (cIdx !== -1) {
            if (countryCombo.currentIndex !== cIdx) {
                countryCombo.currentIndex = cIdx;
            }
            var countryId = LocationData.getCountries(translate)[cIdx].id;
            var cityList = LocationData.getCitiesForCountry(countryId, translate);
            cityCombo.model = cityList;
            
            var cityIdx = LocationData.findCityIndex(countryId, root.cfg_city);
            if (cityIdx !== -1) {
                if (cityCombo.currentIndex !== cityIdx) {
                    cityCombo.currentIndex = cityIdx;
                }
            } else {
                // Custom city in this country
                cityCombo.currentIndex = cityList.length - 1; // "Other / Custom..."
                customCityField.text = root.cfg_city;
            }
        } else {
            // Custom country
            var countries = LocationData.getCountries(translate);
            countryCombo.currentIndex = countries.length - 1; // "Other / Custom Entry..."
            cityCombo.model = [translate("Other / Custom...")];
            cityCombo.currentIndex = 0;
            customCountryField.text = root.cfg_country;
            customCityField.text = root.cfg_city;
        }
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

            // Country Dropdown
            ComboBox {
                id: countryCombo
                Kirigami.FormData.label: translate("Country")
                visible: root.cfg_locationMode === "city"
                textRole: "name"
                valueRole: "id"
                model: LocationData.getCountries(root.translate)

                onActivated: function(index) {
                    var countries = LocationData.getCountries(root.translate);
                    var selected = countries[index];
                    if (selected.id === "custom") {
                        root.cfg_country = customCountryField.text || "";
                        cityCombo.model = [root.translate("Other / Custom...")];
                        cityCombo.currentIndex = 0;
                        root.cfg_city = customCityField.text || "";
                    } else {
                        root.cfg_country = selected.id;
                        var cities = LocationData.getCitiesForCountry(selected.id, root.translate);
                        cityCombo.model = cities;
                        cityCombo.currentIndex = 0;
                        if (cities.length > 1) {
                            root.cfg_city = cities[0];
                        }
                    }
                }
            }

            // City Dropdown
            ComboBox {
                id: cityCombo
                Kirigami.FormData.label: translate("City")
                visible: root.cfg_locationMode === "city"
                model: LocationData.getCitiesForCountry("Turkey", root.translate)

                onActivated: function(index) {
                    var isCustom = (index === model.length - 1);
                    if (isCustom) {
                        root.cfg_city = customCityField.text || "";
                    } else {
                        root.cfg_city = model[index];
                    }
                }

                Component.onCompleted: {
                    root.syncDropdownsFromConfig();
                }
            }

            // Custom Country TextField (Visible if custom country selected)
            TextField {
                id: customCountryField
                Kirigami.FormData.label: translate("Custom Country")
                visible: root.cfg_locationMode === "city" && countryCombo.currentIndex === (countryCombo.count - 1)
                placeholderText: "e.g. Turkey"
                text: root.cfg_country
                onTextChanged: {
                    if (visible) {
                        root.cfg_country = text;
                    }
                }
            }

            // Custom City TextField (Visible if custom city or custom country selected)
            TextField {
                id: customCityField
                Kirigami.FormData.label: translate("Custom City")
                visible: root.cfg_locationMode === "city" && (cityCombo.currentIndex === (cityCombo.count - 1) || countryCombo.currentIndex === (countryCombo.count - 1))
                placeholderText: "e.g. İstanbul"
                text: root.cfg_city
                onTextChanged: {
                    if (visible) {
                        root.cfg_city = text;
                    }
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
