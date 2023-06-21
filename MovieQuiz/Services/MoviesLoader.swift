//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Aleksey Kolesnikov on 26.05.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
}

extension MoviesLoader {
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_qctsqbpr") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    /// загружает топ 250 фильмов imdb
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
                case .success(let data):
                    do {
                        let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                        handler(.success(mostPopularMovies))
                    } catch {
                        handler(.failure(error))
                    }
                case .failure(let error):
                    handler(.failure(error))
            }
        }
        
    }
}
