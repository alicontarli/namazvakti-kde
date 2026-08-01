import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../code/Translations.js" as Translations

ScrollView {
    id: root

    property string cfg_language: Plasmoid.configuration.language

    readonly property string currentLanguage: cfg_language || Plasmoid.configuration.language
    function translate(str) {
        return Translations.translate(str, currentLanguage);
    }

    onCfg_languageChanged: {
        languageCombo.syncFromConfig();
    }

    function getLanguagesList() {
        return [
            { id: "auto", name: translate("Automatic / Default") },
            { id: "en", name: "English" },
            { id: "tr", name: "Türkçe" },
            { id: "ar", name: "العربية" },
            { id: "bn", name: "বাংলা" },
            { id: "es", name: "Español" },
            { id: "fr", name: "Français" },
            { id: "de", name: "Deutsch" },
            { id: "ru", name: "Русский" },
            { id: "fa", name: "فارسی" },
            { id: "ur", name: "اردو" },
            { id: "id", name: "Bahasa Indonesia" }
        ];
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
                id: languageCombo
                Kirigami.FormData.label: translate("Language")
                textRole: "name"
                valueRole: "id"
                model: root.getLanguagesList()

                function syncFromConfig() {
                    var targetId = root.cfg_language || "auto";
                    var langs = root.getLanguagesList();
                    for (var i = 0; i < langs.length; i++) {
                        if (langs[i].id === targetId) {
                            if (currentIndex !== i) {
                                currentIndex = i;
                            }
                            return;
                        }
                    }
                }

                onActivated: function(index) {
                    var langs = root.getLanguagesList();
                    if (langs[index] && langs[index].id) {
                        root.cfg_language = langs[index].id;
                    }
                }

                Component.onCompleted: {
                    syncFromConfig();
                }
            }
        }
    }
}
