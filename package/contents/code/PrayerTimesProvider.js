.pragma library
.import "Cache.js" as Cache

/**
 * Direct API fetch helper for monthly calendar.
 * Returns the XMLHttpRequest instance so that the caller can abort it if needed.
 */
function fetchCalendar(year, month, settings, callback) {
    var url;
    var method = settings.calculationMethod || '13';
    var school = settings.school || '0';
    
    if (settings.locationMode === 'coords') {
        var lat = settings.latitude;
        var lng = settings.longitude;
        url = "https://api.aladhan.com/v1/calendar/" + year + "/" + month + "?latitude=" + lat + "&longitude=" + lng + "&method=" + method + "&school=" + school;
    } else {
        var city = encodeURIComponent(settings.city || 'İstanbul');
        var country = encodeURIComponent(settings.country || 'Turkey');
        url = "https://api.aladhan.com/v1/calendarByCity/" + year + "/" + month + "?city=" + city + "&country=" + country + "&method=" + method + "&school=" + school;
    }

    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.timeout = 10000; // 10 seconds timeout
    
    var aborted = false;
    
    xhr.onreadystatechange = function() {
        if (aborted) return;
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response && response.code === 200 && response.data) {
                        callback(null, response.data);
                    } else {
                        callback(new Error("Invalid API response structure"), null);
                    }
                } catch (e) {
                    callback(e, null);
                }
            } else {
                callback(new Error("API responded with status code " + xhr.status), null);
            }
        }
    };
    
    xhr.ontimeout = function() {
        if (aborted) return;
        aborted = true;
        callback(new Error("Request timed out"), null);
    };
    
    xhr.onerror = function() {
        if (aborted) return;
        callback(new Error("Network error"), null);
    };

    xhr.send();
    
    return xhr;
}

/**
 * Returns prayer times for a given date, prioritizing cache, otherwise fetching from API.
 */
function getTimingsForDate(date, settings, forceRefresh, callback) {
    var year = date.getFullYear();
    var month = date.getMonth() + 1; // 1-indexed
    var day = date.getDate();
    
    var monthData = null;
    if (!forceRefresh) {
        monthData = Cache.loadFromCache(year, month, settings);
    }
    
    if (monthData) {
        extractDayTimings(monthData, day, year, month, callback);
        return null; // Indicates that cache was hit and no request was started
    }
    
    // Cache miss or force refresh
    console.log("[NamazVaktiKDE] Cache miss/refresh for " + year + "-" + month + ". Fetching from AlAdhan API...");
    
    var xhr = fetchCalendar(year, month, settings, function(err, data) {
        if (err) {
            callback(err, null);
            return;
        }
        
        Cache.saveToCache(year, month, settings, data);
        extractDayTimings(data, day, year, month, callback);
    });
    
    return xhr;
}

/**
 * Extracts specific day timings from monthly data array.
 */
function extractDayTimings(monthData, day, year, month, callback) {
    if (monthData && monthData.length >= day) {
        var dayEntry = monthData[day - 1];
        if (dayEntry && parseInt(dayEntry.date.gregorian.day, 10) === day) {
            callback(null, dayEntry.timings);
            return;
        }
        // Fallback search if calendar array indices don't match for some reason
        for (var i = 0; i < monthData.length; i++) {
            var d = monthData[i];
            if (parseInt(d.date.gregorian.day, 10) === day) {
                callback(null, d.timings);
                return;
            }
        }
    }
    callback(new Error("Timings for day " + day + " not found in month data for " + year + "-" + month), null);
}
