import Foundation

/// Finds paired hearing aids via `system_profiler SPBluetoothDataType -json`
/// (Bluetooth minor type "Hearing Aid"). No names or vendor IDs are hardcoded.
struct PairedHearingAid: Equatable {
    let name: String
    let connected: Bool
}

enum HearingAidDiscovery {
    /// Slow (about 1-2 s); call off the main thread and cache the result.
    static func scan() -> [PairedHearingAid] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        process.arguments = ["SPBluetoothDataType", "-json"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do { try process.run() } catch { return [] }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let controllers = root["SPBluetoothDataType"] as? [[String: Any]] else { return [] }

        var result: [PairedHearingAid] = []
        for controller in controllers {
            for (key, connected) in [("device_connected", true), ("device_not_connected", false)] {
                for entry in controller[key] as? [[String: Any]] ?? [] {
                    for (name, info) in entry {
                        guard let info = info as? [String: Any],
                              (info["device_minorType"] as? String)?.caseInsensitiveCompare("Hearing Aid") == .orderedSame
                        else { continue }
                        let aid = PairedHearingAid(name: name, connected: connected)
                        if !result.contains(aid) { result.append(aid) }
                    }
                }
            }
        }
        return result
    }
}
