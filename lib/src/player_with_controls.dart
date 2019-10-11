import 'dart:ui';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/cupertino_controls.dart';
import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatefulWidget {
  PlayerWithControls({Key key}) : super(key: key);

  @override
  _PlayerWithControlsState createState() => _PlayerWithControlsState();
}

class _PlayerWithControlsState extends State<PlayerWithControls> {
  bool isPlaying = false;

  VideoPlayerController _videoPlayerController;

  @override
  void didChangeDependencies() {
    VideoPlayerController oldController = _videoPlayerController;
    _videoPlayerController =  ChewieController.of(context).videoPlayerController;
    if (oldController != _videoPlayerController) {
      oldController?.removeListener(listener);
      _videoPlayerController.addListener(listener);
    }
    super.didChangeDependencies();
  }

  void listener() {
    setState(() {
      isPlaying = _videoPlayerController.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio:
              chewieController.aspectRatio ?? _calculateAspectRatio(context),
          child: _buildPlayerWithControls(chewieController, context),
        ),
      ),
    );
  }
 
  Container _buildPlayerWithControls(
    ChewieController chewieController,
    BuildContext context,
  ) {
    return Container(
      child: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: chewieController.aspectRatio ??
                  _calculateAspectRatio(context),
              child: VideoPlayer(chewieController.videoPlayerController),
            ),
          ),
          !isPlaying
              ? chewieController.placeholder ?? Container()
              : Container(),
          chewieController.overlay ?? Container(),
          _buildControls(context, chewieController),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    return chewieController.showControls
        ? chewieController.customControls != null
            ? chewieController.customControls
            : Theme.of(context).platform == TargetPlatform.android
                ? MaterialControls()
                : CupertinoControls(
                    backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                    iconColor: Color.fromARGB(255, 200, 200, 200),
                  )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
