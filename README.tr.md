# Namaz Vakti KDE

Namaz Vakti KDE, KDE Plasma 6 masaüstü ortamı için geliştirilmiş yerel bir panel eklentisidir (plasmoid). Panelinizde sıradaki namaz vaktini ve kalan süreyi temiz, hafif ve görsel olarak bütünleşik bir biçimde gösterir.

Bu proje, **Namaz Vakti GNOME** eklentisinin KDE Plasma 6 için yeniden tasarlanıp geliştirilmiş yerel sürümüdür.

## Özellikler

* **Temiz Panel Görünümü:** Panelde ek simgeler olmadan dikey veya yatay yerleşime uygun sade metin tabanlı tasarım.
* **Detaylı Popup (Açılır Menü):** Tıklandığında aktif konum, yerel tarih, 6 vakitlik namaz listesi (aktif vakit vurgulanmış olarak), manuel yenileme ve ayarlar düğmelerini sunan modern arayüz.
* **Gelişmiş Konum Desteği:** İster şehir/ülke araması ister doğrudan coğrafi koordinatlar (Enlem/Boylam) ile kullanım.
* **Esnek Hesap Yöntemleri:** Başta Diyanet İşleri Başkanlığı yöntemi olmak üzere MWL, ISNA, Umm al-Qura gibi hesaplama standartları desteği.
* **Mezhep Ayarı:** Varsayılan olarak Standart (Şafi, Maliki, Hanbeli - Diyanet uyumlu) ve Hanefi mezhebine göre ikindi vakti seçeneği.
* **Manuel Dakika Düzeltmeleri:** Vakitler arasında oluşabilecek küçük sapmaları düzeltmek için her vakte özel -30 ile +30 dakika aralığında ayarlama olanağı.
* **Çevrimdışı Çalışma ve Önbellek:** Veriler AlAdhan API üzerinden aylık olarak indirilir ve SQLite (QtQuick.LocalStorage) üzerinde güvenle saklanır. İnternet kesilse dahi önbellekteki vakitler kullanılmaya devam eder.
* **11 Dil Desteği:** Türkçe, English, العربية, বাংলা, Español, Français, Deutsch, Русский, فارسی, اردو ve Bahasa Indonesia dilleri arasında plasmashell'i yeniden başlatmadan anında geçiş.
* **Zamanlama Toleransı:** Her saniye kaynak tüketmek yerine, bir sonraki dakikaya kalan süreyi milisaniye hassasiyetinde hesaplayarak yalnızca dakikada bir tetiklenen hafif zamanlayıcı.
* **Masaüstü Bildirimleri:** Vakit girdiğinde veya vakitten belirli bir süre önce masaüstü bildirimi gönderme seçeneği.

## Kurulum ve Güncelleme

### Yerel Kurulum (Kullanıcı Düzeyinde)

Eklentiyi yerel kullanıcı dizininize kurmak için:

```bash
./scripts/install-local.sh
```

Bu betik otomatik olarak gerekli doğrulamaları yapacak ve `kpackagetool6` aracılığıyla eklentiyi `~/.local/share/plasma/plasmoids/com.local.namazvakti/` dizinine kuracaktır.

### Güncelleme

Betik, eklentinin zaten kurulu olduğunu algılarsa otomatik olarak güncelleyecektir. Aynı kur komutunu tekrar çalıştırmanız yeterlidir:

```bash
./scripts/install-local.sh
```

### Kaldırma

Eklentiyi sisteminizden kaldırmak için:

```bash
./scripts/uninstall-local.sh
```

## Yapılandırma ve Ayarlar

Eklenti kurulduktan sonra KDE panelinize ekleyebilir ve üzerine sağ tıklayıp **"Namaz Vakti KDE Yapılandırması..."** seçeneğine tıklayarak ayarlara erişebilirsiniz. Ayarlar 4 ana sekmeden oluşur:

1. **Konum:** Konum modu (Şehir/Ülke veya Coğrafi Koordinatlar) seçilir ve girişler yapılır.
2. **Hesaplama:** Hesaplama yöntemi, ikindi mezhebi ve namaz vakitlerine özel dakika bazında düzeltmeler (+/- 30 dakika) yapılandırılır.
3. **Görünüm:** Panel gösterim modları ("Vakit adı + kalan süre" veya "Sadece kalan süre"), 24 saat biçimi, araç ipucu (tooltip) gösterimi ve vakit bildirim ayarları belirlenir.
4. **Dil:** Arayüz dili plasmashell yeniden başlatılmadan anında değiştirilebilir.

## Geliştirme ve Testler

### Testleri Çalıştırma

Çekirdek zamanlama, zaman dilimi ayrıştırma, dakika düzeltmeleri ve çeviri modüllerini test etmek için Qt 6'nın QML test aracını kullanıyoruz:

```bash
./scripts/test.sh
```

### Paketleme

Betik yardımıyla linting, test ve arşivleme süreçlerini çalıştırıp dağıtıma hazır `.plasmoid` ve `.zip` dosyalarını `dist/` klasörüne çıkarabilirsiniz:

```bash
./scripts/package.sh
```

Üretilen paketler:
* `dist/namaz-vakti-kde-1.0.0.plasmoid`
* `dist/namaz-vakti-kde-1.0.0.zip`

## Sorun Giderme

Eklentiyle ilgili günlükleri ve olası hataları izlemek için KDE günlük sistemini filtreleyebilirsiniz:

```bash
journalctl --user -f
# veya
journalctl --user -b | grep -i NamazVaktiKDE
```

## Lisans

Bu proje GPL lisansı altında korunmaktadır.
