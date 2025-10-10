https://www.youtube.com/watch?v=xFeWVugaouk
Hello everybody and welcome back.

Today I'm excited to introduce the first episode of the systems design 3.0 question series. While I spend a lot of time on this channel talking about tiny things, today we will just be talking about tiny URL, not my Chad. So let's go ahead and get into it.

I'm trying out a new format today. Please give me all the feedback that you want in the comments section. I've tried to incorporate literally years of feedback that I've gotten from a lot of people to make this as clear and concise as possible. I don't want to go overboard, but I will explain things as we go. And please bear with me. Let's get into it.

For this video, we're going to stick with the minimum possible set of requirements for a service like **Tiny URL**. In practice, this means we need to support two features.
  - First, we need to be able to have a client **provide a URL** and then **pass them back a short URL**. These return short URLs can be configured with an **expiration time** after which point they can be reused with another long URL.
  - Next, if another client provides us with a **given short URL**, we need to be able to **redirect them to the original longer URL** that it maps to.

Notably, we will **not cover** a couple of other problems which we will leave for subsequent videos.
  - The first is going to be the paste **bin type** of functionality in which we allow users to provide long text content to store as opposed to URLs.
  - The latter is actually **counting** how many times that a given short URL has been clicked.

Fortunately, for this problem, I've been able to find some accurate **usage metrics** for the site bit. Wikipedia and their official blog. In their case,
  - users create 600 million short URLs per month, and
  - the site processes 10 billion clicks of their short URLs per month.

Converting these metrics to get **operation counts per second**, this means that we'd have
  - 228 creations per second with
  - 3,805 redirects per second.

We've mentioned so far that we want to be able to support the creation of 600 million short URLs per month. While these may be configured with expiration dates, let's go above and beyond and make sure that our URLs are configured in a way such that we've got plenty of **capacity to make short URLs**.
  - 600 million URLs per month comes out to 7.2 billion per year, meaning that over a 100 years, we might store 720 billion unique short URLs, assuming no purging of expired URLs from our storage.

If we configure our short URLs to use **8 characters from A to Z and 0 to 9**, that leaves us with **36 characters** to the power of 8, which is almost 3 trillion. This seems more than sufficient for our short URL suffixes.

At a high level, we need to **maintain a mapping between our long and short URLs**. This mapping gets updated over time as users create new URLs and queried as users provide a short URL to figure out the associated longer one. While we could keep a mapping like this completely in memory with a hashmap, that would mean that the data wouldn't be very durable in the event of component failures or restarts, given we're only handling a few thousand operations per second here. Using a database in order to maintain this mapping seems like a natural choice.

Let's think about an example schema here since we'll need this in the following section for some back of the envelope capacity estimates in our schema. We'll need the following fields.
  - The suffix of the short URL,
  - the entire long URL,
  - some sort of user ID field for the creator and
  - an expiry time using millie since epoch should suffice here.

If we estimate that a long URL is on average 50 characters, we can say that it takes 74 bytes per row of data. The breakdown here is a bite per character, eight characters in the short URL, 50 in the long one, and eight bytes for the user ID and the expiry time. Using our 74 bytes per row estimate in conjunction with our maximum 720 billion rows, we can see that at most we'd be storing **48 TB** of data.

The actual volume of requests that we're handling here is not super large. **Databases can often handle multiple thousands of reads per second**, especially if they're fairly simple, as they are in this case. the write operations become a bit less clear and we'll cover them in more depth later in this video.

Is it possible to handle all of these operations on a single beefy machine? Honestly, maybe. That being said, we'll discuss scaling this problem out a bit because we'd certainly be pushing the limits here. If we wanted to use more commodity hardware, it feels like a single digit number of database nodes should be able to do the trick.

Now, let's take a look into our design. You can see that we've got a few different components here.
  - First, we have a few **application servers** sitting behind a **load balancer** which can **roundroin requests** to them.
  - Next, we've got our **distributed database** which contains the before mentioned URL mappings table.
  - In terms of **APIs**, it's pretty simple.
    - When creating a URL, we go to the table and add an entry.
    - When we're looking to be directed, we simply find the corresponding entry for our short URL and issue an HTTP redirect to send the user to the long URL.
  - Note that read operations on these tables are an order of magnitude more common than writes based on the calculations that we did before. Hence, we want to optimize for those.
  - Finally, we've got a look aside **caching layer** here which enables us to avoid hotspots across our different Postgress instances by speeding up certain reads for popular short URLs.

The central piece of our problem here is the **key generation service** which is responsible for maintaining mappings from short URL to long URL. For now, we've opted to use a standard **Postgress** relational database here, which we'll cover more in depth in the deep dive section of the video.

Because we want this to be **distributed across many database nodes**, we can do so by assigning each a contiguous **range of the short URL** space. We can seed these by creating a row for all possible short URLs and an initial expiration time of zero so that any new attempts to create a short URL will succeed.

