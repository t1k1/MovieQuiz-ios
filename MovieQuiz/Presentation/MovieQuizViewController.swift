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
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 15
        
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
    }
}

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    /// метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
    }
    
    /// метод изменения границы картинки в зависимости от ответа на вопрос
    func highlightImageBorder(isCorrectAnswer: Bool){
        imageView.layer.masksToBounds = true
        changeBorderVisability(borderIsHidden: false)
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    /// метод скрывает/показывает рамку у катинки
    func changeBorderVisability(borderIsHidden: Bool) {
        imageView.layer.borderWidth = borderIsHidden ? 0 : 8
    }
    
    /// приватный метод делает доступными/недоступными кнопки да,нет
    func buttonCanBePressed(_ state: Bool) {
        yesButton.isUserInteractionEnabled = state
        noButton.isUserInteractionEnabled = state
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
}
