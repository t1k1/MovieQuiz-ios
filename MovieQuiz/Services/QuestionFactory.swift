//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.05.2023.
//

import Foundation
import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    private enum MoreOrLessEnum {
        case more
        case less
    }
    
    /// инициализирует загрузку данных
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                    case .success(let mostPopularMovies):
                        let errorMessage = mostPopularMovies.errorMessage
                        let items = mostPopularMovies.items
                        
                        if !(errorMessage.isEmpty) && items.isEmpty {
                            self.delegate?.didFailToLoadData(error: errorMessage)
                        }
                            
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(error: error.localizedDescription)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.delegate?.didFailToLoadData(error: error.localizedDescription)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let ratingInQuestion = (2..<10).randomElement() ?? 7
            
            var moreOrLess: String
            var correctAnswer: Bool
            switch generateRandomMoreLess() {
                case .less:
                    moreOrLess = "меньше"
                    correctAnswer = rating < Float(ratingInQuestion)
                case .more:
                    moreOrLess = "больше"
                    correctAnswer = rating > Float(ratingInQuestion)
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: "Рейтинг этого фильма \(moreOrLess) чем \(ratingInQuestion)?",
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
        
        
    }
    
    private func generateRandomMoreLess() -> MoreOrLessEnum {
        let randomSelection = Int.random(in: 0...1)
        
        switch randomSelection {
            case 0: return .more
            case 1: return .less
            default: return .more
        }
    }
    
    init(delegate: QuestionFactoryDelegate, moviesLoader: MoviesLoading) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
}
