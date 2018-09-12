# An Illustration of How To Build A Simple App With Reasonable Architecture

**JUST FOR SELF-RECORD PURPOSE**

> Background: I am going to build a simple app to simulate the Direct Message function behavior of the official Twtter app, I would like to design a well-developed layered architecture, including UI layer, Persistence Layer, Network Layer, etc. This repo is all about how and why I build like this.

##  Here's what I said about my design and implementation:

Because I wanted this app could be developed and maintained for a long term, so it's important to start with the architectural design.

### Network Layer
First of all, I would like to talk about the network layer. I designed multiple layers of abstraction for the network layer and used the POP approach to make the network layer more flexible. I have constructed a corresponding `Request` object for each Endpoint request, which adheres to the EndpointRequest protocol and could be set up easily, whereas EndpointRequest is used by `TWEndpointServiceImpl` class, and the `TWEndpointServiceImpl` is an implementation of `TWEndpointService` protocol that performs a real network request internally. `TWEndpointServiceImpl` is used in `TWEndpointRequestOperation`, and the ability of multithreading could be easily used through the NSOperation, which is convenient for requesting network data. The developers actually invokes categories of the `TWEndpointAPIManager` class to request newtork data, and the `TWEndpointAPIManager` conveniently isolating all the endpoint requests. In particular, because I couldn't get a valid keys from Twitter, I mocked my requests data in these cases:
* Followers: TwEndpointAPIManager+FollowerListRequest.m 
* Current User: TWGlobalConfiguration.m

### Persistence Layer 

And for the data persistence layer, I chose Core Data technology, in Core Data. We can design flexible models and build relationships between them. With the help of NSPredicate, we can easily do associated lookup. Core Data is a good data persistence framework. But there is one drawback, I think, is that all of its operations depend directly on NSManagedObject, NSManagedContext and KVC, any developers could accidentally missetting a property in anywhere, and once the save method is called, it will be persisted to the database. In addition, if you want to replace Core Data with another data persistence framework in the future, such as Realm, sqlite, or a future new tool, it would be difficult to replace Core Data because of the coupling of Core Data. So, based on the above considerations, I spent about a day designing a data persistence layer protocol that included generic operations on data persistence and accepted only plain objects, not NSManagedObjects. Within the framework, NSManagedObject and plain objects are converted to and from each other through the runtime, and as a result, I hide all the implementation details with Core Data under the data persistence layer I designed. Because the operations are common objects, you can avoid the problem of NSManagedObject being mishandled and can be easily replaced in the future.

### UI Layer

As far as the UI layer is concerned, because in this situation, I only want to use the framework that comes with the system, so I can't use some tools like ReactiveCocoa to help with data binding. For simplicity and limited time reason, I used a one-way data flow pattern similar to React + Redux, treating ViewController as a View. Each ViewController contains a Action object that responds to the occurrence of the corresponding event, and the ViewController provides render methods that are invoked by the Action object to implement a simple one-way data flow, although I have to admit that this piece of implementation is somewhat crude. If I have enough time, I could do it better. In the past, I used to use code + AutoLayout to build the UI, but this time I used storyboard to construct all the UIs because of time. For multiple developers projects, storyboard may not be the best choice, because it can cause a lot of git conflicts and cause problems with merging code, but Apple is constantly optimizing Storyboard, so it might be a good choice for now. 

A lot of protocol is used throughout the code, of course, because the outdated Objective-C doesn't make the most of Protocol, and I'm sure it would be better if it were Swift :)
