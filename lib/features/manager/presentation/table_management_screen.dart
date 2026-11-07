import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/table_model.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/status_badge.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  late List<TableModel> _tables;

  @override
  void initState() {
    super.initState();
    _tables = List.from(MockData.tables);
  }

  void _cycleStatus(String tableId) {
    setState(() {
      _tables = _tables.map((t) {
        if (t.id == tableId) {
          TableStatus next;
          switch (t.status) {
            case TableStatus.available:
              next = TableStatus.reserved;
              break;
            case TableStatus.reserved:
              next = TableStatus.occupied;
              break;
            case TableStatus.occupied:
              next = TableStatus.available;
              break;
          }
          return TableModel(
            id: t.id,
            restaurantId: t.restaurantId,
            tableNumber: t.tableNumber,
            section: t.section,
            capacity: t.capacity,
            status: next,
            minimumSpend: t.minimumSpend,
            features: t.features,
          );
        }
        return t;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _tables.where((t) => t.status == TableStatus.available).length;
    final reservedCount = _tables.where((t) => t.status == TableStatus.reserved).length;
    final occupiedCount = _tables.where((t) => t.status == TableStatus.occupied).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const AppHeader(
        title: 'Floor & Table Layout',
        subtitle: 'Tap table to cycle status',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Floor Status Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Available', '$availableCount', const Color(0xFF16A34A)),
                _buildLegendItem('Reserved', '$reservedCount', const Color(0xFFDC2626)),
                _buildLegendItem('Occupied', '$occupiedCount', const Color(0xFFD97706)),
              ],
            ),
          ),

          // Grid of Tables
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _tables.length,
              itemBuilder: (context, index) {
                final table = _tables[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: table.status == TableStatus.available
                          ? AppColors.primaryGreen.withOpacity(0.4)
                          : AppColors.borderLight,
                      width: table.status == TableStatus.available ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _cycleStatus(table.id),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  table.tableNumber,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                StatusBadge.fromTableStatus(table.status),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  table.section.label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline, size: 14, color: AppColors.primaryGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Seats up to ${table.capacity}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              'Tap to toggle',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
