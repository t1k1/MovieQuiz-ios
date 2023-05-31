//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.05.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
}
