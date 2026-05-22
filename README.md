# Kare Kod Eğitim Kurumları - Kreş Günlük Rapor ve Ödeme Sistemi

Bu proje, bir kreşteki öğrenci, veli, günlük rapor ve ödeme işlemlerini takip etmek için hazırlanmış bir Flutter mobil uygulamasıdır. Uygulamada öğretmen/yönetici ve veli olmak üzere iki farklı kullanıcı rolü bulunmaktadır.

## Kullanılan Teknolojiler

- Flutter
- Dart
- Supabase
- Supabase Auth
- Supabase Database
- Visual Studio Code
- GitHub

## Projenin Amacı

Uygulamanın amacı, kreşteki öğrencilerin günlük durumlarının ve ödeme bilgilerinin dijital ortamda takip edilmesini sağlamaktır. Öğretmenler öğrenci ekleyebilir, öğrenci bilgilerini düzenleyebilir, günlük rapor girebilir ve ödeme durumlarını takip edebilir. Veliler ise sadece kendi çocuklarına ait bilgileri, günlük raporları ve ödeme kayıtlarını görüntüleyebilir.

## Kullanıcı Rolleri

### Öğretmen / Yönetici

- Tüm öğrencileri görüntüleyebilir.
- Yeni öğrenci ekleyebilir.
- Öğrenci bilgilerini düzenleyebilir.
- Öğrenci silebilir.
- Günlük rapor ekleyebilir.
- Tüm ödeme kayıtlarını takip edebilir.
- Profil bilgilerini görüntüleyebilir.

### Veli

- Sadece kendi çocuğunu görüntüleyebilir.
- Kendi çocuğunun günlük raporunu görebilir.
- Kendi çocuğunun ödeme kayıtlarını görebilir.
- Ödeme yapma işlemini simüle edebilir.
- Profilinde kendi bilgilerini görebilir.

## Özellikler

- Supabase Auth ile kullanıcı kayıt ve giriş sistemi
- Öğretmen kaydı için kurum kodu kontrolü
- Veli kayıt olurken çocuk seçme sistemi
- Veli-çocuk ilişkisinin veritabanında tutulması
- Oturumu açık tutma özelliği
- Şifremi unuttum özelliği
- Öğrenci listeleme
- Öğrenci ekleme, düzenleme ve silme
- Öğrenci bilgi sayfası
- Günlük rapor ekleme ve görüntüleme
- Ödeme takibi
- Gecikmiş, bekleyen ve ödenmiş ödeme ayrımı
- Veli ödeme yapma simülasyonu
- Profil sayfası
- Log kayıt sistemi

## Supabase Tabloları

Projede kullanılan temel tablolar:

- profiles
- children
- child_parents
- daily_reports
- payments
- logs

## Test Hesapları

### Öğretmen Hesabı

E-posta: testogretmen@gmail.com   
Şifre: 123456

### Veli Hesabı

E-posta: testveli@gmail.com  
Şifre: 123456

Öğretmen kayıt kodu: KAREKOD2026

## Ekran Görüntüleri

Uygulamaya ait ekran görüntülerini teslim dosyasına ayrıca ekledim.

## GitHub

Proje GitHub üzerinde düzenli commitlerle geliştirilmiştir.


## Kurulum

```bash
flutter pub get
flutter run