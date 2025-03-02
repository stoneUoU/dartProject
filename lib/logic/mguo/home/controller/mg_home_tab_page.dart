import 'package:FlutterProject/base/config/YLZMacros.dart';
import 'package:FlutterProject/base/config/YLZStyle.dart';
import 'package:FlutterProject/base/navigator/HiNavigator.dart';
import 'package:FlutterProject/logic/mguo/home/model/mg_home_model.dart';
import 'package:FlutterProject/logic/mguo/home/model/mg_home_nav_model.dart';
import 'package:FlutterProject/logic/mguo/home/model/mg_home_slide_model.dart';
import 'package:FlutterProject/logic/mguo/home/model/mg_marquee_model.dart';
import 'package:FlutterProject/logic/mguo/home/view/cell/mg_home_square_cell.dart';
import 'package:FlutterProject/logic/mguo/home/view/mg_footer_ad_widget.dart';
import 'package:FlutterProject/logic/mguo/home/view/mg_footer_button_widget.dart';
import 'package:FlutterProject/logic/mguo/home/view/mg_footer_feedback_widget.dart';
import 'package:FlutterProject/logic/mguo/home/view/mg_home_header_widget.dart';
import 'package:FlutterProject/logic/mguo/home/view/mg_home_more_column_header_widget.dart';
import 'package:FlutterProject/net/dao/mguo/mg_home_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../view/cell/mg_home_normal_cell.dart';

class MGHomeTabPage extends StatefulWidget {
  final MGHomeNavModel model;

  const MGHomeTabPage({Key? key, required this.model}) : super(key: key);

  @override
  _MGHomeTabPageState createState() => _MGHomeTabPageState();
}

class _MGHomeTabPageState extends State<MGHomeTabPage> {
  late Future _futureBuilderFuture;
  ScrollController _scrollController = new ScrollController();
  MGHomeModel homeModel = MGHomeModel();
  MGMarqueeModel _marqueeModel = MGMarqueeModel();
  int page = 1;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _start(widget.model.id ?? 0, page);
    if ((widget.model.id ?? 0) == 0) {
      _fetchDatas(1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MGHomeModel model = snapshot.data! as MGHomeModel;
            homeModel = model;
            return contentChild(model);
          } else {
            return Center(child: SpinKitFadingCircle(
              itemBuilder: (_, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.red : Colors.green,
                  ),
                );
              },
            ));
          }
        });
  }

  Widget contentChild(MGHomeModel homeModel) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: _buildWidget(homeModel),
        reverse: false,
        controller: _scrollController,
      ),
    );
  }

  List<Widget> _buildWidget(MGHomeModel model) {
    List<Widget> widgetList = [];
    if (widget.model.id == 0) {
      //推荐页代码：
      widgetList.add(_BannerHeaderGrid(
          homeModel: model, isRecommend: true, marqueeModel: _marqueeModel));
      widgetList.add(_MovieHeaderGrid(
        homeModel: model,
      ));
      widgetList.add(_TvHeaderGrid(
        homeModel: model,
      ));
      //添加电视剧下方的尾巴
      if ((model.video?.length ?? 0) > 0) {
        Video? video = model.video?[0];
        widgetList.add(_MGFooterGrid(video: video ?? Video(), isFinal: false));
      }
      int maxLength = (model.video?.length ?? 0);
      for (int index = 0; index < maxLength; index++) {
        Video? video = model.video?[index];
        video?.indexSection = index;
        video?.headType = 0;
        widgetList.add(_VideoHeaderGrid(
          video: video ?? Video(),
        ));
        if (index == maxLength - 1) {
          widgetList.add(_MGFooterGrid(video: video ?? Video(), isFinal: true));
        } else {
          Video? videoModel = model.video?[index + 1];
          widgetList
              .add(_MGFooterGrid(video: videoModel ?? Video(), isFinal: false));
        }
      }
    } else {
      widgetList.add(_BannerHeaderGrid(
          isRecommend: false, homeModel: model, marqueeModel: _marqueeModel));
      //渲染data里面的数据：
      widgetList.add(_MoreColumnHeaderGrid(homeModel: model));

      if (model.news!.length > 0) {
        print("AAAAAA");
        Video video = Video();
        video.headType = 2;
        video.indexSection = 6;
        video.setData(model.news!);
        video.setName("今日最新");
        widgetList.add(_VideoHeaderGrid(
          video: video,
        ));
      }
      Video video = Video();
      video.headType = 1;
      video.indexSection = 6;
      video.setData(model.data!);
      video.setName(model.typeName ?? "");
      widgetList.add(_VideoHeaderGrid(
        video: video,
      ));
    }
    return widgetList;
  }

  Future _start(int id, int page) async {
    MGHomeModel model;
    if (id == 0) {
      model = await MGHomeDao.dataRecommendLists(id, page);
    } else {
      //这里有轮播图片:
      MGSlideListModel slideListModel =
          await MGHomeDao.dataRecommendLists(id, page);
      model = await MGHomeDao.dataMoreColumnLists(id, "all");
      model.setSlide(slideListModel.slide ?? []);
    }
    return model;
  }

  _fetchDatas(int page, int limit) async {
    MGMarqueeModel model = await MGHomeDao.dataMarquees(page, limit);
    if (!mounted) return;
    setState(() {
      _marqueeModel = model;
    });
  }
}

