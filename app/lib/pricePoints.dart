import 'package:collection/collection.dart';

class Pricepoints {
  final double x;
  final double y;
  Pricepoints({required this.x, required this.y});
}

List<Pricepoints> get pricePoint {
  final data = <double>[2, 4, 6, 11, 3, 6, 4];
  return data
      .mapIndexed(
          ((index, element) => Pricepoints(x: index.toDouble(), y: element)))
      .toList();
}
