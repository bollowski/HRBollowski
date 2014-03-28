//
//  Recipe+RemoteAccessors.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 11/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "Recipe+RemoteAccessors.h"

@implementation Recipe (RemoteAccessors)

+ (void)loadAllOnResult:(RecipeArrayBlock)resultBlock onError:(RecipeErrorBlock)errorBlock {
    // Fetch all recipes on server
    [[HRAPIManager sharedClient] GET:@"recipes" parameters:nil success:^(NSURLSessionDataTask *__unused task, id JSON) {
        if (resultBlock) {
            resultBlock(JSON);
        }
    }                        failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)createInstanceOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock {
    // The app is in progress of uploading the recipe
    [self recipeIsUploadingToServer];

    NSDictionary *parameters = @{@"recipe" :
            @{@"name" : self.name,
                    @"difficulty" : self.difficulty,
                    @"description" : self.desc ? self.desc : @"",
                    @"instructions" : self.instructions ? self.instructions : @""}
    };

    __weak Recipe *weakSelf = self;

    [[HRAPIManager sharedClient] POST:@"recipes"
                           parameters:parameters
            constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {

                if ([weakSelf.localphotopath length]) {
                    NSData *imageData = [NSData dataWithContentsOfFile:weakSelf.localphotopath];
                    NSString *fileName = [weakSelf photoNameForServer];

                    [formData appendPartWithFileData:imageData name:@"recipe[photo]" fileName:fileName mimeType:@"image/jpeg"];
                }
            } success:^(NSURLSessionDataTask *task, id responseObject) {
        resultBlock([NSNumber numberWithInt:[[responseObject objectForKey:@"id"] integerValue]]);

        // The app is not in progress of uploading the recipe
        [self recipeIsNotUploadingToServer];

        DDLogVerbose(@"Success, responseObject: %@", responseObject);

    }                         failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self recipeIsNotUploadingToServer];
        errorBlock(error);
    }];
}

- (void)saveOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock {
    // The app is in progress of uploading the recipe
    [self recipeIsUploadingToServer];

    NSDictionary *parameters = @{@"recipe" :
            @{@"name" : self.name,
                    @"difficulty" : self.difficulty,
                    @"description" : self.desc ? self.desc : @"",
                    @"instructions" : self.instructions ? self.instructions : @""}
    };

    NSString *url = [[[[HRAPIManager sharedClient] baseURLAsString] stringByAppendingString:@"/recipes/"]
            stringByAppendingString:[self.objectidonserver stringValue]];

    NSMutableURLRequest *request = [[[HRAPIManager sharedClient] requestSerializer]
            multipartFormRequestWithMethod:@"PUT"
                                 URLString:url
                                parameters:parameters
                 constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                     if ([self.localphotopath length]) {
                         NSData *imageData = [NSData dataWithContentsOfFile:self.localphotopath];
                         NSString *fileName = [self photoNameForServer];

                         [formData appendPartWithFileData:imageData name:@"recipe[photo]" fileName:fileName mimeType:@"image/jpeg"];
                     }
                 } error:nil];

    [[[HRAPIManager sharedClient] dataTaskWithRequest:request
                                    completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {

                                        // The app is not in progress of uploading the recipe
                                        [self recipeIsNotUploadingToServer];

                                        if (error)
                                            errorBlock(error);
                                        else
                                            resultBlock([NSNumber numberWithInt:0]);
                                    }] resume];
}

- (void)markRecipeAsFavoriteOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock {
    [self recipeIsUploadingToServer];

    NSDictionary *parameters = @{@"recipe" :
            @{@"name" : self.name,
                    @"difficulty" : self.difficulty,
                    @"favorite" : [self favoriteAsString]}
    };

    [[HRAPIManager sharedClient] PUT:[@"recipes/" stringByAppendingString:[self.objectidonserver stringValue]]
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 [self recipeIsNotUploadingToServer];
                                 DDLogVerbose(@"Success, responseObject: %@", responseObject);

                                 resultBlock([NSNumber numberWithInt:0]);
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 [self recipeIsNotUploadingToServer];
                                 errorBlock(error);
                             }];

}

- (void)deleteFromServerOnResult:(RecipeObjectBlock)resultBlock onError:(RecipeErrorBlock)errorBlock {
    // Delete recipe from server
    [[HRAPIManager sharedClient] DELETE:[@"recipes/" stringByAppendingString:[self.objectidonserver stringValue]]
                             parameters:nil
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    resultBlock(self);
                                }
                                failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    errorBlock(error);
                                }];
}

// This logic make sure that a recipe is only uploaded once
- (void)recipeIsUploadingToServer {
    self.uploading = [NSNumber numberWithBool:YES];
    [self save];
}

- (void)recipeIsNotUploadingToServer {
    self.uploading = [NSNumber numberWithBool:NO];
    [self save];
}

@end