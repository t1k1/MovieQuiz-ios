//
//  AlertPresentableDelagate.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 23.05.2023.
//

import UIKit

protocol AlertPresentableDelagate: AnyObject {
    func present(alert: UIAlertController, animated flag: Bool)
}
