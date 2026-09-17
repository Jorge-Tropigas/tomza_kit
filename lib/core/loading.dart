class Loading {
  static bool _isLoading = false;

  static bool get isLoading => _isLoading;

  static void setLoading(bool value) {
    _isLoading = value;
  }
}
