import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';

class SchedulePickupContent extends ConsumerStatefulWidget {
  const SchedulePickupContent({super.key});

  @override
  ConsumerState<SchedulePickupContent> createState() => _SchedulePickupContentState();
}

class _SchedulePickupContentState extends ConsumerState<SchedulePickupContent> {
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedWasteType = 'Mixed Waste';

  final List<String> _wasteTypes = [
    'Mixed Waste',
    'Plastic',
    'Paper & Cardboard',
    'Glass',
    'Metal',
    'Organic / Food Waste',
    'E-Waste',
  ];

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submitPickupRequest() {
    if (_selectedDate == null || _selectedTime == null) {
      Helpers.showToast('Please select date and time', isError: true);
      return;
    }

    // TODO: Connect to API later
    Helpers.showToast('Pickup request submitted successfully! 🎉');

    // Clear form
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _notesController.clear();
      _selectedWasteType = 'Mixed Waste';
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule a Pickup',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Book trusted collectors for your waste',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerTile(
                          title: 'Date',
                          value: _selectedDate != null
                              ? DateFormat('EEE, MMM d').format(_selectedDate!)
                              : 'Select Date',
                          icon: Icons.calendar_today,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPickerTile(
                          title: 'Time',
                          value: _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Select Time',
                          icon: Icons.access_time,
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Waste Type
                  const Text('Waste Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _wasteTypes.map((type) {
                      final selected = type == _selectedWasteType;
                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedWasteType = type),
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Additional Notes (Optional)',
                      hintText: 'Any special instructions...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitPickupRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Request Pickup',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}