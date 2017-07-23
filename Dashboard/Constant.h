//
//  Constant.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#ifndef Constant_h
#define Constant_h


#pragma mark - API KEY

#define API_KEY           @"Lu__gDyuS2SEw7MJmxyUWw"
#define GOOGLE_API_KEY    @"AIzaSyBfzd3igMBpI0FUiUsow0jmhoTWpt2LQLA"
#define CLIENT_ID         @"123456"
#define CLIENT_SECRET     @"secret123456"


#pragma mark - URLs
#define HEROKU_BASE_URL   @"https://guarded-savannah-35433.herokuapp.com/"
#define BASE_URL          @"https://riseapp-dot-rise-team-tool-qa.appspot.com"
#define AUTH_URL          @"https://auth-dot-rise-team-tool-qa.appspot.com"
#define DONATE_URL        @"https://donate-dot-rise-team-tool-qa.appspot.com"

#define STRIPE_VERSION     @"2017-06-05"//@"2016-07-06"
#define STRIPE_PUB_KEY    @"pk_test_4bE0pVqCXoFro6aV9iJnnIhX"   //chingpaq
//#define STRIPE_PUB_KEY  @"pk_test_zEaBQsmR9aKOqnlbjNLuN3gK" // newfounders test


#pragma mark - DEVICE IDENTIFICATION
#define IS_IPHONE_4_INCH (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_4_7_INCH (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_5_5_INCH (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)736) < DBL_EPSILON)


#pragma mark - NSNOTIFICATIONCENTER KEYS

#define ADDRESS_UPDATED             @"AddressUpdated"
#define YOUR_ELECTIONS_RECEIVED     @"YourElectionsReceived"
#define CONTACTS_ELECTIONS_RECEIVED @"ContactsElectionsReceived"


#pragma mark - NSUSERDEFAULT KEYS

#define IS_SESSION_ACTIVE   @"IsSessionActive"
#define USER_IMAGE_URL      @"UserImageURL"
#define USER_FULL_NAME      @"UserFullName"
#define USER_LOCATION       @"UserLocation"
#define USER_STREET         @"UserStreet"
#define USER_CITY           @"UserCity"
#define USER_STATE          @"UserState"
#define USER_ZIP_CODE       @"UserZipCode"
#define USER_ADDRESS_EXISTS @"UserAddressExists"
#define CONTACTS_IMPORTED   @"ContactsImported"
#define ALL_CONTACTS        @"AllContacts"
#define USERNAME            @"Username"
#define PASSWORD            @"Password"
#define AUTH_TOKEN          @"AuthToken"
#define REFRESH_TOKEN       @"RefreshToken"


#pragma mark - FONTS

#define BLACK_FONT_8     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_8      [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_8     [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_8     [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_8    [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_8   [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_8  [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_8      [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_9     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_9      [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_9     [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_9     [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_9    [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_9   [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_9  [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_9      [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_10    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_10     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_10    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_10    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_10   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_10  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_10 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_10     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_11    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_11     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_11    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_11    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_11   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_11  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_11 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_11     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_12    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_12     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_12    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_12    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_12   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_12  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_12 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_12     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_13    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_13     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_13    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_13    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_13   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_13  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_13 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_13     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_14    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_14     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_14    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_14    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_14   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_14  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_14 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_14     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_15    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_15     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_15    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_15    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_15   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_15  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_15 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_15     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_16    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_16     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_16    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_16    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_16   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_16  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_16 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_16     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_17    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_17     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_17    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_17    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_17   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_17  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_17 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_17     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]

#define BLACK_FONT_18    [UIFont systemFontOfSize:8.0 weight:UIFontWeightBlack];
#define BOLD_FONT_18     [UIFont systemFontOfSize:8.0 weight:UIFontWeightBold];
#define HEAVY_FONT_18    [UIFont systemFontOfSize:8.0 weight:UIFontWeightHeavy];
#define LIGHT_FONT_18    [UIFont systemFontOfSize:8.0 weight:UIFontWeightLight];
#define MEDIUM_FONT_18   [UIFont systemFontOfSize:8.0 weight:UIFontWeightMedium];
#define REGULAR_FONT_18  [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
#define SEMIBOLD_FONT_18 [UIFont systemFontOfSize:8.0 weight:UIFontWeightSemibold];
#define THIN_FONT_18     [UIFont systemFontOfSize:8.0 weight:UIFontWeightThin]


#endif /* Constant_h */
