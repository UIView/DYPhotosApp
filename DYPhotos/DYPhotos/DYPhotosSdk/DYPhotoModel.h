//
//  DYPhotoModel.h
//  DYPhotos
//
//  Created by Yahui Duan on 16/7/20.
//  Copyright © 2016年 nimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAssetCollection;
@class PHFetchResult;
@class UIImage;

@interface DYPhotoModel : NSObject
@property UIImage *thumbnailImage;
@property NSString *photoGrupName;
@property NSString *imageCount;
@property PHAssetCollection *assetCollection;
@property PHFetchResult *assetsFetchResult;

@end
