import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    private let presenter = MovieQuizPresenter()
    /// переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    /// фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    /// показывает алерты
    private var alertPresenter: AlertPresenterProtocol?
    /// для подсчета статистики
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 15
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        alertPresenter = AlertPresenter(delagate: self)
        statisticService = StatisticServiceImplementation()
        
        activityIndicator.startAnimating()
        questionFactory?.loadData()
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate, AlertPresentableDelagate {
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(error: String) {
        showNetworkError(message: error)
    }
    
    // MARK: - AlertPresentableDelagate
    func present(alert: UIAlertController, animated flag: Bool) {
        self.present(alert, animated: flag)
    }
    
    /// приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
    }
    
    /// приватный метод, который меняет цвет рамки, имает на вход булевое значение и ничего не возвращает
    func showAnswerResult(isCorrect: Bool) {
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
            guard let self = self else { return }
            
            imageView.layer.borderWidth = 0
            buttonCanBePressed(true)
            
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.statisticService = self.statisticService
            self.presenter.alertPresenter = self.alertPresenter
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    /// приватный метод делает доступными/недоступными кнопки да,нет
    private func buttonCanBePressed(_ state: Bool) {
        yesButton.isUserInteractionEnabled = state
        noButton.isUserInteractionEnabled = state
    }
    
    /// приватный метод который показывает что произошла ошибка
    private func showNetworkError(message: String){
        activityIndicator.stopAnimating()
        
        let alert = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self = self else {
                return
            }
            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            activityIndicator.startAnimating()
            questionFactory?.loadData()
        })
        alertPresenter?.show(alert)
    }
}
