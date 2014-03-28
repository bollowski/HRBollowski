//
//  HRImageManager.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 25/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

// TODO: Should manage to resize images (not prioritized)

#import "HRImageManager.h"

@implementation HRImageManager

- (UIImage *)loadImageForRecipe:(Recipe *)recipe {
    if ([recipe.localphotopath length]) {
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:recipe.localphotopath]];

        if (img) {
            return img;
        } else {
            /*The img can not be loaded and might have been 
             deleted from the NSCachesDirectory we should therefor delete the local reference
             and so we try to fetch it online
             */
            recipe.localphotopath = nil;
            [recipe save];
        }
    }
    return nil;
}

- (NSString *)storeImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    NSString *cachedFolderPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *cachedImagePath = [[cachedFolderPath stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%@.jpg", [NSDate date]]]
            stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (![imageData writeToFile:cachedImagePath atomically:YES]) {
        return nil;
    } else {
        return cachedImagePath;
    }
}

- (void)deleteImageWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:path];

    if (fileExists) {
        if (![fileManager removeItemAtPath:path error:&error]) {
            DDLogError(@"HRImageManager - deleteImageWithPath - Failed to delete image: %@", [error localizedDescription]);
        }
    }
}

@end
