import 'dart:async';
import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_instagram_stories/story_controller.dart';

import 'story_view.dart';
import 'utils.dart';

class VideoLoader {
  String? url;

  File? videoFile;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    if (this.videoFile != null) {
      this.state = LoadState.loading;
    }

    final Stream<FileInfo> fileStream =
        // ignore: deprecated_member_use
        DefaultCacheManager().getFile(this.url!,
            headers: this.requestHeaders as Map<String, String>?);

    fileStream.listen((fileInfo) {
      if (this.videoFile == null) {
        this.state = LoadState.success;
        this.videoFile = fileInfo.file;
        onComplete();
      }
    });
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final String? url;

  StoryVideo({this.url, this.storyController, Key? key})
      : super(key: key ?? UniqueKey());

  static StoryVideo fromUrl({
    String? url,
    StoryController? controller,
    VoidCallback? adjustDuration,
    Key? key,
  }) {
    return StoryVideo(
      url: url,
      storyController: controller,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void>? playerLoader;

  StreamSubscription? _streamSubscription;

  CachedVideoPlayerController? playerController;

  @override
  void initState() {
    super.initState();
    if (widget.url == null) {
      return;
    }

    playerController = CachedVideoPlayerController.network(widget.url!);
    playerController?.initialize().then((v) {
      widget.storyController!.play();
      setState(() {});
    });

    if (widget.storyController != null) {
      playerController?.addListener(checkIfVideoFinished);
      _streamSubscription =
          widget.storyController!.playbackNotifier.listen((playbackState) {
        if (playbackState == PlaybackState.pause) {
          playerController?.pause();
        } else {
          playerController?.play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  Widget getContentView() {
    if (widget.url == null) {
      return Container();
    }
    if (playerController?.value.isInitialized ?? false) {
      return Center(
        child: AspectRatio(
          aspectRatio: playerController!.value.aspectRatio,
          child: CachedVideoPlayer(playerController!),
        ),
      );
    }
    return !(playerController?.value.hasError ?? true)
        ? Center(
            child: Container(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          )
        : Center(
            child: Text(
            "Media failed to load.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ));
  }

  @override
  void dispose() {
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  void checkIfVideoFinished() {
    try {
      if (playerController?.value.position.inSeconds ==
          playerController?.value.duration.inSeconds) {
        playerController?.removeListener(checkIfVideoFinished);
      }
    } catch (e) {}
  }
}
