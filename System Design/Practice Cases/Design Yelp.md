The functional requirements are:

1. Users should be able to **search** for businesses by name, location (lat/long), and category
2. Users should be able to **view** businesses (and their reviews)
3. Users should be able to leave **reviews** on businesses (mandatory 1-5 star rating and optional text)

The scale of the system is:
    100M daily users,
    10M businesses

The constraints are:
    Each user can only leave one review per business


1. How will users be able to search for businesses?

The client will send the request to the Search Business endpoint, which could include the name, location, or category. The Application Server will handle the request through the Api Gateway. The Api Gateway will validate the request through different layers (Authentication, Authorization, Security, and Routing). If everything is fine, the request will be processed by the Search Service. The Search Service will be in charge of querying the Elasticsearch instance with all the parameters passed. If any result is returned, it will complete the data with the information in the Database.

2. How will users be able to view a businesses details and reviews?

The client will send a request to the View business api, providing the ID of the business. The View Service will be in charge of retrieving the data from the Database, by joining the information of the tables businesses, categories, reviews, and users. The response will include all the information about the Business and an array of all the Reviews.

3. How will users be able to leave reviews on businesses?

The client will send a POST request to the Reviews endpoint. The request will include the rating and, optionally, a comment. The Review Service will validate that the client can only post one review to the business. If the user has already posted a review to the business, the request will be denied.

4. How would you efficiently calculate and update the average rating for businesses to ensure it's readily available in search results and still accurate up to the minute?

We can apply the Change Data Capture (CDC) strategy. When a new review is posted, it will send a message to the Update Rating Queue (RabbitMW). The Update Rating Workers will be in charge of processing the Update Rating messages from the Queue. The workers will process the message in bulk, which means that they will consume more than 1 message at the same time, for example, they will take 10 messages. This will improve the performance in case one business is popular and is receiving too many reviews, instead of updating many times, it will be grouped in one update. We can use this sql query to update the avg_rating column: UPDATE business SET avg_rating = ( SELECT AVG(rating) FROM reviews WHERE business_id = {business_id}) WHERE id = {business_id}.

5. How would your bulk processing approach handle a situation where a very popular business receives hundreds of reviews per minute? What trade-offs exist between processing frequency and rating accuracy?

Adopting the Queue will ensure that the rating is accurate but it will mean that the workers will be updating the business table too frequently, which could impact the Search and View service, because it will cause latency while the services are waiting for the businesses table to be released. So in this case we can change the Worker by a Cron Job that runs every minute, this will group all the reviews per business and updates the avg_rating, so if there are to many reviews to a specific business, all of them will be grouped and at the end there will be only one update per business.

6. How would you modify your system to ensure that a user can only leave one review per business?

I would add, as a first step in the Review Service, a validation layer that checks if the user has already left a review for the business. If so, the request will be denied; otherwise, it will continue with the process. Another layer will be adding the unique index for the combination of business_id and user_id columns in the reviews table.

7. How would your system handle the case where a user wants to update their existing review rather than create a new one? What API design and database operations would you implement to support this functionality?

To handle this use case, it will require a new API endpoint, it will require the ID of the review, the rating and, optionally, the comment. This will be handled by the Update Review Service, and it will update the row in the Database.

8. How can you improve search to handle complex queries more efficiently?

We can include the avg_rating in Elasticsearch, so we can sort the results by the best rating. Also we can create shards based on region to speed up the search.

9. How would you modify your system to allow searching by predefined location names such as cities (e.g., 'San Francisco') or neighborhoods (e.g., 'Mission District')? Assume you have a finite list of supported location names.

I would have a predefined list of the locations with the latitude, longitude, and the name or description of the place. So the user could choose the location from the list and the latitude and longitude will be used to perform the search.


name: text
location: geo_point
category: keyword

{
  "properties": {
    "location": { "type": "geo_point" },
    "name": { "type": "text" },
    "category": { "type": "keyword" }
  }
}


GET your_index/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "name": "electra"
          }
        },
        {
          "term": {
            "category": "bookstore"
          }
        },
        {
          "geo_distance": {
            "distance": "5km",
            "location": {
              "lat": 16.6400278,
              "lon": -93.0890492
            }
          }
        }
      ]
    }
  },
  "sort": [
    {
      "_geo_distance": {
        "location": {
          "lat": 16.6400278,
          "lon": -93.0890492
        },
        "order": "asc",
        "unit": "km",
        "mode": "min",
        "distance_type": "arc"
      }
    }
  ],
  "script_fields": {
    "distance_km": {
      "script": {
        "source": "doc['location'].arcDistance(params.lat, params.lon) / 1000",
        "params": {
          "lat": 16.6400278,
          "lon": -93.0890492
        }
      }
    }
  }
}
