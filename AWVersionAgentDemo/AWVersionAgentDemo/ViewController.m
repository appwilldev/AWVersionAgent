//
//  ViewController.m
//  AWVersionAgentDemo
//
//  Created by Heyward Fann on 3/5/13.
//  Copyright (c) 2013 Appwill. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 50)];
    label.text = @"Press Home to send app to background.";
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
