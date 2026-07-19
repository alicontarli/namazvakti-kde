.pragma library

/**
 * Positional string formatter. Replaces %1$s, %2$s, etc. with arguments.
 * Also supports simple %s replacing chronologically.
 */
function formatString(template) {
    if (!template) return '';
    var args = Array.prototype.slice.call(arguments, 1);
    var usedArgs = args.slice();
    
    // Replace %1$s, %2$d, etc.
    var result = template.replace(/%(\d+)\$[sd]/g, function(match, index) {
        var idx = parseInt(index, 10) - 1;
        return usedArgs[idx] !== undefined ? usedArgs[idx] : match;
    });

    // Replace basic %s or %d
    result = result.replace(/%[sd]/g, function() {
        return usedArgs.shift();
    });

    return result;
}

/**
 * Parses a HH:MM time string into total minutes from midnight.
 */
function parseTimeToMinutes(timeStr) {
    if (!timeStr) return 0;
    // Safe parse: strip any trailing brackets or timezone offsets, e.g. "20:46 (+03)" or "20:46 (EEST)"
    var cleanStr = timeStr.split(' ')[0];
    var parts = cleanStr.split(':');
    if (parts.length < 2) return 0;
    var h = parseInt(parts[0], 10);
    var m = parseInt(parts[1], 10);
    if (isNaN(h) || isNaN(m)) return 0;
    return h * 60 + m;
}

/**
 * Formats total minutes from midnight back to HH:MM (24h or 12h)
 */
function formatTime(totalMinutes, use24h) {
    if (use24h === undefined) use24h = true;
    var h = Math.floor(totalMinutes / 60) % 24;
    var m = totalMinutes % 60;
    var mStr = m.toString().padStart(2, '0');
    
    if (use24h) {
        return h.toString().padStart(2, '0') + ":" + mStr;
    } else {
        var ampm = h >= 12 ? 'PM' : 'AM';
        var h12 = h % 12;
        if (h12 === 0) h12 = 12;
        return h12.toString().padStart(2, '0') + ":" + mStr + " " + ampm;
    }
}

/**
 * Formats remaining minutes into localized duration description.
 */
function formatDurationText(t, totalMinutes) {
    var h = Math.floor(totalMinutes / 60);
    var m = totalMinutes % 60;
    
    if (h > 0) {
        return formatString(t('%1$d hour(s) %2$d minute(s)'), h, m);
    }
    return formatString(t('%1$d minute(s)'), m);
}

/**
 * Formats the top-panel timer display.
 */
function formatRemainingTime(t, remainingMinutes, showHhMm) {
    if (showHhMm === undefined) showHhMm = true;
    if (remainingMinutes < 0) remainingMinutes = 0;
    
    if (showHhMm) {
        var h = Math.floor(remainingMinutes / 60);
        var m = remainingMinutes % 60;
        return h.toString().padStart(2, '0') + ":" + m.toString().padStart(2, '0');
    } else {
        return formatString(t('%1$d min'), remainingMinutes);
    }
}

/**
 * Formats the tooltip text.
 */
function formatTooltip(t, nextPrayerLabel, remainingMinutes, targetTimeStr, locationStr) {
    var durationText = formatDurationText(t, remainingMinutes);
    
    var line1 = formatString(t('%1$s remaining until %2$s'), durationText, nextPrayerLabel);
    var line2 = formatString(t('%1$s: %2$s'), nextPrayerLabel, targetTimeStr);
    var line3 = formatString(t('Location: %1$s'), locationStr);
    
    return line1 + "\n" + line2 + "\n" + line3;
}
