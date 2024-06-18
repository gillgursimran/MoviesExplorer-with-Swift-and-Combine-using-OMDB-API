//
//  MoviesViewModel.swift
//  MoviesExplorer
//
//  Created by Gursimran Singh Gill on 2024-06-16.
//

import Foundation
import Combine

class MoviesViewModel: ObservableObject {
    private let requestHandler: RequestHandler
    private var currentPage = 1
    private var canLoadMorePages = true
    private var moviesRequestParams: [String: String]
    private var cancellables = Set<AnyCancellable>()

    @Published var searchText: String = ""
    @Published var isEditing: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var moviesList : [MoviesData] = []
    
    init() {
        requestHandler = RequestHandler.shared
        moviesRequestParams = [ApiQueryKeys.authKey.rawValue: RequestHandler.apiKey]
        loadMoreMovies()
    }
    
    func loadMoreMovies() {
        errorMessage = nil
        guard !isLoading && canLoadMorePages else { return }
        isLoading = true
        
        if searchText.count >= 3 { // This sets up search query if search text is more than 3 letters
            moviesRequestParams[ApiQueryKeys.title.rawValue] = nil
            moviesRequestParams[ApiQueryKeys.search.rawValue] = searchText
            if currentPage == 1 {
                moviesList.removeAll()
            }
            moviesRequestParams[ApiQueryKeys.page.rawValue] = "\(currentPage)"
        } else if searchText.isEmpty { // This sets up search query with 'all' as search text,
                                       // if search text is empty to display some results on screen
            moviesRequestParams[ApiQueryKeys.title.rawValue] = nil
            moviesRequestParams[ApiQueryKeys.search.rawValue] = "all"
            if currentPage == 1 {
                moviesList.removeAll()
            }
            currentPage += 1
            moviesRequestParams[ApiQueryKeys.page.rawValue] = "\(currentPage)"
        } else { // This sets up search by title query if search text is less than 3 letters,
                 // as if common letters or text less than 3 letters is searched, api returns error.
            moviesRequestParams[ApiQueryKeys.search.rawValue] = nil
            moviesRequestParams[ApiQueryKeys.title.rawValue] = searchText
            moviesList.removeAll()
        }
        
        requestMovies()
    }
    
    private func requestMovies() {
        requestHandler
            .sendRequest(url: RequestHandler.moviesSearchUrl, params: moviesRequestParams)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.canLoadMorePages = false
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] data in
                guard let self = self else { return }
                do {
                    if self.moviesRequestParams["t"] != nil {
                        let parsedData = try JSONDecoder().decode(MoviesData.self, from: data)
                        self.moviesList = [parsedData]
                        self.canLoadMorePages = false
                    } else {
                        let parsedData = try JSONDecoder().decode(Response.self, from: data)
                        self.moviesList.append(contentsOf: parsedData.Search)
                        if self.moviesList.count == Int(parsedData.totalResults) {
                            self.canLoadMorePages = false
                        } else {
                            self.currentPage += 1
                        }
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                    self.canLoadMorePages = false
                }
            })
            .store(in: &self.cancellables)
    }
    
    func resetValuesAndLoad() {
        canLoadMorePages = true
        currentPage = 1
        loadMoreMovies()
    }
}
