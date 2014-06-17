//
//  mwpAppDelegate.h
//  mwp
//
//  Created by richie on 14-6-17.
//  Copyright (c) 2014年 richie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface mwpAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
