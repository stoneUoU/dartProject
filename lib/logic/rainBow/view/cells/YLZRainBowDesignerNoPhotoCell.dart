import 'package:FlutterProject/base/config/YLZMacros.dart';
import 'package:FlutterProject/base/config/YLZStyle.dart';
import 'package:FlutterProject/logic/rainBow/model/YLZRainBowModel.dart';
import 'package:FlutterProject/logic/rainBow/view/YLZRainBowBoxLabelView.dart';
import 'package:flutter/material.dart';

class YLZRainBowDesignerNoPhotoCell extends StatefulWidget {
  Rs rs;
  YLZRainBowDesignerNoPhotoCell({Key? key, required this.rs}) : super(key: key);

  @override
  _YLZRainBowDesignerNoPhotoCellState createState() =>
      _YLZRainBowDesignerNoPhotoCellState();
}

class _YLZRainBowDesignerNoPhotoCellState
    extends State<YLZRainBowDesignerNoPhotoCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScreenW(context) - 30,
        margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: new Column(
          children: <Widget>[
            _makeTopView(widget.rs),
            _makeCenterView(),
            _makeBottomView(widget.rs),
          ],
        ));
  }

  Widget _makeTopView(Rs rs) {
    return Row(
      children: <Widget>[
        new Container(
          width: 45.0,
          height: 45.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.5),
            child: FadeInImage.assetNetwork(
              placeholder: "assets/images/avater_icon.png",
              image: "${rs.headImage}",
              fit: BoxFit.cover,
            ),
          ),
        ),
        new Container(
            margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: Column(
              children: <Widget>[
                new Container(
                  width: ScreenW(context) - 30.0 - 60.0,
                  child: Text(
                    "${widget.rs.userName}",
                    style:
                        TextStyle(color: Color(YLZColorTitleTwo), fontSize: 14),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                new Container(
                  width: ScreenW(context) - 30.0 - 60.0,
                  child: Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 1,
                        child: Text(
                          "${widget.rs.city}",
                          style: TextStyle(
                              color: Color(YLZColorTitleTwo), fontSize: 14),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      new Expanded(
                        flex: 2,
                        child: Text(
                          "${widget.rs.priceUnit}" == ""
                              ? ""
                              : "服务：${widget.rs.priceUnit}",
                          style: TextStyle(
                              color: Color(YLZColorTitleTwo), fontSize: 14),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget _makeCenterView() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 15.0, 0, 0),
      width: ScreenW(context) - 30.0,
      height: 1,
      color: Color(YLZColorTitleTwo),
    );
  }

  Widget _makeBottomView(Rs rs) {
    if (rs.title == "") {
      return Container(
          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: YLZRainBowBoxLabelView(boxStr: "设计师"));
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              width: ScreenW(context) - 30.0,
              child: Text(
                "${widget.rs.title}",
                style: TextStyle(color: Color(YLZColorTitleTwo), fontSize: 16),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: YLZRainBowBoxLabelView(boxStr: "设计师")),
          ],
        ),
      );
    }
  }
}