class _BannerHeaderGrid extends StatelessWidget {
  final bool isRecommend;
  final MGHomeModel homeModel;
  final MGMarqueeModel marqueeModel;
  const _BannerHeaderGrid(
      {Key? key,
      required this.isRecommend,
      required this.homeModel,
      required this.marqueeModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        header: buildHeaderContainer(),
        sliver: SliverPadding(
          padding: EdgeInsets.all(0.0),
          sliver: buildSliverGrid(context), //SliverGrid和GridView类似)
          //一组sliver类型的小部件
        ));
  }

  SliverGrid buildSliverGrid(BuildContext context) {
    double cellWidth = ((MediaQuery.of(context).size.width));
    double desiredCellHeight = isRecommend ? 216 : 224;
    double childAspectRatio = cellWidth / desiredCellHeight;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 0.0,
          mainAxisSpacing: 0.0,
          childAspectRatio: childAspectRatio),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        MGSlideModel sildeModel = homeModel.slide![index];
                        return ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0)),
                            child: new FadeInImage.assetNetwork(
                              placeholder:
                                  "assets/images/ylz_blank_rectangle.png",
                              image: "${sildeModel.img}",
                              fit: BoxFit.cover,
                            ));
                      },
                      // viewportFraction: 0.8,
                      // scale: 0.9,
                      onTap: (index) {
                        MGSlideModel sildeModel = homeModel.slide![index];
                        // HiNavigator().onJumpTo(RouteStatus.scan);
                        HiNavigator().onJumpTo(RouteStatus.movieDetail,
                            args: {"movieId": sildeModel.id});
                        // args: {"id": 42484});
                      },
                      autoplay: true,
                      itemCount: homeModel.slide?.length ?? 0,
                      loop: true,
                      pagination: new SwiperPagination(
                          alignment: Alignment.bottomRight,
                          builder: DotSwiperPaginationBuilder(
                              activeColor: Color(YLZColorLightBlueView)))),
                ),
                _buildUnderBannerContainer(context, marqueeModel)
              ],
            ),
          );
        },
        childCount: 1,
      ),
    );
  }

  Container _buildUnderBannerContainer(
      BuildContext context, MGMarqueeModel marqueeModel) {
    if (!isRecommend) {
      return Container(
        margin: EdgeInsets.only(top: 8),
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            String listString = homeModel.categorys![index];
            return Container(
                decoration: new BoxDecoration(
                    color: Color(MGColorMainViewThree),
                    borderRadius: BorderRadius.all(Radius.circular(6.0))),
                margin: EdgeInsets.only(right: 10),
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${listString}",
                      style: TextStyle(
                          color: Color(YLZColorTitleFive),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    )),
                width: 60,
                height: 36);
          },
          itemCount: homeModel.categorys!.length,
        ),
      );
    } else {
      return Container(
        color: Color(MGColorMainViewThree),
        margin: EdgeInsets.only(top: 8),
        height: 28,
        child: Row(
          children: [
            Container(
              width: 72,
              color: Color(MGColorMainViewTwo),
              child: Image.asset(
                'assets/images/mg_home_toutiao_logo.png',
              ),
            ),
            _buildComplexMarquee(context, marqueeModel)
          ],
        ),
      );
    }
  }

  Widget _buildComplexMarquee(
      BuildContext context, MGMarqueeModel marqueeModel) {
    return Container(
        width: ScreenW(context) - (36 + 72),
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 28,
        child: Swiper(
          itemCount: marqueeModel.top?.length ?? 0,
          scrollDirection: Axis.vertical,
          loop: true,
          autoplay: true,
          itemBuilder: (BuildContext context, int index) {
            MGMarqueeTopModel topModel = marqueeModel.top![index];
            return Container(
              height: 28,
              alignment: Alignment.center,
              child: Text(
                "${topModel.title}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            );
          },
        ));
  }

  Container buildHeaderContainer() {
    return Container(height: 10.0, color: Colors.white);
  }
}

class _MovieHeaderGrid extends StatelessWidget {
  final MGHomeModel homeModel;
  const _MovieHeaderGrid({Key? key, required this.homeModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        header: _buildHeaderContainer(),
        sliver: SliverPadding(
          padding: EdgeInsets.all(0.0),
          sliver: buildSliverGrid(context, homeModel), //SliverGrid和GridView类似)
          //一组sliver类型的小部件
        ));
  }

  SliverGrid buildSliverGrid(BuildContext context, MGHomeModel homeModel) {
    double cellWidth = ((MediaQuery.of(context).size.width));
    double desiredCellHeight = 182;
    double childAspectRatio = cellWidth / desiredCellHeight;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: childAspectRatio),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                VideoModel videoModel = homeModel.hotvideo![index];
                return InkWell(
                  child: Container(
                    margin: EdgeInsets.only(
                        right:
                            index == homeModel.hotvideo!.length - 1 ? 0 : 10),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                  child: new FadeInImage.assetNetwork(
                                    placeholder:
                                        "assets/images/ylz_blank_rectangle.png",
                                    image: "${videoModel.img}",
                                    fit: BoxFit.cover,
                                  )),
                              width: 104,
                              height: 146,
                            ),
                            Positioned(
                                right: 6,
                                bottom: 6,
                                child: Text(
                                  "${videoModel.score}",
                                  style: TextStyle(
                                      color: Colors.deepOrange, fontSize: 16),
                                ))
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 104,
                          height: 36,
                          child: Text(
                            "${videoModel.name}",
                            style: TextStyle(
                                color: Color(YLZColorTitleOne), fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    HiNavigator().onJumpTo(RouteStatus.movieDetail,
                        args: {"movieId": videoModel.id});
                  },
                );
              },
              itemCount: homeModel.hotvideo?.length ?? 0,
            ),
          );
        },
        childCount: 1,
      ),
    );
  }

  Container _buildHeaderContainer() {
    return Container(
      alignment: Alignment.centerLeft,
      height: 44,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Container(
                child: Image.asset(
              'assets/images/mg_home_tuijian_icon.png',
            )),
            Container(
              margin: EdgeInsets.only(left: 12.0),
              child: Text(
                "推荐电影",
                style: TextStyle(color: Color(YLZColorTitleOne), fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TvHeaderGrid extends StatelessWidget {
  final MGHomeModel homeModel;
  const _TvHeaderGrid({Key? key, required this.homeModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        header: buildHeaderContainer(),
        sliver: SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: buildSliverGrid(context), //SliverGrid和GridView类似)
          //一组sliver类型的小部件
        ));
  }

  SliverGrid buildSliverGrid(BuildContext context) {
    double cellWidth = ((MediaQuery.of(context).size.width - 42) / 2);
    double desiredCellHeight = 136;
    double childAspectRatio = cellWidth / desiredCellHeight;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: childAspectRatio),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          VideoModel? videoModel = homeModel.tv?.data?[index];
          return InkWell(
              child: MgHomeNormalCell(
                  videoModel: videoModel, cellWidth: cellWidth),
              onTap: () {
                HiNavigator().onJumpTo(RouteStatus.movieDetail,
                    args: {"movieId": videoModel?.id ?? 0});
                // HiNavigator()
                //     .onJumpTo(RouteStatus.videoPlay, args: {"id": 42484});
              });
        },
        childCount: homeModel.tv?.data?.length ?? 0,
      ),
    );
  }

  Container buildHeaderContainer() {
    return Container(
      alignment: Alignment.centerLeft,
      height: 44,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Container(
                child: Image.asset(
              'assets/images/mg_home_opera_icon.png',
            )),
            Container(
              margin: EdgeInsets.only(left: 12.0),
              child: Text(
                "电视剧",
                style: TextStyle(color: Color(YLZColorTitleOne), fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _VideoHeaderGrid extends StatelessWidget {
  final Video video;
  const _VideoHeaderGrid({Key? key, required this.video}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        header: MGHomeHeaderWidget(video: video),
        sliver: SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: buildSliverGrid(context), //SliverGrid和GridView类似)
          //一组sliver类型的小部件
        ));
  }

  SliverGrid buildSliverGrid(BuildContext context) {
    if (video.indexSection == 0) {
      double cellWidth = ((MediaQuery.of(context).size.width - 42) / 2);
      double desiredCellHeight = 136;
      double childAspectRatio = cellWidth / desiredCellHeight;
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: childAspectRatio),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            VideoModel? videoModel = video.data?[index];
            return MgHomeNormalCell(
                videoModel: videoModel, cellWidth: cellWidth);
          },
          childCount: video.data?.length ?? 0,
        ),
      );
    } else {
      double cellWidth = (MediaQuery.of(context).size.width - 52) / 3;
      double desiredCellHeight = 196;
      double childAspectRatio = cellWidth / desiredCellHeight;
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: childAspectRatio),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            VideoModel? videoModel = video.data?[index];
            return InkWell(
                child: MgHomeSquareCell(
                    videoModel: videoModel, cellWidth: cellWidth),
                onTap: () {
                  HiNavigator().onJumpTo(RouteStatus.movieDetail,
                      args: {"movieId": videoModel?.id ?? 0});
                });
          },
          childCount: video.data?.length ?? 0,
        ),
      );
    }
  }
}

