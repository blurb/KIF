//
//  KIFTestScenario.m
//  KIF
//
//  Created by Michael Thole on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "KIFTestScenario.h"
#import "KIFTestStep.h"

static NSString* kDefaultCategory = @"default";

@interface KIFTestScenario ()

@property (nonatomic, readwrite, retain) NSArray *steps;
@property (nonatomic, readwrite) BOOL skippedByFilter;

- (void)_initializeStepsIfNeeded;

@end

@implementation KIFTestScenario

@synthesize description;
@synthesize category;
@synthesize steps;
@synthesize skippedByFilter;

#pragma mark Static Methods

+ (id)scenarioWithDescription:(NSString *)description category:(NSString*)category
{
    KIFTestScenario *scenario = [[self alloc] init];
    scenario.description = description;
    scenario.category = category;

    return [scenario autorelease];
}

+ (id)scenarioWithDescription:(NSString *)description
{
    return [self scenarioWithDescription:description category:kDefaultCategory];
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)dealloc
{
    self.steps = nil;
    self.description = nil;
    self.category = nil;
    
    [super dealloc];
}

#pragma mark Public Methods

- (void)initializeSteps;
{
    // For subclasses
}

- (NSArray *)steps;
{
    [self _initializeStepsIfNeeded];
    return steps;
}

- (void)addStep:(KIFTestStep *)step;
{
    NSAssert(![steps containsObject:step], @"The step %@ is already added", step);
    
    [self _initializeStepsIfNeeded];
    [steps addObject:step];
}

- (void)addStepsFromArray:(NSArray *)inSteps;
{
    for (KIFTestStep *step in inSteps) {
        NSAssert(![steps containsObject:step], @"The step %@ is already added", step);
    }
    
    [self _initializeStepsIfNeeded];
    [steps addObjectsFromArray:inSteps];
}

-(void)setDescription:(NSString *)desc
{
    if (desc != description) {
        [description release];
        description = [desc retain];
        
        skippedByFilterInvalid = YES;
    }
}

-(void)setCategory:(NSString *)c
{
    if (c != category) {
        [category release];
        category = [c retain];
        
        skippedByFilterInvalid = YES;
    }
}

-(BOOL)skippedByFilter
{
    if (skippedByFilterInvalid) {
        skippedByFilterInvalid = NO;
        skippedByFilter = NO;
        
        NSString *filter = [[[NSProcessInfo processInfo] environment] objectForKey:@"KIF_SCENARIO_FILTER"];
        if (filter) {
            skippedByFilter = ([description rangeOfString:filter options:NSRegularExpressionSearch].location == NSNotFound);
        }
        NSString *categoryFilter = [[[NSProcessInfo processInfo] environment] objectForKey:@"KIF_SCENARIO_CATEGORY_FILTER"];
        if (!skippedByFilter && categoryFilter) {
            skippedByFilter = ([category rangeOfString:categoryFilter options:NSRegularExpressionSearch].location == NSNotFound);
        }
        NSString *categoryExcludeFilter = [[[NSProcessInfo processInfo] environment] objectForKey:@"KIF_SCENARIO_CATEGORY_EXCLUDE_FILTER"];
        if (!skippedByFilter && categoryExcludeFilter) {
            skippedByFilter = ([category rangeOfString:categoryExcludeFilter options:NSRegularExpressionSearch].location != NSNotFound);
        }
    }
    return skippedByFilter;
}

#pragma mark Private Methods

- (void)_initializeStepsIfNeeded
{
    if (!steps) {
        self.steps = [NSMutableArray array];
        [self initializeSteps];
    }
}

@end
