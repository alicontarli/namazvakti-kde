import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.notification as KNotification

import "../code/Constants.js" as Constants
import "../code/Schedule.js" as Schedule
import "../code/Translations.js" as Translations
import "../code/Formatter.js" as Formatter
import "../code/Validation.js" as Validation
import "../code/PrayerTimesProvider.js" as PrayerTimesProvider
import "../code/Cache.js" as Cache

PlasmoidItem {
    id: root
    
    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar ? fullRepresentation : null
    
    // Core properties
    property var todayTimings: null
    property var tomorrowTimings: null
    property var lastSuccessfulUpdate: null
    property bool isOffline: false
    property bool isLoading: false
    property string errorText: ""
    property var activeRequest: null
    
    // Calculated values
    property var nextPrayerResult: null
    property string lastNotificationKey: ""

    // Tooltip configuration
    toolTipMainText: nextPrayerResult ? 
        (Constants.getPrayerLabels(translate)[nextPrayerResult.key] + " · " + Formatter.formatRemainingTime(translate, nextPrayerResult.remainingMinutes, Plasmoid.configuration.showHhMm)) : 
        translate("Offline")

    toolTipSubText: {
        if (!todayTimings || !nextPrayerResult) return translate("Error - Failed to load data");
        var settings = getSettingsObj();
        var adjusted = Schedule.getAdjustedPrayerTimes(todayTimings, settings);
        var targetTimeStr = Formatter.formatTime(adjusted[nextPrayerResult.key], Plasmoid.configuration.use24h);
        var locationName = Plasmoid.configuration.locationMode === 'city' ? 
            Plasmoid.configuration.city + ", " + Plasmoid.configuration.country :
            Plasmoid.configuration.latitude.toFixed(4) + ", " + Plasmoid.configuration.longitude.toFixed(4);
            
        return Formatter.formatTooltip(translate, Constants.getPrayerLabels(translate)[nextPrayerResult.key], nextPrayerResult.remainingMinutes, targetTimeStr, locationName);
    }
    
    // Translation helper
    readonly property string currentLanguage: Plasmoid.configuration.language
    function translate(str) {
        return Translations.translate(str, currentLanguage);
    }

    function getSettingsObj() {
        return {
            locationMode: Plasmoid.configuration.locationMode,
            city: Plasmoid.configuration.city,
            country: Plasmoid.configuration.country,
            latitude: Plasmoid.configuration.latitude,
            longitude: Plasmoid.configuration.longitude,
            calculationMethod: Plasmoid.configuration.calculationMethod,
            school: Plasmoid.configuration.school,
            imsakAdjustment: Plasmoid.configuration.imsakAdjustment,
            gunesAdjustment: Plasmoid.configuration.gunesAdjustment,
            ogleAdjustment: Plasmoid.configuration.ogleAdjustment,
            ikindiAdjustment: Plasmoid.configuration.ikindiAdjustment,
            aksamAdjustment: Plasmoid.configuration.aksamAdjustment,
            yatsiAdjustment: Plasmoid.configuration.yatsiAdjustment
        };
    }

    function updateData(forceRefresh) {
        if (isLoading) return;
        isLoading = true;
        errorText = "";

        if (activeRequest) {
            try { activeRequest.abort(); } catch(e) {}
            activeRequest = null;
        }

        var now = new Date();
        var settings = getSettingsObj();

        var todayXhr = PrayerTimesProvider.getTimingsForDate(now, settings, forceRefresh, function(errToday, timings) {
            root.activeRequest = null;
            if (errToday) {
                console.warn("[NamazVaktiKDE] Today timings fetch failed: " + errToday.message);
                root.isOffline = true;
                root.fallbackToCachedData(function() {
                    root.isLoading = false;
                    root.updateSchedule();
                });
                return;
            }

            root.todayTimings = timings;

            // Fetch tomorrow's timings
            var tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
            var tomorrowXhr = PrayerTimesProvider.getTimingsForDate(tomorrow, settings, forceRefresh, function(errTom, tomTimings) {
                root.activeRequest = null;
                root.isLoading = false;
                if (errTom) {
                    console.warn("[NamazVaktiKDE] Tomorrow timings fetch failed: " + errTom.message);
                } else {
                    root.tomorrowTimings = tomTimings;
                }
                root.isOffline = false;
                root.lastSuccessfulUpdate = new Date();
                root.updateSchedule();
            });
            
            if (tomorrowXhr) {
                root.activeRequest = tomorrowXhr;
            } else {
                root.isLoading = false;
                root.isOffline = false;
                root.lastSuccessfulUpdate = new Date();
                root.updateSchedule();
            }
        });

        if (todayXhr) {
            root.activeRequest = todayXhr;
        }
    }

    function fallbackToCachedData(callback) {
        try {
            var now = new Date();
            var settings = getSettingsObj();
            root.todayTimings = Cache.loadFromCache(now.getFullYear(), now.getMonth() + 1, settings);
            
            var tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
            root.tomorrowTimings = Cache.loadFromCache(tomorrow.getFullYear(), tomorrow.getMonth() + 1, settings);
        } catch (e) {
            console.error("[NamazVaktiKDE] Fallback to cache failed: " + e.message);
        }
        if (callback) callback();
    }

    function updateSchedule() {
        var now = new Date();
        var settings = getSettingsObj();

        if (!todayTimings) {
            root.nextPrayerResult = null;
            return;
        }

        var result = Schedule.getNextPrayer(
            now, 
            todayTimings, 
            tomorrowTimings, 
            settings, 
            Plasmoid.configuration.showImsak, 
            Plasmoid.configuration.showGunes
        );

        root.nextPrayerResult = result;

        if (result) {
            checkNotifications(result.key, result.remainingMinutes);
        }
    }

    function checkNotifications(prayerKey, remaining) {
        if (!Plasmoid.configuration.notifyOnTime) return;

        var beforeMinutes = Plasmoid.configuration.notifyBeforeMinutes;
        var cacheKey = "";

        if (remaining === 0) {
            cacheKey = prayerKey + "_0";
            if (root.lastNotificationKey !== cacheKey) {
                root.sendNotification(prayerKey, 0);
                root.lastNotificationKey = cacheKey;
            }
        } else if (beforeMinutes > 0 && remaining === beforeMinutes) {
            cacheKey = prayerKey + "_" + beforeMinutes;
            if (root.lastNotificationKey !== cacheKey) {
                root.sendNotification(prayerKey, beforeMinutes);
                root.lastNotificationKey = cacheKey;
            }
        }
    }

    function sendNotification(prayerKey, minutes) {
        var labels = Constants.getPrayerLabels(translate);
        var label = labels[prayerKey] || prayerKey;
        var body = "";
        if (minutes === 0) {
            body = Formatter.formatString(translate("%1$s time has entered."), label);
        } else {
            body = Formatter.formatString(translate("%2$d minute(s) remaining for %1$s"), label, minutes);
        }

        prayerNotification.text = body;
        prayerNotification.sendEvent();
    }

    function startTimer() {
        var millisToNextMinute = 60000 - (Date.now() % 60000);
        minuteTimer.interval = millisToNextMinute + 100;
        minuteTimer.start();
    }

    Timer {
        id: minuteTimer
        repeat: false
        onTriggered: {
            root.updateSchedule();
            var now = new Date();
            if (now.getHours() === 0 && now.getMinutes() === 0) {
                root.updateData(false);
            }
            root.startTimer();
        }
    }

    KNotification.Notification {
        id: prayerNotification
        title: "Namaz Vakti KDE"
        iconName: "namaz-vakti"
    }

    Connections {
        target: Plasmoid.configuration
        function onLocationModeChanged() { root.updateData(true); }
        function onCityChanged() { root.updateData(true); }
        function onCountryChanged() { root.updateData(true); }
        function onLatitudeChanged() { root.updateData(true); }
        function onLongitudeChanged() { root.updateData(true); }
        function onCalculationMethodChanged() { root.updateData(true); }
        function onSchoolChanged() { root.updateData(true); }
        
        function onImsakAdjustmentChanged() { root.updateSchedule(); }
        function onGunesAdjustmentChanged() { root.updateSchedule(); }
        function onOgleAdjustmentChanged() { root.updateSchedule(); }
        function onIkindiAdjustmentChanged() { root.updateSchedule(); }
        function onAksamAdjustmentChanged() { root.updateSchedule(); }
        function onYatsiAdjustmentChanged() { root.updateSchedule(); }
        
        function onShowImsakChanged() { root.updateSchedule(); }
        function onShowGunesChanged() { root.updateSchedule(); }
        function onLanguageChanged() { root.updateSchedule(); }
    }

    Component.onCompleted: {
        updateData(false);
        startTimer();
    }

    Component.onDestruction: {
        minuteTimer.stop();
        if (activeRequest) {
            try { activeRequest.abort(); } catch(e) {}
        }
    }

    // Bind views
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
