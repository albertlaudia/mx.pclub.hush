//
//  LockWidget.swift
//  RunnerWidget
//
//  The home screen widget for Prayer Lock. Shows the current streak
//  with a flame + day number. Reads from the App Group written by the
//  Dart side via the home_widget package.
//

import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
  let date: Date
  let streak: Int
  let best: Int
  let practiced: Bool
  let label: String
}

struct StreakProvider: TimelineProvider {
  func placeholder(in context: Context) -> StreakEntry {
    StreakEntry(date: Date(), streak: 0, best: 0, practiced: false, label: "0-day streak")
  }

  func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> ()) {
    let entry = readEntry()
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> ()) {
    let entry = readEntry()
    // Refresh at midnight (start of next day) so the streak dot is accurate.
    let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60 * 60 * 24)
    completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
  }

  private func readEntry() -> StreakEntry {
    let defaults = UserDefaults(suiteName: "group.mx.pclub.lock")
    let streak = defaults?.integer(forKey: "streak") ?? 0
    let best = defaults?.integer(forKey: "best") ?? 0
    let practiced = defaults?.bool(forKey: "practiced") ?? false
    let label = defaults?.string(forKey: "label") ?? "\(streak)-day streak"
    return StreakEntry(date: Date(), streak: streak, best: best, practiced: practiced, label: label)
  }
}

struct LockWidgetEntryView: View {
  var entry: StreakProvider.Entry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    case .accessoryCircular:
      circularView
    case .accessoryRectangular:
      rectView
    default:
      smallView
    }
  }

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("🔥")
        .font(.system(size: 22))
      Text("\(entry.streak)")
        .font(.system(size: 36, weight: .light, design: .rounded))
        .foregroundColor(.black)
      Text(entry.streak == 1 ? "day streak" : "day streak")
        .font(.caption2)
        .foregroundColor(.gray)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding(12)
    .containerBackground(for: .widget) {
      Color(red: 1.0, green: 0.973, blue: 0.906) // cream
    }
  }

  private var mediumView: some View {
    HStack(alignment: .center, spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text("🔥")
          .font(.system(size: 28))
        Text("\(entry.streak)")
          .font(.system(size: 48, weight: .light, design: .rounded))
          .foregroundColor(.black)
        Text(entry.streak == 1 ? "day streak" : "day streak")
          .font(.caption)
          .foregroundColor(.gray)
      }
      Spacer()
      VStack(alignment: .trailing, spacing: 4) {
        Text("best")
          .font(.caption2)
          .foregroundColor(.gray)
        Text("\(entry.best)")
          .font(.system(size: 18, weight: .semibold, design: .rounded))
          .foregroundColor(.orange)
        if entry.practiced {
          Text("today ✓")
            .font(.caption2)
            .foregroundColor(.green)
        } else {
          Text("tap to pray")
            .font(.caption2)
            .foregroundColor(.orange)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(16)
    .containerBackground(for: .widget) {
      Color(red: 1.0, green: 0.973, blue: 0.906) // cream
    }
  }

  private var circularView: some View {
    VStack(spacing: 0) {
      Text("🔥").font(.system(size: 14))
      Text("\(entry.streak)").font(.system(size: 16, weight: .bold, design: .rounded))
    }
    .containerBackground(for: .widget) { Color.clear }
  }

  private var rectView: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("🔥 prayer lock").font(.caption2)
      Text("\(entry.streak) day").font(.headline)
    }
    .containerBackground(for: .widget) { Color.clear }
  }
}

struct LockWidget: Widget {
  let kind: String = "LockWidget"
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
      LockWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Prayer Lock")
    .description("Your current prayer streak, on your home screen.")
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
  }
}

@main
struct LockWidgetBundle: WidgetBundle {
  var body: some Widget {
    LockWidget()
  }
}
