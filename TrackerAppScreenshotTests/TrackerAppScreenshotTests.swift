import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerAppScreenshotTests: XCTestCase {
    func testTrackersVCLight() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = TabBarController.configure()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        let trackersVC = (vc.children.first as? UINavigationController)?.viewControllers.first
        print(String(describing: trackersVC))
        guard let view = trackersVC?.view else { return }
        assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testTrackersVCDark() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = TabBarController.configure()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        let trackersVC = (vc.children.first as? UINavigationController)?.viewControllers.first
        print(String(describing: trackersVC))
        guard let view = trackersVC?.view else { return }
        assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
