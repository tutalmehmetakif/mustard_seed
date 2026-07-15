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
func defaultBackgroundImageName() -> String {
    let images = [
        "WidgetDefaultBG1", "WidgetDefaultBG2", "WidgetDefaultBG3",
        "WidgetDefaultBG4", "WidgetDefaultBG5",
    ]
    let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    return images[dayOfYear % images.count]
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
                HStack(spacing: 5) {
                    Circle().fill(goldAccent).frame(width: 5, height: 5)
                    Text("GÜNÜN AYETİ")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(creamText.opacity(0.7))
                }
                Spacer()
                HStack(spacing: 5) {
                    Text(moonEmoji(for: entry.moonPhase)).font(.system(size: 15))
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(entry.moonPhase.uppercased())
                            .font(.system(size: 8, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(creamText.opacity(0.85))
                        Text(entry.hijriDate)
                            .font(.system(size: 7, weight: .light))
                            .foregroundColor(creamText.opacity(0.5))
                    }
                }
            }
            Text("\"\(entry.verseText)\"")
                .font(.system(size: 16, design: .serif))
                .italic()
                .foregroundColor(creamText)
                .lineSpacing(3)
                .lineLimit(3)
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
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.07, blue: 0.05),
                        Color(red: 0.122, green: 0.106, blue: 0.075),
                        Color(red: 0.07, green: 0.06, blue: 0.04)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                GeometryReader { geo in
                    Circle().fill(goldAccent.opacity(0.18))
                        .frame(width: 90, height: 90).blur(radius: 30)
                        .position(x: geo.size.width - 10, y: 0)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(goldAccent.opacity(0.15), lineWidth: 1)
        )
    }

    private var photoLayout: some View {
    GeometryReader { geo in
        ZStack(alignment: .bottomLeading) {
Group {
    if let uiImage = loadUserPhoto() {
        ZStack {
            Color.green
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
            Text("USER PHOTO").foregroundColor(.white).font(.caption)
        }
    } else if let moonImage = loadMoonPhoto() {
        ZStack {
            Color.blue
            Image(uiImage: moonImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
            Text("MOON PHOTO").foregroundColor(.white).font(.caption)
        }
    } else {
        ZStack {
            Color.red
            Text("FALLBACK").foregroundColor(.white).font(.caption)
        }
    }
}
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.85), Color.black.opacity(0.0)],
                startPoint: .bottom, endPoint: .top
            )
            .frame(width: geo.size.width, height: geo.size.height)

            VStack(alignment: .leading, spacing: 6) {
                Text("\"\(entry.verseText)\"")
                    .font(.system(size: 14, design: .serif))
                    .italic()
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .shadow(color: .black.opacity(0.6), radius: 3)
                HStack(spacing: 5) {
                    Circle().fill(goldAccent).frame(width: 4, height: 4)
                    Text(entry.verseReference.uppercased())
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(goldAccent)
                }
            }
            .padding(14)
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .clipped()
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