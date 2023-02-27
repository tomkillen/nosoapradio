import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart' as forge2d;
import '../../../models/bubble.dart';

/// Callback delegate for when this bubble is selected
typedef OnBubbleSelected = Function(BuildContext context, Bubble bubble);

/// Callback delegate for when this bubble is popped
typedef OnBubblePopped = Function(Bubble bubble);

/// UI Widget for displaying a UI element whose position and size is driven
/// by the physics simulation BubbleSimulation.
class RadioStationBubble extends StatefulWidget {
  /// The bubble this UI element represents
  final Bubble bubble;

  /// Callback when this bubble was selected (double tap)
  final OnBubbleSelected onBubbleSelected;

  /// Callback when this bubble was popped (single tap)
  final OnBubblePopped onBubblePopped;

  const RadioStationBubble(
      {super.key, required this.bubble, required this.onBubbleSelected, required this.onBubblePopped});

  @override
  State<RadioStationBubble> createState() => _RadioStationBubbleState();
}

class _RadioStationBubbleState extends State<RadioStationBubble> {
  StreamSubscription<forge2d.Vector2>? _positionStreamSubscription;
  forge2d.Vector2 _position = forge2d.Vector2.zero();
  double _radius = 0;
  double _angle = 0;

  @override
  void initState() {
    super.initState();

    // Initialize our transform to the current state of the bubble
    _position = widget.bubble.position;
    _radius = widget.bubble.radius;

    // Subscribe to the position stream of this bubble for updating our position
    _positionStreamSubscription = widget.bubble.positionStream.stream.listen((position) {
      setState(() {
        _position = position;

        // this could be it's own stream but we dont need to update this more
        // frequently than position. This suggests some packed data type should
        // be what is stream. Perhaps the bubble itself, or perhaps a matrix
        // representation
        _angle = widget.bubble.angle;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Position this element at the position indicated by the physics sim
    return Positioned(
        top: _position.y - _radius,
        left: _position.x - _radius,

        // 2. Constrain the size of this bubble to the size of the physics body
        child: SizedBox(
          width: _radius * 2,
          height: _radius * 2,

          // 3. Stack a bubble texture on top of the radio station cover art
          child: Stack(
            children: [
              // 4. Position the cover art a bit inside the bubble
              Positioned(
                  top: 2,
                  left: 2,
                  // 4. Position the cover art a bit inside the bubble
                  child: SizedBox(
                    width: _radius * 2 - 4,
                    height: _radius * 2 - 4,
                    // 5. Clip the shape of the rendered image to be a circle, fitting within the bubble
                    child: ClipOval(
                        // 6. The cover art image should rotate but the bubble texture should not
                        // since the bubble texture has highlights that remain fixed, so we get a kind
                        // of parallax-esque effect as the cover art rotates within the bubble
                        child: Transform.rotate(
                            angle: _angle,

                            /// 7. Load the cover art, using the network cache
                            child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: widget.bubble.station!.favicon,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error)))),
                  )),

              // 8. Listen for user input, a tap pops this bubble and a double tap selects it
              GestureDetector(
                  onDoubleTap: () => widget.onBubbleSelected(context, widget.bubble),
                  onTap: () => widget.onBubblePopped(widget.bubble),
                  // 9. Place a bubble texture over the top of the bubble to make it look like a bubble
                  // with some nice oily highlights
                  child: const Image(image: AssetImage('assets/images/oily_bubble.png')))
            ],
          ),
        ));
  }
}
