import UIKit

// Drop-in white overlay to obscure UI during screen capture/recording,
// and to flash on user screenshots.
final class SecureOverlay {
    static let shared = SecureOverlay()

    private var overlayWindow: UIWindow?
    private var isShown: Bool = false

    private func makeWindow() -> UIWindow {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.windowLevel = .alert + 1
        win.backgroundColor = .white
        win.isHidden = false
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.modalPresentationStyle = .overFullScreen
        win.rootViewController = vc
        return win
    }

    func show() {
        guard !isShown else { return }
        isShown = true
        if overlayWindow == nil {
            overlayWindow = makeWindow()
        }
        overlayWindow?.isHidden = false
        overlayWindow?.alpha = 1.0
    }

    func hide() {
        isShown = false
        overlayWindow?.isHidden = true
    }

    func flash(duration: TimeInterval = 1.0) {
        if overlayWindow == nil { overlayWindow = makeWindow() }
        guard let win = overlayWindow else { return }
        win.isHidden = false
        win.alpha = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self else { return }
            if !self.isShown { // only hide if not persistently shown
                win.isHidden = true
            }
        }
    }
}

