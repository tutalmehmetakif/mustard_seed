//
//  VerseWidget.swift
//
//  BU DOSYA XCODE PROJESİNİN PARÇASI DEĞİL — referans koddur.
//  Xcode'da "VerseWidget" hedefindeki VerseWidget.swift dosyasının
//  İÇERİĞİNİ bununla DEĞİŞTİR.
//

import WidgetKit
import SwiftUI

let appGroupId = "group.io.supabase.mustardseed"
let goldAccent = Color(red: 0.788, green: 0.635, blue: 0.153) // #C9A227
let creamText = Color(red: 0.961, green: 0.933, blue: 0.894)  // #F5EEE4

struct VerseEntry: TimelineEntry {
    let date: Date
    let verseId: String
    let verseText: String
    let verseReference: String
    let hijriDate: String
    let moonPhase: String
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

struct VerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> VerseEntry {
        VerseEntry(
            date: Date(),
            verseId: "",
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
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> VerseEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return VerseEntry(
            date: Date(),
            verseId: defaults?.string(forKey: "verse_id") ?? "",
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
            lockScreenLayout
        default:
            homeScreenLayout
        }
    }

    // MARK: - Kilit Ekranı

    private var lockScreenLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                HStack(spacing: 3) {
                    Circle()
                        .fill(goldAccent)
                        .frame(width: 3, height: 3)
                    Text("GÜNÜN AYETİ")
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(1)
                }
                Spacer()
                HStack(spacing: 3) {
                    Text(moonEmoji(for: entry.moonPhase))
                        .font(.system(size: 11))
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(entry.moonPhase.uppercased())
                            .font(.system(size: 7, weight: .semibold))
                        Text(entry.hijriDate)
                            .font(.system(size: 6, weight: .light))
                    }
                }
            }
            Text("\"\(entry.verseText)\"")
                .font(.system(size: 12, weight: .medium, design: .serif))
                .italic()
                .lineLimit(2)
                .lineSpacing(1)
            HStack(spacing: 4) {
                Circle()
                    .fill(goldAccent)
                    .frame(width: 4, height: 4)
                Text(entry.verseReference.uppercased())
                    .font(.system(size: 8, weight: .semibold))
            }
        }
        .padding(.horizontal, 2)
    }

    // MARK: - Ana Ekran

    private var homeScreenLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(goldAccent)
                        .frame(width: 5, height: 5)
                    Text("GÜNÜN AYETİ")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(creamText.opacity(0.7))
                }
                Spacer()
                HStack(spacing: 5) {
                    Text(moonEmoji(for: entry.moonPhase))
                        .font(.system(size: 15))
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

            Rectangle()
                .fill(goldAccent.opacity(0.12))
                .frame(height: 1)
                .padding(.top, 14)
                .padding(.bottom, 10)

            HStack(spacing: 6) {
                Circle()
                    .fill(goldAccent)
                    .frame(width: 5, height: 5)
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
                // Sıcak, koyu diyagonal degrade — düz siyah opaklık yerine
                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.07, blue: 0.05),
                        Color(red: 0.122, green: 0.106, blue: 0.075),
                        Color(red: 0.07, green: 0.06, blue: 0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Sağ üst köşede yumuşak altın parıltı — uygulama kartlarındaki
                // "ambient background decoration" ile aynı dil
                GeometryReader { geo in
                    Circle()
                        .fill(goldAccent.opacity(0.18))
                        .frame(width: 90, height: 90)
                        .blur(radius: 30)
                        .position(x: geo.size.width - 10, y: 0)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(goldAccent.opacity(0.15), lineWidth: 1)
        )
    }
}

struct VerseWidget: Widget {
    let kind: String = "VerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
            VerseWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.09, green: 0.07, blue: 0.05)
                }
                // Widget'a dokununca uygulamayı "Ayet Açıklaması" ekranına
                // götüren deep link. main.dart'taki AppLinks dinleyicisi
                // bunu yakalayıp go_router ile /verse-detail/:id rotasına
                // yönlendiriyor.
                .widgetURL(
                    URL(string: "io.supabase.mustardseed://verse-detail?id=\(entry.verseId)")
                )
        }
        .configurationDisplayName("Hardal Tanesi")
        .description("Günün ayetini kilit ekranında ya da ana ekranında gör.")
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
    }
}