import 'dart:ffi';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toeic_quiz/constants.dart';

class AudioController extends StatefulWidget {
  AudioController({
    Key? key,
    this.durationTime = 70,
    required this.changeToDurationCallBack,
    required this.playCallBack,
    required this.pauseCallBack,
    required this.audioPlayer,
  }) : super(key: key);

  int durationTime;
  final Function(double timestamp)? changeToDurationCallBack;
  final Function() playCallBack;
  final Function() pauseCallBack;
  final AssetsAudioPlayer audioPlayer;

  String coverFormatTime(int value) {
    int min = (value / 60).toInt();
    int sec = value % 60;
    return '${min < 10 ? '0$min' : '$min'}:${sec < 10 ? '0$sec' : '$sec'}';
  }

  @override
  State<AudioController> createState() => _AudioControllerState();
}

class _AudioControllerState extends State<AudioController> {
  bool sliderIsSliding = false;
  double _currentDuration = 1.0; // for both text and slider
  double _currentSliderValue = 1.0; // just for slider for slide only
  bool isPlaying = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.audioPlayer.currentPosition.listen((positionValue) {
      setState(() {
        _currentDuration = positionValue.inSeconds.toDouble();
        if (!sliderIsSliding) _currentSliderValue = _currentDuration;
      });
    });
    //durationTime = (widget.audioPlayer.current.value as Playing).du
    widget.audioPlayer.current.listen((playingAudio) {
      widget.durationTime = playingAudio!.audio.duration.inSeconds;
    });

    widget.audioPlayer.isPlaying.listen((event) {
      setState(() {
        isPlaying = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Material(
      color: isDarkMode ? kSurfaceDarkColor : kBottomControllerBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Row(
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.all(kPaddingIconButton),
                  constraints: BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _currentDuration = (_currentDuration - 5) > 0
                          ? (_currentDuration - 5)
                          : 0.0;
                      _currentSliderValue = _currentDuration;
                      widget.changeToDurationCallBack!(_currentDuration);
                    });
                  },
                  icon: Icon(
                    Icons.replay_5_rounded,
                    color: isDarkMode
                        ? kOnSurfaceDarkColorText
                        : kIconBottomControllerColor,
                  ),
                ),
                IconButton(
                  // play
                  padding: EdgeInsets.all(kPaddingIconButton),
                  constraints: BoxConstraints(),
                  onPressed: () {
                    if (isPlaying)
                      widget.pauseCallBack();
                    else
                      widget.playCallBack();
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                    color: isDarkMode
                        ? kOnSurfaceDarkColorText
                        : kIconBottomControllerColor,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.all(kPaddingIconButton),
                  constraints: BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _currentDuration =
                          (_currentDuration + 5) < widget.durationTime
                              ? (_currentDuration + 5)
                              : widget.durationTime.toDouble();
                      _currentSliderValue = _currentDuration;
                      widget.changeToDurationCallBack!(_currentDuration);
                    });
                  },
                  icon: Icon(
                    Icons.forward_5_rounded,
                    color: isDarkMode
                        ? kOnSurfaceDarkColorText
                        : kIconBottomControllerColor,
                  ),
                ),
                SizedBox(width: 6.0),
                //Text(widget.coverFormatTime(_currentDuration.toInt())),
                Text(widget.coverFormatTime(_currentDuration.toInt())),
              ],
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                    //thumbColor: Colors.green,
                    trackShape: RectangularSliderTrackShape(),
                    activeTrackColor: kSliderActiveColor,
                    inactiveTrackColor: kSliderInactiveColor,
                    thumbColor: kSliderActiveColor,
                    inactiveTickMarkColor: Colors.transparent,
                    activeTickMarkColor: Colors.transparent,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7)),
                child: Slider(
                  value: _currentSliderValue,
                  label: widget.coverFormatTime(_currentSliderValue.toInt()),
                  divisions: widget.durationTime,
                  min: 0.0,
                  max: widget.durationTime.toDouble(),
                  onChanged: (val) {
                    sliderIsSliding = true;
                    setState(() {
                      _currentSliderValue = val;
                    });
                  },
                  onChangeEnd: (val) {
                    sliderIsSliding = false;
                    setState(() {
                      _currentDuration = val;
                    });
                    widget.changeToDurationCallBack!(val);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
