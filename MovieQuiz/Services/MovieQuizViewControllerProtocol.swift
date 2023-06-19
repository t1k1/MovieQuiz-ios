//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 19.06.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func changeBorderWidth(width: CGFloat)
    func buttonCanBePressed(_ state: Bool)
    func hideLoadingIndicator()
    func showLoadingIndicator()
}
