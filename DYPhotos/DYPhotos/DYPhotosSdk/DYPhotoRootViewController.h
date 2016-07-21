//
//  DYPhotoRootViewController.h
//  DYPhotos
//
//  Created by Yahui Duan on 16/7/20.
//  Copyright © 2016年 nimo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DYPhotoModel;

@interface DYPhotoRootViewController : UINavigationController
+ (DYPhotoRootViewController *)sharePhotoInstantiation;
@end

@interface DYPhotoRootListViewController : UIViewController

@end

@interface RHLibraryGroupTableViewCell : UITableViewCell
// 更新cell 的布局
-(void)setCellModel:(DYPhotoModel *)assetsGroup;

@end