import 'package:flutter/material.dart';
import 'package:gate_pass_project/screens/qr_generation_screen/qr_generation_screen.dart';

class ExitButtonScreen extends StatefulWidget {
  const ExitButtonScreen({super.key});

  @override
  State<ExitButtonScreen> createState() => _ExitButtonScreenState();
}

class _ExitButtonScreenState extends State<ExitButtonScreen> {
  final _formKey = GlobalKey<FormState>();
  String urgency = 'Urgency';
  String name = '';
  String department = '';
  String tutor = '';
  String time = '';
  String reason = '';

  final List<String> timeSlots = [
    '08:00 - 09:00 AM',
    '09:00 - 10:00 AM',
    '10:00 - 11:00 AM',
    '11:00 - 12:00 PM',
    '12:00 - 01:00 PM',
    '01:00 - 02:00 PM',
    '02:00 - 03:00 PM',
    '03:00 - 04:00 PM',
    '04:00 - 05:00 PM',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gate Pass Request',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField('Name', (val) => name = val),
                const SizedBox(height: 16),
                _buildTextField('Department', (val) => department = val),
                const SizedBox(height: 16),
                _buildTextField('Tutor', (val) => tutor = val),
                const SizedBox(height: 16),
                _buildRadioButtons(),
                const SizedBox(height: 16),
                _buildTimeSlotGrid(),
                const SizedBox(height: 16),
                _buildTextField('Reason', (val) => reason = val, maxLines: 3),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(Icons.exit_to_app, color: Colors.white),
                  label: Text(
                    'Exit',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Handle exit logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Exit request submitted!')),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QrGenerationScreen(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onSaved, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
      onSaved: (val) => onSaved(val ?? ''),
    );
  }

  Widget _buildRadioButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRadio('Urgency'),
        const SizedBox(width: 24),
        _buildRadio('Normal'),
      ],
    );
  }

  Widget _buildRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: urgency,
          activeColor: Colors.deepPurple,
          onChanged: (val) {
            setState(() {
              urgency = val!;
            });
          },
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((slot) {
            final isSelected = time == slot;
            return GestureDetector(
              onTap: () {
                setState(() {
                  time = slot;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (time.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select a time slot',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
