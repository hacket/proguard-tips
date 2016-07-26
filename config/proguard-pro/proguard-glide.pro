# Glide3.7 specific rules #
# https://github.com/bumptech/glide/wiki/Configuration#keeping-a-glidemodule

# 官网
-keepnames class com.mypackage.MyGlideModule

-keepnames cn.zengfansheng.common.base.GlideConfigModule
# or more generally:
-keep public class * implements com.bumptech.glide.module.GlideModule

# 网络 https://github.com/krschultz/android-proguard-snippets/blob/master/libraries/proguard-glide.pro
#-keep public class * implements com.bumptech.glide.module.GlideModule
#-keep public enum com.bumptech.glide.load.resource.bitmap.ImageHeaderParser$** {
#    **[] $VALUES;
#    public *;
#}

# 原版
#-keepnames class com.mypackage.MyGlideModule
# or more generally:
#-keep public class * implements com.bumptech.glide.module.GlideModule

# for DexGuard only
#-keepresourcexmlelements manifest/application/meta-data@value=GlideModule