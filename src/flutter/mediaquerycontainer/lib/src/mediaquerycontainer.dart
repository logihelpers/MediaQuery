import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flet/src/utils/launch_url.dart';

class MediaQueryContainerTapEvent {
  final double localX;
  final double localY;
  final double globalX;
  final double globalY;

  MediaQueryContainerTapEvent(
      {required this.localX,
      required this.localY,
      required this.globalX,
      required this.globalY});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'lx': localX,
        'ly': localY,
        'gx': globalX,
        'gy': globalY
      };
}

class MediaQueryContainerChangeEvent {
  final double width;
  final double height;

  MediaQueryContainerChangeEvent(
      {required this.width,
      required this.height});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'width': width,
        'height': height,
      };
}

class MediaQueryContainerControl extends StatefulWidget with FletStoreMixin {
  final Control? parent;
  final Control control;
  final List<Control> children;
  final bool parentDisabled;
  final bool? parentAdaptive;
  final FletControlBackend backend;

  const MediaQueryContainerControl(
      {super.key,
      this.parent,
      required this.control,
      required this.children,
      required this.parentDisabled,
      required this.parentAdaptive,
      required this.backend});

  State<MediaQueryContainerControl> createState() => _MediaQueryContainerControlState();
}

class _MediaQueryContainerControlState extends State<MediaQueryContainerControl> with FletStoreMixin {

