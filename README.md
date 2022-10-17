# Proguard拆分

## 背景
最近开始做新项目，需要做代码混淆。就直接从之前的项目中将`proguard-rules.pro`文件拷贝过来，然后在gradle中配置：

``` 
buildTypes {
    release {
        minifyEnabled true
        zipAlignEnabled true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), "$rootDir/config/proguard-rules.pro"
    }
}
```

### 存在的不足

像我这种情况，新启动的一个项目，需要Proguard。但是如果写在一个文件中，而且没有任何注释，如果还没有写在一块，拷贝过来还是需要一个个去检查是否需要，去掉了某个库的混淆，增加了某些库的混淆。

比如我之前用的是Retrofit1，在`proguard-rules.pro`配置：

``` 
# Retrofit 1.X

-keep class com.squareup.okhttp.** { *; }
-keep class retrofit.** { *; }
-keep interface com.squareup.okhttp.** { *; }

-dontwarn com.squareup.okhttp.**
-dontwarn okio.**
-dontwarn retrofit.**
-dontwarn rx.**

-keepclasseswithmembers class * {
    @retrofit.http.* <methods>;
}

# If in your rest service interface you use methods with Callback argument.
-keepattributes Exceptions

# If your rest service methods throw custom exceptions, because you've defined an ErrorHandler.
-keepattributes Signature

# Also you must note that if you are using GSON for conversion from JSON to POJO representation, you must ignore those POJO classes from being obfuscated.
# Here include the POJO's that have you have created for mapping JSON response to POJO for example.
```

现在我升级到retrofit2，由于retrofit2库做了修改，Proguard规则也需要更新为：

``` 
# Retrofit 2.X
## https://square.github.io/retrofit/ ##

-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}
```

如果存在多个这样的库，那是不是很增加工作量。下面我们换一种姿势来看。

## 换一种姿势

在项目的根目录建立`config/proguard-pro/`目录，将所有第三方的库和一些通用的配置全部配置在里面：

* 基本不用动的规则
  
  `proguard-normal.pro`
  
  ``` 
  ## Proguard normal ##
  
  # ============================== 基本不用动区域 ==============================
  
  # ------------------------------- 基本指令区 -------------------------------
  
  # 代码混淆的压缩比例(0-7) , 默认为5 , 一般不需要改
  -optimizationpasses 5
  
  # 混淆后类名都小写 (windows最后加上 , 因为windows大小写敏感)
  -dontusemixedcaseclassnames
  
  # 指定不去忽略非公共的库的类(即混淆第三方, 第三方库可能自己混淆了 , 可在后面配置某些第三方库不混淆)
  # 默认跳过，有些情况下编写的代码与类库中的类在同一个包下，并且持有包中内容的引用，此时就需要加入此条声明
  -dontskipnonpubliclibraryclasses
  
  # 指定不去忽略非公共的库的类的成员
  -dontskipnonpubliclibraryclassmembers
  
  # 不做预检验，preverify是proguard的四个步骤之一
  # Android不需要preverify，去掉这一步可以加快混淆速度
  -dontpreverify
  
  # 有了verbose这句话，混淆后就会生成映射文件
  # 包含有类名->混淆后类名的映射关系
  # 然后使用printmapping指定映射文件的名称
  -verbose
  -printmapping proguardMapping.txt
  
  # 指定混淆时采用的算法，后面的参数是一个过滤器
  # 这个过滤器是谷歌推荐的算法，一般不改变
  -optimizations !code/simplification/cast,!field/*,!class/merging/*
  
  # 保护代码中的Annotation不被混淆
  # 这在JSON实体映射时非常重要，比如fastJson
  -keepattributes *Annotation*,InnerClasses
  
  -keep public class com.google.vending.licensing.ILicensingService
  -keep public class com.android.vending.licensing.ILicensingService
  
  # 避免混淆泛型
  # 这在JSON实体映射时非常重要，比如fastJson
  -keepattributes Signature
  
  #抛出异常时保留源文件和代码行号
  -keepattributes SourceFile,LineNumberTable
  # ------------------------------- 基本指令区 -------------------------------
  
  # ------------------------------- 默认保留区 -------------------------------
  
  # 保留四大组件
  -keep public class * extends android.app.Activity
  # 保留就保证layout中定义的onClick方法不影响
  # We want to keep methods in Activity that could be used in the XML attribute onClick
  -keepclassmembers class * extends android.app.Activity{
      public void *(android.view.View);
  }
  -keep public class * extends android.app.Service
  -keep public class * extends android.content.BroadcastReceiver
  -keep public class * extends android.content.ContentProvider
  -keep public class * extends android.app.Application
  
  -keep public class * extends android.app.backup.BackupAgentHelper
  -keep public class * extends android.preference.Preference
  
  # For native methods, see http://proguard.sourceforge.net/manual/examples.html#native
  # 保留类名和native成员方法
  -keepclasseswithmembernames class * {
      native <methods>;
  }
  
  # 枚举类不能被混淆
  # # For enumeration classes, see http://proguard.sourceforge.net/manual/examples.html#enumerations
  -keepclassmembers enum * {
      public static **[] values();
      public static ** valueOf(java.lang.String);
  }
  
  # 保留自定义控件(继承自View)的setter、getter和构造方法
  # keep setters in Views so that animations can still work.
  # see http://proguard.sourceforge.net/manual/examples.html#beans
  -keep public class * extends android.view.View{
      public <init>(android.content.Context);
      public <init>(android.content.Context, android.util.AttributeSet);
      public <init>(android.content.Context, android.util.AttributeSet, int);
      *** get*();
      void set*(***);
  }
  
  # 保留Parcelable序列化的类不能被混淆
  #-keep class * implements android.os.Parcelable {
  #  public static final android.os.Parcelable$Creator *;
  #}
  # 官方
  -keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
  }
  
  # 所有实现了 Serializable 接口的类及其成员都不进行混淆
  -keepnames class * implements java.io.Serializable
  -keepclassmembers class * implements java.io.Serializable {
      static final long serialVersionUID;
      private static final java.io.ObjectStreamField[] serialPersistentFields;
      !static !transient <fields>;
      private void writeObject(java.io.ObjectOutputStream);
      private void readObject(java.io.ObjectInputStream);
      java.lang.Object writeReplace();
      java.lang.Object readResolve();
  }
  
  # 对R文件下的所有类及其方法 , 都不能被混淆
  #-keep class **.R$* {
  # *;
  #}
  # 官方
  -keepclassmembers class **.R$* {
      public static <fields>;
  }
  
  # The support library contains references to newer platform versions.
  # Don't warn about those in case this app is linking against an older
  # platform version.  We know about them, and they are safe.
  -dontwarn android.support.**
  
  # Understand the @Keep support annotation.
  -keep class android.support.annotation.Keep
  
  -keep @android.support.annotation.Keep class * {*;}
  
  -keepclasseswithmembers class * {
      @android.support.annotation.Keep <methods>;
  }
  
  -keepclasseswithmembers class * {
      @android.support.annotation.Keep <fields>;
  }
  
  -keepclasseswithmembers class * {
      @android.support.annotation.Keep <init>(...);
  }
  
  # ------------------------------- 默认保留区 end-------------------------------
  
  #------------------------------- 以上内容基本是SDK目录下的proguard-android-optimize.txt内容 ------------------------------- #
  
  # ------------------------------- webview相关 -------------------------------
  
  -dontwarn android.webkit**
  
  # WebView(可选)
  -keepclassmembers class * extends android.webkit.WebView {
     public *;
  }
  
  # WebView的复杂操作
  -keepclassmembers class * extends android.webkit.WebViewClient {
       public void *(android.webkit.WebView,java.lang.String,android.graphics.Bitmap);
       public boolean *(android.webkit.WebView,java.lang.String);
  }
  -keepclassmembers class * extends android.webkit.WebChromeClient {
       public void *(android.webkit.WebView,java.lang.String);
  }
  
  # 与JS交互
  -keepattributes SetJavaScriptEnabled
  -keepattributes JavascriptInterface
  
  # 保留与JS交互接口 , API17+
  -keepclassmembers class * {
      @android.webkit.JavascriptInterface <methods>;
  }
  
  # ------------------------------- webview相关 end -------------------------------
  
  -dontwarn org.apache.**
  
  # ============================== 基本不动区域 end ==============================
  ```
  
  ​
  
