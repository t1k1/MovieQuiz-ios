//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.06.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresentableDelagate {
    // MARK: - Variables
    private weak var viewController: MovieQuizViewController?
    /// для подсчета статистики
    private let statisticService: StatisticService?
    /// фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    /// перезентер для вывода алертов
    private var alertPresenter: AlertPresenterProtocol?
    
    /// текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    /// общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    /// переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex: Int = 0
    /// количество правильных ответов на вопросы
    private var correctAnswers = 0
 
    // MARK: - Initialization
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
    
        alertPresenter = AlertPresenter(delagate: self)
        
        viewController.showLoadingIndicator()
    }
    
    // MARK: - AlertPresentableDelagate
    func present(alert: UIAlertController, animated flag: Bool) {
        viewController?.present(alert, animated: flag)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(error: String) {
        showNetworkError(message: error)
    }
    
    // MARK: - Internal functions
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    /// метод конвертации, который принимает вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - Private functions
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: true)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.buttonCanBePressed(false)
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            viewController?.changeBorderWidth(width: 0)
            viewController?.buttonCanBePressed(true)
            
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев, метод ничего не принимает и ничего не возвращает
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            showResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    /// приватный метод показывает результат квиза
    private func showResults() {
        guard let statisticService = statisticService else {
            print("Не удалось получить статистику")
            return
        }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let alert = AlertModel(title: "Этот раунд окончен!",
                               message: makeMessage(statisticService: statisticService,
                                                    correctAnswers: correctAnswers,
                                                    totalQuestions: self.questionsAmount),
                               buttonText: "Сыграть еще раз",
                               completion: { [weak self] in
            guard let self = self else {
                return
            }
            restartGame()
        })
        alertPresenter?.show(alert)
    }
    
    /// приватный метод формирует message для алерта
    private func makeMessage(statisticService: StatisticService, correctAnswers: Int, totalQuestions: Int) -> String {
        let bestGame = statisticService.bestGame
        let message = """
        Ваш результат: \(correctAnswers)/\(totalQuestions)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return message
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// приватный метод который показывает что произошла ошибка
    private func showNetworkError(message: String){
        viewController?.hideLoadingIndicator()
        
        let alert = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self = self else { return }
            
            self.restartGame()
            viewController?.showLoadingIndicator()
        })
        alertPresenter?.show(alert)
    }
}