  Future<void> returnToFlet(double _width, double _height) async {
    widget.backend.triggerControlEvent(
      widget.control.id, 
      "size_change", 
      json.encode(MediaQueryContainerChangeEvent(
          width: _width,
          height: _height)
      .toJson()));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("MediaQueryContainer build: ${widget.control.id}");

    final mediaQuery = MediaQuery.of(context);

    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    
    () async {
      returnToFlet(screenWidth, screenHeight);
    }();

    var bgColor = widget.control.attrColor("bgColor", context);
    var contentCtrls =
        widget.children.where((c) => c.name == "content" && c.isVisible);
    bool ink = widget.control.attrBool("ink", false)!;
    bool onClick = widget.control.attrBool("onclick", false)!;
    bool onTapDown = widget.control.attrBool("onTapDown", false)!;
    String url = widget.control.attrString("url", "")!;
    String? urlTarget = widget.control.attrString("urlTarget");
    bool onLongPress = widget.control.attrBool("onLongPress", false)!;
    bool onHover = widget.control.attrBool("onHover", false)!;
    bool ignoreInteractions = widget.control.attrBool("ignoreInteractions", false)!;
    bool disabled = widget.control.isDisabled || widget.parentDisabled;
    bool? adaptive = widget.control.attrBool("adaptive") ?? widget.parentAdaptive;
    Widget? child = contentCtrls.isNotEmpty
        ? createControl(widget.control, contentCtrls.first.id, disabled,
            parentAdaptive: adaptive)
        : null;

    var animation = parseAnimation(widget.control, "animate");
    var blur = parseBlur(widget.control, "blur");
    var colorFilter =
        parseColorFilter(widget.control, "colorFilter", Theme.of(context));
    var width = widget.control.attrDouble("width");
    var height = widget.control.attrDouble("height");
    var padding = parseEdgeInsets(widget.control, "padding");
    var margin = parseEdgeInsets(widget.control, "margin");
    var alignment = parseAlignment(widget.control, "alignment");

    return withPageArgs((context, pageArgs) {
      var borderRadius = parseBorderRadius(widget.control, "borderRadius");
      var clipBehavior = parseClip(widget.control.attrString("clipBehavior"),
          borderRadius != null ? Clip.antiAlias : Clip.none)!;
      var decorationImage =
          parseDecorationImage(Theme.of(context), widget.control, "image", pageArgs);
      var boxDecoration = boxDecorationFromDetails(
        shape: parseBoxShape(widget.control.attrString("shape"), BoxShape.rectangle)!,
        color: bgColor,
        gradient: parseGradient(Theme.of(context), widget.control, "gradient"),
        borderRadius: borderRadius,
        border: parseBorder(Theme.of(context), widget.control, "border",
            Theme.of(context).colorScheme.primary),
        boxShadow: parseBoxShadow(Theme.of(context), widget.control, "shadow"),
        blendMode: parseBlendMode(widget.control.attrString("blendMode")),
        image: decorationImage,
      );
      var boxForegroundDecoration = parseBoxDecoration(
          Theme.of(context), widget.control, "foregroundDecoration", pageArgs);
      Widget? result;

      var onAnimationEnd = widget.control.attrBool("onAnimationEnd", false)!
          ? () {
              widget.backend.triggerControlEvent(
                  widget.control.id, "animation_end", "mediaquerycontainer");
            }
          : null;
      if ((onClick || url != "" || onLongPress || onHover || onTapDown) &&
          ink &&
          !disabled) {
        var ink = Material(
            color: Colors.transparent,
            borderRadius: boxDecoration!.borderRadius,
            child: InkWell(
              // Dummy callback to enable widget
              // see https://github.com/flutter/flutter/issues/50116#issuecomment-582047374
              // and https://github.com/flutter/flutter/blob/eed80afe2c641fb14b82a22279d2d78c19661787/packages/flutter/lib/src/material/ink_well.dart#L1125-L1129
              onTap: onClick || url != "" || onTapDown
                  ? () {
                      debugPrint("MediaQueryContainer ${widget.control.id} clicked!");
                      if (url != "") {
                        openWebBrowser(url, webWindowName: urlTarget);
                      }
                      if (onClick) {
                        widget.backend.triggerControlEvent(widget.control.id, "click");
                      }
                    }
                  : null,
              onTapDown: onTapDown
                  ? (details) {
                      widget.backend.triggerControlEvent(
                          widget.control.id,
                          "tap_down",
                          json.encode(MediaQueryContainerTapEvent(
                                  localX: details.localPosition.dx,
                                  localY: details.localPosition.dy,
                                  globalX: details.globalPosition.dx,
                                  globalY: details.globalPosition.dy)
                              .toJson()));
                    }
                  : null,
              onLongPress: onLongPress
                  ? () {
                      debugPrint("MediaQueryContainer ${widget.control.id} long pressed!");
                      widget.backend.triggerControlEvent(widget.control.id, "long_press");
                    }
                  : null,
              onHover: onHover
                  ? (value) {
                      debugPrint("MediaQueryContainer ${widget.control.id} hovered!");
                      widget.backend.triggerControlEvent(
                          widget.control.id, "hover", value.toString());
                    }
                  : null,
              borderRadius: borderRadius,
              splashColor: widget.control.attrColor("inkColor", context),
              child: Container(
                padding: padding,
                alignment: alignment,
                clipBehavior: Clip.none,
                child: child,
              ),
            ));

        result = animation == null
            ? Container(
                width: width,
                height: height,
                margin: margin,
                clipBehavior: clipBehavior,
                decoration: boxDecoration,
                foregroundDecoration: boxForegroundDecoration,
                child: ink,
              )
            : AnimatedContainer(
                duration: animation.duration,
                curve: animation.curve,
                width: width,
                height: height,
                margin: margin,
                decoration: boxDecoration,
                foregroundDecoration: boxForegroundDecoration,
                clipBehavior: clipBehavior,
                onEnd: onAnimationEnd,
                child: ink);
      } else {
        result = animation == null
            ? Container(
                width: width,
                height: height,
                margin: margin,
                padding: padding,
                alignment: alignment,
                decoration: boxDecoration,
                foregroundDecoration: boxForegroundDecoration,
                clipBehavior: clipBehavior,
                child: child)
            : AnimatedContainer(
                duration: animation.duration,
                curve: animation.curve,
                width: width,
                height: height,
                margin: margin,
                padding: padding,
                alignment: alignment,
                decoration: boxDecoration,
                foregroundDecoration: boxForegroundDecoration,
                clipBehavior: clipBehavior,
                onEnd: onAnimationEnd,
                child: child);

        if ((onClick || onLongPress || onHover || onTapDown || url != "") &&
            !disabled) {
          result = MouseRegion(
            cursor: onClick || onTapDown || url != ""
                ? SystemMouseCursors.click
                : MouseCursor.defer,
            onEnter: onHover
                ? (value) {
                    debugPrint(
                        "MediaQueryContainer's mouse region ${widget.control.id} entered!");
                    widget.backend.triggerControlEvent(widget.control.id, "hover", "true");
                  }
                : null,
            onExit: onHover
                ? (value) {
                    debugPrint(
                        "MediaQueryContainer's mouse region ${widget.control.id} exited!");
                    widget.backend.triggerControlEvent(widget.control.id, "hover", "false");
                  }
                : null,
            child: GestureDetector(
              onTap: onClick || url != ""
                  ? () {
                      debugPrint("MediaQueryContainer ${widget.control.id} clicked!");
                      if (url != "") {
                        openWebBrowser(url, webWindowName: urlTarget);
                      }
                      if (onClick) {
                        widget.backend.triggerControlEvent(widget.control.id, "click");
                      }
                    }
                  : null,
              onTapDown: onTapDown
                  ? (details) {
                      widget.backend.triggerControlEvent(
                          widget.control.id,
                          "tap_down",
                          json.encode(MediaQueryContainerTapEvent(
                                  localX: details.localPosition.dx,
                                  localY: details.localPosition.dy,
                                  globalX: details.globalPosition.dx,
                                  globalY: details.globalPosition.dy)
                              .toJson()));
                    }
                  : null,
              onLongPress: onLongPress
                  ? () {
                      debugPrint("MediaQueryContainer ${widget.control.id} clicked!");
                      widget.backend.triggerControlEvent(widget.control.id, "long_press");
                    }
                  : null,
              child: result,
            ),
          );
        }
      }

      if (blur != null) {
        result = borderRadius != null
            ? ClipRRect(
                borderRadius: borderRadius,
                child: BackdropFilter(filter: blur, child: result))
            : ClipRect(child: BackdropFilter(filter: blur, child: result));
      }
      if (colorFilter != null) {
        result = ColorFiltered(colorFilter: colorFilter, child: result);
      }

      if (ignoreInteractions) {
        result = IgnorePointer(child: result);
      }

      return constrainedControl(context, result, widget.parent, widget.control);
    });
  }

  @override
  void initState() {
    super.initState();
  }
}
