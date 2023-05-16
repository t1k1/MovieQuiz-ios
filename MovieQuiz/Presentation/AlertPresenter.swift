//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.05.2023.
//

import UIKit

final class AlertPresenter {
    private weak var viewController: UIViewController?
        
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

extension AlertPresenter: AlertPresenterProtocol {
    func show(_ alertArgs: AlertModel) {
        let alert = UIAlertController(title: alertArgs.title,
                                      message: alertArgs.message,
                                      preferredStyle: .alert)
        
        // константа с кнопкой для системного алерта
        let action = UIAlertAction(title: alertArgs.buttonText, style: .default) { _ in
            alertArgs.completion()
        }
        
        // добавляем в алерт кнопку
        alert.addAction(action)
        // показываем всплывающее окно
        viewController?.present(alert, animated: true, completion: nil)
    }
}
