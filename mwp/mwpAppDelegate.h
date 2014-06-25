//
//  mwpAppDelegate.h
//  mwp
//
//  Created by richie on 14-6-17.
//  Copyright (c) 2014年 richie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface mwpAppDelegate : NSObject <NSApplicationDelegate>{
    __weak NSSegmentedControl *_scChangeWp;
    IBOutlet NSMenu *status_menu;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)showPreference:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)segControlClicked:(id)sender;


@property (weak) IBOutlet NSSegmentedCell *scChangeWP;
@property (weak) IBOutlet NSSegmentedControl *scChangeWp;
@end

__strong NSStatusItem *status_item;

int refreshTimeout = 0;

int activePaperIndex = 1;

int totalPaper = 17;

NSTimer *globalTimer;

const int segMin = 60;

const int segHour = 60 * 60;

const int segDay = 60 * 60 * 24;