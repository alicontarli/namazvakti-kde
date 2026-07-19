.pragma library

/**
 * Validates coordinate latitude range [-90, 90]
 */
function validateLatitude(lat) {
    var val = parseFloat(lat);
    return !isNaN(val) && val >= -90.0 && val <= 90.0;
}

/**
 * Validates coordinate longitude range [-180, 180]
 */
function validateLongitude(lng) {
    var val = parseFloat(lng);
    return !isNaN(val) && val >= -180.0 && val <= 180.0;
}

/**
 * Validates city name is not empty
 */
function validateCity(city) {
    return typeof city === 'string' && city.trim().length > 0;
}

/**
 * Validates country name is not empty
 */
function validateCountry(country) {
    return typeof country === 'string' && country.trim().length > 0;
}
