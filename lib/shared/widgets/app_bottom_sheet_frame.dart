import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class AppBottomSheetFrame extends StatelessWidget {
  const AppBottomSheetFrame({
    required this.child,
    super.key,
    this.header,
    this.body,
    this.maxHeightFactor = 0.88,
    this.bodyScrollable = true,
  });

  final Widget child;
  final Widget? header;
  final Widget? body;
  final double maxHeightFactor;
  final bool bodyScrollable;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final mediaQuery = MediaQuery.of(context);
    final safeTop = mediaQuery.padding.top;
    final safeBottom = mediaQuery.padding.bottom;
    final maxHeight = ((mediaQuery.size.height - safeTop - 20) *
            maxHeightFactor)
        .clamp(280.0, mediaQuery.size.height);
    final resolvedBody = body ?? child;
    final hasSplitLayout = header != null || body != null;

    return SafeArea(
      top: false,
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              10,
              14,
              12 + mediaQuery.viewInsets.bottom + safeBottom,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bodyMaxHeight = (constraints.maxHeight - 56).clamp(
                  0.0,
                  constraints.maxHeight,
                );

                return Material(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(30),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: palette.outline,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (hasSplitLayout && header != null) ...[
                            header!,
                            const SizedBox(height: 16),
                          ],
                          Flexible(
                            fit: FlexFit.loose,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: bodyMaxHeight,
                              ),
                              child:
                                  bodyScrollable
                                      ? SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child:
                                            hasSplitLayout
                                                ? resolvedBody
                                                : child,
                                      )
                                      : ClipRect(
                                        child:
                                            hasSplitLayout
                                                ? resolvedBody
                                                : child,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
