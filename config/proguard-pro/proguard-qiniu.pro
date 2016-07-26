# Qiniu7.2+ specific rules #
# http://developer.qiniu.com/code/v7/sdk/android.html

-keep class com.qiniu.**{*;}
-keep class com.qiniu.**{public <init>();}

# -ignorewarnings 这个也是必须加的，如果不加这个，编译的时候可能可以通过，但是 release 的时候还是会出现错误
-ignorewarnings
