# HearingSwitch

A menu-bar app for Apple silicon Macs that switches audio output between the built-in speakers and paired Made for iPhone (MFi) hearing devices.

It discovers hearing devices at runtime (Bluetooth devices whose type is Hearing Aid) instead of hardcoding anyone’s name or device ID.

## Requirements

- An Apple silicon Mac
- macOS 13 or later
- Hearing devices already paired in System Settings

Intel Macs and Rosetta are not supported.

## What it does

The menu-bar icon (an audio waveform) lets you:

- Switch to your hearing devices, if they are currently connected to the Mac
- Switch to the built-in speakers
- Open Accessibility settings, where you can connect or disconnect hearing devices by hand
- Start HearingSwitch at login
- Quit

Switching sets both regular audio and alert sounds to the selected output.

macOS has no public way for an app to take hearing devices from an iPhone or give them back. If the iPhone currently has the Bluetooth connection, choose **Open Accessibility Settings (Hearing Devices)…** and connect the devices there. After that, HearingSwitch can select them as the output.

## Download

Get the latest `HearingSwitch-*-arm64.zip` from [Releases](https://github.com/aikidovation/HearingSwitch/releases). Unzip it and move `HearingSwitch.app` wherever you like, such as the Applications folder.

The download is built for Apple silicon and is ad-hoc signed. It is not notarized by Apple, so macOS will treat it as coming from an unidentified developer.

## Opening the app the first time

Because the app is not signed by an identified Apple developer, the first open is blocked until you allow it.

1. Try to open `HearingSwitch.app` (double-click it, or right-click and choose Open). macOS will warn that Apple could not verify it.
2. Open **System Settings**, click **Privacy & Security** in the sidebar, and scroll down to **Security**.
3. Click **Open Anyway**. This button is available for about an hour after you try to open the app. See [Apple’s steps for opening an app from an unidentified developer](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unknown-developer-mh40616/mac).
4. Enter your Mac login password if asked, then click **Open** on the warning that appears again.

After that, you can open HearingSwitch like any other app. It appears only in the menu bar (there is no Dock icon).

More background from Apple: [Safely open apps on your Mac](https://support.apple.com/en-us/102445).

## Start at login

HearingSwitch does not register itself as a login item until you turn on **Start at Login** in its menu. macOS may then ask you to allow it. If approval is still needed, the app opens **System Settings › General › Login Items** so you can allow HearingSwitch there.

## Permissions

HearingSwitch does not need Accessibility, Bluetooth, microphone, or other privacy permissions to switch the Mac’s audio output.

It only needs:

- Your OK to open it the first time (unidentified developer, above)
- Your OK in Login Items if you use **Start at Login**

## Build from source

Install Xcode, then in this directory run:

```bash
./build.sh
```

That writes an ad-hoc-signed Apple silicon app to `build/HearingSwitch.app`. Open it with:

```bash
open build/HearingSwitch.app
```

## Optional device override

If automatic discovery picks the wrong Bluetooth output, you can save a specific Core Audio device UID:

```bash
defaults write com.aikidovation.HearingSwitch HearingDeviceUID "<uid>"
```

There is no default override.

## License

MIT. See [LICENSE](LICENSE).
