import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

import 'models/stories_data.dart';
import 'models/stories_list_with_pressed.dart';
import 'settings.dart';
import 'story_view.dart';

export 'settings.dart';
export 'story_controller.dart';
export 'story_image.dart';
export 'story_video.dart';
export 'story_view.dart';

class GroupedStoriesView extends StatefulWidget {
  final String? collectionDbName;
  final String? languageCode;
  final int? imageStoryDuration;
  final ProgressPosition? progressPosition;
  final bool? repeat;
  final bool? inline;
  final Icon? closeButtonIcon;
  final Color? closeButtonBackgroundColor;
  final Color? backgroundColorBetweenStories;
  final bool? sortingOrderDesc;
  final TextStyle? captionTextStyle;
  final EdgeInsets? captionMargin;
  final EdgeInsets? captionPadding;

  GroupedStoriesView(
      {this.collectionDbName,
      this.languageCode,
      this.imageStoryDuration,
      this.progressPosition,
      this.repeat,
      this.inline,
      this.backgroundColorBetweenStories,
      this.closeButtonIcon,
      this.closeButtonBackgroundColor,
      this.sortingOrderDesc,
      this.captionTextStyle,
      this.captionMargin,
      this.captionPadding});

  @override
  _GroupedStoriesViewState createState() => _GroupedStoriesViewState();
}

class _GroupedStoriesViewState extends State<GroupedStoriesView> {
  final _firestore = FirebaseFirestore.instance;
  final storyController = StoryController();
  List<List<StoryItem>> storyItemList = [];
  late StoriesData _storiesData;

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _storiesData = StoriesData(
      languageCode: widget.languageCode,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final StoriesListWithPressed storiesListWithPressed =
        ModalRoute.of(context)!.settings.arguments as StoriesListWithPressed;
    return DismissiblePage(
      direction: DismissiblePageDismissDirection.down,
      onDismissed: () {
        Navigator.of(context).pop();
      },
      child: WillPopScope(
        onWillPop: () {
          _navigateBack();
          return Future.value(false);
        },
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: widget.backgroundColorBetweenStories,
            body: Stack(
              children: [
                Container(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: _firestore
                        .collection(widget.collectionDbName!)
                        .doc(storiesListWithPressed.pressedStoryId)
                        .get(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.grey[700],
                          ),
                        );
                      }
                      Map<String, dynamic> toPass = {
                        'snapshotData': snapshot.data?.data(),
                        'pressedStoryId': storiesListWithPressed.pressedStoryId,
                        'captionTextStyle': widget.captionTextStyle,
                      };
                      _storiesData.parseStories(
                        toPass,
                        widget.imageStoryDuration,
                        widget.captionTextStyle,
                        widget.captionMargin,
                        widget.captionPadding,
                      );
                      storyItemList.add(_storiesData.storyItems);

                      return Hero(
                        tag: storiesListWithPressed.pressedStoryId ?? '',
                        child: Dismissible(
                            background: Container(
                                color: widget.backgroundColorBetweenStories),
                            crossAxisEndOffset: 0.0,
                            key: UniqueKey(),
                            onDismissed: (DismissDirection direction) {
                              if (direction == DismissDirection.endToStart) {
                                String? nextStoryId =
                                    storiesListWithPressed.nextElementStoryId();
                                if (nextStoryId == null) {
                                  _navigateBack();
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    TransitionRightMaterialPageRoute(
                                      builder: (context) =>
                                          _groupedStoriesView(),
                                      settings: RouteSettings(
                                        arguments: StoriesListWithPressed(
                                            pressedStoryId: nextStoryId,
                                            storiesIdsList:
                                                storiesListWithPressed
                                                    .storiesIdsList),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                String? previousStoryId = storiesListWithPressed
                                    .previousElementStoryId();
                                if (previousStoryId == null) {
                                  _navigateBack();
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    TransitionLeftMaterialPageRoute(
                                      builder: (context) =>
                                          _groupedStoriesView(),
                                      settings: RouteSettings(
                                        arguments: StoriesListWithPressed(
                                            pressedStoryId: previousStoryId,
                                            storiesIdsList:
                                                storiesListWithPressed
                                                    .storiesIdsList),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: StoryView(
                              widget.sortingOrderDesc!
                                  ? storyItemList[0].reversed.toList()
                                  : storyItemList[0],
                              controller: storyController,
                              progressPosition: widget.progressPosition!,
                              repeat: widget.repeat!,
                              inline: widget.inline!,
                              onStoryShow: (StoryItem s) {
                                _onStoryShow(s);
                              },
                              goForward: () {},
                              onComplete: () {
                                String? nextStoryId =
                                    storiesListWithPressed.nextElementStoryId();
                                if (nextStoryId == null) {
                                  _navigateBack();
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    TransitionRightMaterialPageRoute(
                                      builder: (context) =>
                                          _groupedStoriesView(),
                                      settings: RouteSettings(
                                        arguments: StoriesListWithPressed(
                                          pressedStoryId: nextStoryId,
                                          storiesIdsList: storiesListWithPressed
                                              .storiesIdsList,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            )),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: widget.closeButtonIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GroupedStoriesView _groupedStoriesView() {
    return GroupedStoriesView(
      collectionDbName: widget.collectionDbName,
      languageCode: widget.languageCode,
      imageStoryDuration: widget.imageStoryDuration,
      captionTextStyle: widget.captionTextStyle,
      captionMargin: widget.captionMargin,
      captionPadding: widget.captionPadding,
      progressPosition: widget.progressPosition,
      repeat: widget.repeat,
      inline: widget.inline,
      backgroundColorBetweenStories: widget.backgroundColorBetweenStories,
      closeButtonIcon: widget.closeButtonIcon,
      closeButtonBackgroundColor: widget.closeButtonBackgroundColor,
      sortingOrderDesc: widget.sortingOrderDesc,
    );
  }

  _navigateBack() {
    Navigator.pop(context);
    // return Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   '/',
    //   (_) => false,
    //   arguments: 'back_from_stories_view',
    // );
  }

  void _onStoryShow(StoryItem s) {}
}

class TransitionRightMaterialPageRoute<T> extends MaterialPageRoute<T> {
  TransitionRightMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

class TransitionLeftMaterialPageRoute<T> extends MaterialPageRoute<T> {
  TransitionLeftMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(0.0, 0.0);
    const end = Offset(0.0, 0.0);
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
