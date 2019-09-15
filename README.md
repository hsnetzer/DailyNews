# DailyNews

DailyNews fetches articles from the New York Times API. To combat incessant news-checking, the app will only fetch new articles once per day per section. 

## Caveats

- When you exceed the API's rate limit, fetching articles fails silently in the current implementation.

## TODO

- Change the appearance of articles when they've been clicked on.
- Implement a way to reset the section list.
- Save articles and prevent them being deleted after 7 days.
- Create a richer UI for the articles list. 
