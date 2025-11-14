String getDate(String date) {
  try {
    if (date.isEmpty || date.length < 10) {
      return 'N/A';
    }
    String year = date.substring(0, 4);
    String month = date.substring(5, 7);
    String day = date.substring(8, 10);
    return '$day/$month/$year';
  } catch (e) {
    return 'N/A';
  }
}
