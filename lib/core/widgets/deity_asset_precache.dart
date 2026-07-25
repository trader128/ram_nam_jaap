import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/deity/domain/deity_catalog.dart';

/// Warms deity artwork into the image cache once at startup to reduce first-frame jank.
class DeityAssetPrecache extends ConsumerStatefulWidget {
  const DeityAssetPrecache({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DeityAssetPrecache> createState() => _DeityAssetPrecacheState();
}

class _DeityAssetPrecacheState extends ConsumerState<DeityAssetPrecache> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = (MediaQuery.sizeOf(context).width * dpr).round();
    for (final deity in DeityCatalog.all) {
      precacheImage(
        ResizeImage(
          AssetImage(deity.backgroundImage),
          width: width,
        ),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
