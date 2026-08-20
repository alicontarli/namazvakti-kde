.pragma library

var COUNTRIES = [
    {
        id: "Turkey",
        name: "Turkey (Türkiye)",
        cities: [
            "Adana", "Adıyaman", "Afyonkarahisar", "Ağrı", "Aksaray", "Amasya", "Ankara", "Antalya", "Ardahan", "Artvin",
            "Aydın", "Balıkesir", "Bartın", "Batman", "Bayburt", "Bilecik", "Bingöl", "Bitlis", "Bolu", "Burdur",
            "Bursa", "Çanakkale", "Çankırı", "Çorum", "Denizli", "Diyarbakır", "Düzce", "Edirne", "Elazığ", "Erzincan",
            "Erzurum", "Eskişehir", "Gaziantep", "Giresun", "Gümüşhane", "Hakkari", "Hatay", "Iğdır", "Isparta", "İstanbul",
            "İzmir", "Kahramanmaraş", "Karabük", "Karaman", "Kars", "Kastamonu", "Kayseri", "Kilis", "Kırıkkale", "Kırklareli",
            "Kırşehir", "Kocaeli", "Konya", "Kütahya", "Malatya", "Manisa", "Mardin", "Mersin", "Muğla", "Muş",
            "Nevşehir", "Niğde", "Ordu", "Osmaniye", "Rize", "Sakarya", "Samsun", "Şanlıurfa", "Siirt", "Sinop",
            "Şırnak", "Sivas", "Tekirdağ", "Tokat", "Trabzon", "Tunceli", "Uşak", "Van", "Yalova", "Yozgat", "Zonguldak"
        ]
    },
    {
        id: "Germany",
        name: "Germany (Deutschland)",
        cities: [
            "Berlin", "Bochum", "Bonn", "Bremen", "Dortmund", "Dresden", "Duisburg", "Düsseldorf", "Essen", "Frankfurt",
            "Hamburg", "Hannover", "Köln", "Leipzig", "Mannheim", "München", "Nürnberg", "Stuttgart", "Wuppertal"
        ]
    },
    {
        id: "United Kingdom",
        name: "United Kingdom",
        cities: [
            "Birmingham", "Bradford", "Bristol", "Cardiff", "Edinburgh", "Glasgow", "Leeds", "Leicester", "Liverpool", "London",
            "Manchester", "Newcastle", "Sheffield"
        ]
    },
    {
        id: "United States",
        name: "United States",
        cities: [
            "Austin", "Boston", "Chicago", "Columbus", "Dallas", "Denver", "Detroit", "Houston", "Indianapolis", "Jacksonville",
            "Los Angeles", "Miami", "New York", "Philadelphia", "Phoenix", "San Antonio", "San Diego", "San Francisco", "San Jose", "Seattle", "Washington"
        ]
    },
    {
        id: "France",
        name: "France",
        cities: [
            "Bordeaux", "Lille", "Lyon", "Marseille", "Montpellier", "Nantes", "Nice", "Paris", "Rennes", "Strasbourg", "Toulouse"
        ]
    },
    {
        id: "Netherlands",
        name: "Netherlands (Nederland)",
        cities: [
            "Almere", "Amsterdam", "Breda", "Eindhoven", "Groningen", "Nijmegen", "Rotterdam", "The Hague", "Tilburg", "Utrecht"
        ]
    },
    {
        id: "Saudi Arabia",
        name: "Saudi Arabia (المملكة العربية السعودية)",
        cities: [
            "Abha", "Al Khobar", "Buraydah", "Dammam", "Jeddah", "Jubail", "Khamis Mushait", "Mecca", "Medina", "Najran", "Riyadh", "Tabuk", "Taif", "Yanbu"
        ]
    },
    {
        id: "Azerbaijan",
        name: "Azerbaijan (Azərbaycan)",
        cities: [
            "Baku", "Ganja", "Lankaran", "Mingachevir", "Nakhchivan", "Quba", "Shaki", "Shirvan", "Sumqayit", "Yevlakh"
        ]
    },
    {
        id: "Egypt",
        name: "Egypt (مصر)",
        cities: [
            "Alexandria", "Aswan", "Asyut", "Cairo", "Damietta", "Fayoum", "Giza", "Ismailia", "Luxor", "Mansoura", "Port Said", "Suez", "Tanta", "Zagazig"
        ]
    },
    {
        id: "Indonesia",
        name: "Indonesia",
        cities: [
            "Bandung", "Bekasi", "Bogor", "Depok", "Jakarta", "Makassar", "Medan", "Palembang", "Semarang", "Surabaya", "Tangerang", "Yogyakarta"
        ]
    },
    {
        id: "Pakistan",
        name: "Pakistan (پاکستان)",
        cities: [
            "Faisalabad", "Gujranwala", "Hyderabad", "Islamabad", "Karachi", "Lahore", "Multan", "Peshawar", "Quetta", "Rawalpindi", "Sialkot"
        ]
    },
    {
        id: "United Arab Emirates",
        name: "United Arab Emirates (الإمارات)",
        cities: [
            "Abu Dhabi", "Ajman", "Al Ain", "Dubai", "Fujairah", "Ras Al Khaimah", "Sharjah", "Umm Al Quwain"
        ]
    },
    {
        id: "Canada",
        name: "Canada",
        cities: [
            "Calgary", "Edmonton", "Hamilton", "Montreal", "Ottawa", "Quebec City", "Toronto", "Vancouver", "Winnipeg"
        ]
    },
    {
        id: "Australia",
        name: "Australia",
        cities: [
            "Adelaide", "Brisbane", "Canberra", "Gold Coast", "Hobart", "Melbourne", "Perth", "Sydney"
        ]
    },
    {
        id: "Belgium",
        name: "Belgium (Belgique / België)",
        cities: [
            "Antwerp", "Bruges", "Brussels", "Charleroi", "Ghent", "Leuven", "Liege", "Namur"
        ]
    },
    {
        id: "Austria",
        name: "Austria (Österreich)",
        cities: [
            "Graz", "Innsbruck", "Klagenfurt", "Linz", "Salzburg", "Vienna", "Villach"
        ]
    },
    {
        id: "Switzerland",
        name: "Switzerland (Schweiz / Suisse)",
        cities: [
            "Basel", "Bern", "Geneva", "Lausanne", "Lugano", "Lucerne", "St. Gallen", "Zurich"
        ]
    },
    {
        id: "Sweden",
        name: "Sweden (Sverige)",
        cities: [
            "Gothenburg", "Helsingborg", "Linköping", "Malmö", "Örebro", "Stockholm", "Uppsala", "Västerås"
        ]
    },
    {
        id: "Norway",
        name: "Norway (Norge)",
        cities: [
            "Bergen", "Drammen", "Fredrikstad", "Kristiansand", "Oslo", "Sandnes", "Stavanger", "Tromsø", "Trondheim"
        ]
    },
    {
        id: "Denmark",
        name: "Denmark (Danmark)",
        cities: [
            "Aalborg", "Aarhus", "Copenhagen", "Esbjerg", "Horsens", "Kolding", "Odense", "Randers", "Vejle"
        ]
    },
    {
        id: "Uzbekistan",
        name: "Uzbekistan (Oʻzbekiston)",
        cities: [
            "Andijan", "Bukhara", "Fergana", "Namangan", "Nukus", "Samarkand", "Tashkent"
        ]
    },
    {
        id: "Kazakhstan",
        name: "Kazakhstan (Қазақстан)",
        cities: [
            "Aktobe", "Almaty", "Astana", "Atyrau", "Karaganda", "Kostanay", "Pavlodar", "Shymkent"
        ]
    },
    {
        id: "Northern Cyprus",
        name: "Northern Cyprus (KKTC)",
        cities: [
            "Gazimağusa (Famagusta)", "Girne (Kyrenia)", "Güzelyurt (Morphou)", "İskele (Trikomo)", "Lefke (Lefka)", "Lefkoşa (Nicosia)"
        ]
    }
];

