//
//  ViewController.h
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 18/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFFourSquarePlacesViewController.h"

@interface ViewController : UIViewController <JFFourSquarePlacesViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel  *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *openButton;
- (IBAction)openMapView:(id)sender;

@end
