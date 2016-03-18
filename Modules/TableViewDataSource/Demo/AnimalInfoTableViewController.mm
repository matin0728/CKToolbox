//
//  AnimalInfoCollectionViewController.m
//  CKToolbox
//
//  Created by Jonathan Crooke on 17/01/2016.
//  Copyright (c) 2016 Jonathan Crooke. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AnimalInfoTableViewController.h"
#import "AnimalInfo.h"
#import "AnimalComponent.h"
#import "AnimalCellConfiguration.h"
#import <ComponentKit/ComponentKit.h>
#import "CKCollectionViewTransactionalDataSource.h"
//#import "CKCollectionViewSupplementaryDataSource.h"
#import "CKTransactionalComponentDataSourceConfiguration.h"

@interface AnimalInfoTableViewController () <CKComponentProvider, CKSupplementaryViewDataSource>

@property (nonatomic, strong) NSMutableArray <AnimalInfo *> *animals;
@property (nonatomic, strong) CKCollectionViewTransactionalDataSource *dataSource;

@end

@implementation AnimalInfoTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.delegate = self;

  self.dataSource = [[CKCollectionViewTransactionalDataSource alloc]
                     initWithCollectionView:self.collectionView
                     supplementaryViewDataSource:self
                     configuration:self.configuration];

//  self.refreshControl = ^{
//    UIRefreshControl *control = [[UIRefreshControl alloc] init];
//    [control addTarget:self action:@selector(_loadAnimals) forControlEvents:UIControlEventValueChanged];
//    [self.collectionView addSubview:control];
//    return control;
//  }();

  [self _loadAnimals];
}

//- (void)loadView {
//    [super loadView];
//    self.collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    self.collectionView.
//}

- (CKTransactionalComponentDataSourceConfiguration*)configuration
{
  CKComponentFlexibleSizeRangeProvider *provider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:
                                                    CKComponentSizeRangeFlexibleHeight];
  CKSizeRange sizeRange = [provider sizeRangeForBoundingSize:self.collectionView.bounds.size];
  return [[CKTransactionalComponentDataSourceConfiguration alloc]
          initWithComponentProvider:[self class]
          context:nil
          sizeRange:sizeRange];
}

#pragma mark Models

- (void)_loadAnimals
{
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    NSMutableSet *removed = [NSMutableSet set];
    for (NSUInteger i = 0; i < self.animals.count; ++i) {
      [removed addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }

    self.animals = [AnimalInfo allAnimals].mutableCopy;
    NSMutableDictionary <NSIndexPath *, AnimalInfo *> *dictionary = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < self.animals.count; ++i) {
      dictionary[[NSIndexPath indexPathForItem:i inSection:0]] = self.animals[i];
    }

    CKTransactionalComponentDataSourceChangesetBuilder *builder = [CKTransactionalComponentDataSourceChangesetBuilder new];
    [builder withInsertedSections:[NSIndexSet indexSetWithIndex:0]];
    [builder withInsertedItems:dictionary];
    [builder withRemovedItems:removed.count ? removed : nil];
    [builder withRemovedSections:removed.count ? [NSIndexSet indexSetWithIndex:0] : nil];

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.dataSource applyChangeset:builder.build
                                 mode:CKUpdateModeAsynchronous userInfo:nil];
//      [self.refreshControl endRefreshing];
    });
  });
}

#pragma mark Component Provider

+ (CKComponent *)componentForModel:(AnimalInfo *)model context:(id<NSObject>)context
{

    return [CKCompositeComponent
            newWithComponent:[CKStackLayoutComponent
                              newWithView:{}
                              size:{}
                              style:{
                                  .alignItems = CKStackLayoutAlignItemsStretch
                              }
                              children:{
                                  {
                                      [CKLabelComponent
                                       newWithLabelAttributes:{
                                           .string = @"这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试",
                                           .font = [UIFont systemFontOfSize:30]
                                       }
                                       viewAttributes:{}
                                       size:{}]

                                  },
                                  {
                                      [CKLabelComponent
                                       newWithLabelAttributes:{
                                           .string = @"空间里面，文字介绍可以直接点击进入而不需要弹开一个新页面",
                                           .font = [UIFont systemFontOfSize:26],
                                           .color = [UIColor greenColor]
                                       }
                                       viewAttributes:{}
                                       size:{}]

                                  }

                              }]];
  return [AnimalComponent newWithAnimal:model];
}

//- (CGFloat)tableView:(UICollectionView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  return [self.dataSource sizeForItemAtIndexPath:indexPath].height;
//}
//
//- (BOOL)tableView:(UICollectionView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//	  return YES;
//}

//- (NSArray<UICollectionViewRowAction *> *)tableView:(UICollectionView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  UICollectionViewRowAction *delAction = [UICollectionViewRowAction rowActionWithStyle:UICollectionViewRowActionStyleDestructive
//                                                                       title:NSLocalizedString(@"Delete", nil)
//                                                                     handler:^(UICollectionViewRowAction * _Nonnull action,
//                                                                               NSIndexPath * _Nonnull indexPath)
//  {
//    CKTransactionalComponentDataSourceChangesetBuilder *builder = [CKTransactionalComponentDataSourceChangesetBuilder new];
//    [builder withRemovedItems:[NSSet setWithObject:indexPath]];
//    [self.dataSource applyChangeset:builder.build mode:CKUpdateModeSynchronous userInfo:nil];
//    [self.animals removeObjectAtIndex:indexPath.item];
//  }];
//
//  UICollectionViewRowAction *moreInfo = [UICollectionViewRowAction rowActionWithStyle:UICollectionViewRowActionStyleNormal
//                                                                      title:NSLocalizedString(@"More Info", nil)
//                                                                    handler:^(UICollectionViewRowAction * _Nonnull action,
//                                                                              NSIndexPath * _Nonnull indexPath)
//  {
//    AnimalInfo *info = self.animals[indexPath.item];
//    [[UIApplication sharedApplication] openURL:info.URL];
//  }];
//
//  return @[delAction, moreInfo];
//}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self.dataSource announceWillAppearForItemInCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self.dataSource announceDidDisappearForItemInCell:cell];
}

#pragma mark Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSArray *indexPaths = self.collectionView.indexPathsForVisibleItems;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.dataSource updateConfiguration:self.configuration
                                        mode:CKUpdateModeAsynchronous
                                    userInfo:nil];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.collectionView scrollToItemAtIndexPath:indexPaths[indexPaths.count / 2]
                              atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                      animated:YES];
    }];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
  NSArray *indexPaths = self.collectionView.indexPathsForVisibleItems;
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    [self.dataSource updateConfiguration:self.configuration
                                    mode:CKUpdateModeAsynchronous
                                userInfo:nil];
  } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    [self.collectionView scrollToItemAtIndexPath:indexPaths[indexPaths.count / 2]
                          atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                  animated:YES];
  }];
}

@end
