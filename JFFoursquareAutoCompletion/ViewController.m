//
//  ViewController.m
//  JFFoursquareAutoCompletion
//
//  Created by siddarth chaturvedi on 18/12/13.
//  Copyright (c) 2013 JustUnfollow. All rights reserved.
//

#import "ViewController.h"
#import "JFFoursuareAutocompletePlace.h"

@interface ViewController ()

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.geoCoder = [[CLGeocoder alloc] init];
    
    self.locationLabel.adjustsFontSizeToFitWidth = YES;
    self.locationLabel.minimumScaleFactor = 0.5;
}


- (IBAction)openMapView:(id)sender {
    
    JFFourSquarePlacesViewController *viewController = [[JFFourSquarePlacesViewController alloc] initWithNibName:@"JFFoursquareViewController" bundle:nil];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - JFFourSquarePlacesViewController delegate.

- (void)JFFourSquarePlacesViewControllerDismissed:(JFFoursuareAutocompletePlace*)selectedPlace {
    
    if(selectedPlace.name) {
        self.locationLabel.text = [selectedPlace placeDiscription];
    } else {
        //If JFFoursuareAutocompletePlace don't have any name that means it is selcted by taping it on the map.
        //So in that case reverse geocode that particular location.
        [self.activityView startAnimating];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:selectedPlace.latitude
                                                         longitude:selectedPlace.longitude];
        [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if(!error) {
                CLPlacemark *placeMark = (CLPlacemark*)[placemarks objectAtIndex:0];
                self.locationLabel.text = [self adressString:placeMark];
                [self.activityView stopAnimating];
            }
        }];
    }
}

-(NSString*)adressString:(CLPlacemark*)placemark {
    
    NSMutableString *description = [[NSMutableString alloc] initWithString:placemark.name];
    if(placemark.locality && ![placemark.locality isEqualToString:@""]) {
        [description appendFormat:@", %@",placemark.locality];
    }
    if(placemark.country && ![placemark.country isEqualToString:@""]) {
        [description appendFormat:@", %@",placemark.country];
    }
    return description;
}

@end
