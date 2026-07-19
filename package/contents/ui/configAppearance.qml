import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Translations.js" as Translations
import "../code/Constants.js" as Constants

ScrollView {
    id: root

    property string cfg_viewMode: viewModeCombo.currentValue || "name-time"
    property alias cfg_showImsak: showImsakCheck.checked
    property alias cfg_showGunes: showGunesCheck.checked
    property alias cfg_use24h: use24hCheck.checked
    property alias cfg_showTooltip: showTooltipCheck.checked
    property alias cfg_showHhMm: showHhMmCheck.checked
    property alias cfg_notifyOnTime: notifyOnTimeCheck.checked
    property alias cfg_notifyBeforeMinutes: notifyBeforeMinutesSpin.value

    readonly property string currentLanguage: Plasmoid.configuration.language
    function translate(str) {
        return Translations.translate(str, currentLanguage);
    }

    onCfg_viewModeChanged: {
        var modes = Constants.getViewModes(translate);
        for (var i = 0; i < modes.length; i++) {
            if (modes[i].id === cfg_viewMode) {
                viewModeCombo.currentIndex = i;
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

            ComboBox {
                id: viewModeCombo
                Kirigami.FormData.label: translate("Panel Display Mode")
                textRole: "name"
                valueRole: "id"
                model: Constants.getViewModes(translate)
                onCurrentValueChanged: {
                    root.cfg_viewMode = currentValue;
                }
                Component.onCompleted: {
                    var modes = Constants.getViewModes(translate);
                    for (var i = 0; i < modes.length; i++) {
                        if (modes[i].id === Plasmoid.configuration.viewMode) {
                            currentIndex = i;
                            break;
                        }
                    }
                }
            }

            CheckBox {
                id: showImsakCheck
                Kirigami.FormData.label: translate("Show Imsak Time in Panel")
            }

            CheckBox {
                id: showGunesCheck
                Kirigami.FormData.label: translate("Show Sunrise Time in Panel")
            }

            CheckBox {
                id: use24hCheck
                Kirigami.FormData.label: translate("Use 24-Hour Format")
            }

            CheckBox {
                id: showTooltipCheck
                Kirigami.FormData.label: translate("Show Tooltip (When hovering over panel)")
            }

            CheckBox {
                id: showHhMmCheck
                Kirigami.FormData.label: translate("Show Remaining Time in HH:MM Format")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: translate("Notification Settings")
            }

            CheckBox {
                id: notifyOnTimeCheck
                Kirigami.FormData.label: translate("Send Notification at Prayer Time")
            }

            SpinBox {
                id: notifyBeforeMinutesSpin
                Kirigami.FormData.label: translate("Warn N Minutes Before Prayer Time (0 = Disabled)")
                from: 0
                to: 15
                enabled: notifyOnTimeCheck.checked
            }
        }
    }
}
