.pragma library

var PRAYERS = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'];

function getPrayerLabels(t) {
    return {
        imsak: t('Imsak'),
        gunes: t('Sunrise'),
        ogle: t('Dhuhr'),
        ikindi: t('Asr'),
        aksam: t('Maghrib'),
        yatsi: t('Isha')
    };
}

function getCalculationMethods(t) {
    return [
        { id: '13', name: t('Diyanet İşleri Başkanlığı (Turkey)') },
        { id: '3', name: t('Muslim World League') },
        { id: '2', name: t('ISNA') },
        { id: '5', name: t('Egyptian General Authority of Survey') },
        { id: '4', name: t('Umm al-Qura, Makkah') },
        { id: '99', name: t('Automatic / Default') }
    ];
}

function getJurisprudenceSchools(t) {
    return [
        { id: '0', name: t('Standard (Shafi, Maliki, Hanbali - Recommended for Diyanet)') },
        { id: '1', name: t('Hanafi (Later Asr time)') }
    ];
}

function getViewModes(t) {
    return [
        { id: 'name-time', name: t('Prayer name + Remaining time') },
        { id: 'time-only', name: t('Only remaining time') }
    ];
}
