import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:ez_health/assets/constants/constants.dart';
import 'package:ez_health/providers/appointment_provider.dart';
import 'package:intl/intl.dart';
import 'package:ez_health/assets/widgets/buttons/horizontal_button.dart';

class DoctorAppointmentDetailsScreen extends StatelessWidget {
  final String appointmentId;

  const DoctorAppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(appointmentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Appointment not found'));
                }

                final appointmentData = snapshot.data!.data() as Map<String, dynamic>;

                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? double.infinity : 600,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: isSmallScreen ? 40 : 60),
                            _buildHeader(appointmentData, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 40 : 50),
                            _buildAppointmentCard(appointmentData, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 40 : 50),
                            _buildDoneButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> data, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          data['patientName'] ?? 'Patient Name',
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: isSmallScreen ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: customLightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: customBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data, bool isSmallScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Reference', data['appointmentNumber'] ?? 'N/A', isSmallScreen),
            SizedBox(height: isSmallScreen ? 15 : 20),
            _buildDetailRow('Date', _formatDate(data['appointmentDate']), isSmallScreen),
            SizedBox(height: isSmallScreen ? 15 : 20),
            _buildDetailRow('Time', data['appointmentTime'] ?? 'N/A', isSmallScreen),
            SizedBox(height: isSmallScreen ? 15 : 20),
            _buildDetailRow('Age', '${data['age']?.toString() ?? 'N/A'} years', isSmallScreen),
            SizedBox(height: isSmallScreen ? 15 : 20),
            _buildDetailRow('Gender', data['gender'] ?? 'N/A', isSmallScreen),
            SizedBox(height: isSmallScreen ? 15 : 20),
            _buildDetailRow('Status', data['status']?.toUpperCase() ?? 'N/A', isSmallScreen, 
              isHighlighted: true),
            if (data['problemDescription'] != null && data['problemDescription'].toString().isNotEmpty) ...[
              const Divider(height: 40),
              Text(
                'Problem Description',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['problemDescription'],
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isSmallScreen,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        isHighlighted
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: customLightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 16 : 18,
                    color: customBlue,
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return HorizontalBtn(
      onPressed: () {
        Navigator.of(context).pop();
      },
      text: 'Done',
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('MMM dd, yyyy').format(date.toDate());
    } else if (date is String) {
      return date;
    } else if (date is DateTime) {
      return DateFormat('MMM dd, yyyy').format(date);
    }
    return 'Date not available';
  }
} 