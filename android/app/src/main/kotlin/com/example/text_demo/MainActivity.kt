package com.example.text_demo

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val channel = "toJava"
    @Override
    protected fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (android.os.Build.VERSION.SDK_INT > 9) {
            val policy: StrictMode.ThreadPolicy = Builder().permitAll().build()
            StrictMode.setThreadPolicy(policy)
        }
        MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), channel).setMethodCallHandler(
                object : MethodCallHandler() {
                    @Override
                    fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
                        if (methodCall.method != null) {
                            result.success(toJava(methodCall.method))
                        } else {
                            result.notImplemented()
                        }
                    }
                }
        )
    }


    fun toJava(name: String): String? {
        System.out.println("传递的参数是$name")
        return "您好$name"
    }

}
