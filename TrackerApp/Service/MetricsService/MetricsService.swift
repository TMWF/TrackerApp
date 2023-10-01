import Foundation
import YandexMobileMetrica

struct MetricsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "e1144404-518c-4b05-9694-218817cde117") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: Events, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
