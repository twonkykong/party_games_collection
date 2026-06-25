import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PartyQrCodeCard extends StatelessWidget {
  const PartyQrCodeCard({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        children: [
          QrImageView(
            data: code,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: Colors.white,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: const Color(0xFF111111),
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Сканируйте QR-код, чтобы подключиться без ручного ввода',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF3E3632)),
          ),
        ],
      ),
    );
  }
}
