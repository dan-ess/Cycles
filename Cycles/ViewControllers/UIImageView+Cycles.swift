//
//  UIImageView+Cycles.swift
//  Cycles
//

import Foundation
import UIKit

extension UIImageView {
    func loadImageUsingUrlString(urlString: String, completion: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                print(String(describing: error))
                completion()
            }
            
            if let data = data {   
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.image = UIImage(data: data)
                    completion()
                }
            }
        })
        dataTask.resume()
    }
}
