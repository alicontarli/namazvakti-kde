import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Translations.js" as Translations
import "../code/Constants.js" as Constants

ScrollView {
    id: root

    property string cfg_calculationMethod: calculationMethodCombo.currentValue || "13"
    property string cfg_school: schoolCombo.currentValue || "0"
    
    property alias cfg_imsakAdjustment: imsakAdj.value
    property alias cfg_gunesAdjustment: gunesAdj.value
    property alias cfg_ogleAdjustment: ogleAdj.value
    property alias cfg_ikindiAdjustment: ikindiAdj.value
    property alias cfg_aksamAdjustment: aksamAdj.value
    property alias cfg_yatsiAdjustment: yatsiAdj.value

    readonly property string currentLanguage: Plasmoid.configuration.language
    function translate(str) {
        return Translations.translate(str, currentLanguage);
    }

    onCfg_calculationMethodChanged: {
        var methods = Constants.getCalculationMethods(translate);
        for (var i = 0; i < methods.length; i++) {
            if (methods[i].id === cfg_calculationMethod) {
                calculationMethodCombo.currentIndex = i;
                break;
            }
        }
    }

    onCfg_schoolChanged: {
        var schools = Constants.getJurisprudenceSchools(translate);
        for (var i = 0; i < schools.length; i++) {
            if (schools[i].id === cfg_school) {
                schoolCombo.currentIndex = i;
                break;
            }
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

            Label {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.italic: true
                text: translate("Prayer times are calculated based on the selected method. If there are discrepancies with your local mosque timetable, you can make minute-by-minute adjustments.")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            ComboBox {
                id: calculationMethodCombo
                Kirigami.FormData.label: translate("Calculation Method")
                textRole: "name"
                valueRole: "id"
                model: Constants.getCalculationMethods(translate)
                onCurrentValueChanged: {
                    root.cfg_calculationMethod = currentValue;
                }
                Component.onCompleted: {
                    var methods = Constants.getCalculationMethods(translate);
                    for (var i = 0; i < methods.length; i++) {
                        if (methods[i].id === Plasmoid.configuration.calculationMethod) {
                            currentIndex = i;
                            break;
                        }
                    }
                }
            }

            ComboBox {
                id: schoolCombo
                Kirigami.FormData.label: translate("Asr Calculation School")
                textRole: "name"
                valueRole: "id"
                model: Constants.getJurisprudenceSchools(translate)
                onCurrentValueChanged: {
                    root.cfg_school = currentValue;
                }
                Component.onCompleted: {
                    var schools = Constants.getJurisprudenceSchools(translate);
                    for (var i = 0; i < schools.length; i++) {
                        if (schools[i].id === Plasmoid.configuration.school) {
                            currentIndex = i;
                            break;
                        }
                    }
                }
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: translate("Minute Adjustments")
            }

            SpinBox {
                id: imsakAdj
                Kirigami.FormData.label: translate("Imsak")
                from: -30
                to: 30
            }

            SpinBox {
                id: gunesAdj
                Kirigami.FormData.label: translate("Sunrise")
                from: -30
                to: 30
            }

            SpinBox {
                id: ogleAdj
                Kirigami.FormData.label: translate("Dhuhr")
                from: -30
                to: 30
            }

            SpinBox {
                id: ikindiAdj
                Kirigami.FormData.label: translate("Asr")
                from: -30
                to: 30
            }

            SpinBox {
                id: aksamAdj
                Kirigami.FormData.label: translate("Maghrib")
                from: -30
                to: 30
            }

            SpinBox {
                id: yatsiAdj
                Kirigami.FormData.label: translate("Isha")
                from: -30
                to: 30
            }
        }
    }
}
