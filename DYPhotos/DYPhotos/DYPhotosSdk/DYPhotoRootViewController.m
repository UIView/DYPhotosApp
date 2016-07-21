//
//  DYPhotoRootViewController.m
//  DYPhotos
//
//  Created by Yahui Duan on 16/7/20.
//  Copyright © 2016年 nimo. All rights reserved.
//

#import "DYPhotoRootViewController.h"
#import "DYAssetCollectionViewController.h"
#import "DYPhotoModel.h"

@import Photos;

@interface DYPhotoRootViewController ()

@end

@implementation DYPhotoRootViewController

+ (DYPhotoRootViewController *)sharePhotoInstantiation{
    DYPhotoRootListViewController *shareVC =[[DYPhotoRootListViewController alloc] init];
    DYPhotoRootViewController *tempPhotoNav=[[DYPhotoRootViewController alloc] initWithRootViewController:shareVC];
    return tempPhotoNav;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

// Photo List View Controller
@interface DYPhotoRootListViewController ()<UITableViewDelegate,UITableViewDataSource,PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) NSMutableArray *sectionFetchResults;
@property (nonatomic, strong) NSMutableArray *fetchResults;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DYPhotoRootListViewController

static NSString * const AllPhotosReuseIdentifier = @"DYRootPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

static NSString * const AllPhotosSegue = @"showAllPhotos";
static NSString * const CollectionSegue = @"showCollection";

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    UITableView *tempTableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tempTableView.delegate=self;
    tempTableView.dataSource=self;
    [self.view addSubview:tempTableView];
    self.tableView=tempTableView;
    [self loadTempTableData];
}

#warning Need to optimize
- (void)loadTempTableData {
    
    PHCachingImageManager *cachImageManager= [[PHCachingImageManager alloc] init];
    self.sectionFetchResults =[NSMutableArray array];
    
    // Create a PHFetchResult object for each section in the table view.
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    [self loadTempTableRowData:allPhotos withImageManager:cachImageManager withCollection:nil];

    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    NSIndexSet *indexSet =[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, smartAlbums.count)];
    NSArray *photoFetchResults=@[];
    
    for (int i=0; i<smartAlbums.count; i++) {
        PHAssetCollection *collection = smartAlbums[i];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [self loadTempTableRowData:assetsFetchResult withImageManager:cachImageManager withCollection:collection];
    }
    for (int i=0; i<topLevelUserCollections.count; i++) {
        PHAssetCollection *collection = topLevelUserCollections[i];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [self loadTempTableRowData:assetsFetchResult withImageManager:cachImageManager withCollection:collection];
    }
    // Store the PHFetchResult objects and localized titles for each section.
//    self.sectionFetchResults = @[allPhotos, smartAlbums, topLevelUserCollections];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [self.tableView reloadData];
}

-(void)loadTempTableRowData:(PHFetchResult *)assetsFetchResult withImageManager:(PHCachingImageManager *)cachImageManager withCollection:(PHAssetCollection *)collection{
    if (assetsFetchResult.count==0) {
        return ;
    }
    DYPhotoModel *photoModel=[[DYPhotoModel alloc] init];
    photoModel.assetCollection=collection;
    photoModel.assetsFetchResult=assetsFetchResult;
    photoModel.photoGrupName=collection.localizedTitle;
    photoModel.imageCount=[NSString stringWithFormat:@"%@",@(assetsFetchResult.count)];
    PHAsset *asset=assetsFetchResult[0];
    __weak typeof(self) weakSelf = self;
    [cachImageManager requestImageForAsset:asset
                                targetSize:CGSizeMake(150, 150)
                               contentMode:PHImageContentModeAspectFill
                                   options:nil
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 // Set the cell's thumbnail image if it's still showing the same asset.
                                 photoModel.thumbnailImage = result;
                                 __strong typeof(weakSelf) strongSelf = weakSelf;
                                 [strongSelf.sectionFetchResults addObject:photoModel];
                             }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = self.sectionFetchResults.count;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RHLibraryGroupTableViewCell *cell = nil;
    DYPhotoModel *photoModel = self.sectionFetchResults[indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier];
    if (cell==nil) {
        cell=[[RHLibraryGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AllPhotosReuseIdentifier];
    }
    [cell setCellModel:photoModel];
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DYAssetCollectionViewController *assetVC =[[DYAssetCollectionViewController alloc] init];
    [self.navigationController pushViewController:assetVC animated:YES];
}
#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [self.sectionFetchResults mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [self.sectionFetchResults enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            
            if (changeDetails != nil) {
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:[changeDetails fetchResultAfterChanges]];
                reloadRequired = YES;
            }
        }];
        
        if (reloadRequired) {
            self.sectionFetchResults = updatedSectionFetchResults;
            [self.tableView reloadData];
        }
        
    });
}

#pragma mark - Actions

- (IBAction)handleAddButtonItem:(id)sender {
    // Prompt user from new album title.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Album Name", @"");
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSString *title = textField.text;
        if (title.length == 0) {
            return;
        }
        
        // Create a new album with the title entered.
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error creating album: %@", error);
            }
        }];
    }]];
    
    [self presentViewController:alertController animated:YES completion:NULL];
}

@end

#pragma mark - RHLibraryGroupTableViewCell

@interface RHLibraryGroupTableViewCell ()

@property (nonatomic, weak) DYPhotoModel *assetsGroup;

@end

@implementation RHLibraryGroupTableViewCell

-(void)setCellModel:(DYPhotoModel *)assetsGroup
{
    self.assetsGroup            = assetsGroup;
    
    self.imageView.image        = assetsGroup.thumbnailImage;
    self.textLabel.text         = assetsGroup.photoGrupName;
    self.detailTextLabel.text   = assetsGroup.imageCount;
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle         = UITableViewCellSelectionStyleNone;
    
}

@end