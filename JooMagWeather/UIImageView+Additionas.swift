//
//  UIImageView+Additionas.swift
//  FavouriteLocations
//
//  Created by Developer on 27/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

extension UIImageView {

    func setImageFromUrl(imageUrl:URL) {
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.image = UIImage(data: data)
            }
        }.resume()
    }

}
