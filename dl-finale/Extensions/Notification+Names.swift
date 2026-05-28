//
//  Notification+Names.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import Foundation

extension Notification.Name {
    /// Posted by ObjectDetector when a new set of detected objects is ready.
    static let detectedObjectsUpdated = Notification.Name("detectedObjectsUpdated")
}