function getCountries(t) {
    var list = [];
    for (var i = 0; i < COUNTRIES.length; i++) {
        list.push({
            id: COUNTRIES[i].id,
            name: COUNTRIES[i].name
        });
    }
    list.push({
        id: "custom",
        name: t ? t("Other / Custom Entry...") : "Other / Custom Entry..."
    });
    return list;
}

function getCitiesForCountry(countryId, t) {
    for (var i = 0; i < COUNTRIES.length; i++) {
        if (COUNTRIES[i].id === countryId) {
            var cities = COUNTRIES[i].cities.slice();
            cities.push(t ? t("Other / Custom...") : "Other / Custom...");
            return cities;
        }
    }
    return [t ? t("Other / Custom...") : "Other / Custom..."];
}

function findCountryIndex(countryName) {
    if (!countryName) return 0;
    var norm = countryName.trim().toLowerCase();
    for (var i = 0; i < COUNTRIES.length; i++) {
        if (COUNTRIES[i].id.toLowerCase() === norm || COUNTRIES[i].name.toLowerCase().indexOf(norm) !== -1) {
            return i;
        }
    }
    if (norm === "türkiye" || norm === "turkiye" || norm === "tr") return 0;
    return -1;
}

function findCityIndex(countryId, cityName) {
    if (!cityName) return 0;
    var norm = cityName.trim().toLowerCase();
    for (var i = 0; i < COUNTRIES.length; i++) {
        if (COUNTRIES[i].id === countryId) {
            for (var j = 0; j < COUNTRIES[i].cities.length; j++) {
                if (COUNTRIES[i].cities[j].toLowerCase() === norm) {
                    return j;
                }
            }
            break;
        }
    }
    return -1;
}
