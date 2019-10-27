import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familytree/core/constants/app_constants.dart';
import 'package:familytree/core/models/authentication/user_model.dart';
import 'package:familytree/core/viewmodels/widget/edit_profile_view_model.dart';
import 'package:familytree/ui/helper/base_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class EditProfileDialog extends StatefulWidget {
  final Function(User user) updateUser;
  final User user;
  const EditProfileDialog({this.updateUser, this.user});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final List<CropAspectRatioPreset> ratioPresets = [
    CropAspectRatioPreset.square,
    CropAspectRatioPreset.ratio3x2,
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.ratio4x3,
    CropAspectRatioPreset.ratio16x9
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
  User updateData;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _updateProfilePicture(
      Future<bool> Function(File image) uploadProfileImage) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) => Container(
        child: Wrap(
          children: <Widget>[
            ListTile(
              title: Text('Ambil gambar kamera'),
              onTap: () => openCamera(uploadProfileImage),
            ),
            ListTile(
              title: Text('Ambil gambar gallery'),
              onTap: () => openGallery(uploadProfileImage),
            ),
          ],
        ),
      ),
    );
  }

  void openCamera(Future<bool> Function(File image) uploadProfileImage) async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.camera);
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: ratioPresets,
        androidUiSettings: androidUiSettings,
        iosUiSettings: iosUiSettings,
      );

      if (croppedFile != null) {
        var uploadResult = await uploadProfileImage(croppedFile);
        if (uploadResult) {
          Toast.show(
            "Gambar berjaya ditukar!",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
          );
          Navigator.pop(context);
        } else {
          Toast.show(
            "Gambar tidak berjaya ditukar",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
          );
          Navigator.pop(context);
        }
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

  void openGallery(Future<bool> Function(File image) uploadProfileImage) async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: ratioPresets,
        androidUiSettings: androidUiSettings,
        iosUiSettings: iosUiSettings,
      );

      if (croppedFile != null) {
        var uploadResult = await uploadProfileImage(croppedFile);
        if (uploadResult) {
          Toast.show(
            "Gambar berjaya ditukar!",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
          );
          Navigator.pop(context);
        } else {
          Toast.show(
            "Gambar tidak berjaya ditukar",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
          );
          Navigator.pop(context);
        }
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: new AppBar(
        title: const Text('Kemaskini Profil'),
        centerTitle: true,
      ),
      body: BaseWidget<EditProfileViewModel>(
        model: EditProfileViewModel(
            firestore: Firestore.instance,
            firebaseStorage: FirebaseStorage.instance),
        builder: (context, model, child) => Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 120.0,
                      top: 25.0,
                      bottom: 25.0,
                    ),
                    child: CircleAvatar(
                      backgroundImage: model.profileImage == null
                          ? NetworkImage(
                              'https://www.microsoft.com/en-us/research/wp-content/uploads/2017/09/avatar_user_36443_1506533427.jpg')
                          : null,
                      child: model.profileImage != null
                          ? ClipOval(
                              child: Image.network(
                                model.profileImage,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(),
                      radius: screenSize.height * 0.07,
                    ),
                  ),
                  Divider(
                    thickness: 2.0,
                    color: ColorPalette.oceanGreenColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: TextFormField(
                      onSaved: model.setBirthPlace,
                      initialValue: widget.user.birthPlace,
                      decoration: InputDecoration(
                        hintText: 'Tempat Lahir',
                        labelText: 'Tempat Lahir',
                        contentPadding: EdgeInsets.all(20.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: ColorPalette.keppelColor,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: ColorPalette.keppelColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: TextFormField(
                      onSaved: model.setCurrentAddress,
                      initialValue: widget.user.currentAddress,
                      decoration: InputDecoration(
                        hintText: 'Alamat Sekarang',
                        labelText: 'Alamat',
                        contentPadding: EdgeInsets.all(20.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: ColorPalette.keppelColor,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: ColorPalette.keppelColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: TextFormField(
                      onSaved: model.setCurrentState,
                      initialValue: widget.user.currentState,
                      decoration: InputDecoration(
                        hintText: 'Negeri Sekarang',
                        labelText: 'Negeri',
                        contentPadding: EdgeInsets.all(20.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: ColorPalette.keppelColor,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: ColorPalette.keppelColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2.0,
                    color: ColorPalette.oceanGreenColor,
                  ),
                  FlatButton(
                    onPressed: () =>
                        _updateProfilePicture(model.uploadProfileImage),
                    child: Text(
                      'Change Picture',
                      style: TextStyle(
                        color: ColorPalette.keppelColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2.0,
                    color: ColorPalette.oceanGreenColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Center(
                      child: Container(
                        width: screenSize.width * 0.5,
                        height: screenSize.height * 0.05,
                        child: RaisedButton(
                          color: ColorPalette.blueSapphireColor,
                          onPressed: () async {
                            _formKey.currentState.save();
                            await model.updateProfile(widget.user);
                            widget.user.birthPlace = model.birthPlace;
                            widget.user.currentAddress = model.currentAddress;
                            widget.user.currentState = model.currentState;
                            widget.user.image = model.profileImage;
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              color: ColorPalette.teaGreenColor,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
