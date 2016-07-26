## Stetho1.3.1  specific rules ##

# Updated as of Stetho 1.3.1
# Note: Doesn't include Javascript console lines. See https://github.com/facebook/stetho/tree/master/stetho-js-rhino#proguard

-keep class com.facebook.stetho.** { *; }

# rhino (javascript)
#-dontwarn org.mozilla.javascript.**
#-dontwarn org.mozilla.classfile.**
#-keep class org.mozilla.javascript.** { *; }