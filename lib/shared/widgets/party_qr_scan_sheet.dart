import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/app_palette.dart';
import 'app_bottom_sheet_frame.dart';

Future<String?> showPartyQrScannerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _PartyQrScannerSheet(),
  );
}

class _PartyQrScannerSheet extends StatefulWidget {
  const _PartyQrScannerSheet();

  @override
  State<_PartyQrScannerSheet> createState() => _PartyQrScannerSheetState();
}

class _PartyQrScannerSheetState extends State<_PartyQrScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    returnImage: false,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resolveBarcode(BarcodeCapture capture) async {
    if (_handled) {
      return;
    }
    final value = capture.barcodes
        .map((item) => item.rawValue?.trim())
        .whereType<String>()
        .firstWhere((item) => item.isNotEmpty, orElse: () => '');
    if (value.isEmpty) {
      return;
    }

    _handled = true;
    await _controller.stop();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppBottomSheetFrame(
      maxHeightFactor: 0.78,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Сканировать QR', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'После распознавания код автоматически подставится и партия сразу проверится.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 360,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      fit: BoxFit.cover,
                      onDetect: _resolveBarcode,
                      errorBuilder: (context, error) {
                        return ColoredBox(
                          color: palette.surfaceMuted,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Не удалось открыть камеру. Проверьте разрешение в браузере и попробуйте снова.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              await _controller.stop();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
      child: const SizedBox.shrink(),
    );
  }
}
