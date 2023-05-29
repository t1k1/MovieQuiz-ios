import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer ? false : true)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer ? true : false)
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    /// переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    /// переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    /// общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    /// фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    /// текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    /// показывает алерты
    private var alertPresenter: AlertPresenterProtocol?
    /// для подсчета статистики
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 15
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        alertPresenter = AlertPresenter(delagate: self)
        statisticService = StatisticServiceImplementation()
        
        loadingIndicatorHidden(false)
        questionFactory?.loadData()
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate, AlertPresentableDelagate {
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        loadingIndicatorHidden(true)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(error: Error) {
        showNetworkError(message: "Невозможно загрузить данные")
    }
    
    // MARK: - AlertPresentableDelagate
    func present(alert: UIAlertController, animated flag: Bool) {
        self.present(alert, animated: flag)
    }
    
    // MARK: - Private functions
    /// метод конвертации, который принимает вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    /// приватный метод для показа activityIndicator
    private func loadingIndicatorHidden(_ state: Bool){
        activityIndicator.isHidden = state
        if state {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    /// приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
    }
    
    /// приватный метод, который меняет цвет рамки, имает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        buttonCanBePressed(false)
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев, метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        buttonCanBePressed(true)
        
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            showResults()
        } else {
            currentQuestionIndex += 1
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
                                                    totalQuestions: questionsAmount),
                               buttonText: "Сыграть еще раз",
                               completion: { [weak self] in
            guard let self = self else {
                return
            }
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.show(alert)
    }
    
    /// приватный метод делает доступными/недоступными кнопки да,нет
    private func buttonCanBePressed(_ state: Bool) {
        yesButton.isUserInteractionEnabled = state
        noButton.isUserInteractionEnabled = state
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
    
    /// приватный метод который показывает что произошла ошибка
    private func showNetworkError(message: String){
        loadingIndicatorHidden(true)
        
        let alert = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self = self else {
                return
            }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            loadingIndicatorHidden(false)
            questionFactory?.loadData()
        })
        alertPresenter?.show(alert)
    }
}
