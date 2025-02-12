import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ez_health/assets/constants/constants.dart';
import 'package:ez_health/patient/payment/payment_methods_screen.dart';
import 'package:ez_health/assets/constants/horizontal_button.dart';
import 'package:ez_health/providers/appointment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late TextEditingController _ageController;
  late TextEditingController _otherPersonNameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _otherPersonNameController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _otherPersonNameController.dispose();
    super.dispose();
  }

  void _handleAgeChange(String value, AppointmentProvider provider) {
    if (value.isEmpty) {
      provider.setAge(0);
      return;
    }

    final age = int.tryParse(value);
    if (age != null && age >= 0 && age <= 100) {
      provider.setAge(age.toDouble());
    } else if (age != null && age > 100) {
      _ageController.text = '100';
      _ageController.selection = TextSelection.fromPosition(
        const TextPosition(offset: 3),
      );
      provider.setAge(100);
    }
  }

  bool _isFormValid(AppointmentProvider provider) {
    // Check if booking type is selected
    if (provider.bookingFor.isEmpty) return false;

    // If booking for other, check if name is provided
    if (provider.bookingFor == 'Other' &&
        _otherPersonNameController.text.trim().isEmpty) return false;

    // Check if gender is selected
    if (provider.gender.isEmpty) return false;

    // Check if age is greater than 0
    if (provider.age <= 0) return false;

    return true;
  }

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    return doc.data()?['role'] == 'admin';
  }

  void _handleProceedToPayment(BuildContext context, AppointmentProvider provider) async {
    final isAdmin = await _isAdmin();

    if (isAdmin) {
      try {
        // Create confirmed appointment directly for admin
        await provider.createAppointment(isAdmin: true);
        
        if (!context.mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to AdminDashboardScreen by popping until we reach it
        if (!context.mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);

      } catch (e) {
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Original patient flow
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
      );
    }
  }

  Widget _buildEmergencyToggle(AppointmentProvider provider, bool isSmallScreen) {
    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, snapshot) {
        // Only show if user is admin and data is loaded
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 24),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: provider.isEmergency ? Colors.red.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: provider.isEmergency ? Colors.red.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Case',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: provider.isEmergency ? Colors.red : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mark this as an emergency appointment',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.isEmergency,
                onChanged: (value) => provider.setEmergency(value),
                activeColor: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    if (!_isEditing) {
      _ageController.text = appointmentProvider.age.round().toString();
    }

    final bool isFormValid = _isFormValid(appointmentProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Appointment Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: customBlue,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 600,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking for',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildDropdown(
                      'Select Here',
                      ['Myself', 'Other'],
                      appointmentProvider.bookingFor,
                      (val) {
                        appointmentProvider.setBookingFor(val);
                        if (val != 'Other') {
                          _otherPersonNameController.clear();
                        }
                        setState(() {});
                      },
                      isSmallScreen,
                    ),
                    if (appointmentProvider.bookingFor == 'Other') ...[
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Text(
                        'Name of the other person *',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      _buildTextField(
                        controller: _otherPersonNameController,
                        hintText: 'Enter name',
                        isSmallScreen: isSmallScreen,
                        onChanged: (value) {
                          appointmentProvider.setOtherPersonName(value);
                          setState(() {});
                        },
                      ),
                    ],
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildDropdown(
                      'Select Here',
                      ['Male', 'Female', 'Other'],
                      appointmentProvider.gender,
                      (val) {
                        appointmentProvider.setGender(val);
                        setState(() {});
                      },
                      isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    _buildAgeSection(appointmentProvider, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Text(
                      'Write Your Problem',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildProblemTextField(
                      appointmentProvider,
                      isSmallScreen,
                    ),
                    _buildEmergencyToggle(appointmentProvider, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 80 : 100),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isSmallScreen ? 16 : 24,
                left: isSmallScreen ? 16 : 24,
                right: isSmallScreen ? 16 : 24,
              ),
              child: FutureBuilder<bool>(
                future: _isAdmin(),
                builder: (context, snapshot) {
                  return HorizontalBtn(
                    text: snapshot.data == true 
                      ? 'Create Appointment'
                      : 'Process to Payment',
                    enabled: isFormValid,
                    onPressed: () => _handleProceedToPayment(context, appointmentProvider),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isSmallScreen,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      ),
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String value,
    Function(String) onChanged,
    bool isSmallScreen,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 12 : 16,
            ),
            child: Text(
              hint,
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
          value: value.isEmpty ? null : value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
                child: Text(
                  item,
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAgeSection(AppointmentProvider provider, bool isSmallScreen) {
    return Column(
      children: [
        SizedBox(
          width: isSmallScreen ? 60 : 80,
          child: TextField(
            controller: _ageController,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onTap: () {
              setState(() {
                _isEditing = true;
              });
            },
            onChanged: (value) {
              setState(() {
                _isEditing = true;
                _handleAgeChange(value, provider);
              });
            },
            onSubmitted: (value) {
              if (value.isEmpty) {
                _ageController.text = '0';
                provider.setAge(0);
              }
              setState(() {
                _isEditing = false;
              });
            },
            onEditingComplete: () {
              if (_ageController.text.isEmpty) {
                _ageController.text = '0';
                provider.setAge(0);
              }
              setState(() {
                _isEditing = false;
              });
            },
          ),
        ),
        Row(
          children: [
            Text(
              '0',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: isSmallScreen ? 2 : 3,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isSmallScreen ? 8 : 10,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: isSmallScreen ? 16 : 20,
                  ),
                ),
                child: Slider(
                  value: provider.age,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      _isEditing = false;
                      provider.setAge(value);
                    });
                  },
                ),
              ),
            ),
            Text(
              '100',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProblemTextField(
      AppointmentProvider provider, bool isSmallScreen) {
    return TextField(
      maxLines: 4,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: 'Describe your problem here...',
        contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      ),
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      onChanged: provider.setProblemDescription,
    );
  }
}