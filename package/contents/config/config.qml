import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18n("Location")
         icon: "mark-location"
         source: "configLocation.qml"
    }
    ConfigCategory {
         name: i18n("Calculation")
         icon: "accessories-calculator"
         source: "configCalculation.qml"
    }
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "configAppearance.qml"
    }
    ConfigCategory {
         name: i18n("Language")
         icon: "preferences-desktop-locale"
         source: "configLanguage.qml"
    }
}
