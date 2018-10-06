//
//  NSString+Helper.m
//  Nemo
//
//  Created by Dushyant Bansal on 24/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

-(NSString*)favIconUrlStringFromHtmlString:(NSString*)htmlString

{
  
  NSScanner *htmlScanner = [NSScanner scannerWithString:htmlString];
  
  
  
  while ([htmlScanner isAtEnd] == NO)
    
  {
    
    [htmlScanner scanUpToString:@"<link" intoString:NULL];
    
    if(![htmlScanner isAtEnd])
      
    {
      
      NSString *linkString;
      
      [htmlScanner scanUpToString:@"/>" intoString:&linkString];
      
      
      
      // we have a link element.  does it have rel set to anything we want?
      
      if(([linkString rangeOfString:@"rel=\"shortcut icon\""].location != NSNotFound)||
         
         ([linkString rangeOfString:@"rel='shortcut icon'"].location != NSNotFound)||
         
         ([linkString rangeOfString:@"rel=\"icon\""].location != NSNotFound)||
         
         ([linkString rangeOfString:@"rel='icon'"].location != NSNotFound)||
         
         ([linkString rangeOfString:@"rel=icon "].location != NSNotFound))
        
      {
        
        // yep, grab the href
        
        NSScanner *hrefScanner = [NSScanner scannerWithString:linkString];
        
        [hrefScanner scanUpToString:@"href=" intoString:NULL];
        
        if(![hrefScanner isAtEnd])
          
        {
          
          [hrefScanner scanString:@"href=" intoString:NULL];
          
          NSString *hrefString;
          
          
          
          // scan up to a space.
          
          // if we don't hit one cause the href was the last thing in the element, we don't care
          
          [hrefScanner scanUpToString:@" " intoString:&hrefString];
          
          
          
          // clean up any quotes
          
          hrefString = [hrefString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
          
          hrefString = [hrefString stringByReplacingOccurrencesOfString:@"'" withString:@""];
          
          
          
          // we're done, return
          
          return hrefString;
          
        }
        
      }
      
    }
    
  }
  
  
  
  return nil;
  
}

@end
