//
//  HYViewController.m
//  HttpClient
//
//  Created by 465738515@qq.com on 12/21/2018.
//  Copyright (c) 2018 465738515@qq.com. All rights reserved.
//

#import "HYViewController.h"
#import "HttpClient.h"

@interface HYViewController ()

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [HttpClient GET:@"www.baidu.com" response:^(HttpResponse *response) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
