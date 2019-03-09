//
//  CycleServiceArea.swift
//  CycleService
//

public enum CycleServiceArea: Int, CaseIterable {
    // TODO: consider using romaji representations of these areas
    case 千代田区 = 1
    case 中央区 = 2
    case 港区 = 3
    case 江東区 = 4
    case 新宿区 = 5
    case 文京区 = 6
    case 大田区 = 7
    case 渋谷区 = 8
    case なぞ = 9
    case 品川区 = 10
    
    static func withLabel(_ label: String) -> CycleServiceArea? {
        for area in self.allCases {
            if String(describing: area) == label {
                return area
            }
        }
        return nil
    }
}
