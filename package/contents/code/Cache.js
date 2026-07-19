.pragma library
.import QtQuick.LocalStorage as Sql

var _db = null;

/**
 * Initializes and returns the local SQLite database.
 */
function getDb() {
    if (!_db) {
        try {
            _db = Sql.LocalStorage.openDatabaseSync("NamazVaktiKDE", "1.0", "Namaz Vakti KDE Cache", 1000000);
            _db.transaction(function(tx) {
                tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS cache (" +
                    "  year INTEGER, " +
                    "  month INTEGER, " +
                    "  fingerprint TEXT, " +
                    "  location_desc TEXT, " +
                    "  data TEXT, " +
                    "  timestamp INTEGER, " +
                    "  PRIMARY KEY (year, month, fingerprint)" +
                    ")"
                );
            });
        } catch (e) {
            console.error("[NamazVaktiKDE] LocalStorage failed to open/initialize: " + e.toString());
            throw e;
        }
    }
    return _db;
}

/**
 * Serializes the settings that impact calculation/fetching into a fingerprint string.
 */
function getSettingsFingerprint(settings) {
    if (settings.locationMode === 'coords') {
        var lat = parseFloat(settings.latitude || 0).toFixed(3);
        var lng = parseFloat(settings.longitude || 0).toFixed(3);
        return "coords_" + lat + "_" + lng + "_" + settings.calculationMethod + "_" + settings.school;
    } else {
        var city = (settings.city || '').trim().toLowerCase();
        var country = (settings.country || '').trim().toLowerCase();
        return "city_" + city + "_" + country + "_" + settings.calculationMethod + "_" + settings.school;
    }
}

/**
 * Saves monthly calendar data to cache.
 */
function saveToCache(year, month, settings, data) {
    try {
        var db = getDb();
        var fingerprint = getSettingsFingerprint(settings);
        var locationDesc = settings.locationMode === 'coords' ? 
            parseFloat(settings.latitude || 0).toFixed(4) + ", " + parseFloat(settings.longitude || 0).toFixed(4) :
            settings.city + ", " + settings.country;
        
        var dataStr = JSON.stringify(data);
        var timestamp = Date.now();
        
        db.transaction(function(tx) {
            tx.executeSql(
                "INSERT OR REPLACE INTO cache (year, month, fingerprint, location_desc, data, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
                [year, month, fingerprint, locationDesc, dataStr, timestamp]
            );
        });
        
        cleanupCache(db);
    } catch (e) {
        console.warn("[NamazVaktiKDE] Save to cache failed: " + e.toString());
    }
}

/**
 * Loads cached monthly data if it matches the settings fingerprint.
 */
function loadFromCache(year, month, settings) {
    try {
        var db = getDb();
        var fingerprint = getSettingsFingerprint(settings);
        var res = null;
        
        db.transaction(function(tx) {
            var rs = tx.executeSql(
                "SELECT data FROM cache WHERE year = ? AND month = ? AND fingerprint = ?",
                [year, month, fingerprint]
            );
            if (rs.rows.length > 0) {
                res = JSON.parse(rs.rows.item(0).data);
            }
        });
        return res;
    } catch (e) {
        console.warn("[NamazVaktiKDE] Load from cache failed: " + e.toString());
        return null;
    }
}

/**
 * Deletes cache database entries older than 90 days.
 */
function cleanupCache(db) {
    try {
        var cutoff = Date.now() - (90 * 24 * 60 * 60 * 1000);
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM cache WHERE timestamp < ?", [cutoff]);
        });
    } catch (e) {
        console.warn("[NamazVaktiKDE] Cache cleanup failed: " + e.toString());
    }
}

/**
 * Clears all entries in the cache table.
 */
function clearAllCache() {
    try {
        var db = getDb();
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM cache");
        });
    } catch (e) {
        console.warn("[NamazVaktiKDE] Clear cache failed: " + e.toString());
    }
}
