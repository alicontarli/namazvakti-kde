# Namaz Vakti KDE — Implementation Notes

Bu belgede Namaz Vakti KDE plasmoidinin mimari kararları, platform entegrasyonu detayları ve GNOME sürümünden port edilirken uygulanan teknik yaklaşımlar özetlenmiştir.

## Sistem ve Ortam Bilgileri

* **Plasma Sürümü:** 6.7.2
* **Qt Sürümü:** 6.11.1 (QML Runtime 6.11.1)
* **Pencere Sistemi:** Wayland
* **Kurulum Aracı:** `kpackagetool6` (Version 2.0)
* **SDK / Test Araçları:** `plasmoidviewer` 6.7.3, `plasmawindowed` 1.0, `/usr/lib/qt6/bin/qmltestrunner`, `/usr/lib/qt6/bin/qmllint`

## Mimari Yaklaşımlar ve Kararlar

### 1. Saf QML/JS Yaklaşımı
Projenin herhangi bir derlenen C++ eklentisi (C++ QML Plugin) veya root yetkileri gerektiren harici bir sistem servisi olmadan saf QML/JS ile çalışması hedeflenmiştir. Bu sayede eklenti tamamen taşınabilir olup doğrudan yerel kullanıcı dizininden çalıştırılabilmektedir.

### 2. Ağ İstekleri ve Timeout Yönetimi
* AlAdhan API endpoint'lerinden aylık takvim verisi asenkron QML `XMLHttpRequest` kullanılarak çekilir.
* Ağ isteklerinde 10 saniyelik zaman aşımı (`xhr.timeout = 10000`) ve `ontimeout` / `onerror` callback'leri tanımlanmıştır.
* `main.qml` üzerinde aktif bir ağ isteği varken yeni bir yenileme tetiklendiğinde veya eklenti kaldırıldığında (`Component.onDestruction`), önceki istek `activeRequest.abort()` ile güvenli bir şekilde iptal edilerek hafıza sızıntısı ve gecikmiş callback'lerin arayüze zarar vermesi engellenir.

### 3. Önbellek Stratejisi (LocalStorage)
* Aylık namaz vakti verilerini saklamak için saf QML tarafında desteklenen en kararlı yerel veri tabanı çözümü olan `QtQuick.LocalStorage` kullanılmıştır.
* Veritabanı işlemleri senkron olduğundan, her dakika veri tabanına erişim engellenmiş; sadece başlangıç, konum/ayar değişikliği, yenileme veya ay geçişlerinde okuma/yazma yapılmıştır.
* Cache verileri, settings fingerprint'leri ile eşleştirilerek saklanır. Ayar fingerprint'i şu parametrelerden üretilir:
  * Konum Modu (city/coords)
  * Şehir ve Ülke (şehir aramalarında)
  * Yuvarlanmış Enlem/Boylam (koordinat aramalarında, ~100m toleransla)
  * Hesap Yöntemi
  * İkindi Mezhebi (school)
* Bu fingerprint sayesinde, ayar değiştiğinde cache geçersiz kılınarak yeni veri çekilir; ancak dakika düzeltmeleri veya görünüm ayarları gibi yerel hesaplamalar cache fingerprint'ini etkilemez ve gereksiz ağ isteği üretilmez.
* Veritabanında biriken 90 günden eski cache verileri her kayıt işleminde otomatik olarak temizlenir.

### 4. Gerçek Zamanlı Dil Değişimi
KDE'nin sistem düzeyindeki Ki18n dil desteği anlık dil değişikliklerini plasmashell'i yeniden başlatmadan uygulayamadığından, GNOME projesindeki kataloğa benzer merkezi bir `Translations.js` modülü entegre edilmiştir. 
QML'in dinamik özellik bağlama (property binding) yapısından yararlanılarak, arayüzdeki tüm metinler `translate(key)` fonksiyonuna bağlanmıştır. `Plasmoid.configuration.language` değiştiğinde tüm aydınlatmalar ve metin alanları anında yeniden hesaplanıp güncellenir.

### 5. Dakika Sınırına Hizalı Zamanlayıcı
Hafif çalışmayı sağlamak ve CPU kaynak tüketimini en aza indirmek için sürekli saniye sayan bir Timer yerine, bir sonraki dakikanın başına kalan milisaniye farkı hesaplanarak tek seferlik (`repeat: false`) QML zamanlayıcısı kurulur. Zamanlayıcı tetiklendiğinde arayüzü günceller ve bir sonraki dakika sınırı için kendisini tekrar planlar.

## Testler ve Doğrulama

### Otomatik Testler
`tests/tst_namazvakti.qml` dosyası altında `qmltestrunner` ile çalıştırılan 24 test senaryosu bulunmaktadır. Testler şunları doğrular:
* İmsak öncesi/sonrası, gün içi vakit geçişleri ve Yatsı sonrası yarının İmsak vakti hesabı.
* Ay sonu, yıl sonu (31 Aralık - 1 Ocak) geçişleri.
* 24 saat ve 12 saat biçimlerine göre duration ve time formatlama.
* Bozuk API yanıtlarının reddi ve zaman dilimi parametrelerinin güvenli ayrıştırılması.
* Manuel düzeltmeler ve gece yarısı taşmaları.
* Fingerprint eşleşmesi ve cache invalidation.
* RTL dil tespiti ve çoklu dilde çeviri fallback'leri.

### Görsel ve Panel Doğrulaması
Aşağıdaki form factor ve senaryolar hem `plasmoidviewer` hem de yerel panel kurulumu üzerinden doğrulanmıştır:
* **Yatay Panel:** Tek satırlık temiz metin tasarımı.
* **Dikey Panel:** Metnin otomatik iki satıra düşerek taşma/kesilme yapmaması.
* **Açık/Koyu Tema:** Kirigami tema renkleri (`textColor`, `highlightColor`, `highlightedTextColor`) sayesinde her iki temada da yüksek okunabilirlik ve uyum.
* **Sağdan Sola (RTL) Diller:** Arapça/Urduca/Farsça gibi dillerde arapça rakamların ve metin hizalamalarının bozulmadan gösterilmesi.
