/// Market price row returned by the backend market service.
class MarketPrice {
  const MarketPrice({
    required this.id,
    required this.crop,
    required this.marketName,
    required this.price,
    required this.unit,
    required this.updatedAt,
    this.changePercent,
  });

  final String id;
  final String crop;
  final String marketName;
  final double price;
  final String unit;
  final DateTime updatedAt;
  final double? changePercent;
}

class MarketPricePoint {
  const MarketPricePoint({
    required this.date,
    required this.price,
  });

  final DateTime date;
  final double price;
}

class MarketOverview {
  const MarketOverview({
    required this.prices,
    required this.updatedAt,
    this.featuredCrop,
    this.priceHistory = const [],
  });

  final List<MarketPrice> prices;
  final DateTime updatedAt;
  final String? featuredCrop;
  final List<MarketPricePoint> priceHistory;
}
