Capacitor wrapper to harden screenshots on mobile

Overview
- Android: fully block screenshots using FLAG_SECURE.
- iOS: cannot truly block screenshots. We add: white overlay while screen is being recorded, and 1s white flash on user screenshot.

Prerequisites
- Node.js 18+
- Android Studio (SDK + emulator/device)
- Xcode (for iOS builds on macOS)

Quick Start (from the repo root)
1) Initialize Capacitor using current web as the app:
   - npm init -y
   - npm i -D @capacitor/cli
   - npm i @capacitor/core
   - npx cap init deep com.deep.app --web-dir .

2) Add platforms
   - npx cap add android
   - npx cap add ios

3) Sync and open
   - npx cap sync
   - npx cap open android
   - npx cap open ios

Android: Enable FLAG_SECURE
1) In Android Studio, open: android/app/src/main/java/.../MainActivity.kt
2) Replace its content with native/android/MainActivity.kt from this repo (adjust package if needed).
3) Build and run on device.

iOS: Add secure overlay + flash on screenshot
1) In Xcode, add file native/ios/SecureOverlay.swift to your iOS target.
2) In AppDelegate.swift, add the indicated snippet (below) to observe capture/screenshot and show/hide overlay.
3) Build and run on device.

AppDelegate.swift snippet (Capacitor)
// In AppDelegate.swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Show overlay while screen is captured (recorded / mirroring)
    NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main) { _ in
      if UIScreen.main.isCaptured { SecureOverlay.shared.show() } else { SecureOverlay.shared.hide() }
    }
    // Flash overlay for 1s when user takes a screenshot
    NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { _ in
      SecureOverlay.shared.flash(duration: 1.0)
    }
    // Initialize state on launch
    if UIScreen.main.isCaptured { SecureOverlay.shared.show() }
    return true
  }
}

Notes
- Android FLAG_SECURE blocks screenshots and screen recording; compliant with Play policies when your content is sensitive.
- iOS overlay prevents screen recording from exposing content live. Screenshots cannot be preemptively blocked; the flash occurs after capture.
- In the web app, a 3‑finger swipe on phones already flashes a white overlay for 1s. You can also call window.__antiSSShow(ms) from JS.

