class Ticker {
  const Ticker();
  Stream<int> tick({required int interval}) {
    return Stream.periodic(Duration(seconds: interval), (x) => x);
  }
}
