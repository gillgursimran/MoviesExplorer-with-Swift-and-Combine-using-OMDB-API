//
//  MoviesExplorerView.swift
//  MoviesExplorer
//
//  Created by Gursimran Singh Gill on 2024-06-16.
//

import SwiftUI
import SDWebImageSwiftUI

struct MoviesExplorerView: View {
    @StateObject var viewModel = MoviesViewModel()
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            searchBar()
            if viewModel.moviesList.isEmpty {
                noMoviesFoundView()
                Spacer()
            }
            moviesListView()
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    fileprivate func searchBar() -> some View {
        return HStack {
            TextField("search",
                      text: $viewModel.searchText,
                      onEditingChanged: { editing in
                          withAnimation {
                              viewModel.isEditing = editing
                          }
                      }
            )
            .focused($isTextFieldFocused)
            .padding(Dimens.spacingRegular)
            .background(Color(.systemGray6))
            .cornerRadius(Dimens.spacingSmall)
            .onChange(of: viewModel.searchText) {
                viewModel.resetValuesAndLoad()
            }
            .overlay(
                HStack {
                    Spacer()
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                            viewModel.resetValuesAndLoad()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(.gray))
                                .padding(.trailing, Dimens.spacingRegular)
                        }
                    }
                }
            )
            
            if viewModel.isEditing {
                Button("cancel") {
                    viewModel.searchText = ""
                    isTextFieldFocused = false
                    viewModel.resetValuesAndLoad()
                }
            }
        }
        .padding(.horizontal, Dimens.spacingRegular)
    }
    
    fileprivate func noMoviesFoundView() -> some View {
        return Text("noMovies")
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.top, Dimens.spacingLarge)
            .padding(.horizontal, Dimens.spacingLarge)
    }
    
    fileprivate func moviesListView() -> some View {
        return List(viewModel.moviesList, id: \.id) { movie in
            HStack(spacing: Dimens.spacingMedium) {
                WebImage(url: URL(string: movie.poster)) { image in
                    image.resizable()
                } placeholder: {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.secondary.opacity(0.2))
                        Image(systemName: "photo")
                    }
                    
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .containerRelativeFrame(.horizontal) { size, axis in
                    size * 0.2
                }
                VStack(alignment: .leading) {
                    Text(movie.title)
                        .bold()
                    Text(movie.yearOfRelease)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Button(action: {}) {
                        HStack(spacing: Dimens.spacingXsmall) {
                            Image(systemName: "plus")
                            Text("addToWatchlist")
                                .font(.footnote)
                                .fontWeight(.regular)
                        }
                    }
                    .padding(Dimens.spacingSmall)
                    .padding(.trailing, Dimens.spacingXsmall)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(.infinity)
                }
            }
            .onAppear {
                if movie.id == viewModel.moviesList.last?.id {
                    viewModel.loadMoreMovies()
                }
            }
        }
    }
}

#Preview {
    MoviesExplorerView()
}
