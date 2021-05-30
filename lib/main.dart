import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:simple_permissions/simple_permissions.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, //primary theme color
      ),
      home: FileDownload(), //call to homepage class
    );
  }
}
class FileDownload extends StatefulWidget{
  @override
  _FileDownloadState createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
  bool isLoading;
  bool _allowWriteFile=false;

  String progress="";
  Dio dio;

  @override
  void initState() {

    super.initState();
    dio=Dio();
  }

  requestWritePermission() async {

    PermissionStatus permissionStatus = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);



    if (permissionStatus == PermissionStatus.authorized) {

      setState(() {

        _allowWriteFile = true;

      });

    }

  }

  Future<String>getDirectoryPath() async
  {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    Directory directory= await new Directory(appDocDirectory.path+'/'+'dir').create(recursive: true);

    return directory.path;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(title: Text("FIle Download"),backgroundColor: Colors.red,),
      body: Container(
        child: GestureDetector(onTap:(){
          getDirectoryPath().then((path) {
            downloadMyFile("https://tripfinderdev.devopsolution.net/TripFiles/Jazan_Trip.pdf","$path/file  ");
          });        },child: Center(child: Text("download"),),),
      ),

    );
  }
  Future downloadMyFile(String url,path) async {
    if(!_allowWriteFile)
    {
      requestWritePermission();
    }
    try{


      ProgressDialog progressDialog=ProgressDialog(context,type: ProgressDialogType.Normal,isDismissible: false);
      progressDialog.style(message: "AppConfig.labels.downloading_file");
      progressDialog.show();


      await dio.download(url, path,onReceiveProgress: (rec,total){
        setState(() {
          isLoading=true;
          progress=((rec/total)*100).toStringAsFixed(0)+"%";
          progressDialog.update(message: "Downloading $progress");
        });

      }).then((value)  {
        progressDialog.hide();
        File f=File(path);
        debugPrint("======== "+f.path);
        if(f.existsSync())
        {
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return PDFScreen(f.path);
          }));
          return;
        }

      }).catchError((er){
        progressDialog.hide();
      });
    }

    catch( e)
    {

      debugPrint(e.toString());
    }
  }

}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Document"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        path: pathPDF);
  }
}

