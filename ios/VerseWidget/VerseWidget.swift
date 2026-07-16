//
//  VerseWidget.swift
//

import WidgetKit
import SwiftUI
import AppIntents

let appGroupId = "group.io.supabase.mustardseed"
let goldAccent = Color(red: 0.788, green: 0.635, blue: 0.153)
let creamText = Color(red: 0.961, green: 0.933, blue: 0.894)

struct VerseEntry: TimelineEntry {
    let date: Date
    let verseId: String
    let verseText: String
    let verseReference: String
    let hijriDate: String
    let moonPhase: String
    let moonIllumination: Double
    let moonIsWaxing: Bool
    let moonPhaseName: String
    let moonDay: Int   // YENİ
    let configuration: VerseWidgetConfigurationIntent
}

func moonEmoji(for phase: String) -> String {
    switch phase {
    case "Hilal": return "🌙"
    case "İlk Dördün": return "🌛"
    case "Dolunay": return "🌕"
    case "Son Dördün": return "🌜"
    default: return "🌙"
    }
}

/// Ayın o günkü aydınlanma diskini matematiksel olarak çizen shape.
/// Hiçbir statik görsele ihtiyaç duymaz — Flutter tarafındaki
/// MoonPhaseCalculator'dan gelen illumination/isWaxing değerlerine göre
/// her gün gerçekten farklı, pürüzsüz bir ay diski üretir.
struct MoonPhaseShape: Shape {
    var illumination: Double // 0.0 (yeni ay) ... 1.0 (dolunay)
    var isWaxing: Bool       // true: ay büyüyor, false: ay küçülüyor

    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // k: -1 (yeni ay, tamamen karanlık) ... +1 (dolunay, tamamen aydınlık)
        let k = CGFloat(2 * illumination - 1)
        let litOnRight = isWaxing

        // Bezier ile elips yayı çizmek için standart "kappa" sabiti.
        let kappa: CGFloat = 0.5522847498

        var path = Path()
        let top = CGPoint(x: center.x, y: center.y - r)
        let bottom = CGPoint(x: center.x, y: center.y + r)

        path.move(to: top)

        // 1) Dış yarım daire — aydınlık tarafın sabit dış kenarı.
        path.addArc(
            center: center,
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: !litOnRight
        )

        // 2) İç terminatör eğrisi — x-yarıçapı k'ya göre şişer/çöker.
        let ellipseRx = r * k * (litOnRight ? -1 : 1)
        let c1 = CGPoint(x: center.x + ellipseRx, y: bottom.y - r * kappa)
        let c2 = CGPoint(x: center.x + ellipseRx, y: top.y + r * kappa)

        path.addCurve(to: top, control1: c1, control2: c2)
        path.closeSubpath()

        return path
    }
}

/// Ay diskini (karanlık zemin + aydınlık kısım) hazır bir View olarak sunar.
/// Widget'ın herhangi bir yerinde `MoonPhaseView(illumination:isWaxing:size:)`
/// ile kullanılabilir.
struct MoonPhaseView: View {
    let illumination: Double
    let isWaxing: Bool
    let size: CGFloat
    var litColor: Color = Color(red: 0.961, green: 0.933, blue: 0.847)
    var darkColor: Color = Color(red: 0.15, green: 0.13, blue: 0.10)

    var body: some View {
        ZStack {
            Circle()
                .fill(darkColor)
            MoonPhaseShape(illumination: illumination, isWaxing: isWaxing)
                .fill(litColor)
        }
        .frame(width: size, height: size)
    }
}

