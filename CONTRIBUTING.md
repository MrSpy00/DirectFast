# Contributing to DirectFast

## TR

DirectFast projesine katkıda bulunmak istediğiniz için teşekkürler.

### Geliştirme Akışı
1. Depoyu fork edin.
2. Yeni bir branch açın:
   - `feature/<kisa-aciklama>`
   - `fix/<kisa-aciklama>`
3. Değişikliklerinizi küçük ve anlamlı commit'ler halinde yapın.
4. Aşağıdaki kontrollerin tamamı yeşil olmalı:
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --release`
5. Pull Request açın ve aşağıdaki bilgileri ekleyin:
   - Problem tanımı
   - Çözüm özeti
   - Test kanıtı (çıktı/screenshot)

### Kod Standartları
- Dart/Flutter style guide uyumu zorunludur.
- Kamuya açık API ve kullanıcıya etkisi olan davranışlarda README güncelleyin.
- Yeni özelliklerde birim testi ekleyin.

### Issue Açma
- Hata bildirimleri için `Bug Report` şablonunu kullanın.
- Özellik önerileri için `Feature Request` şablonunu kullanın.

### Güvenlik Bildirimi
Güvenlik açığı bulursanız lütfen herkese açık issue yerine bakımcıya özel olarak bildirin.

---

## EN

Thank you for contributing to DirectFast.

### Development Flow
1. Fork the repository.
2. Create a new branch:
   - `feature/<short-description>`
   - `fix/<short-description>`
3. Keep commits small and meaningful.
4. Ensure all checks pass:
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --release`
5. Open a Pull Request and include:
   - Problem statement
   - Solution summary
   - Test evidence (output/screenshot)

### Code Standards
- Follow Dart/Flutter style guidelines.
- Update README for behavior changes and public-facing features.
- Add unit tests for new features.

### Issue Reporting
- Use the `Bug Report` template for bugs.
- Use the `Feature Request` template for feature ideas.

### Security Reporting
If you discover a security issue, please report it privately instead of opening a public issue.
