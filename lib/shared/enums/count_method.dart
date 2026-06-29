enum CountMethod {
  tap('tap'),
  volume('volume'),
  both('both');

  const CountMethod(this.storageKey);

  final String storageKey;

  static CountMethod fromStorageKey(String? value) {
    return CountMethod.values.firstWhere(
      (method) => method.storageKey == value,
      orElse: () => CountMethod.tap,
    );
  }
}
