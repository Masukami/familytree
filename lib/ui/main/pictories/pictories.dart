import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familytree/core/constants/app_constants.dart';
import 'package:familytree/core/models/authentication/user_model.dart';
import 'package:familytree/core/viewmodels/views/pictories_view_model.dart';
import 'package:familytree/ui/helper/base_widget.dart';
import 'package:familytree/ui/main/pictories/new_pictory.dart';
import 'package:familytree/ui/main/pictories/pictory_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PictoriesScreen extends StatefulWidget {
  @override
  _PictoriesScreenState createState() => _PictoriesScreenState();
}

class _PictoriesScreenState extends State<PictoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BaseWidget<PictoriesViewModel>(
      model: PictoriesViewModel(
        userID: Provider.of<User>(context).id,
        firestore: Firestore.instance,
      ),
      onModelReady: (model) => model.getPictories(),
      builder: (context, model, child) => Stack(
        children: <Widget>[
          model.pictories != null && model.pictories.length > 0
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15.0,
                  ),
                  child: ListView.builder(
                    itemCount: model.pictories.length,
                    itemBuilder: (context, index) => Card(
                      child: InkWell(
                        onTap: () {
                          var route = MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PictoryDetailScreen(
                              pictory: model.pictories[index],
                            ),
                          );
                          Navigator.push(context, route);
                        },
                        child: Stack(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Image.network(
                                  model.pictories[index].image,
                                  fit: BoxFit.cover,
                                  height: screenSize.height * 0.2,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        model.pictories[index].title,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                color: ColorPalette.keppelColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    DateFormat('dd MMM').format(
                                      model.pictories[index].date,
                                    ),
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.035,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                    ),
                  ),
                )
              : Container(
                  child: Center(
                    child: Text(
                      'TIADA PICTORIES DIJUMPAI',
                      style: TextStyle(
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          Positioned(
            top: screenSize.height * 0.7,
            right: screenSize.width * 0.1,
            child: FloatingActionButton(
              backgroundColor: ColorPalette.keppelColor,
              onPressed: () async => await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (BuildContext context) => NewPictoryDialog(
                          updatePictories: model.updatePictories,
                        ),
                    fullscreenDialog: true),
              ),
              child: Icon(Icons.edit),
            ),
          )
        ],
      ),
    );
  }
}
