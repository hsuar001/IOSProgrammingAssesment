//
//  LookUpViewController.m
//  IOSProgrammingAssesmentV1
//
//  Created by Humberto Suarez on 3/2/16.
//  Copyright © 2016 Humberto Suarez. All rights reserved.
//

#import "LookUpViewController.h"
#import "Acronysm.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>

static NSString * const BaseURLString =@"http://www.nactem.ac.uk/software/acromine/";

@interface LookUpViewController ()
@property (nonatomic,strong) NSMutableArray * responseArray;
@end

@implementation LookUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)LookUpButtonPressed:(id)sender
{
    
    NSDictionary *params = @ {@"sf" :self.lookUpTextField.text };
    NSString *urlString = [NSString stringWithFormat:@"%@dictionary.py",BaseURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer =[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    self.responseTextView.text = @"";
    [self.lookUpTextField resignFirstResponder];
    self.responseArray = [NSMutableArray array];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

    [manager GET:url.absoluteString parameters:params progress:nil
         success:^(NSURLSessionTask *task, id responseObject)
    {
        
        NSError* error;
        
        if(responseObject!=nil){
            NSArray* json = [NSJSONSerialization
                                  JSONObjectWithData:responseObject //1
                                  options:kNilOptions
                                  error:&error];
            NSLog(@"JSON: %@", json);
            if(json.count >0)
            {
                Acronysm * acr;
                for(NSDictionary *dic in json)
                {
                    NSArray *lfs = [dic objectForKey:@"lfs"];
                    for(NSDictionary *lfsDict in lfs)
                    {
                        acr = [self parseJSONObjectWithDict:lfsDict];
                        [self.responseArray addObject:acr];
                    }
                }
                //[self parseJSONObjectWithJson:json];
            }
            for(Acronysm*a in self.responseArray)
            {
                self.responseTextView.text = [self.responseTextView.text stringByAppendingString:@"\n"];
                self.responseTextView.text = [self.responseTextView.text stringByAppendingString:[self formatStringFromAcronysm:a]];
            }
            self.responseArray = nil;;
            [hud hide:YES];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [hud hide:YES];
        self.responseTextView.text = error.description;
        NSLog(@"Error: %@", error);
    }];
    
}
-(Acronysm*)parseJSONObjectWithDict:(NSDictionary*)lfsDict
{

    Acronysm *acr  = nil;
    if(lfsDict!= nil)
    {
        acr = [[Acronysm alloc]init];
        acr.vars = [[NSMutableArray alloc]init];
        acr.freq =  [lfsDict objectForKey:@"freq"];
        acr.lf = [lfsDict objectForKey:@"lf"];
        acr.since = [lfsDict objectForKey:@"since"];
        
        NSArray *vars = [lfsDict objectForKey:@"vars"];
        for(NSDictionary * dic in vars)
           [acr.vars addObject:[self parseJSONObjectWithDict:dic]];
    }
    return acr;
}
-(NSString*)formatStringFromAcronysm:(Acronysm*)acr
{
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@\n  freq:%@  since:%@",acr.lf,acr.freq,acr.since];
    if([acr.vars count]>0)
        [result appendString:@"\nVariation"];
        
    for(Acronysm* acrVar in acr.vars)
    {
        [result appendFormat:@"\n     %@",[self formatStringFromAcronysm:acrVar]];
    }
    return result;
}
@end