class _MGFooterGrid extends StatelessWidget {
  final Video video;
  final bool isFinal;
  const _MGFooterGrid({Key? key, required this.video, required this.isFinal})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        header: buildHeaderContainer(),
        sliver: SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: buildSliverGrid(context), //SliverGrid和GridView类似)
          //一组sliver类型的小部件
        ));
  }

  SliverGrid buildSliverGrid(BuildContext context) {
    if (isFinal) {
      double cellWidth = MediaQuery.of(context).size.width - 32;
      double desiredCellHeight = 200;
      double childAspectRatio = cellWidth / desiredCellHeight;
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.0,
            childAspectRatio: childAspectRatio),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              // color: Colors.yellow,
              child: Column(
                children: [MGFooterButtonWidget(), MGFooterFeedBackWidget()],
              ),
            );
          },
          childCount: 1,
        ),
      );
    } else {
      if (video.ad != null) {
        double cellWidth = MediaQuery.of(context).size.width - 32;
        double desiredCellHeight = 254;
        double childAspectRatio = cellWidth / desiredCellHeight;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
              childAspectRatio: childAspectRatio),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Container(
                // color: Colors.yellow,
                child: Column(
                  children: [
                    MGFooterButtonWidget(),
                    MGFooterAdWidget(
                      adModel: video.ad ?? AdModel(),
                    )
                  ],
                ),
              );
            },
            childCount: 1,
          ),
        );
      } else {
        double cellWidth = MediaQuery.of(context).size.width - 32;
        double desiredCellHeight = 76;
        double childAspectRatio = cellWidth / desiredCellHeight;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
              childAspectRatio: childAspectRatio),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Container(
                // color: Colors.yellow,
                child: Column(
                  children: [MGFooterButtonWidget()],
                ),
              );
            },
            childCount: 1,
          ),
        );
      }
    }
  }

  Container buildHeaderContainer() {
    return Container(height: 0, color: Colors.transparent);
  }
}

