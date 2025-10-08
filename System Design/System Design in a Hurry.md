## [System Design in a Hurry](https://www.hellointerview.com/learn/system-design/in-a-hurry/introduction)

### A. Introduction

- Assembling the right pieces: you'll need to know some core concepts, key technologies, and common patterns. On this base, you'll establish a strategy or delivery framework for executing the interview.

![Overall Structure](1_overall_structure.png)


### Types of System Design Interviews
![4 types of software design interviews](2.4_types_of_software_design_interviews.png)

- ### Product Design

Sometimes called "Product Architecture" interviews, or ambiguously "System Design" interviews, are the most common type of system design interview.You'll be asked to design a system behind a product. For example, design the backend for a chat application, or the backend for a ride sharing application. Often these interviews are described in terms of a "use case" - for example, "design the backend for a chat application that supports 1:1 and group chats". Example Questions:
  - Design a ride-sharing service like Uber
  - Design a chat application like Slack
  - Design a social network like Facebook

- ### Infrastructure Design

Are less common than product design interviews. You'll be asked to design a system that supports a particular infrastructure use case. For example, design a message broker or a rate limiter. These interviews are deeper in the stack, your interviewer will be looking for more emphasis on system-level mastery (e.g. consensus algorithms, durability considerations) than high-level design. Example Questions:
  - Design a rate limiter
  - Design a message broker
  - Design a key-value store

- ### Object Oriented Design

