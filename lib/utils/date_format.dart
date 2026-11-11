String formatIsoDate(String iso) {
  final String date = iso.length >= 10 ? iso.substring(0, 10) : iso;
  final List<String> parts = date.split("-");
  if (parts.length != 3) {
    return iso;
  }
  return "${parts[2]}.${parts[1]}.${parts[0]}";
}
