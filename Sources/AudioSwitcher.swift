import AppKit
import CoreAudio
import ServiceManagement

@MainActor
final class AudioSwitcher: ObservableObject {
    @Published private(set) var outputs: [AudioOutput] = []
    @Published private(set) var defaultID: AudioObjectID = 0
    @Published private(set) var pairedAids: [PairedHearingAid] = []
    @Published private(set) var startsAtLogin = SMAppService.mainApp.status == .enabled
    @Published var notice: String?

    /// Optional per-user override: `defaults write com.aikidovation.HearingSwitch HearingDeviceUID <uid>`.
    private var overrideUID: String? { UserDefaults.standard.string(forKey: "HearingDeviceUID") }

    /// Opens System Settings > Accessibility. URL found in the system's
    /// AccessibilitySettingsWidgetExtension; Hearing Devices is a section there.
    static let accessibilitySettingsURL = URL(string: "x-apple.systempreferences:com.apple.Accessibility-Settings.extension")!

    init() {
        refresh()
        rescanBluetooth()
        AudioDevices.observeChanges { [weak self] in
            Task { @MainActor in
                self?.refresh()
                self?.rescanBluetooth()
            }
        }
    }

    var builtInSpeakers: AudioOutput? {
        outputs.first { $0.isBuiltIn && $0.uid == "BuiltInSpeakerDevice" } ?? outputs.first { $0.isBuiltIn }
    }

    /// The hearing-device output, if it is currently a Core Audio device.
    var hearingOutput: AudioOutput? {
        if let uid = overrideUID, let match = outputs.first(where: { $0.uid == uid }) { return match }
        let names = Set(pairedAids.map(\.name))
        return outputs.first { $0.isBluetooth && names.contains($0.name) }
    }

    var hasPairedHearingAids: Bool { !pairedAids.isEmpty || hearingOutput != nil }

    func refresh() {
        outputs = AudioDevices.outputs()
        defaultID = AudioDevices.defaultOutputID()
        startsAtLogin = SMAppService.mainApp.status == .enabled
    }

    func rescanBluetooth() {
        Task.detached(priority: .utility) {
            let aids = HearingAidDiscovery.scan()
            await MainActor.run { self.pairedAids = aids }
        }
    }

    func select(_ output: AudioOutput) {
        notice = AudioDevices.setDefaultOutput(output.id) ? nil : "Couldn't switch to \(output.name)."
        refresh()
    }

    func selectHearingDevices() {
        if let output = hearingOutput {
            select(output)
        } else {
            notice = "Hearing devices aren't connected to this Mac. Connect them in Accessibility › Hearing Devices."
            rescanBluetooth()
        }
    }

    func openHearingSettings() {
        NSWorkspace.shared.open(Self.accessibilitySettingsURL)
    }

    func setStartsAtLogin(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            notice = nil
        } catch {
            notice = "Start at Login: \(error.localizedDescription)"
        }
        refresh()
        if on && SMAppService.mainApp.status == .requiresApproval {
            notice = "Approve HearingSwitch in System Settings › General › Login Items."
            SMAppService.openSystemSettingsLoginItems()
        }
    }
}
