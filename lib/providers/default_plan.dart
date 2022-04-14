import '../domains/plan.dart';
import '../utils.dart';

class DefaultPlan {
  Plan? _default;

  bool get hasDefaulPlan {
    return _default != null;
  }

  Plan? get defaultPlan => _default;

  static const planDefaultUrl = "/plan/default";
  void fetchDefaultPlan() async {
    // print("default");
    var json = await sendGet(planDefaultUrl);
    _default = Plan.fromJson(json);
  }
}
