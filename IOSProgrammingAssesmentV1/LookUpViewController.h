//
//  LookUpViewController.h
//  IOSProgrammingAssesmentV1
//
//  Created by Humberto Suarez on 3/2/16.
//  Copyright © 2016 Humberto Suarez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LookUpViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *lookUpTextField;
- (IBAction)LookUpButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;

@end
