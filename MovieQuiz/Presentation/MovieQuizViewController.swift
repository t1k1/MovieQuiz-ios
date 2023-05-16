import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
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
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // MARK: - Variables
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    // фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }
}

extension MovieQuizViewController {
   
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
    
    // MARK: - Private functions
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage.named(model.image),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        // создаём объекты всплывающего окна
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        
        // константа с кнопкой для системного алерта
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        // добавляем в алерт кнопку
        alert.addAction(action)
        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                            text: "Ваш результат \(correctAnswers)/10",
                                            buttonText: "Сыграть еще раз"))
            
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
}

extension UIImage {
    static func named(_ name: String) -> UIImage {
        if let image = UIImage(named: name) {
            return image
        } else {
            return UIImage()
        }
    }
}
