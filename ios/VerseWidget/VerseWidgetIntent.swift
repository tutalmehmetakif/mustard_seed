//
//  VerseWidgetIntent.swift
//

import WidgetKit
import AppIntents

enum VerseWidgetStyle: String, AppEnum {
    case minimal
    case moonPhase
    case photo

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Stili"

    static var caseDisplayRepresentations: [VerseWidgetStyle: DisplayRepresentation] = [
        .minimal: "Minimal",
        .moonPhase: "Ay Evreli",
        .photo: "Fotoğraflı"
    ]
}

struct VerseWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Hardal Tanesi Widget"
    static var description = IntentDescription("Görünüm stilini seç.")

    @Parameter(title: "Stil", default: .moonPhase)
    var style: VerseWidgetStyle
}