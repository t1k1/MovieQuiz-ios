//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.05.2023.
//

import Foundation

struct QuizQuestion {
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let image: String
    /// строка с вопросом о рейтинге фильма
    let text: String
    /// булевое значение, правильный ответ на вопрос
    let correctAnswer: Bool
}
