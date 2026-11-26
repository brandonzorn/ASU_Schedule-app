String toIsoDate(DateTime d) {
  final String year = d.year.toString().padLeft(4, "0");
  final String month = d.month.toString().padLeft(2, "0");
  final String day = d.day.toString().padLeft(2, "0");
  return "$year-$month-$day";
}

String formatIsoDate(String iso) {
  final String date = iso.length >= 10 ? iso.substring(0, 10) : iso;
  final List<String> parts = date.split("-");
  if (parts.length != 3) {
    return iso;
  }
  return "${parts[2]}.${parts[1]}.${parts[0]}";
}

String formatLocalDateTime(DateTime dateTime) {
  final DateTime local = dateTime.toLocal();
  final String day = local.day.toString().padLeft(2, "0");
  final String month = local.month.toString().padLeft(2, "0");
  final String hour = local.hour.toString().padLeft(2, "0");
  final String minute = local.minute.toString().padLeft(2, "0");
  return "$day.$month.${local.year} $hour:$minute";
}
