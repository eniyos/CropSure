import 'package:flutter_test/flutter_test.dart';
import 'package:cropsure/services/blockchain/solana_service.dart';

void main() {
  group('SolanaService', () {
    test('anchors passport data and returns signature and explorer URL', () async {
      final service = SolanaService();
      final result = await service.anchorPassportData(
        passportId: 'pass_12345',
        passportData: {
          'cropLabel': 'Organic Wheat',
          'farmName': 'Green Valley Farm',
        },
      );

      expect(result.isSuccess, true);
      expect(result.valueOrNull?.signature.isNotEmpty, true);
      expect(result.valueOrNull?.explorerUrl.contains('cluster=devnet'), true);
    });
  });
}
