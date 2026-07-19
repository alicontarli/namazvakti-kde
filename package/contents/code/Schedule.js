.pragma library
.import "Formatter.js" as Formatter
.import "Constants.js" as Constants

var API_MAP = {
    imsak: 'Fajr',
    gunes: 'Sunrise',
    ogle: 'Dhuhr',
    ikindi: 'Asr',
    aksam: 'Maghrib',
    yatsi: 'Isha'
};

/**
 * Gets adjusted prayer times in minutes from midnight.
 */
function getAdjustedPrayerTimes(timings, adjustments) {
    adjustments = adjustments || {};
    var result = {};
    for (var i = 0; i < Constants.PRAYERS.length; i++) {
        var key = Constants.PRAYERS[i];
        var apiKey = API_MAP[key];
        var timeStr = timings[apiKey];
        var baseMinutes = Formatter.parseTimeToMinutes(timeStr);
        var offset = adjustments[key + "Adjustment"] || 0;
        // Apply adjustment and ensure it wraps around 24 hours (1440 minutes)
        result[key] = (baseMinutes + offset + 1440) % 1440;
    }
    return result;
}

/**
 * Calculates the next prayer and remaining time in minutes.
 */
function getNextPrayer(nowDate, todayTimings, tomorrowTimings, adjustments, showImsak, showGunes) {
    if (showImsak === undefined) showImsak = true;
    if (showGunes === undefined) showGunes = true;
    adjustments = adjustments || {};

    if (!todayTimings) return null;

    var todayAdjusted = getAdjustedPrayerTimes(todayTimings, adjustments);
    var tomorrowAdjusted = tomorrowTimings ? getAdjustedPrayerTimes(tomorrowTimings, adjustments) : null;

    var nowMinutes = nowDate.getHours() * 60 + nowDate.getMinutes();
    
    var candidates = [];

    // Helper to add candidates for a specific base offset (0 for today, 1440 for tomorrow)
    var addCandidates = function(adjustedTimes, baseOffset, isTomorrowVal) {
        for (var i = 0; i < Constants.PRAYERS.length; i++) {
            var key = Constants.PRAYERS[i];
            if (key === 'imsak' && !showImsak) continue;
            if (key === 'gunes' && !showGunes) continue;
            
            candidates.push({
                key: key,
                absoluteMinutes: baseOffset + adjustedTimes[key],
                targetMinutes: adjustedTimes[key],
                isTomorrow: isTomorrowVal
            });
        }
    };

    // Add today's candidates
    addCandidates(todayAdjusted, 0, false);

    // Add tomorrow's candidates
    if (tomorrowAdjusted) {
        addCandidates(tomorrowAdjusted, 1440, true);
    }

    // Sort candidates chronologically
    candidates.sort(function(a, b) { 
        return a.absoluteMinutes - b.absoluteMinutes; 
    });

    // Find the first candidate that is in the future
    for (var j = 0; j < candidates.length; j++) {
        var candidate = candidates[j];
        if (candidate.absoluteMinutes > nowMinutes) {
            return {
                key: candidate.key,
                remainingMinutes: candidate.absoluteMinutes - nowMinutes,
                targetMinutes: candidate.targetMinutes,
                isTomorrow: candidate.isTomorrow
            };
        }
    }

    // Fallback: If no candidate found (e.g. tomorrowTimings wasn't loaded yet),
    // wrap around to the first candidate of today (acting as if it is tomorrow)
    if (candidates.length > 0) {
        var first = candidates[0];
        return {
            key: first.key,
            remainingMinutes: (1440 - nowMinutes) + first.targetMinutes,
            targetMinutes: first.targetMinutes,
            isTomorrow: true
        };
    }

    return null;
}
