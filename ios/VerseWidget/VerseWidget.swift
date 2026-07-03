//
//  VerseWidget.swift
//
//  BU DOSYA XCODE PROJESİNİN PARÇASI DEĞİL — referans koddur.
//  Xcode'da "Widget Extension" hedefi oluşturduğunda otomatik gelen
//  VerseWidget.swift (ya da benzeri) dosyasının İÇERİĞİNİ bununla
//  DEĞİŞTİR. Adımlar için ios_widget_reference/README.md'ye bak.
//

import WidgetKit
import SwiftUI

// App Group kimliği — lib/features/home/data/widget_service.dart
// içindeki WidgetService.iOSAppGroupId ile BİREBİR aynı olmalı.
let appGroupId = "group.io.supabase.mustardseed"

// Hardal Tanesi marka renkleri (core/theme/app_colors.dart ile aynı).
let goldBright = Color(red: 0.79, green: 0.64, blue: 0.15) // #C9A227

struct VerseEntry: TimelineEntry {
    let date: Date
    let verseText: String
    let verseReference: String
    let hijriDate: String
    let moonPhase: String
}

struct VerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> VerseEntry {
        VerseEntry(
            date: Date(),
            verseText: "Bir ayet gününüzü değiştirebilir.",
            verseReference: "İnşirah Suresi, 6. Ayet",
            hijriDate: "19 Zilhicce 1446",
            moonPhase: "Hilal"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
        let entry = loadEntry()
        // iOS'a "3 saat sonra tekrar sorabilirsin" diyoruz — kesin garanti
        // değil, sistem uygun gördüğünde yeniler. Günlük otomatik yenileme
        // garantisi için ileride BackgroundTasks eklenmesi gerekebilir.
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> VerseEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return VerseEntry(
            date: Date(),
            verseText: defaults?.string(forKey: "verse_text")
                ?? "Bir ayet gününüzü değiştirebilir.",
            verseReference: defaults?.string(forKey: "verse_reference") ?? "",
            hijriDate: defaults?.string(forKey: "hijri_date") ?? "",
            moonPhase: defaults?.string(forKey: "moon_phase") ?? "Hilal"
        )
    }
}

struct VerseWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: VerseEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // Kilit ekranı widget'ı — küçük ve sade.
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.moonPhase) · \(entry.hijriDate)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(goldBright)
                Text("\"\(entry.verseText)\"")
                    .font(.system(size: 12, weight: .medium))
                    .italic()
                    .lineLimit(2)
                Text(entry.verseReference)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(goldBright)
            }
            .padding(.horizontal, 2)

        default:
            // Ana ekran widget'ı — biraz daha ferah, kullanıcının kendi
            // fotoğrafının üstünde yarı saydam bir kart gibi durur.
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(entry.moonPhase)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(goldBright)
                    Text("·")
                        .foregroundColor(.white.opacity(0.6))
                    Text(entry.hijriDate)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                }
                Text("\"\(entry.verseText)\"")
                    .font(.system(size: 14, weight: .medium))
                    .italic()
                    .foregroundColor(.white)
                    .lineLimit(3)
                Text(entry.verseReference.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(goldBright)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct VerseWidget: Widget {
    let kind: String = "VerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
            VerseWidgetEntryView(entry: entry)
                .containerBackground(Color.black.opacity(0.4), for: .widget)
        }
        .configurationDisplayName("Hardal Tanesi")
        .description("Günün ayetini kilit ekranında ya da ana ekranında gör.")
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
    }
}