Sometimes called "Low Level Design", are less common than product design interviews, but still occur at companies that use an object-oriented language like Java (Amazon is notable for these interviews). You'll be asked to design a system that supports a particular use-case, but the emphasis on the interview is assembling the correct class structure, adhering to SOLID principles, coming up with a sensible entity design, etc. For example, design a Parking Lot reservation system or a Vending Machine, but rather than breaking this problem down into services and describing the backend database you're instead asked to describe the class structure of a solution. We instead recommend [Grokking the Low Level Design Interview](https://www.educative.io/courses/grokking-the-low-level-design-interview-using-ood-principles). Example Questions:
  - Design a parking lot reservation system
  - Design a vending machine
  - Design an elevator control system

- ### Frontend Design

Are focused on the architecture of a complex frontend application. Are most common with specialized frontend engineering roles at larger companies. For example, you might be asked to design the frontend for a spreadsheet application or a video editor. We instead recommend you try [Great Frontend for both material and practice problems for frontend design interviews](https://www.greatfrontend.com/). Example Questions:
  - Design the frontend for a spreadsheet application
  - Design the frontend for a video editor

### Interview Assessment

Important: Deliver a working system.

- ### Problem Navigation

Asses your ability to navigate a complex problem. You should be able to **break down the problem** into smaller, more manageable pieces, **prioritize** the most important ones, and then **navigate** through those pieces to a solution. This is often the most important part of the interview. The most common ways that candidates fail with this competency are:
  - Insufficiently **exploring the problem** and **gathering requirements**.
  - **Focusing** on uninteresting/trivial aspects of the problem vs the **most important** ones.
  - **Getting stuck** on a particular piece of the problem and not being able to **move forward**.

- ### High-Level Design

With a problem broken down, wow you can **solve each of pieces**. This is where your knowledge of the **Core Concepts** comes into play. You should be able to **describe how you would solve each piece** of the problem, and **how those pieces fit together** into a cohesive whole. The most common ways that candidates fail with this competency are:
  - Not having a **strong understanding of the core concepts** to solve the problem.
  - Ignoring **scaling** and **performance** considerations.
  - "Spaghetti design" - a solution that is not **well-structured** and difficult to **understand**.

- ### Technical Excellence

You'll need to know about **best practices**, **current technologies**, and **how to apply them**. This is where your knowledge of the **Key Technologies** is important. You should be able to describe how you would use current technologies, with well-recognized patterns, to solve the problems. The most common ways that candidates fail with this competency are:
  - Not knowing about **available technologies**.
  - Not knowing **how to apply those technologies** to the problem at hand.
  - Not recognizing **common patterns** and **best practices**.

- ### Communication and Collaboration

Interviews are frequently **collaborative**, and your interviewer will be looking to see how you work with them to solve the problem. This will include your **ability to communicate complex concepts**, respond to **feedback** and **questions**, and in some cases **work together** with the interviewer to solve the problem. The most common ways that candidates fail with this competency are:
  - Not being able to **communicate complex concepts** clearly.
  - Being defensive or argumentative when receiving **feedback**.
  - Getting lost in the weeds and not being able to **work with the interviewer** to solve the problem.

---

### B. How to Prepare for System Design Interviews

- **Build a Foundation**

  1. Understand what a [system design interview](https://www.hellointerview.com/learn/system-design/in-a-hurry/introduction) is
  2. Choose a [delivery framework](https://www.hellointerview.com/learn/system-design/in-a-hurry/delivery)
  3. Start with the basics: [Core Concepts](https://www.hellointerview.com/learn/system-design/in-a-hurry/core-concepts), [Key Technologies](https://www.hellointerview.com/learn/system-design/in-a-hurry/key-technologies), and [Common Patterns](https://www.hellointerview.com/learn/system-design/in-a-hurry/patterns)

- **Practice Practice Practice**

  1. [Choose a question](https://www.hellointerview.com/learn/system-design/in-a-hurry/how-to-prepare)
  2. Read the requirements
  3. Try to answer on your own
  4. Read the answer key
  5. Put your knowledge to the test

---

### C. Delivery Framework

The delivery framework is a sequence of steps and timings we recommend for your interview. By structuring your interview in this way, you'll stay focused on the bits that are most important to your interviewer. An added benefit is that you'll have a clear path to fall back if you're overwhelmed.

![Recommended system design interview structure](3_system_design_interview_structure.png)

- ### Requirements (~5 minutes)

Get a clear understanding of the system that you are being asked to design. Break your requirements into two sections.

- **1. Functional Requirements**

Are your **"Users/Clients should be able to..."** statements. These are the **core features** of your system and should be the first thing you discuss with your interviewer. **Ask targeted questions** as if you were talking to a client, customer, or product manager ("does the system need to do X?", "what would happen if Y?") to arrive at a **prioritized list of core features**. For example, if you were designing a system like Twitter, you might have the following functional requirements:
  - Users should be able to post tweets
  - Users should be able to follow other users
  - Users should be able to see tweets from users they follow

Keep your requirements targeted! The main objective in the remaining part of the interview is to develop a system that meets the requirements you've identified -- so it's crucial to be strategic in your **prioritization**. Many of these systems have hundreds of features, but it's your job to **identify and prioritize the top 3**. Having a long list of requirements will hurt you more than it will help you and many top FAANGs directly evaluate you on your ability to **focus on what matters**.

- **2. Non-functional Requirements**

Are statements about the **system qualities** that are important to your users. These can be phrased as **"The system should be able to..."** or "The system should be..." statements. For example, if you were designing a system like Twitter, you might have the following non-functional requirements:
  - The system should be highly available, prioritizing availability over consistency
  - The system should be able to scale to support 100M+ DAU (Daily Active Users)
  - The system should be low latency, rendering feeds in under 200ms

It's important that non-functional requirements are put in the **context** of the system and, where possible, are **quantified**. For example, "the system should be low latency" is obvious and not very meaningful—nearly all systems should be low latency. "The system should have low latency search, < 500ms," is much more useful as it identifies the part of the system that most needs to be low latency and provides a target.

Here is a checklist of things to consider that might help you identify the most important non-functional requirements for your system. You'll want to identify the top 3-5 that are most relevant to your system.
1. **CAP Theorem**: Should your system prioritize **consistency** or **availability**? Note, **partition tolerance** is a given in distributed systems.
2. **Environment Constraints**: Are there any constraints on the environment in which your system will run? For example, are you running on a mobile device with limited battery life? Running on devices with limited memory or limited bandwidth (e.g. streaming video on 3G)?
3. **Scalability**: All systems need to scale, but does this system have unique scaling requirements? For example, does it have bursty traffic at a specific time of day? Are there events, like holidays, that will cause a significant increase in traffic? Also consider the read vs write ratio here. Does your system need to scale reads or writes more?
4. **Latency**: How quickly does the system need to respond to user requests? Specifically consider any requests that require meaningful computation. For example, low latency search when designing Yelp.
5. **Durability**: How important is it that the data in your system is not lost? For example, a social network might be able to tolerate some data loss, but a banking system cannot.
6. **Security**: How secure does the system need to be? Consider data protection, access control, and compliance with regulations.
7. **Fault Tolerance**: How well does the system need to handle failures? Consider redundancy, failover, and recovery mechanisms.
8. **Compliance**: Are there legal or regulatory requirements the system needs to meet? Consider industry standards, data protection laws, and other regulations.

- **3. Capacity Estimation**

We believe this is often unnecessary. Instead, perform calculations only if they will directly influence your design. In most scenarios, you're dealing with a large, distributed system – and it's reasonable to assume as much. When would it be necessary? Imagine you are designing a TopK system for trending topics in FB posts. You would want to estimate the number of topics you would expect to see, as this will influence whether you can use a single instance of a data structure like a min-heap or if you need to shard it across multiple instances, which will have a big impact on your design.

[Learning to estimate relevant quantities quickly](https://www.hellointerview.com/blog/mastering-estimation) will help you quickly reason through design trade-offs in your design.

- ### Core Entities (~2 minutes)

Identify and list the core entities of your system. This helps you to **define terms**, understand the **data central** to your design, and gives you a foundation to build on. These are the core entities that your **API will exchange** and that your system will **persist in a Data Model**. This is as simple bulleted list and explaining this is your first draft to the interviewer.

Why not list the entire data model at this point? Because you don't know what you don't know. As you design your system, you'll discover new entities and **relationships** that you didn't anticipate. By starting with a small list, you can quickly iterate and add to it as you go. Once you get into the high level design and have a clearer sense of exactly what state needs to update upon each request you can start to build out the list of relevant **columns/fields** for each entity.

For our Twitter example, our core entities are rather simple:
  - User
  - Tweet
  - Follow

A couple useful questions to ask yourself to help identify core entities:
  - Who are the **actors** in the system? Are they overlapping?
  - What are the **nouns or resources** necessary to satisfy the functional requirements?

Aim to choose **good names** for your entities.

- ### API or System Interface (~5 minutes)

Define the **contract** between your system and its users. This maps directly to the functional requirements you've already identified (but not always!). You will use this contract to guide your high-level design and to ensure that you're meeting the requirements you've identified.

You have a quick decision to make here -- which **API protocol** should you use?
- **REST (Representational State Transfer)**: Uses HTTP verbs (GET, POST, PUT, DELETE) to perform CRUD operations on resources. This should be your **default choice** for most interviews.
- **GraphQL**: Allows clients to specify exactly what data they want to receive, avoiding over-fetching and under-fetching. Choose this when you have diverse clients with different data needs.
- **RPC (Remote Procedure Call)**: Action-oriented protocol (like gRPC) that's faster than REST for service-to-service communication. Use for internal APIs when performance is critical.

Real-time features, you'll also need *WebSockets* or *Server-Sent Events*, but design your core API first.

For Twitter, we would choose REST and design our endpoints using our core entities as resources. Resources should be **plural nouns** that represent things in your system:

```
POST /v1/tweets
body: {
  "text": string
}

GET /v1/tweets/{tweetId} -> Tweet

POST /v1/users/{userId}/follows

GET /v1/feed -> Tweet[]
```

Notice how we use **plural resource names** (tweets, not tweet) and put the userId in the path for the follow endpoint since it's required to identify which user to follow. The tweet endpoint doesn't include userId because we get that from the **authentication token** in the request header.

Never rely on **sensitive information** like user IDs from request bodies when they should come from authentication. Always authenticate requests and derive the current user from the auth token, not from user input.

- ### Data Flow [Optional] (~5 minutes)

For some backend systems, especially **data-processing systems**, it can be helpful to describe the high level **sequence of actions or processes** that the system performs on the **inputs** to produce the desired **outputs**.

We usually define the data flow via a **simple list**. You'll use this flow to inform your high-level design in the next section. For a web crawler, this might look like:
  1. Fetch seed URLs
  2. Parse HTML
  3. Extract URLs
  4. Store data
  5. Repeat

- ### High Level Design (~10-15 minutes)

This consists of **drawing** boxes and arrows to represent the different components of your system and how they **interact**. **Components** are basic building blocks like servers, databases, caches, etc.

Don't over think this! Your primary goal is to design an architecture that **satisfies the API** you've designed and, thus, the **requirements** you've identified. In most cases, you can even go one-by-one through your **API endpoints** and build up your design sequentially to satisfy each one.

Stay focused! It's incredibly common for candidates to start layering on complexity too early, resulting in them never arriving at a complete solution. Focus on a relatively **simple design** that meets the **core functional requirements**, and then layer on complexity to satisfy the non-functional requirements in your deep dives section. It's natural to identify areas where you can add complexity, like caches or message queues, while in the high-level design. We encourage you to note these areas with a simple verbal callout and written note, and then move on.

As you're drawing your design, you should be talking through your **thought process** with your interviewer. Be explicit about how data flows through the system and what state (either in databases, caches, message queues, etc.) changes with each request, starting from API **requests** and ending with the **response**. When your request reaches your database or persistence layer, it's a great time to start **documenting** the relevant columns/fields for each entity. You can do this directly next to your database visually. This helps keep it close to the relevant components and makes it easy to evolve as you iterate on your design. No need to worry too much about types here.

Don't waste your time documenting every column/field in your schema. For example, your interviewer knows that a User table has a name, email, and password hash so you don't need to write these down. Instead, focus on the columns/fields that are particularly relevant to your design.

For our simple Twitter example, here is how you might build up your design, one endpoint at a time:


![High Level Design](4_high_level_design.png)

- ### Deep Dives (~10 minutes)

Now that you have a high-level design in place you're going to use the remaining 10 or so minutes of the interview to harden your design by
  (a) ensuring it meets all of your **non-functional requirements**
  (b) addressing **edge cases**
  (c) identifying and addressing **issues and bottlenecks** and
  (d) **improving** the design based on probes from your interviewer

So for example, one of our non-functional requirements for Twitter was that our system needs to scale to >100M DAU. We could then lead a discussion oriented around **horizontal scaling**, the introduction of **caches**, and **database sharding** -- updating our design as we go. Another was that feeds need to be fetched with low latency. We'd lead a discussion about **fanout-on-read** vs **fanout-on-write** and the use of caches.

A common mistake candidates make is that they try to talk over their interviewer here. Make sure you give your interviewer room to ask questions and probe your design. Chances are they have specific signals they want to get from you and you're going to miss it if you're too busy talking. Plus, you'll hurt your evaluation on communication and collaboration.
