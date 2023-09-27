import Foundation
//import YandexMobileMetrica

struct MetricsService {
    static func activate() {
//        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "a6fbd965-2c9d-4ae9-b2b8-a7e8567c472d") else { return }
//
//        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: Events, params : [AnyHashable : Any]) {
//        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
//            print("REPORT ERROR: %@", error.localizedDescription)
//        })
    }
}
