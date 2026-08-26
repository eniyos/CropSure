import '../../core/utils/result.dart';
import '../../models/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<Result<DashboardSummary>> getFarmerDashboard();
}
