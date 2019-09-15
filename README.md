# DailyNews

DailyNews fetches articles from the New York Times API. To reduce the urge to check the news multiple times a day, the app will only fetch new articles once per day per section. 

## Caveats

- When you exceed the API's rate limit, fetching articles fails silently in the current implementation.

## Hypothetical TODO

- Change the appearance of articles that you've already read.
- Implement a way to reset the section list.
- Have a way to save articles and prevent them being deleted after 7 days.
- Make sure the image isn't set after a cell has been reused.
