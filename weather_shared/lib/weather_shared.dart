/// Weather Shared Library
library;
// Contains all shared components for the weather application

// Models
export 'models/weather.dart';
export 'models/forecast.dart';
export 'models/location.dart';

// Services
export 'services/weather_service.dart';
export 'services/temperature_utils.dart';

// Config
export 'core/config/api_config.dart';

// Widgets
export 'widgets/weather_icon.dart';
export 'widgets/weather_forecast.dart';

// Re-export commonly used types
export 'package:http/http.dart' show Response;
