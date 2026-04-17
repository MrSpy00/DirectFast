# Contributing to DirectFast

Thank you for helping improve DirectFast.

---

## TR

DirectFast'e katkı verdiğiniz için teşekkür ederiz. Bu doküman; geliştirme akışını, kalite beklentilerini ve PR kabul kriterlerini açıklar.

### 1) Ön Koşullar

- Flutter SDK (önerilen: stable kanal)
- Dart SDK
- Android toolchain (Android Studio + SDK)
- Git

### 2) Yerel Geliştirme Kurulumu

1. Depoyu fork edin ve klonlayın.
2. Bağımlılıkları yükleyin:

```bash
flutter pub get
```

1. Uygulamayı yerelde çalıştırın:

```bash
flutter run
```

### 3) Branch Stratejisi

- Yeni özellik: `feature/<kisa-aciklama>`
- Hata düzeltme: `fix/<kisa-aciklama>`
- Dokümantasyon: `docs/<kisa-aciklama>`
- Bakım/refactor: `chore/<kisa-aciklama>`

### 4) Kodlama Kuralları

- Dart/Flutter style guide uyumu zorunludur.
- Değişiklikleri küçük, net ve bağımsız commit'ler halinde yapın.
- Kullanıcıya etkisi olan davranış değişikliklerinde README ve gerekiyorsa CHANGELOG güncelleyin.
- Yeni özelliklerde veya hata düzeltmelerinde ilgili birim testi ekleyin.

### 5) Zorunlu Kalite Kontrolleri

PR açmadan önce aşağıdaki komutların tamamı başarılı olmalıdır:

```bash
flutter analyze
flutter test
flutter build apk --release
```

### 6) Pull Request Süreci

1. Branch'inizi güncel `main` ile senkronize edin.
2. PR açarken `.github/pull_request_template.md` şablonunu eksiksiz doldurun.
3. Aşağıdaki bilgileri mutlaka ekleyin:
   - Problem tanımı
   - Çözüm özeti
   - Test kanıtı (çıktı veya ekran görüntüsü)
   - Potansiyel kırıcı değişiklikler
4. CI kontrolleri (analyze/test/build) yeşil olmadan PR merge edilmez.

### 7) Issue Açma Kuralları

- Hata bildirimleri için `Bug Report` şablonunu kullanın.
- Özellik talepleri için `Feature Request` şablonunu kullanın.
- Eksik bilgi içeren issue'lar ek bilgi istenerek beklemeye alınabilir.

### 8) Commit Mesajı Önerisi

Conventional Commit formatı önerilir:

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `refactor: ...`
- `test: ...`
- `chore: ...`

### 9) Güvenlik Bildirimi

Güvenlik açığı bulduysanız herkese açık issue açmak yerine bakımcıya özel olarak bildirin.

---

## EN

Thank you for contributing to DirectFast. This guide defines the development flow, quality expectations, and PR acceptance criteria.

### 1) Prerequisites

- Flutter SDK (recommended: stable channel)
- Dart SDK
- Android toolchain (Android Studio + SDK)
- Git

### 2) Local Development Setup

1. Fork and clone the repository.
2. Install dependencies:

```bash
flutter pub get
```

1. Run the app locally:

```bash
flutter run
```

### 3) Branch Strategy

- New feature: `feature/<short-description>`
- Bug fix: `fix/<short-description>`
- Documentation: `docs/<short-description>`
- Maintenance/refactor: `chore/<short-description>`

### 4) Coding Standards

- Follow Dart/Flutter style guidelines.
- Keep commits small, clear, and independent.
- Update README and, if needed, CHANGELOG for user-facing behavior changes.
- Add related unit tests for new features and bug fixes.

### 5) Required Quality Gates

Before opening a PR, all commands below must pass:

```bash
flutter analyze
flutter test
flutter build apk --release
```

### 6) Pull Request Process

1. Rebase or sync your branch with the latest `main`.
2. Fill out `.github/pull_request_template.md` completely.
3. Include the following in your PR description:
   - Problem statement
   - Solution summary
   - Test evidence (output or screenshot)
   - Potential breaking changes
4. PRs are not merged unless CI checks (analyze/test/build) are green.

### 7) Issue Reporting Rules

- Use `Bug Report` template for bugs.
- Use `Feature Request` template for feature ideas.
- Issues missing critical information may be put on hold until updated.

### 8) Commit Message Recommendation

Conventional Commits are recommended:

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `refactor: ...`
- `test: ...`
- `chore: ...`

### 9) Security Reporting

If you discover a security vulnerability, please report it privately instead of opening a public issue.