/// Kullanıcının AppDelegate.swift üzerinden App Group container'ına
/// yazdığı fotoğrafı okur (varsa).
func loadUserPhoto() -> UIImage? {
    guard let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupId
    ) else { return nil }
    let fileURL = containerURL.appendingPathComponent("widget_user_photo.jpg")
    guard let data = try? Data(contentsOf: fileURL) else { return nil }
    return UIImage(data: data)
}
/// AstronomyAPI'den indirilip App Group container'ına kaydedilen,
/// o günün GERÇEK ay fotoğrafını okur (bkz. WidgetService.syncMoonPhoto).
func loadMoonPhoto() -> UIImage? {
    guard let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupId
    ) else { return nil }
    let fileURL = containerURL.appendingPathComponent("widget_moon_photo.jpg")
    guard let data = try? Data(contentsOf: fileURL) else { return nil }
    return UIImage(data: data)
}
/// Kullanıcı fotoğraf seçmediyse, güne göre döngüsel olarak hazır
/// görsellerden birini seçer — Android tarafındaki mantıkla birebir aynı.
/// Flutter tarafındaki MoonPhaseName enum değerini (örn. "waxingCrescent"),
/// Assets.xcassets'teki NASA fotoğrafının adına çevirir.
func moonPhaseImageName(for phaseName: String) -> String {
    switch phaseName {
    case "newMoon": return "MoonNew"
    case "waxingCrescent": return "MoonWaxingCrescent"
    case "firstQuarter": return "MoonFirstQuarter"
    case "waxingGibbous": return "MoonWaxingGibbous"
    case "full": return "MoonFull"
    case "waningGibbous": return "MoonWaningGibbous"
    case "thirdQuarter": return "MoonThirdQuarter"
    case "waningCrescent": return "MoonWaningCrescent"
    default: return "MoonFull"
    }
}

/// Ay döngüsünün 0-29. gününe karşılık gelen, o günün GERÇEK NASA
/// fotoğrafının Assets.xcassets'teki adını döner.
func moonDayImageName(for day: Int) -> String {
    let clamped = max(0, min(29, day))
    return "MoonDay\(clamped)"
}

struct VerseProvider: AppIntentTimelineProvider {
   func placeholder(in context: Context) -> VerseEntry {
    VerseEntry(
        date: Date(),
        verseId: "",
        verseText: "Bir ayet gününüzü değiştirebilir.",
        verseReference: "İnşirah Suresi, 6. Ayet",
        hijriDate: "19 Zilhicce 1446",
        moonPhase: "Hilal",
        moonIllumination: 0.3,
        moonIsWaxing: true,
        moonPhaseName: "waxingCrescent",
        moonDay: 3,   // YENİ
        configuration: VerseWidgetConfigurationIntent()
    )
}
    func snapshot(for configuration: VerseWidgetConfigurationIntent, in context: Context) async -> VerseEntry {
        loadEntry(configuration: configuration)
    }

