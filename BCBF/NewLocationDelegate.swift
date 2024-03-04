//
//  NewLocationDelegate.swift
//  BCBF
//
//  Created by user216835 on 5/2/22.
//

import Foundation

protocol NewLocationDelegate: NSObject {
    func annotationAdded(annotation: LocationAnnotation)
}
