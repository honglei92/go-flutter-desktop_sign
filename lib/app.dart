// This example demos the TextField/SelectableText widget and keyboard
// integration with the go-flutter text backend

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'dart:io' show Directory;
import 'package:path/path.dart' as path;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample for testing text input',
      theme: ThemeData(
        // If the host is missing some fonts, it can cause the
        // text to not be rendered or worse the app might crash.
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
      ),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  var keystorePath = "D:\\01whl\\key\\tianmagongchang.jks";
  var unSignedApkPath = "D:\\sign\\vivo\\vivo_unsign.apk";
  var signedApkPath = "";
  var mPassword = "tm123456";
  var mAlias = "alias";
  FocusNode myFocus = FocusNode();
  TextEditingController textEditingControllerKeyFile =
      new TextEditingController();
  TextEditingController textEditingControllerPwd = new TextEditingController();
  TextEditingController textEditingControllerApk = new TextEditingController();
  TextEditingController textEditingControllerAlias =
      new TextEditingController();
  var shell = Shell();

  _press(int type) async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      if (type == 1)
        textEditingControllerApk.text = result.files.single.path;
      else if (type == 2) {
        textEditingControllerKeyFile.text = result.files.single.path;
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingControllerPwd.addListener(() async {
      keystorePath = textEditingControllerKeyFile.text.toString();
      mPassword = textEditingControllerPwd.text.toString();
      print("aaa" + mPassword);
      var keytoolStr =
          "echo " + mPassword + "|keytool -v -list -keystore " + keystorePath;
      await shell.run('''$keytoolStr''').then((value) => handle(value.outText));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tenma Signer'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: SelectableText.rich(
                // this text can be copied with "Ctrl-C"
                TextSpan(
                  text: '天马', // default text style
                  children: <TextSpan>[
                    TextSpan(
                        text: ' 给空包签名',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ' (内部使用)',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 10)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: new EdgeInsets.all(8.0),
              child: new Column(children: <Widget>[
                Padding(
                    padding: new EdgeInsets.all(8.0),
                    child: Expanded(
                      child: Row(children: <Widget>[
                        Expanded(
                          child: TextField(
                            obscureText: false,
                            controller: textEditingControllerApk,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '源apk路径',
                            ),
                            onSubmitted: (value) {
                              print("TextField 1:" + value);
                            },
                            onEditingComplete: () =>
                                FocusScope.of(context).requestFocus(myFocus),
                          ),
                        ),
                        Container(
                            child: Padding(
                          padding: new EdgeInsets.only(left: 10.0),
                          child: MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: Text('选择'),
                              onPressed: () => _press(1)),
                        ))
                      ]),
                    )),
                Padding(
                    padding: new EdgeInsets.all(8.0),
                    child: Expanded(
                      child: Row(children: <Widget>[
                        Expanded(
                          child: TextField(
                            obscureText: false,
                            controller: textEditingControllerKeyFile,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '签名文件路径',
                            ),
                            onSubmitted: (value) {
                              print("TextField 1:" + value);
                            },
                            onEditingComplete: () =>
                                FocusScope.of(context).requestFocus(myFocus),
                          ),
                        ),
                        Container(
                            child: Padding(
                          padding: new EdgeInsets.only(left: 10.0),
                          child: MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: Text('选择'),
                              onPressed: () => _press(2)),
                        ))
                      ]),
                    )),
                Padding(
                  padding: new EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: '签名文件密码'),
                    controller: textEditingControllerPwd,
                    onSubmitted: (value) {
                      setState(() {
                        print("TextField 2:" + value);
                      });
                    },
                    onChanged: (value) {
                      checkPwd(value);
                    },
                  ),
                ),
                Padding(
                  padding: new EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: '签名文件别名'),
                    controller: textEditingControllerAlias,
                    onSubmitted: (value) {
                      setState(() {
                        print("TextField 2:" + value);
                      });
                    },
                  ),
                ),
                new MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: new Text('开始签名'),
                  onPressed: () async {
                    print("开始签名 :");
                    //从当前目录到系统临时目录的路径
                    print(path.relative(Directory.systemTemp.path));
                    // const platform = const MethodChannel("toJava");
                    // String returnValue = await platform.invokeMethod("张三");
                    // print("从原生Android的java方法返回的值是：" + returnValue);
                    // ...
                    sign();
                  },
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  handle(String value) {
    List<String> lines = value.split("\n");
    lines.forEach((element) {
      if (element.contains("别名:")) {
        String tempAlias = element.replaceAll("别名:", "");
        textEditingControllerAlias.text = tempAlias;
        mAlias = tempAlias;
      }
    });
    print("aaa" + value);
  }

  Future<void> sign() async {
    var now = new DateTime.now();
    print(now);
    var nowTime = now.toIso8601String();
    unSignedApkPath = textEditingControllerApk.text.toString();
    var tempUnSignedApkPath = unSignedApkPath;
    signedApkPath = tempUnSignedApkPath.replaceAll(".apk", "signed.apk");
    var shellStr = "echo " +
        mPassword +
        "|jar\\jre\\bin\\jarsigner -verbose -keystore " +
        keystorePath +
        " -signedjar " +
        signedApkPath +
        " " +
        unSignedApkPath +
        " " +
        mAlias;
    await shell.run('''$shellStr''').then((value) => success());
  }

  Future<void> checkPwd(String value) async {
    keystorePath = textEditingControllerKeyFile.text.toString();
    mPassword = textEditingControllerPwd.text.toString();
    print("aaa" + mPassword);
    var keytoolStr =
        "echo " + mPassword + "|keytool -v -list -keystore " + keystorePath;
    await shell.run('''$keytoolStr''').then((value) => handle(value.outText));
  }

  success() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text("签名成功,文件路径:" + signedApkPath),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(1),
                child: Text('确定'),
              ),
            ],
          );
        });
  }
}
