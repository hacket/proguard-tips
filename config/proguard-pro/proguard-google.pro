## google官方库 ##

# ------------------------------- support v7 start -------------------------------
-keep public class android.support.v7.widget.** { *; }
-keep public class android.support.v7.internal.widget.** { *; }
-keep public class android.support.v7.internal.view.menu.** { *; }

# CoordinatorLayout.Behavior
# CoordinatorLayout resolves the behaviors of its child components with reflection.
-keep class * extends android.support.design.widget.CoordinatorLayout$Behavior {
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>();
}
# ------------------------------- support v7 end -------------------------------

# ------------------------------- support v4 start -------------------------------
# 如果是eclipse目录结构用到了android支持包加入
# -libraryjars  libs/android-support-v4.jar

# 如果有引用android-support-v4.jar包，可以添加下面这行
-keep public class com.null.test.ui.fragment.** {*;}

-dontwarn **CompatHoneycomb
-dontwarn **CompatHoneycombMR2
-dontwarn **CompatCreatorHoneycombMR2
-keep interface android.support.v4.app.** { *; }
#-keep class android.support.v4.** { *; }
-keep public class * extends android.support.v4.**
# ------------------------------- support v4 end -------------------------------

# ------------------------------- google play service start
-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}

-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}

-keepnames @com.google.android.gms.common.annotation.KeepName class *
-keepclassmembernames class * {
    @com.google.android.gms.common.annotation.KeepName *;
}

-keepnames class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

-keep class com.google.android.gms.**{ *; }

# ------------------------------- google play service end -------------------------------

# ------------------------------- AndroidAnnotations start -------------------------------
## AndroidAnnotations specific rules ##
# Only required if not using the Spring RestTemplate
-dontwarn org.androidannotations.api.rest.**

# 手动启用support keep注解
-dontskipnonpubliclibraryclassmembers
-printconfiguration
-keep,allowobfuscation @interface android.support.annotation.Keep
-keep @android.support.annotation.Keep class *
-keepclassmembers class * {
    @android.support.annotation.Keep *;
}
# ------------------------------- AndroidAnnotations end -------------------------------

#-keep class android.support.**{ *; }
