import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Translations.js" as Translations

ScrollView {
    id: root
    
    property string cfg_locationMode: Plasmoid.configuration.locationMode
    property alias cfg_city: cityField.text
    property alias cfg_country: countryField.text
    property real cfg_latitude: Plasmoid.configuration.latitude
    property real cfg_longitude: Plasmoid.configuration.longitude

    readonly property string currentLanguage: Plasmoid.configuration.language
    function translate(str) {
        return Translations.translate(str, currentLanguage);
    }

    onCfg_latitudeChanged: {
        var val = parseFloat(latitudeField.text);
        if (isNaN(val) || val !== cfg_latitude) {
            latitudeField.text = cfg_latitude.toString();
        }
    }
    
    onCfg_longitudeChanged: {
        var val = parseFloat(longitudeField.text);
        if (isNaN(val) || val !== cfg_longitude) {
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
            }

            // City section
            TextField {
                id: cityField
                Kirigami.FormData.label: translate("City")
                visible: root.cfg_locationMode === "city"
                placeholderText: "e.g. İstanbul"
            }

            TextField {
                id: countryField
                Kirigami.FormData.label: translate("Country")
                visible: root.cfg_locationMode === "city"
                placeholderText: "e.g. Turkey"
            }

            // Coordinates section
            TextField {
                id: latitudeField
                Kirigami.FormData.label: translate("Latitude")
                visible: root.cfg_locationMode === "coords"
                placeholderText: "e.g. 41.0082"
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
                validator: DoubleValidator { bottom: -180.0; top: 180.0; decimals: 6 }
                onTextChanged: {
                    var val = parseFloat(text);
                    if (!isNaN(val) && val >= -180.0 && val <= 180.0) {
                        root.cfg_longitude = val;
                    }
                }
            }
        }
    }
}
