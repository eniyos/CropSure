import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/features/market/controllers/market_controller.dart';
import 'package:cropsure/services/market/mock_market_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MarketController loads prices', () async {
    final controller = MarketController(MockMarketRepository());
    await controller.load();
    expect(controller.state, LoadState.success);
    expect(controller.overview?.prices, isNotEmpty);
    expect(controller.overview?.prices.first.crop, 'Tomato');
  });
}
