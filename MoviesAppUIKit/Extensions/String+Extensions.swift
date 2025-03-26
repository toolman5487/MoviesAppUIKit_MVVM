//
//  String+Extensions.swift
//  MoviesAppUIKit
//
//  Created by Mohammad Azam on 10/12/23.
//

import Foundation

extension String {
    
    var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
}
