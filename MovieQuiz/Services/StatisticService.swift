//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 17.05.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
}

final class StatisticServiceImplementation: StatisticService {
    private enum Keys: String {
        case correct,
             total,
             bestGame,
             gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    /// количество вопросов
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    /// количество правильных ответов в игре
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    /// средняя точность игры
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    /// количество игр
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    /// лучшая попытка
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                    let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    /// метод для сохранения текущего результата игры
    func store(correct count: Int, total amount: Int) {
        total += amount
        correct += count
        gamesCount += 1
        
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        
        if bestGame < currentGame {
            bestGame = currentGame
        }
    }
}
