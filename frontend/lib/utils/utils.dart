String formatFlightTime(String estimatedFlightTimeStr) {
  double hours = double.parse(estimatedFlightTimeStr);
  int hh = hours.floor();
  int mm = ((hours - hh) * 60).round();
  return '${hh.toString().padLeft(2, '0')}h${mm.toString().padLeft(2, '0')}min';
}