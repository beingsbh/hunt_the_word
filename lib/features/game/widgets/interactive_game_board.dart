import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/letter_cell_widget.dart';
import '../../../engine/models/grid_coordinate.dart';
import '../viewmodels/game_provider.dart';

/// Interactive touch grid supporting continuous multi-directional word swiping.
class InteractiveGameBoard extends StatelessWidget {
  const InteractiveGameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<GameProvider>();
    final matrix = vm.matrix;
    final rows = vm.rows;
    final cols = vm.cols;
    final foundMap = vm.board.foundCoordinatesMap;
    final selectedCoords = vm.selectedCoordinates.toSet();
    final hintCoord = vm.highlightedHintCoordinate;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = min(constraints.maxWidth, constraints.maxHeight);
        const padding = AppSpacing.sm;
        final gridInnerSize = availableSize - (padding * 2);
        const cellGap = 5.0;
        final totalGaps = (cols - 1) * cellGap;
        final cellSize = ((gridInnerSize - totalGaps) / cols).clamp(28.0, 56.0);
        final boardWidth = (cellSize * cols) + totalGaps + (padding * 2);
        final boardHeight =
            (cellSize * rows) + ((rows - 1) * cellGap) + (padding * 2);

        GridCoordinate? getCoordFromLocalOffset(Offset local) {
          final x = local.dx - padding;
          final y = local.dy - padding;
          final c = (x / (cellSize + cellGap)).floor();
          final r = (y / (cellSize + cellGap)).floor();

          if (r >= 0 && r < rows && c >= 0 && c < cols) {
            return GridCoordinate(r, c);
          }
          return null;
        }

        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            transform: vm.isWobblingError
                ? Matrix4.translationValues(8.0, 0.0, 0.0)
                : Matrix4.identity(),
            child: GestureDetector(
              onPanStart: (details) {
                final coord = getCoordFromLocalOffset(details.localPosition);
                if (coord != null) {
                  vm.onPanStart(coord);
                }
              },
              onPanUpdate: (details) {
                final coord = getCoordFromLocalOffset(details.localPosition);
                if (coord != null) {
                  vm.onPanUpdate(coord);
                }
              },
              onPanEnd: (_) => vm.onPanEnd(),
              child: Container(
                width: boardWidth,
                height: boardHeight,
                padding: const EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color:
                      theme.cardTheme.color?.withValues(alpha: 0.8) ??
                      Colors.white,
                  borderRadius: AppRadius.radiusXl,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(rows, (r) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(cols, (c) {
                        final coord = GridCoordinate(r, c);
                        LetterCellStatus status;
                        Color? highlightColor;

                        if (selectedCoords.contains(coord)) {
                          status = LetterCellStatus.selected;
                        } else if (foundMap.containsKey(coord)) {
                          status = LetterCellStatus.found;
                          final colorIdx = foundMap[coord] ?? 0;
                          highlightColor =
                              AppColors.wordHighlights[colorIdx %
                                  AppColors.wordHighlights.length];
                        } else if (hintCoord == coord) {
                          status = LetterCellStatus.highlighted;
                        } else {
                          status = LetterCellStatus.idle;
                        }

                        return LetterCellWidget(
                          letter: matrix[r][c],
                          status: status,
                          highlightColor: highlightColor,
                          size: cellSize,
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
