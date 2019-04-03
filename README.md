# An Illustration of How To Build A Simple App With Reasonable Architecture

> Background: I am going to build a simple app to simulate the Direct Message function behavior of the official Twitter app, I would like to design a well-developed layered architecture, including UI layer, Persistence Layer, Network Layer, etc. This repo is all about how and why I build like this.

***A PLAYGROUND FOR IMPROVING ARCHITECTURE SKILL***

***JUST FOR SELF-RECORD PURPOSE***

##  Here's what I said about my design and implementation:

Because I want this app could be developed and maintained for a long term, so it's important to start with the architectural design.

### Network Layer
First of all, I would like to talk about the network layer. I designed multiple layers of abstraction for the network layer and used the POP approach to make the network layer more flexible. I have constructed a corresponding `Request` object for each Endpoint request, which adheres to the `EndpointRequest` protocol and could be set up easily, whereas `EndpointRequest` is used by `TWEndpointServiceImpl` class, and the `TWEndpointServiceImpl` is an implementation of `TWEndpointService` protocol which performs a real network request internally. `TWEndpointServiceImpl` is used in `TWEndpointRequestOperation`, and the ability of multithreading could be easily used through the NSOperation, which is convenient for requesting network data. The developers actually invokes categories of the `TWEndpointAPIManager` class to request newtork data, and the `TWEndpointAPIManager` conveniently isolating all the endpoint requests. In particular, because I couldn't get valid keys from Twitter, I mocked my requests data in these cases:
* Followers: TwEndpointAPIManager+FollowerListRequest.m 
* Current User: TWGlobalConfiguration.m

### Persistence Layer 

And for the data persistence layer, I chose Core Data technology. In Core Data, We can design flexible models and build relationships between them. With the help of NSPredicate, we can easily do associated lookup. Core Data is a good data persistence framework, but there is one drawback, I think, is that all of its operations depend directly on NSManagedObject, NSManagedContext and KVC, any developers could accidentally missetting a property in anywhere, and once the save method is called, it will be persisted to the database. In addition, if you want to replace Core Data with another data persistence framework in the future, such as Realm, sqlite, or a new tool in the future, it would be difficult to replace Core Data because of the coupling of Core Data APIs. So, based on the above considerations, I spent about one day designing a data persistence layer protocol that included generic operations on data persistence and accepted only plain objects, not NSManagedObjects. Within the framework, NSManagedObjects and plain objects are converted to and from each other through the runtime, and as a result, I hide all the implementation details with Core Data under the data persistence layer I designed. Because the operations are common objects, you can avoid the problems of NSManagedObject being mishandled and can be easily replaced in the future.

### UI Layer

As far as the UI layer is concerned, because in this situation, I only want to use the framework that comes with the system, so I can't use some tools like ReactiveCocoa to help with data binding. For simplicity and limited time reason, I used a one-way data flow pattern similar to React + Redux, treating ViewController as a View. Each ViewController contains a Action object that responds to the occurrence of the corresponding event, and the ViewController provides render methods that are invoked by the Action object to implement a simple one-way data flow, although I have to admit that this piece of implementation is somewhat crude. If I have enough time, I could do it better. In the past, I used to use code + AutoLayout to build the UI, but this time I used storyboard to construct all the UIs because of limited time. For a multiple developers project, storyboard may not be the best solution, because it can cause a lot of git conflicts and problems with merging code, but Apple is constantly optimizing Storyboard, so it might be a good choice in the immediate future

A lot of protocols were used throughout the project, of course, because the outdated Objective-C doesn't make the most power of Protocol, and I'm sure it would be better if it were Swift :)

### Log Service

The core of Log Service is a class named TWLogService, it handles observers registers and dispatch the specific log information to observers which observed the log level, on the queue of Log Service itself, with concurrent behaviour, obviously, the Log Service guarantee the thread-safe issue. Now the Foundation only provides a Console Printer which cares about all types of log levels ( Debug, Info, Warn, Error, Fatal ), it receive information then print them onto the console. A full function, powerful logger can be implemented under the Log Server mechanism.

Log Service provide a module named `TWRemoteLogReporter` to collect those logs tagged as `fatal` and `error` ( by registering via using `TWLogService.registerObserver(_ :observer, logLevel: xxx)` ), it would use its internal `TWRemoteLogPersistenceStrategy` implementation to append logs to pending queue in memory first, and persist the logs to disk if the pending queue in memory hits the max count you assign to, then retrieve them from disk when logs in disk reach water line. The `TWRemoteLogPersistenceStrategy` implementation should at least provide two layers of buffer structure, one in memory, and another one in disk for reliability guarantee purpose. `TWRemoteLogReporter` doesn't care about how `TWRemoteLogPersistenceStrategy` implementation implementes the persistence logic, only cares about if it reach water line, when that moment comes, receive those persisted data from `TWRemoteLogPersistenceStrategy` implementation, then send them to your remote log service. The default `TWRemoteLogPersistenceStrategy` implementation in this playground is using item counts as standard, you could implement an implementation with binary standard if you need one.

### Dependency Injection

Introduce a very simple dependency injection module in this section, this simple dependency injection module handles the initialization of dependency instance ( entity ), no matter the instance is singleton or normal one, provides some very useful and convenient macros to developers.

