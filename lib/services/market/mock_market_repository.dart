import '../../core/utils/result.dart';
import '../../models/market_price.dart';
import 'market_repository.dart';

class MockMarketRepository implements MarketRepository {
  static const _delay = Duration(milliseconds: 500);

  @override
  Future<Result<MarketOverview>> getMarketOverview() async {
    await Future<void>.delayed(_delay);
    final now = DateTime.now();

    return Success(
      MarketOverview(
        updatedAt: now.subtract(const Duration(hours: 2)),
        featuredCrop: 'Tomato',
        prices: [
          MarketPrice(
            id: 'm1',
            crop: 'Tomato',
            marketName: 'Nashik APMC',
            price: 28.5,
            unit: '₹/kg',
            updatedAt: now.subtract(const Duration(hours: 2)),
            changePercent: 3.2,
          ),
          MarketPrice(
            id: 'm2',
            crop: 'Grape',
            marketName: 'Pune Market Yard',
            price: 62.0,
            unit: '₹/kg',
            updatedAt: now.subtract(const Duration(hours: 4)),
            changePercent: -1.5,
          ),
          MarketPrice(
            id: 'm3',
            crop: 'Spinach',
            marketName: 'Nashik APMC',
            price: 18.0,
            unit: '₹/kg',
            updatedAt: now.subtract(const Duration(hours: 3)),
            changePercent: 0.8,
          ),
          MarketPrice(
            id: 'm4',
            crop: 'Onion',
            marketName: 'Lasalgaon APMC',
            price: 22.4,
            unit: '₹/kg',
            updatedAt: now.subtract(const Duration(hours: 5)),
            changePercent: 5.1,
          ),
        ],
        priceHistory: [
          for (var i = 6; i >= 0; i--)
            MarketPricePoint(
              date: now.subtract(Duration(days: i)),
              price: 26 + (6 - i) * 0.4,
            ),
        ],
      ),
    );
  }
}
