//
//  Environment
//  Cycles
//

import Foundation

public enum Environment {
    enum Keys {
        enum Plist {
            static let gmsApiKey = "GMS_API_KEY"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let gmsApiKey: String = {
        guard let key = infoDictionary[Keys.Plist.gmsApiKey] as? String else {
            fatalError("gms_api_key not set for this environment")
        }
        return key
    }()
}
