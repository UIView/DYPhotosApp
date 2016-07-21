//
//  ViewController.m
//  DYPhotos
//
//  Created by Yahui Duan on 16/7/20.
//  Copyright © 2016年 nimo. All rights reserved.
//

#import "ViewController.h"
#import "DYPhotoRootViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openPhotosAction:(id)sender {
    DYPhotoRootViewController *shareVC =[DYPhotoRootViewController sharePhotoInstantiation];
    [self presentViewController:shareVC animated:YES completion:^{
    }];
}

@end
