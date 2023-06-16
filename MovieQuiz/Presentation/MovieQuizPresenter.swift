//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.06.2023.
//

import UIKit

final class MovieQuizPresenter {
    // MARK: - Variables
    /// переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex: Int = 0
    /// общее количество вопросов для квиза
    let questionsAmount: Int = 10
    
    // MARK: - Functions
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// метод конвертации, который принимает вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
