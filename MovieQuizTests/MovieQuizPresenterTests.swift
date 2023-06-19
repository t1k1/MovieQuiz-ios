//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Aleksey Kolesnikov on 19.06.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) { }
    func highlightImageBorder(isCorrectAnswer: Bool) { }
    func changeBorderWidth(width: CGFloat) { }
    func buttonCanBePressed(_ state: Bool) { }
    func hideLoadingIndicator() { }
    func showLoadingIndicator() { }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Test question", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Test question")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