* okhttp3
  
  `proguard-square-okhttp3.pro`
  
  ``` 
  # OkHttp3 specific rules #
  
  -keepattributes Signature
  -keepattributes *Annotation*
  -keep class okhttp3.** { *; }
  -keep interface okhttp3.** { *; }
  -dontwarn okhttp3.**
  ```
  
* eventbus3
  
  proguard-eventbus-3.pro
  
  ``` 
  ## EventBus3  specific rules ##
  # http://greenrobot.org/eventbus/documentation/proguard/
  
  -keepattributes *Annotation*
  -keepclassmembers class ** {
      @org.greenrobot.eventbus.Subscribe <methods>;
  }
  -keep enum org.greenrobot.eventbus.ThreadMode { *; }
  
  # Only required if you use AsyncExecutor
  -keepclassmembers class * extends org.greenrobot.eventbus.util.ThrowableFailureEvent {
      <init>(java.lang.Throwable);
  }
  ```
  

最后在`proguard-rules.pro`将他们全部导入进来：通过`-include指令`导入

``` 
-basedirectory proguard-pro

-include proguard-normal.pro

-include proguard-google.pro
-include proguard-google-gson2.pro
-include proguard-google-protobuf.pro
-include proguard-google-volley.pro

-include proguard-eventbus-3.pro

-include proguard-facebook-stetho.pro

-include proguard-glide.pro

-include proguard-leakcanary.pro

-include proguard-jpush.pro

-include proguard-qiniu.pro

-include proguard-tencent-bugly.pro

-include proguard-umeng.pro

-include proguard-baidu-map.pro
```

如果后面替换了某个库，或者增加了某个库，直接在这个文件注释或者增加一条`-include`就行了。

在`build.gradle`中配置：

``` 
buildTypes {
    release {
        minifyEnabled true
        zipAlignEnabled true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), "$rootDir/config/proguard-rules.pro"
    }
}
```

当然也可以采用这种方式，但这种会导致`build.gradle`文件庞大：

``` 
android {
  buildTypes {
    release {
      minifyEnabled true
      // Library specific proguard files
      proguardFile 'proguard-google-play-services.pro'
      proguardFile 'proguard-gson.pro'
      ...
      // Default proguard files & project app specific rules,
      //  see examples folder for more information
      proguardFile 'proguard-project-app.pro'
      proguardFile getDefaultProguardFile('proguard-android.txt')
      // As of Gradle Android plugin 1.1.0, the test APK has a separate config
      testProguardFile 'proguard-project-test.pro'
    }
  }
}
```
