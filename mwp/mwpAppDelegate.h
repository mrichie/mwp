//
//  mwpAppDelegate.h
//  mwp
//
//  Created by richie on 14-6-17.
//  Copyright (c) 2014年 richie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface mwpAppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet NSMenu *status_menu;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)showPreference:(id)sender;
- (IBAction)saveAction:(id)sender;


@end

__strong NSStatusItem *status_item;
