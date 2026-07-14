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
        return VerseEntry(
            date: Date(),
            verseId: defaults?.string(forKey: "verse_id") ?? "",
            verseText: defaults?.string(forKey: "verse_text")
                ?? "Bir ayet gününüzü değiştirebilir.",
            verseReference: defaults?.string(forKey: "verse_reference") ?? "",
            hijriDate: defaults?.string(forKey: "hijri_date") ?? "",
            moonPhase: defaults?.string(forKey: "moon_phase") ?? "Hilal",
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
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    Image(defaultBackgroundImageName())
                        .resizable()
                }
            }
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