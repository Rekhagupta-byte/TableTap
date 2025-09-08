

import 'package:tabletap_frontend/constants.dart';

String api(String endpoint) {
  // Automatically prepends base URL
  return '${ApiConstants.baseUrl}$endpoint';
}