class _MoreColumnHeaderGrid extends StatefulWidget {
  final MGHomeModel homeModel;

  const _MoreColumnHeaderGrid({Key? key, required this.homeModel})
      : super(key: key);

  @override
  _MoreColumnHeaderGridState createState() => _MoreColumnHeaderGridState();
}

class _MoreColumnHeaderGridState extends State<_MoreColumnHeaderGrid> {
  /**
   * index 0  排行榜
   * index 1  高分榜
   * index 2  热度榜
   ***/
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        header: MGHomeMoreColumnHeaderWidget(
          homeModel: widget.homeModel,
          clickListener: (int idx) {
            setState(() {
              index = idx;
            });
          },
        ),
        sliver: SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: buildSliverGrid(context), //SliverGrid和GridView类似)
          //一组sliver类型的小部件
        ));
  }

  SliverGrid buildSliverGrid(BuildContext context) {
    double cellWidth = (MediaQuery.of(context).size.width - 52) / 3;
    double desiredCellHeight = 196;
    double childAspectRatio = cellWidth / desiredCellHeight;

    List<VideoModel> list = [];
    switch (this.index) {
      case 0:
        list = widget.homeModel.topAll ?? [];
        break;
      case 1:
        list = widget.homeModel.topScore ?? [];
        break;
      default:
        list = widget.homeModel.topHit ?? [];
        break;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: childAspectRatio),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          VideoModel videoModel = list[index];
          return InkWell(
              child: MgHomeSquareCell(
                  videoModel: videoModel, cellWidth: cellWidth),
              onTap: () {
                HiNavigator().onJumpTo(RouteStatus.movieDetail,
                    args: {"movieId": videoModel.id});
              });
        },
        childCount: list.length,
      ),
    );
  }
}