The following code represents the SQL statement that our application might run in order to **generate a new short URL**. Simply put, we look for the first row that we can find that has passed its expiration time and claim it for ourselves.

How do we ensure that all of our database nodes have **balanced load**? When creating a short URL, our application servers can just **randomly select one** of them.

Retrieving a URL should be pretty easy. All we need to do is find the short URL in our database and return the corresponding long URL if it's present and not expired. How do we know which database node to reach out to? We should probably **keep a static mapping of the key ranges per database node** cached on our application servers. We don't anticipate this mapping changing, but in the deep dive section, we can discuss what we might do if we wanted to make our service more adaptable.

Creating an **index** on our database table is a great way to ensure that we maximize our **query performance** in anticipation of common query patterns. Since we know that database reads will greatly outnumber database writes, we probably want to optimize for these.

In our case, the most common query is to find a particular long URL for a known short URL. This means that we should probably create a database index based on the short URL value. Internally, this means that the database sorts the rows based on the short URL so that we can use a **binary search** to speed up our queries that filter on this value.

Postgress uses **single leader asynchronous replication**. For each **shard**, there is one **leader**. All writes must go to the leader and from there they are **propagated asynchronously** over to the replicas. **Replicas** serve the purpose of making data durable as well as being able to serve read requests and increase the read throughput of our system. In the event of a leader **failure**, Postgress is able to promote one of the replicas to take over as the new leader. Note that because the leader is not waiting for responses from its replicas before accepting a write, it is possible that a leader fails before all of its data has been durably replicated. In this event, we may lose some data when a replica is promoted to be the new leader. At the end of the day, this is just a URL shortener, and data durability is best efforts.

While the majority of generated URLs are probably only going to be clicked a few times, a small number of them may be used thousands or even millions of times. For example, imagine that Mr. Beast uses a short URL to allow others to sign up for some giveaway. There's no way for us to anticipate which one of these short URLs are going to receive tons of traffic in advance. If we could, perhaps we could somehow put them all on their own separate database node. Since we can't, a better alternative is to use a **cache**. Because caches store data in memory, they can often handle more than an order of magnitude more requests than a typical disk based database. While the data here isn't as durable, it doesn't matter much since the database is our source of truth.

In our case, we can use a very simple and easy to implement **look aside caching strategy** in conjunction with **Redis**, an open-source memory based key value store. When a request comes in, we first check our cache for it. If it's there, great. Otherwise, we fetch from the database and have the application server place the value in the cache. Since we don't know in advance which short URLs will be hot, using a simple **least recently used replacement policy** should help ensure that we maximize hit rates while constraining how much memory we need to use.

If we make a very handwavy estimate that 1% of keys are responsible for 50% of the load in our system, this would mean that we would need around 480 GB of memory to serve 2,000 requests per second. Once again, this could probably be handled by a single beefy server. If we want a bit more breathing room, we could instead use a **Redis cluster**, which helps do the **distribution and load balancing of keys** for us. In this case, Redis could choose a partition for each database row based on taking a hash of its short URL value so that they're evenly distributed. We're now going to enter our deep dive section. Do you need to watch this to have a solid solution? I'd say no.

That being said, for engineers who actually want to understand the rationale behind the solution that I provided, as well as be able to justify their own in a systems design interview, this section may be quite useful. In the event that some of the terms that I'm using aren't entirely familiar to you, I'd highly recommend going through the systems design concepts videos on this channel.

Recall our URL claiming code from earlier in order to assign a short URL to a particular client. Note that databases are concurrent and as a result each database node may have many simultaneous requests to it in order to claim a URL.

Internally each query will be looping through rows and locking the first available one in order to update it. If one query is grabbing the lock on a row, another query will not be able to move past that row until the first one relinquishes the lock. Using **skip locked** in Postgress is a way to simply jump past any row that is actively locked and only consider subsequent ones. Since we don't care about which short URL we claim, this is totally fine.

Recall that in our Postgress table, we are manually performing random request routing from our application servers to our database nodes when claiming a URL. Instead, what we could do is use some sort of database that manages partitioning and routing for us automatically. Performing manual request routing seems silly as it probably adds a considerable amount of complexity to our application code.

In the event that we needed to **rebalance the key ranges** that each database node holds, things could become very complex. Since we need to notify application servers of the rebalance, there may be a period of time where they're reaching out to the wrong server to find information for a given short URL.

These types of **edge cases** are not trivial to deal with. Even though we're operating under the assumption that we're never rebalancing our key range, let's imagine that this was possible. Why don't we use some sort of extension for Postgress that allows it to be **horizontally scaled** so that we don't have to manage this ourselves? What about a database that not only performs request routing but even **automatically rebalances partitions** like **Cockroach DB**? While we could do these things, there's some nuance to it which depends on the implementation of the request routing and the software that we choose.

