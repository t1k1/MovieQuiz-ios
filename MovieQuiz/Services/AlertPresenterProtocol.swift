//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.05.2023.
//

import Foundation

protocol AlertPresenterProtocol: AnyObject {
    func show(_ alertArgs: AlertModel)
}