If developer wants to mark a class as dependency instance, which means dependency injection module can handle with its initialization, just make this class conforms to `TWDependencyInstance` protocol, implement the required methods, declare the class as a dependency instance via `MARK_AS_DEPENDENCY_INJECTION_ENTITY` marco, an example likes below:

```objc
// ClassA.h
@interface ClassA : NSObject <TWDependencyInstance>

...

@end

// ClassA.m

@implementation ClassA

MARK_AS_DEPENDENCY_INJECTION_ENTITY(ClassA);

+ (instancetype)dependencyInstance {
    return [[self alloc] init]; 
}

+ (TWDependencyInstanceType)dependencyInstanceType {
    return TWDependencyInstanceNormalType;
}

...

@end

```

Above codes make a class conforming to `TWDependencyInstance` protocol, and dependency injection module knows how to return this entity now. For users, they can use another macro to get the injected object with a very easy way:

```objc
// ClassB.m

@interface ClassB ()

@property (nonatomic, strong) ClassA *instance;

@end

@implementation ClassB


- (void)someMethod {
    [self.instance someMethodInClassA]; // self.instance is injected by dependency injection automaticlly
}

DEPENDENCY_INJECTION_PROPERTY(instance, ClassA);

@end

```

If we want to change the injected class with the same key for some reasons like testing or mocking purpose, we could create a class which inherit from original injected class, or we create a new class which has same interface with original one, then mark the newer one as dependency instance ( entity ) via `MARK_AS_DEPENDENCY_INJECTION_ENTITY` with original key, and comment the `MARK_AS_DEPENDENCY_INJECTION_ENTITY` macro in original class.

### Micro Service

Sometimes we need to initialize some services at the very beginning phrase, those service without user interface, just some univeral services we want to use later, `Log Service` introduced previously is one of the cases. To simplify this kind of requirement, I create this `Micro Service` module to handle with the scenario.

If the class meets the scenario, we can make it to conform with `TWMicroService` protocol, `TWMicroService` protocol contains some required static methods for configuration, and some instance methods for micro service lifecycle, each micro service should at least implement `start` method, this method will be called when the service be created.

The static methods of `TWMicroService` are configuration of the micro service, `serviceKey` is used for micro service finding, we can find a micro service with the correct micro service context. `isolateLevel` is used for isolating, if marked as `global`, it will be referred by the global mirco service context, or if it is marked `microApp`, it will be referred by the `microApp` scope context, every micro app could have its own micro service context, if the micro app wants to have some micro service just in its scope, the micro service should be marked as `microApp` isolate level. `initializeLevel` indicates when the micro service framework initialize the micro service, if it be marked as `lazy`, it will be created when the first time we find this micro service via `[context findService:xxx]`, or if it be marked as `immediately`, it will be created when the main app launch.

An example as follows:

```objc
// MicroServiceA.h

@interface MicroServiceA : NSObject <TWMicroService>

@end

// MicroServiceA.m

@implementation MicrServiceA

+ (NSString *)serviceKey {
    return NSStringFromClass(self);
}

+ (TWMicroServiceIsolateLevel)isolateLevel {
    return TWMicroServiceIsolateGlobalLevel;
}

+ (TWMicroServiceInitializeLevel)initializeLevel {
    return TWMicroServiceInitializeLazyLevel;
}

#pragma mark - TWMicroServiceLifeCycle

- (void)start {
    // some service start logic
    ...
}

@end

```

### Event Dispatcher

The event dispatcher is used for the event between `TWEventReceiver`s, like we introduced a micro service named `TWLogService` last section, we can get the instance of the micro service and then call the instance method of the micro service, for `TWLogService`, an example if we can to use the log service to log something, the flow may like:

```objc

[[GetGlobalServiceContext() findService:@"TWLogService"] receivedInformation:({
    TWLogInformation *object = [[TWLogInformation alloc] init];
    object.logLevel = TWLogLevelInfo;
    object.message = @"message of the log";
    object;
})];

```

Look, we still need to know some details of `TWLogService`, we need to get the reference of micro service `TWLogService`. If we want to just post event to somewhere, and we know somewhere can handle with the event, that will fix this problem.

`TWEventDispatcher` is also a micro service, in its `start` method, we collect all classes which conform to `TWEventReceiver` protocol, then we register them into `TWEventDispatcher`, each `TWEventReceiver` will declare which event name they can handle with, I strongly recommend user can distribute event name in a place, to avoid event name conflict. Then the receiver implements the `receivedEvent:` method to try to handle with the event which fit to the acceptable event name. Now, we can ignore the `TWLogService` details and post event via `TWEventDispatcher`.

`TWEventDispatcher` also has event dispatching pressure balance feature, inside the `TWEventDispatcher`, it contains several internal dispatchers, everytime `TWEventDispatcher` receives a event dispatch request, it will find the lowest pressure internal dispatcher, and the event will forward to that internal dispatcher, every internal dispatcher will use `NSOperationQueue` and `NSOperation` to execute tasks concurrently.

---

TODO:
- [ ] A well-developed, well-designed modularization framework, driven by a Router
- [ ] A straightforward, declarative one-way UI data binding framework
- [ ] Theme support
- [ ] High test coverage ratio
- [ ] Objective-C -> Swift
- [ ] A mock node.js service running on heroku, replace real Twitter API
