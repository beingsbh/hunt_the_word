/// Immutable grid coordinate representing a cell at (row, col).
class GridCoordinate {
  final int row;
  final int col;

  const GridCoordinate(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridCoordinate &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';

  Map<String, int> toMap() => {'row': row, 'col': col};

  factory GridCoordinate.fromMap(Map<dynamic, dynamic> map) {
    return GridCoordinate(
      (map['row'] as num).toInt(),
      (map['col'] as num).toInt(),
    );
  }
}
