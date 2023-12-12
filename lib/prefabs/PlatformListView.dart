import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PlatformListView extends StatelessWidget {
  const PlatformListView({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (PlatformProvider.of(context)!.platform == TargetPlatform.macOS) {
      return CupertinoScrollbar(
          child: ListView(
        children: children,
      ));
    }

    if (PlatformProvider.of(context)!.platform == TargetPlatform.windows ||
        PlatformProvider.of(context)!.platform == TargetPlatform.linux ||
        PlatformProvider.of(context)!.platform == TargetPlatform.fuchsia) {
      return Scrollbar(
          child: ListView(
        children: children,
      ));
    }

    return SingleChildScrollView(
      child: Column(
        children: children,
      ),
    );
  }
}
