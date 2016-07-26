# Umeng specific rules #
# http://dev.umeng.com/analytics/android-doc/integration#2_8

# SDK中的部分代码使用反射来调用构造函数
-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}

# SDK需要引用导入工程的资源文件，通过了反射机制得到资源引用文件R.java，但是在开发者通过proguard等混淆/优化工具处理apk时，proguard可能会将R.java删除
-keep public class cn.zengfansheng.androidtools.R$*{
    public static final int *;
}

# 5.0.0及以上版本的SDK
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
