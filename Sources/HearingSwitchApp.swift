import SwiftUI

@main
struct HearingSwitchApp: App {
    @StateObject private var switcher = AudioSwitcher()

    var body: some Scene {
        MenuBarExtra("HearingSwitch", systemImage: "waveform") {
            MenuContent(switcher: switcher)
        }
    }
}

struct MenuContent: View {
    @ObservedObject var switcher: AudioSwitcher

    var body: some View {
        if switcher.hasPairedHearingAids {
            let output = switcher.hearingOutput
            Button(check(output) + (output?.name ?? "Hearing Devices (not connected)")) {
                switcher.selectHearingDevices()
            }
        }
        if let speakers = switcher.builtInSpeakers {
            Button(check(speakers) + speakers.name) { switcher.select(speakers) }
        }
        if let notice = switcher.notice {
            Divider()
            Text(notice)
        }
        Divider()
        Button("Open Accessibility Settings (Hearing Devices)…") { switcher.openHearingSettings() }
        Toggle("Start at Login", isOn: Binding(get: { switcher.startsAtLogin },
                                               set: { switcher.setStartsAtLogin($0) }))
        Divider()
        Button("Quit HearingSwitch") { NSApplication.shared.terminate(nil) }.keyboardShortcut("q")
    }

    private func check(_ output: AudioOutput?) -> String {
        output?.id == switcher.defaultID && output != nil ? "✓ " : "    "
    }
}
