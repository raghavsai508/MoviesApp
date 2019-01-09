# Movies APP
This app downloads the top 20 Popular Movies and has the ability to mark them as favorites and see the details of the movie.

# Features!

  - Load Popular Movies.
  - Mark movie as favorite.
  - Ability to delete from favorites list.
  - Detail of the movie.

### Movies Tab

This View Controller shows popular movies and limits to 20. When the user hits the refresh button it loads the next 20 movies. The user has ability to mark them as favorite.

### Favorites Tab

This ViewController is reponsible for showing all your favorite movies. A "Edit" mode button enables the user to delete favorite movies.

### Movie Detail Page

This ViewController is responsible for showing the details of the movie.

### Enabling the App to Work

  - In Constants.Swift file add www.themoviedb.org API key.
 ```sh
 struct MovieDBValues {
        static let APIKey = ""
    }
```

