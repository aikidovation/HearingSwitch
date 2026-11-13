import AppKit
// Original artwork (not an SF Symbol): rounded-square background with waveform bars.
func render(_ px: Int) -> Data {
  let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  let s = CGFloat(px)/1024
  let bg = NSBezierPath(roundedRect: NSRect(x: 100*s, y: 100*s, width: 824*s, height: 824*s), xRadius: 185*s, yRadius: 185*s)
  NSGradient(starting: NSColor(calibratedRed: 0.20, green: 0.45, blue: 0.95, alpha: 1), ending: NSColor(calibratedRed: 0.05, green: 0.18, blue: 0.55, alpha: 1))!.draw(in: bg, angle: -90)
  let heights: [CGFloat] = [0.22, 0.42, 0.68, 0.90, 0.60, 0.80, 0.48, 0.30, 0.16]
  let barW: CGFloat = 52*s, gap: CGFloat = 26*s
  let total = CGFloat(heights.count)*barW + CGFloat(heights.count-1)*gap
  var x = 512*s - total/2
  NSColor.white.setFill()
  for h in heights { let hh = h*560*s
    NSBezierPath(roundedRect: NSRect(x: x, y: 512*s - hh/2, width: barW, height: hh), xRadius: barW/2, yRadius: barW/2).fill()
    x += barW + gap }
  NSGraphicsContext.restoreGraphicsState()
  return rep.representation(using: .png, properties: [:])!
}
let dir = "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
for b in [16,32,128,256,512] {
  try! render(b).write(to: URL(fileURLWithPath: "\(dir)/icon_\(b)x\(b).png"))
  try! render(b*2).write(to: URL(fileURLWithPath: "\(dir)/icon_\(b)x\(b)@2x.png"))
}
try! render(1024).write(to: URL(fileURLWithPath: "icon-1024.png"))
