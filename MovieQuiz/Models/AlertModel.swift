//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.05.2023.
//

import Foundation

// вью модель для состояния "Вопрос показан"
struct AlertModel {
    // текст заголовка алерта
    let title: String
    //  текст сообщения алерта
    let message: String
    // текст для кнопки алерта
    let buttonText: String
    // замыкание без параметров для действия по кнопке алерта
    let completion: () -> Void
}
