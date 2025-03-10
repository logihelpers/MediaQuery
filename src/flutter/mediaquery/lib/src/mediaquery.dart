import 'package:flet/flet.dart';
import 'package:flutter/material.dart';

class MediaQueryControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final List<Control> children;
  final FletControlBackend backend;

  const MediaQueryControl({
    super.key, this.parent,
    required this.control,
    required this.backend,
    required this.children
  });

  State<MediaQueryControl> createState() => _MediaQueryControlState();
}

class _MediaQueryControlState extends State<MediaQueryControl> with FletStoreMixin{
  @override
  Widget build(BuildContext context) {
    debugPrint("MediaQuery build ($hashCode): ${widget.control.id}");

    final mediaQuery = MediaQuery.of(context);

    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    
    () async {
      returnToFlet(screenWidth, screenHeight);
    }();

    return withPageArgs((context, pageArgs) {
      var contentCtrls =
          widget.children.where((c) => c.name == "content" && c.isVisible);
      
      var mediaQueryControl = createControl(widget.control, contentCtrls.first.id, widget.control.isDisabled);

          return constrainedControl(context, mediaQueryControl, widget.parent, widget.control);
    }); 
  }

  @override
  void initState() {
    super.initState();
  }
  
  Future<void> returnToFlet(double width, double height) async {
    widget.backend.triggerControlEvent(widget.control.id, "size_change", "$width|$height");
  }
}