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
    /// текущий вопрос, который видит пользователь
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers = 0
    /// фабрика вопросов
    var questionFactory: QuestionFactoryProtocol?
    /// для подсчета статистики
    var statisticService: StatisticService?
    var alertPresenter: AlertPresenterProtocol?
    
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
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев, метод ничего не принимает и ничего не возвращает
    func showNextQuestionOrResults() {
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
        statisticService.store(correct: correctAnswers, total: self.questionsAmount)
        
        let alert = AlertModel(title: "Этот раунд окончен!",
                               message: makeMessage(statisticService: statisticService,
                                                    correctAnswers: correctAnswers,
                                                    totalQuestions: self.questionsAmount),
                               buttonText: "Сыграть еще раз",
                               completion: { [weak self] in
            guard let self = self else {
                return
            }
            self.correctAnswers = 0
            self.resetQuestionIndex()
            self.questionFactory?.requestNextQuestion()
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
}
