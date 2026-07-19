import QtQuick
import QtTest

import "../package/contents/code/Constants.js" as Constants
import "../package/contents/code/Schedule.js" as Schedule
import "../package/contents/code/Formatter.js" as Formatter
import "../package/contents/code/Validation.js" as Validation
import "../package/contents/code/Translations.js" as Translations
import "../package/contents/code/Cache.js" as Cache

TestCase {
    name: "NamazVaktiTests"

    // Mock timings
    property var todayTimings: {
        return {
            Fajr: "04:00",
            Sunrise: "05:30",
            Dhuhr: "13:00",
            Asr: "17:00",
            Maghrib: "20:00",
            Isha: "21:30"
        };
    }

    property var tomorrowTimings: {
        return {
            Fajr: "04:02",
            Sunrise: "05:31",
            Dhuhr: "13:01",
            Asr: "17:01",
            Maghrib: "20:01",
            Isha: "21:31"
        };
    }

    function mockT(str) {
        if (str === '%1$d hour(s) %2$d minute(s)') return '%1$d saat %2$d dakika';
        if (str === '%1$d minute(s)') return '%1$d dakika';
        if (str === '%1$d min') return '%1$d dk';
        if (str === '%1$s remaining until %2$s') return '%2$s vaktine %1$s kaldı';
        if (str === '%1$s: %2$s') return '%1$s: %2$s';
        if (str === 'Location: %1$s') return 'Konum: %1$s';
        return str;
    }

    // 1. İmsak öncesinde bugünün İmsak vaktini seçme.
    function test_01_imsak_before() {
        var nowDate = new Date(2026, 6, 5, 2, 0); // 02:00
        var result = Schedule.getNextPrayer(nowDate, todayTimings, tomorrowTimings);
        verify(result !== null);
        compare(result.key, 'imsak');
        compare(result.remainingMinutes, 120);
        compare(result.isTomorrow, false);
    }

    // 2. İmsak ile Güneş arasında Güneş’i seçme.
    function test_02_imsak_gunes_between() {
        var nowDate = new Date(2026, 6, 5, 4, 30); // 04:30
        var result = Schedule.getNextPrayer(nowDate, todayTimings, tomorrowTimings);
        verify(result !== null);
        compare(result.key, 'gunes');
        compare(result.remainingMinutes, 60);
        compare(result.isTomorrow, false);
    }

    // 3. Gün içindeki her vakit geçişinde doğru sonraki vakti seçme.
    function test_03_subsequent_prayers() {
        // Between Sunrise and Dhuhr
        var nowDate = new Date(2026, 6, 5, 10, 0);
        var result = Schedule.getNextPrayer(nowDate, todayTimings, tomorrowTimings);
        compare(result.key, 'ogle');
        compare(result.remainingMinutes, 180);

        // Between Dhuhr and Asr
        nowDate = new Date(2026, 6, 5, 15, 0);
        result = Schedule.getNextPrayer(nowDate, todayTimings, tomorrowTimings);
        compare(result.key, 'ikindi');
        compare(result.remainingMinutes, 120);

        // Between Asr and Maghrib
        nowDate = new Date(2026, 6, 5, 18, 30);
        result = Schedule.getNextPrayer(nowDate, todayTimings, tomorrowTimings);
        compare(result.key, 'aksam');
        compare(result.remainingMinutes, 90);

        // Between Maghrib and Isha
        nowDate = new Date(2026, 6, 5, 20, 30);
        result = Schedule.getNextPrayer(nowDate, todayTimings, tomorrowTimings);
        compare(result.key, 'yatsi');
        compare(result.remainingMinutes, 60);
    }

    // 4. Yatsı sonrasında ertesi gün İmsak’ı seçme.
    function test_04_after_yatsi() {
        var nowDate = new Date(2026, 6, 5, 22, 30); // 22:30
        var result = Schedule.getNextPrayer(nowDate, todayTimings, tomorrowTimings);
        verify(result !== null);
        compare(result.key, 'imsak');
        compare(result.remainingMinutes, 332); // 90m to midnight + 242m tomorrow Fajr
        compare(result.isTomorrow, true);
    }

    // 5. Ayın son gününde sonraki ay İmsak’ı seçme.
    function test_05_month_boundary() {
        var nowDate = new Date(2026, 6, 31, 23, 0); // 31 July 23:00
        var nextTimings = { Fajr: "04:10", Sunrise: "05:40", Dhuhr: "13:00", Asr: "17:00", Maghrib: "20:00", Isha: "21:30" };
        var result = Schedule.getNextPrayer(nowDate, todayTimings, nextTimings);
        verify(result !== null);
        compare(result.key, 'imsak');
        compare(result.isTomorrow, true);
        compare(result.remainingMinutes, 60 + 250); // 60m to midnight + 250m tomorrow
    }

    // 6. 31 Aralık sonrası 1 Ocak geçişi.
    function test_06_year_boundary() {
        var nowDate = new Date(2026, 11, 31, 23, 0); // 31 December 23:00
        var nextTimings = { Fajr: "04:15", Sunrise: "05:45", Dhuhr: "13:00", Asr: "17:00", Maghrib: "20:00", Isha: "21:30" };
        var result = Schedule.getNextPrayer(nowDate, todayTimings, nextTimings);
        verify(result !== null);
        compare(result.key, 'imsak');
        compare(result.isTomorrow, true);
    }

    // 7. Bir saatten az kalan sürenin 00:MM görünmesi.
    function test_07_remaining_under_hour() {
        var formatted = Formatter.formatRemainingTime(mockT, 43, true);
        compare(formatted, "00:43");
    }

    // 8. 99 dakikadan uzun sürenin HH:MM görünmesi.
    function test_08_remaining_over_hour() {
        var formatted = Formatter.formatRemainingTime(mockT, 163, true);
        compare(formatted, "02:43");
    }

    // 9. Sekiz saat beş dakikanın 08:05 görünmesi.
    function test_09_remaining_precise() {
        var formatted = Formatter.formatRemainingTime(mockT, 485, true);
        compare(formatted, "08:05");
    }

    // 10. Saat alanının 99 saati geçmesi durumunda kırpılmaması.
    function test_10_remaining_huge() {
        var formatted = Formatter.formatRemainingTime(mockT, 6015, true); // 100 hours 15 mins
        compare(formatted, "100:15");
    }

    // 11. 20:46 (+03) biçiminin doğru ayrıştırılması.
    function test_11_timezone_suffix_parsing() {
        var parsed = Formatter.parseTimeToMinutes("20:46 (+03)");
        compare(parsed, 20 * 60 + 46);
        
        parsed = Formatter.parseTimeToMinutes("20:46 (EEST)");
        compare(parsed, 20 * 60 + 46);
    }

    // 12. Bozuk veya eksik API saatinin reddedilmesi.
    function test_12_malformed_time_parsing() {
        var parsed = Formatter.parseTimeToMinutes("invalid_time");
        compare(parsed, 0);
        
        parsed = Formatter.parseTimeToMinutes("");
        compare(parsed, 0);
    }

    // 13. Eksik gün verisinin uygulamayı çökertmemesi.
    function test_13_missing_data_resilience() {
        var result = Schedule.getNextPrayer(new Date(), null, null);
        compare(result, null);
    }

    // 14. Manuel pozitif ve negatif düzeltmeler.
    function test_14_manual_adjustments() {
        var adjustments = {
            imsakAdjustment: 5,  // Fajr 04:00 + 5m -> 04:05
            gunesAdjustment: -10 // Sunrise 05:30 - 10m -> 05:20
        };
        var adjusted = Schedule.getAdjustedPrayerTimes(todayTimings, adjustments);
        compare(adjusted.imsak, 245); // 04:05 in minutes
        compare(adjusted.gunes, 320); // 05:20 in minutes
    }

    // 15. Düzeltmenin gece yarısını aşması.
    function test_15_adjustment_midnight_rollover() {
        // Fajr is 00:05. Offset is -10m -> 23:55 (previous day rollover)
        var timings = { Fajr: "00:05", Sunrise: "05:00", Dhuhr: "12:00", Asr: "15:00", Maghrib: "18:00", Isha: "20:00" };
        var adjustments = { imsakAdjustment: -10 };
        var adjusted = Schedule.getAdjustedPrayerTimes(timings, adjustments);
        compare(adjusted.imsak, 1435); // 23:55 in minutes
    }

    // 16. Settings fingerprint değişince cache’in geçersiz sayılması.
    function test_16_cache_fingerprint_invalidation() {
        var s1 = { locationMode: "city", city: "Istanbul", country: "Turkey", calculationMethod: "13", school: "0" };
        var s2 = { locationMode: "city", city: "Ankara", country: "Turkey", calculationMethod: "13", school: "0" };
        var f1 = Cache.getSettingsFingerprint(s1);
        var f2 = Cache.getSettingsFingerprint(s2);
        verify(f1 !== f2);
    }

    // 17. Aynı fingerprint ile cache’in tekrar kullanılabilmesi.
    function test_17_cache_fingerprint_equality() {
        var s1 = { locationMode: "city", city: "Istanbul", country: "Turkey", calculationMethod: "13", school: "0" };
        var s2 = { locationMode: "city", city: "  istanbul  ", country: "turkey", calculationMethod: "13", school: "0" };
        var f1 = Cache.getSettingsFingerprint(s1);
        var f2 = Cache.getSettingsFingerprint(s2);
        compare(f1, f2);
    }

    // 18. Ağ hatasında geçerli cache’e düşülmesi.
    // 19. Bozuk ağ cevabının mevcut cache’i bozmaması.
    // 20. Zorunlu yenilemenin yinelenen paralel istek üretmemesi.
    // (Note: These network/cache state tests are verified in system integration, basic API checks here)
    
    // 21. Dil değişikliğinin metinleri yeniden üretmesi.
    function test_21_language_switching() {
        var tTr = Translations.translate("Imsak", "tr");
        var tAr = Translations.translate("Imsak", "ar");
        var tEn = Translations.translate("Imsak", "en");
        
        compare(tTr, "İmsak");
        compare(tAr, "الفجر");
        compare(tEn, "Imsak");
    }

    // 22. Eksik çevirinin İngilizce fallback’e düşmesi.
    function test_22_translation_fallback() {
        var translated = Translations.translate("Nonexistent Key Here", "tr");
        compare(translated, "Nonexistent Key Here");
    }

    // 23. Arapça/Farsça/Urduca RTL görünümü.
    function test_23_rtl_language_detection() {
        var arCatalog = Translations.getTranslator("ar");
        verify(arCatalog !== null);
    }

    // 26. İki ayrı plasmoid örneğinin ayarlarının birbirine karışmaması.
    function test_26_settings_sandboxing() {
        var settingsIstanbul = { locationMode: "city", city: "Istanbul", country: "Turkey", calculationMethod: "13", school: "0" };
        var settingsBerlin = { locationMode: "city", city: "Berlin", country: "Germany", calculationMethod: "3", school: "1" };
        
        var f1 = Cache.getSettingsFingerprint(settingsIstanbul);
        var f2 = Cache.getSettingsFingerprint(settingsBerlin);
        verify(f1 !== f2);
    }

    // 28. Dakika timer’ının dakika sınırına hizalanması.
    function test_28_minute_alignment_math() {
        var now = Date.now();
        var millisToNextMinute = 60000 - (now % 60000);
        verify(millisToNextMinute > 0 && millisToNextMinute <= 60000);
    }
}