    func timeline(for configuration: VerseWidgetConfigurationIntent, in context: Context) async -> Timeline<VerseEntry> {
        let entry = loadEntry(configuration: configuration)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func loadEntry(configuration: VerseWidgetConfigurationIntent) -> VerseEntry {
    let defaults = UserDefaults(suiteName: appGroupId)
    let illuminationString = defaults?.string(forKey: "moon_illumination") ?? "0.5"
    let isWaxingString = defaults?.string(forKey: "moon_is_waxing") ?? "true"
    let phaseNameString = defaults?.string(forKey: "moon_phase_name") ?? "full"
    let moonDayString = defaults?.string(forKey: "moon_day") ?? "15"

    return VerseEntry(
        date: Date(),
        verseId: defaults?.string(forKey: "verse_id") ?? "",
        verseText: defaults?.string(forKey: "verse_text")
            ?? "Bir ayet gününüzü değiştirebilir.",
        verseReference: defaults?.string(forKey: "verse_reference") ?? "",
        hijriDate: defaults?.string(forKey: "hijri_date") ?? "",
        moonPhase: defaults?.string(forKey: "moon_phase") ?? "Hilal",
        moonIllumination: Double(illuminationString) ?? 0.5,
        moonIsWaxing: isWaxingString == "true",
        moonPhaseName: phaseNameString,
        moonDay: Int(moonDayString) ?? 15,   // YENİ
        configuration: configuration
    )
}
}

struct VerseWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: VerseEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            lockScreenLayout
        default:
            switch entry.configuration.style {
            case .minimal:
                minimalLayout
            case .moonPhase:
                moonPhaseLayout
            case .photo:
                photoLayout
            }
        }
    }

    private var lockScreenLayout: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .center, spacing: 4) {
                Circle().frame(width: 3, height: 3).widgetAccentable()
                Text(entry.hijriDate).font(.system(size: 8, weight: .medium))
                Spacer()
                Text(moonEmoji(for: entry.moonPhase)).font(.system(size: 10))
            }
            Text("\"\(entry.verseText)\"")
                .font(.system(size: 13, weight: .medium, design: .serif))
                .italic()
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .lineSpacing(1)
            HStack(spacing: 4) {
                Circle().frame(width: 3, height: 3).widgetAccentable()
                Text(entry.verseReference.uppercased())
                    .font(.system(size: 8, weight: .semibold))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 2)
    }

    private var minimalLayout: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\"\(entry.verseText)\"")
                .font(.system(size: 17, design: .serif))
                .italic()
                .foregroundColor(creamText)
                .lineSpacing(4)
                .lineLimit(4)
            Text(entry.verseReference.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundColor(goldAccent)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.09, green: 0.07, blue: 0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(goldAccent.opacity(0.12), lineWidth: 1)
        )
    }

   private var moonPhaseLayout: some View {
    VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Circle().fill(goldAccent).frame(width: 5, height: 5)
                    Text("GÜNÜN AYETİ")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(creamText.opacity(0.7))
                }
                Text(entry.hijriDate)
                    .font(.system(size: 8, weight: .light))
                    .foregroundColor(creamText.opacity(0.5))
            }

            Spacer()

            // Gerçek NASA ay fotoğrafı, daire şeklinde kırpılmış —
            // kare/siyah kenar tamamen kayboluyor, sadece yuvarlak ay
            // ikonu kartın arka planının üstünde "yüzüyor" gibi duruyor.
            VStack(spacing: 3) {
                Image(moonPhaseImageName(for: entry.moonPhaseName))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: family == .systemSmall ? 34 : 46,
                           height: family == .systemSmall ? 34 : 46)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(goldAccent.opacity(0.3), lineWidth: 1)
                    )
                Text(entry.moonPhase.uppercased())
                    .font(.system(size: 7, weight: .semibold))
                    .tracking(1)
                    .foregroundColor(creamText.opacity(0.6))
            }
        }

        Text("\"\(entry.verseText)\"")
            .font(.system(size: family == .systemSmall ? 13 : 16, design: .serif))
            .italic()
            .foregroundColor(creamText)
            .lineSpacing(3)
            .lineLimit(family == .systemSmall ? 4 : 3)
            .minimumScaleFactor(0.75)
            .padding(.top, 14)

        Rectangle().fill(goldAccent.opacity(0.12)).frame(height: 1)
            .padding(.top, 14).padding(.bottom, 10)

        HStack(spacing: 6) {
            Circle().fill(goldAccent).frame(width: 5, height: 5)
                .shadow(color: goldAccent.opacity(0.6), radius: 4)
            Text(entry.verseReference.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundColor(goldAccent)
                .lineLimit(1)
        }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.09, green: 0.07, blue: 0.05),
                Color(red: 0.122, green: 0.106, blue: 0.075),
                Color(red: 0.07, green: 0.06, blue: 0.04)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    )
    .overlay(
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(goldAccent.opacity(0.15), lineWidth: 1)
    )
}

    private var photoLayout: some View {
    GeometryReader { geo in
        Group {
            if let uiImage = loadUserPhoto() {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()

                    LinearGradient(
                        colors: [Color.black.opacity(0.85), Color.black.opacity(0.0)],
                        startPoint: .bottom, endPoint: .top
                    )
                    .frame(width: geo.size.width, height: geo.size.height)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("\"\(entry.verseText)\"")
                            .font(.system(size: family == .systemSmall ? 12 : 14, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                            .lineLimit(family == .systemSmall ? 4 : 3)
                            .minimumScaleFactor(0.7)
                            .shadow(color: .black.opacity(0.6), radius: 3)
                        HStack(spacing: 5) {
                            Circle().fill(goldAccent).frame(width: 4, height: 4)
                            Text(entry.verseReference.uppercased())
                                .font(.system(size: 8, weight: .semibold))
                                .tracking(1.2)
                                .foregroundColor(goldAccent)
                                .lineLimit(1)
                        }
                    }
                    .padding(14)
                }
            } else if family == .systemSmall {
                smallMoonLayout(geo: geo)
            } else {
                mediumMoonLayout(geo: geo)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

/// Küçük (systemSmall) widget için: ay üstte küçük bir madalyon,
/// metin altında tam genişlikte — VStack tabanlı, kare orana uygun.
/// Küçük (systemSmall) widget için: ay üstte, büyük ve ortalı; altında
/// ortalanmış etiket, ayet metni ve referans — tamamen dikey/merkezi
/// düzen, kare orana uygun.
private func smallMoonLayout(geo: GeometryProxy) -> some View {
    let moonImageName = moonDayImageName(for: entry.moonDay)
    let moonSize = geo.size.width * 0.42

    return ZStack {
        Image(moonImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geo.size.width, height: geo.size.height)
            .blur(radius: 16)
            .overlay(Color.black.opacity(0.65))
            .clipped()

        VStack(spacing: 8) {
            Image(moonImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: moonSize, height: moonSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(goldAccent.opacity(0.4), lineWidth: 1.5))
                .shadow(color: Color.black.opacity(0.4), radius: 6)

            HStack(spacing: 4) {
                Circle().fill(goldAccent).frame(width: 4, height: 4)
                Text("GÜNÜN AYETİ")
                    .font(.system(size: 8, weight: .semibold))
                    .tracking(1.5)
                    .foregroundColor(creamText.opacity(0.7))
            }

            Text("\"\(entry.verseText)\"")
                .font(.system(size: 11, design: .serif))
                .italic()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .shadow(color: .black.opacity(0.5), radius: 3)

            HStack(spacing: 4) {
                Circle().fill(goldAccent).frame(width: 3, height: 3)
                Text(entry.verseReference.uppercased())
                    .font(.system(size: 7, weight: .semibold))
                    .tracking(0.8)
                    .foregroundColor(goldAccent)
                    .lineLimit(1)
            }
            
        }
        .padding(14)
    }
}

/// Geniş (systemMedium) widget için: metin solda, büyük ay sağda —
/// HStack tabanlı, yatay dikdörtgen orana uygun.
private func mediumMoonLayout(geo: GeometryProxy) -> some View {
    let moonImageName = moonDayImageName(for: entry.moonDay)
    let moonCircleSize = geo.size.height * 0.85

    return ZStack {
        Image(moonImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geo.size.width, height: geo.size.height)
            .blur(radius: 18)
            .overlay(Color.black.opacity(0.55))
            .clipped()

        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Circle().fill(goldAccent).frame(width: 5, height: 5)
                    Text("GÜNÜN AYETİ")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(creamText.opacity(0.7))
                }
                Text("\"\(entry.verseText)\"")
                    .font(.system(size: 15, design: .serif))
                    .italic()
                    .foregroundColor(.white)
                    .lineLimit(4)
                    .minimumScaleFactor(0.65)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                HStack(spacing: 5) {
                    Circle().fill(goldAccent).frame(width: 4, height: 4)
                    Text(entry.verseReference.uppercased())
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(goldAccent)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(moonImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: moonCircleSize, height: moonCircleSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(goldAccent.opacity(0.4), lineWidth: 1.5))
                .shadow(color: Color.black.opacity(0.4), radius: 8)
        }
        .padding(16)
    }
}
}

struct VerseWidget: Widget {
    let kind: String = "VerseWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: VerseWidgetConfigurationIntent.self,
            provider: VerseProvider()
        ) { entry in
            VerseWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.09, green: 0.07, blue: 0.05)
                }
                .widgetURL(
                    URL(string: "io.supabase.mustardseed://verse-detail?id=\(entry.verseId)")
                )
        }
        .configurationDisplayName("Hardal Tanesi")
        .description("Günün ayetini kilit ekranında ya da ana ekranında gör.")
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
        // iOS 17+ widget'lara otomatik uygulanan iç kenar boşluğunu kapatır.
        // Bu olmadan görsellerimiz/gradyanımız widget'ın kenarına tam
        // oturamıyor, her tarafta boşluk kalıyordu (Android'de bu sorun
        // yoktu çünkü Android'in böyle bir otomatik margin sistemi yok).
        .contentMarginsDisabled()
    }
}