# Jpush specific rules #
# http://docs.jiguang.cn/guideline/android_guide/

-dontoptimize
-dontpreverify

-dontwarn cn.jpush.**
-keep class cn.jpush.** { *; }

# v2.0.5 及以上的版本由于引入了protobuf 和 gson ，在上面基础之上增加排除混淆的配置。
#==================gson==========================
-dontwarn com.google.**
-keep class com.google.gson.** {*;}

#==================protobuf======================
-dontwarn com.google.**
-keep class com.google.protobuf.** {*;}
