import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Translations.js" as Translations
import "../code/Constants.js" as Constants

ScrollView {
    id: root

    property string cfg_calculationMethod: Plasmoid.configuration.calculationMethod
    property string cfg_school: Plasmoid.configuration.school
    
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
        calculationMethodCombo.syncFromConfig();
    }

    onCfg_schoolChanged: {
        schoolCombo.syncFromConfig();
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

                function syncFromConfig() {
                    var methods = Constants.getCalculationMethods(translate);
                    for (var i = 0; i < methods.length; i++) {
                        if (methods[i].id === root.cfg_calculationMethod) {
                            if (currentIndex !== i) currentIndex = i;
                            return;
                        }
                    }
                }

                onActivated: function(index) {
                    var methods = Constants.getCalculationMethods(translate);
                    if (methods[index] && methods[index].id) {
                        root.cfg_calculationMethod = methods[index].id;
                    }
                }

                Component.onCompleted: syncFromConfig()
            }

            ComboBox {
                id: schoolCombo
                Kirigami.FormData.label: translate("Asr Calculation School")
                textRole: "name"
                valueRole: "id"
                model: Constants.getJurisprudenceSchools(translate)

                function syncFromConfig() {
                    var schools = Constants.getJurisprudenceSchools(translate);
                    for (var i = 0; i < schools.length; i++) {
                        if (schools[i].id === root.cfg_school) {
                            if (currentIndex !== i) currentIndex = i;
                            return;
                        }
                    }
                }

                onActivated: function(index) {
                    var schools = Constants.getJurisprudenceSchools(translate);
                    if (schools[index] && schools[index].id) {
                        root.cfg_school = schools[index].id;
                    }
                }

                Component.onCompleted: syncFromConfig()
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
