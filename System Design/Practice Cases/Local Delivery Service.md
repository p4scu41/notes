The functional requirements are:

1. Customers should be able to query availability of items, deliverable in 1 hour, by location from nearby fulfillment centers.
2. Customers should be able to order items.

The scale of the system is:

100k items in catalog, 10k fulfillment centers, 1m orders per day

1. How will customers be able to query the availability of items within a *fixed distance* (e.g. 30 miles)?

The user will send a request to the items endpoint, providing the location, the Application Server will query the items that are in stock and are stored in a delivery center located within 30 miles of distance, it will use the location of the delivery center and calculate the distance of the user location.

2. How can we extend the design so that we only return items which can be delivered within *1 hour*?

Each delivery center can have an estimated distance where it can deliver within 1 hr. If the distance between the delivery center and the user is within this estimation it means that the item can be delivered. This result will be validated with a Travel estimation service to have a more realistic result
