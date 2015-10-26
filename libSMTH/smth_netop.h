#ifndef _SMTH_NETOP_H_
#define _SMTH_NETOP_H_
#import <Foundation/Foundation.h>
//attachment
int apiNetAddAttachment(NSString * photo, int * errorcode);

//APNS
int apiNetRegAPNS(NSString * username, NSString * token, NSString * profile);


unsigned int api_get_version();


//defined in libSMTH, implemented not in libSMTH(in client_signature.m).
NSString * client_get_secret();
NSString * client_get_signature();
NSString * client_get_userid();


#endif