# Stubbilino

## Simple stubbing for Objective-C

```objective-c
NSObject<SBStub> *stub = [Stubbilino stubObject:[[NSObject alloc] init]];

[stub stubMethod:@selector(description)
       withBlock:^{ return @"Stubbilino is awesome!"; }];

expect(stub.description).to.equal(@"Stubbilino is awesome!");
```

## Getting started

Stubbilino allows you to selectively stub methods on an object, if you don't
provide a stub, the default implementation will be used.

```objective-c
UITableViewController *viewcontroller = [[UITableViewController alloc] init];
UITableViewCell *myCell = [[UITableViewCell alloc] init];

UITableViewController<SBStub> *stub = (id)[Stubbilino stubObject:viewcontroller];

[stub stubMethod:@selector(numberOfSectionsInTableView:)
       withBlock:^{ return 1; }];

[stub stubMethod:@selector(tableView:numberOfRowsInSection:)
       withBlock:^{ return 1; }];

[stub stubMethod:@selector(tableView:cellForRowAtIndexPath:)
       withBlock:^{ return myCell; }];

[viewcontroller.tableView reloadData];

NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

id cell = [viewcontroller.tableView cellForRowAtIndexPath:indexPath];

expect(cell).to.equal(myCell);
```

You can also remove the stubs once you're done.

```objective-c
[stub removeStub:@selector(numberOfSectionsInTableView:)];
```

Alternatively, you can also unstub the object, returning it to its
original state.

```objective-c
[Stubbilino unstubObject:stub];
```

### Class Methods

Class methods can also be stubbed.

```objective-c
Class<SBClassStub> uiimage = [Stubbilino stubClass:UIImage.class];

[uiimage stubMethod:@selector(imageNamed:)
          withBlock:^(NSString *name) { return myImage; }];
```

Make sure to unstub the classes once you're done.

```objective-c
[Stubbilino unstubClass:uiimage];
```

# License

Copyright (c) 2013 Robert Böhnke. This software is licensed under the MIT License.