Note that we're just doing a select star limit one in the key claiming query that I provided. Depending on the implementation of the request routing, we may always send our requests to the first shard. If you look at the APIs of many distributed databases, very few of them provide a way to explicitly select which node you're sending a query to. We want to spread the load of these URL creations in order to avoid contention on the database nodes. So, we need to be sure that we're routing these requests properly.

It's probably much better to use a database that performs **request routing** for you, but you need to ensure that your requests are actually being evenly distributed to nodes. If we had to build request routing ourselves in a world where keys could be rebalanced, that would be very tough.

One example where we could use existing software to perform request routing is **Citus**, a **sharding extension for Postgress**. Since **each shard itself is represented as a Postgress table**, you can create many small shards relative to the number of database nodes. This means that your application server can request a list of all the shard tables and then choose one of them to query at random. Citus delegates one postgress node as the coordinator which knows where to route the request for the shard table. Therefore, you wouldn't have to implement any manual routing in your application. If we needed to redistribute load between the Postgress nodes, we can manually invoke Citus' functionality to move a shard from one worker to another without needing to make any changes on our application servers.

In the past, I've covered an approach to this problem in which we use a hashing or randomized approach to choose the short URL for a given long URL. For databases where we can't explicitly select a node at random to run our URL claiming query on, attempting to claim a random short URL should spread the load evenly across nodes in the cluster. That being said, there is a world in which that long URL has already been mapped, in which case we'll have a conflict and we'll need to find a new unclaimed short URL. Someone may now comment that we can just hash additional fields to reduce the chance of conflict.

Even if not very common, **conflicts** are a possibility given a limited number of short URLs and we'll need to handle them in our application logic. In this event, we could perform probing by having our application servers retry the request on the lexographically next short URL. To me, this just adds some additional code complexity where we probably don't need it. Though in reality, the chance of hash collisions are super low. Personally, I'd prefer to let the database figure out which URL to pick via one request, which we accomplish in our **key generation service**, but I see the case for both.

When I choose a database for these problems, I generally try to consider two things.
  - The first is the **index** that they use, and
  - the second is how you'd typically perform **replication** for them.

In the case of Postgress, that would be a **B-tree** with **single leader asynchronous replication**. Why did we choose this? Since we're looking for something **read optimized** here, I felt that a **B-tree based index** made the most sense. Of course, in practice, a good **LSM tree** based database is still going to serve reads faster than a bad B treebased one.

B trees read data by traversing to a single location on disk. On the contrary, LSM trees may search for a piece of data in a mem table as well as multiple SStable files on disk. For what it's worth, the LSM treebased index avoids grabbing locks when reading those immutable files, leading to potential performance benefits.

In our application, we're using single leader asynchronous replication, in which case we run the risk of losing some data on a failover. At the end of the day, do we really care? It's just a URL shortener. Would we be better off using a system with any other type of replication? Leaderless replication as used in **Cassandra** or Sila allows always available writing by avoiding long failovers of single leaders.

If a replica goes down, that's okay. Just write to other ones. In our case, if one of our Postgress leaders goes down for a few seconds, we won't be able to write to that key space until it falls over. It really doesn't matter though. If a leader goes down, we'll just write short URLs to our other shards. In the meantime, we can still perform reads from its replicas as well. Again, this is just a URL shortener. Temporary stale reads from replicas are totally fine. We don't need strong consistency. We could also use multiler replication. This enables low latency writers in geographically diverse regions.

Multiler replication comes at the cost of write conflicts when two users from different regions concurrently claim the same short URL. Dealing with resolving these isn't worth the headache here. However, we can still speed this up in a way that supports clients from many different regions. In our case, we could place a subset of the Postgress shard leaders in each region.

Our application servers could be biased to route URL creation and fetch requests to their own region. Cross region reads could be sped up by placing readonly replicas in each region with the caveat that they'll be a little bit further behind the leader due to extended physical distance.

Note that for the **caching** section, I went for the simplest approach possible with using **Redis** and **look aside caching**. Truthfully, I don't think the required throughput for this tiny URL is enough that we'd need anything crazier.

That being said, there are perhaps some optimizations that we could make. Read through caching would allow us to proxy the database from the cache on a cache miss, saving us an extra round trip to populate the cache from our server. That being said, we'd likely have to ditch Reddus and implement this using our own caching layer with an **embedded caching library** so that it knows what queries to send to the database.

Welcome back, everyone. I hope that you enjoyed this video. Um, I'm going to imagine that if I look at my YouTube analytics, probably like 3% of you got here. Uh, so congratulations on being Gigachads. Uh, not going to pander and tell you to like and subscribe. You do that if you want. If I'm ugly, then uh, you probably don't want to see my face much anymore. But I do hope that this was a good introduction to the new series that we're building. Please leave me any feedback or comments if there are ways that I can improve. I am certainly going to take them into account.
