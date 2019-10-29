import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familytree/core/constants/app_constants.dart';
import 'package:familytree/core/models/authentication/user_model.dart';
import 'package:familytree/core/models/pictory/pictory_model.dart';
import 'package:familytree/core/viewmodels/widget/new_pictory_view_model.dart';
import 'package:familytree/ui/helper/base_widget.dart';
import 'package:familytree/ui/helper/loading_overlay.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewPictoryDialog extends StatefulWidget {
  final void Function(Pictory data) updatePictories;

  NewPictoryDialog({this.updatePictories});

  @override
  _NewPictoryDialogState createState() => _NewPictoryDialogState();
}

class _NewPictoryDialogState extends State<NewPictoryDialog> {
  final List<CropAspectRatioPreset> ratioPresets = [
    CropAspectRatioPreset.square,
  ];
  final AndroidUiSettings androidUiSettings = AndroidUiSettings(
      toolbarTitle: 'Cropper',
      toolbarColor: Colors.deepOrange,
      toolbarWidgetColor: Colors.white,
      initAspectRatio: CropAspectRatioPreset.original,
      lockAspectRatio: false);
  final IOSUiSettings iosUiSettings = IOSUiSettings(
    minimumAspectRatio: 1.0,
  );
  TextEditingController title = TextEditingController();
  TextEditingController story = TextEditingController();
  NewPictoryViewModel npvm;
  String _dateFormat = 'dd MM yyyy';
  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;

  @override
  void initState() {
    super.initState();
    title.addListener(_updateTitle);
    story.addListener(_updateStory);
  }

  _updateTitle() {
    npvm.updateTitle(title.text);
  }

  _updateStory() {
    npvm.updateStory(story.text);
  }

  @override
  void dispose() {
    title.dispose();
    story.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text(
          'Terima',
          style: TextStyle(
            color: ColorPalette.oceanGreenColor,
          ),
        ),
        cancel: Text(
          'Batal',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
      initialDateTime: DateTime.now(),
      dateFormat: _dateFormat,
      locale: _locale,
      onConfirm: (dateTime, List<int> index) => npvm.updateDate(dateTime),
    );
  }

  void _newImage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) => Container(
        child: Wrap(
          children: <Widget>[
            ListTile(
              title: Text('Ambil gambar kamera'),
              onTap: () => openCamera(),
            ),
            ListTile(
              title: Text('Ambil gambar gallery'),
              onTap: () => openGallery(),
            ),
          ],
        ),
      ),
    );
  }

  void openCamera() async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.camera);
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: ratioPresets,
        androidUiSettings: androidUiSettings,
        iosUiSettings: iosUiSettings,
      );

      if (croppedFile != null) {
        npvm.updateImage(croppedFile);
        Navigator.pop(context);
      }
    } catch (err) {
      Toast.show(
        "Tiada gambar dijumpai",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
      Navigator.pop(context);
    }
  }

  void openGallery() async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: ratioPresets,
        androidUiSettings: androidUiSettings,
        iosUiSettings: iosUiSettings,
      );

      if (croppedFile != null) {
        npvm.updateImage(croppedFile);
        Navigator.pop(context);
      }
    } catch (err) {
      Toast.show(
        "Tiada gambar dijumpai",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
      Navigator.pop(context);
    }
  }

  void submitPictory() async {
    String postTitle = title.text.trim();
    String postStory = story.text.trim();
    if (npvm.pictoryImage == null) {
      Toast.show(
        'Sila upload gambar untuk pictory ini',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
    } else if (postTitle.isNotEmpty && postStory.isNotEmpty) {
      try {
        String result = await npvm.postPictory();
        widget.updatePictories(npvm.pictory);
        story.clear();
        title.clear();
        Toast.show(
          result,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
        Navigator.pop(context);
      } catch (err) {
        Toast.show(
          err.message,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
      }
    } else {
      Toast.show(
        'Sila isi dengan betul',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BaseWidget<NewPictoryViewModel>(
      model: NewPictoryViewModel(
          firebaseStorage: FirebaseStorage.instance,
          firestore: Firestore.instance,
          userID: Provider.of<User>(context).id),
      builder: (context, model, child) {
        npvm = model;
        return Scaffold(
          appBar: new AppBar(
            title: Text('New Pictory'),
            centerTitle: true,
          ),
          body: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                decoration: BoxDecoration(color: Colors.black87),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      model.pictoryImage != null
                          ? Image.file(
                              model.pictoryImage,
                              fit: BoxFit.cover,
                              height: screenSize.height * 0.2,
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: TextField(
                          controller: title,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15.0),
                            labelText: 'Tajuk Cerita',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorPalette.blueSapphireColor,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorPalette.teaGreenColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: TextField(
                          controller: story,
                          maxLines: 8,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15.0),
                            hintText: 'Apa yang sedang berlaku?',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorPalette.blueSapphireColor,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorPalette.teaGreenColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[350],
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Tarikh : ',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${model.date.day.toString().padLeft(2, '0')} ${model.date.month.toString().padLeft(2, '0')} ${model.date.year}',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                onPressed: () => _showDatePicker(),
                              )
                            ],
                          ),
                        ),
                      ),
                      model.pictoryImage != null
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.image,
                                      color: ColorPalette.keppelColor,
                                      size: screenSize.width * 0.06,
                                    ),
                                    onPressed: () => _newImage(),
                                  ),
                                ],
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              color: ColorPalette.keppelColor,
                              onPressed: () => submitPictory(),
                              child: Text(
                                'Hantar',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(40.0),
              ),
              model.busy ? LoadingOverlay() : Container(),
            ],
          ),
        );
      },
    );
  }
}
