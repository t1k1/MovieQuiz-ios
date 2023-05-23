//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 16.05.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Kill Bill",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Avengers",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Deadpool",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Green Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Old",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Tesla",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Vivarium",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false)
    ]
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
}

/*
// Спринт 6/18: 5 → Тема 3/4: Хранение данных → Урок 7/10
private struct Item: Codable {
    let id: String
    let rank: Int
    let title: String
    let fullTitle: String
    let year: Int
    let image: String
    let crew: String
    let imDbRating: Double
    let imDbRatingCount: Int
    
    enum CodingKeys: CodingKey {
        case id,
             rank,
             title,
             fullTitle,
             year,
             image,
             crew,
             imDbRating,
             imDbRatingCount
    }
    
    enum ParseError: Error {
        case rankFailure
        case yearFailure
        case imDbRatingFailure
        case imDbRatingCountFailure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let rank = try container.decode(String.self, forKey: .rank)
        guard let rank = Int(rank) else { throw ParseError.rankFailure }
        self.rank = rank
        
        let year = try container.decode(String.self, forKey: .year)
        guard let year = Int(year) else { throw ParseError.yearFailure }
        self.year = year
        
        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        guard let imDbRating = Double(imDbRating) else { throw ParseError.imDbRatingFailure }
        self.imDbRating = imDbRating
        
        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        guard let imDbRatingCount = Int(imDbRatingCount) else { throw ParseError.imDbRatingCountFailure }
        self.imDbRatingCount = imDbRatingCount
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        fullTitle = try container.decode(String.self, forKey: .fullTitle)
        image = try container.decode(String.self, forKey: .image)
        crew = try container.decode(String.self, forKey: .crew)
    }
}
private struct Movies: Codable {
    let items: [Item]
    let errorMessage: String
}
//

//приватная функция для парсинга json
private func getMovieCodable(from jsonString: String) -> Movies? {
    var movies: Movies? = nil
    
    do {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        movies = try JSONDecoder().decode(Movies.self, from: data)
    } catch {
        print("Failed to parse: \(error)")
    }
    
    return movies
}

// Спринт 6/18: 5 → Тема 3/4: Хранение данных → Урок 7/10
var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let fileName = "top250MoviesIMDB.json"
documentsURL.appendPathComponent(fileName)
let jsonString = try? String(contentsOf: documentsURL)
guard let jsonString = jsonString else { return }
let movies = getMovieCodable(from: jsonString)
guard let movies = movies else { return }
print(movies)
*/

