//
//  JFFourSquarePlacesViewController.h
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 19/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JFFoursuareAutocompletePlace.h"

@protocol JFFourSquarePlacesViewControllerDelegate;

@interface JFFourSquarePlacesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

/*!
 Contains the latitude delta taht will defines the zoom level of the map.
 */
@property (assign, nonatomic) double                                   latitudeDelta;

/*!
 Contains the lonitude delta taht will defines the zoom level of the map.
 */
@property (assign, nonatomic) double                                   lonitudeDelta;

/*!
 Delegate of JFFourSquarePlacesViewController.
 */
@property (weak, nonatomic) id <JFFourSquarePlacesViewControllerDelegate>  delegate;

//Methods for dismissing this viewcontroller.
- (IBAction)close:(id)sender;
- (IBAction)done:(id)sender;

@end

@protocol JFFourSquarePlacesViewControllerDelegate <NSObject>

/**
 * This will get called when user dismissing the JFFourSquarePlacesViewController.
 *
 * @param selectedPlace an JFFoursuareAutocompletePlace object that is pass back to the caller.
 */
- (void)JFFourSquarePlacesViewControllerDismissed:(JFFoursuareAutocompletePlace*)selectedPlace;

@end