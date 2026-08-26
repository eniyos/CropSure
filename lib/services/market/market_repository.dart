import '../../core/utils/result.dart';
import '../../models/market_price.dart';

abstract class MarketRepository {
  Future<Result<MarketOverview>> getMarketOverview();
}
