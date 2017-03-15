//
// Created by root-sniper on 15/03/2017.
//

#import <sqlite3.h>
#import <pthread.h>
#import "FMDatabaseQueue+Notify.h"
#import "FMDatabase.h"

#define BUFFER_SIZE 256
static NSMutableDictionary *notifyDic = nil;
static char buf[BUFFER_SIZE] = {0};
static pthread_mutex_t pLock;

@implementation FMDatabaseQueue (Notify)

void update_callback(void *user_data, int operation_type,
        char const *database, char const *table, sqlite3_int64 rowid) {
    NSString *tableStr = [NSString stringWithCString:table
                                            encoding:NSUTF8StringEncoding];
    pthread_mutex_lock(&pLock);
    if ([[notifyDic allKeys] containsObject:tableStr]) {
        NSString *notifyStr = [notifyDic objectForKey:tableStr];
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyStr
                                                            object:nil];
    }
    pthread_mutex_unlock(&pLock);
}

/**
 * register db change observer for table: tableName
 * SQLITE_INSERT, SQLITE_DELETE, or SQLITE_UPDATE
 */
- (void)registerObserver:(_Nonnull NSString *)tableName
                  notify:(_Nonnull NSString *)notifyIdentify {
    pthread_mutex_lock(&pLock);
    if (![[notifyDic allKeys] containsObject:tableName]) {
        [notifyDic setObject:notifyIdentify forKey:tableName];
    }
    pthread_mutex_unlock(&pLock);

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sqlite3_update_hook((sqlite3 *) [_db sqliteHandle], update_callback, (void *) buf);
    });
}

/**
 * unregister db change observer for table: tableName
 */
- (void)unRegisterObserver:(_Nonnull NSString *)tableName {
    pthread_mutex_lock(&pLock);
    [notifyDic removeObjectForKey:tableName];
    pthread_mutex_unlock(&pLock);
}

#pragma mark FMDatabaseQueue_Notify initialization

+ (void)load {
    pthread_mutex_init(&pLock, NULL);
    notifyDic = [NSMutableDictionary dictionary];
    memset(buf, 0, BUFFER_SIZE);
}
@end
