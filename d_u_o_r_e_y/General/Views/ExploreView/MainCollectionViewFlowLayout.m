//
//  MainCollectionViewFlowLayout.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "MainCollectionViewFlowLayout.h"


NSString *const MainCollectionViewSectionOneCellKind = @"MainCollectionViewSectionOneCellKind";
NSString *const MainCollectionViewSectionTwoCellKind = @"MainCollectionViewSectionTwoCellKind";
NSString *const MainCollectionViewSectionThreeCellKind = @"MainCollectionViewSectionThreeCellKind";
NSString *const MainCollectionViewAllViewHeaderKind = @"MainCollectionViewAllViewHeaderKind";
NSString *const MainCollectionViewSectionHeaderKind = @"MainCollectionViewSectionHeaderKind";

@interface MainCollectionViewFlowLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSDictionary *headerLayoutInfo;
@property (nonatomic, strong) NSDictionary *footerLayoutInfo;
@property (nonatomic, strong) NSMutableDictionary *headerSizes;
@property (nonatomic, strong) NSMutableDictionary *footerSizes;
@property (nonatomic, readonly) CGFloat cellWidth;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic ) float totalYHeight;
//@property (nonatomic ) float aCellWidth;

@end

#define SECTION_HEADER_HEIGHT 50

@implementation MainCollectionViewFlowLayout

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    return self;
}

- (NSInteger)numberOfSections
{
    return [self.collectionView numberOfSections];
}

- (void)prepareLayout
{
   float _aCellWidth = (self.collectionView.frame.size.width-50)/3;
    _totalYHeight = 0;
    NSMutableDictionary *newLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *sectionOneCellLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *sectionTwoCellLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *sectionThreeCellLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *allHeaderLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *sectionHeaderLayoutDictionary = [NSMutableDictionary dictionary];
    
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        if (section == 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes
                                                                  layoutAttributesForSupplementaryViewOfKind:MainCollectionViewAllViewHeaderKind
                                                                  withIndexPath:indexPath];
            headerAttributes.frame = CGRectMake(0, _totalYHeight, self.collectionView.frame.size.width, 150);
            
            allHeaderLayoutDictionary[indexPath] = headerAttributes;
            _totalYHeight += 150;
        } else if(section==1) {
            NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
            for (int item=0; item<itemsCount; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                    if (indexPath.item==0) {
                        UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes
                                                                              layoutAttributesForSupplementaryViewOfKind:MainCollectionViewSectionHeaderKind
                                                                              withIndexPath:indexPath];
                        footerAttributes.frame = CGRectMake(0, _totalYHeight, self.collectionView.frame.size.width, SECTION_HEADER_HEIGHT);;
                        
                        sectionHeaderLayoutDictionary[indexPath] = footerAttributes;
                        _totalYHeight+=SECTION_HEADER_HEIGHT;
                    }
                
                    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                    if (indexPath.item==0) {
                        layoutAttributes.frame = CGRectMake(10, _totalYHeight, _aCellWidth*2+15, _aCellWidth*2+55);
                    }else if (indexPath.item==1){
                        layoutAttributes.frame = CGRectMake(_aCellWidth*2+40, _totalYHeight, _aCellWidth, _aCellWidth+20);
                        _totalYHeight += _aCellWidth+35;
                    }else if (indexPath.item==2){
                        layoutAttributes.frame = CGRectMake(_aCellWidth*2+40, _totalYHeight, _aCellWidth, _aCellWidth+20);
                        _totalYHeight += _aCellWidth+35;
                    }else{
                        layoutAttributes.frame = CGRectMake(10+_aCellWidth*(indexPath.item-3)+((indexPath.item-3)*15), _totalYHeight, _aCellWidth, _aCellWidth+20);
                    }
                    sectionOneCellLayoutDictionary[indexPath] = layoutAttributes;
            }
            _totalYHeight +=_aCellWidth+35;
        }else if (section==2){
            NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
            for (int i=0; i<itemsCount; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
                if (indexPath.item==0) {
                    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes
                                                                          layoutAttributesForSupplementaryViewOfKind:MainCollectionViewSectionHeaderKind
                                                                          withIndexPath:indexPath];
                    footerAttributes.frame = CGRectMake(0, _totalYHeight, self.collectionView.frame.size.width, SECTION_HEADER_HEIGHT);;
                    
                    sectionHeaderLayoutDictionary[indexPath] = footerAttributes;
                    _totalYHeight+=SECTION_HEADER_HEIGHT;
                }
                UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                if (indexPath.item==0) {
                    layoutAttributes.frame = CGRectMake(10, _totalYHeight, self.collectionView.frame.size.width-20, 70);
                }
                sectionThreeCellLayoutDictionary[indexPath] = layoutAttributes;
            }
            _totalYHeight+=80;

            
        }else if (section==3){
            
            NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
            for (int i=0; i<itemsCount; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
                
                if (indexPath.item==0) {
                    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes
                                                                          layoutAttributesForSupplementaryViewOfKind:MainCollectionViewSectionHeaderKind
                                                                          withIndexPath:indexPath];
                    footerAttributes.frame = CGRectMake(0, _totalYHeight, self.collectionView.frame.size.width, SECTION_HEADER_HEIGHT);
                    
                    sectionHeaderLayoutDictionary[indexPath] = footerAttributes;
                    _totalYHeight+=SECTION_HEADER_HEIGHT;
                }
                UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                int i=_totalYHeight;
                if (indexPath.item>=3) {
                    i=i+_aCellWidth+35;
                }
                
                if (indexPath.item<3) {
                    layoutAttributes.frame = CGRectMake(10+_aCellWidth*indexPath.item+(indexPath.item*15), i, _aCellWidth, _aCellWidth+20);
                }else{
                    layoutAttributes.frame = CGRectMake(10+_aCellWidth*(indexPath.item-3)+((indexPath.item-3)*15), i, _aCellWidth, _aCellWidth+20);
                }
                sectionTwoCellLayoutDictionary[indexPath] = layoutAttributes;
            }
            _totalYHeight +=_aCellWidth*2+70;
        }
    }
    
    newLayoutDictionary[MainCollectionViewSectionOneCellKind] = sectionOneCellLayoutDictionary;
    newLayoutDictionary[MainCollectionViewSectionTwoCellKind] = sectionTwoCellLayoutDictionary;
    newLayoutDictionary[MainCollectionViewSectionThreeCellKind] = sectionThreeCellLayoutDictionary;
    newLayoutDictionary[MainCollectionViewAllViewHeaderKind] = allHeaderLayoutDictionary;
    newLayoutDictionary[MainCollectionViewSectionHeaderKind] = sectionHeaderLayoutDictionary;
    
    self.layoutInfo = newLayoutDictionary;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        return self.layoutInfo[MainCollectionViewSectionOneCellKind][indexPath];
    }else if(indexPath.section==2){
        return self.layoutInfo[MainCollectionViewSectionTwoCellKind][indexPath];
    }else if(indexPath.section==3){
        return self.layoutInfo[MainCollectionViewSectionThreeCellKind][indexPath];
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[kind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, _totalYHeight);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

@end
