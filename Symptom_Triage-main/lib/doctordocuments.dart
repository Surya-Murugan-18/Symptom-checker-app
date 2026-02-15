import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' as foundation;
import 'package:file_picker/file_picker.dart';
import 'package:symtom_checker/documentsverification.dart';
import 'package:symtom_checker/doctor_verification_progress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/doctor_session.dart';
import 'package:symtom_checker/doctor_dashboard.dart';

class DoctorDocuments extends StatefulWidget {
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? password;

  const DoctorDocuments({
    Key? key,
    this.fullName,
    this.email,
    this.mobile,
    this.password,
  }) : super(key: key);

  @override
  State<DoctorDocuments> createState() => _DoctorDocumentsState();
}

class _DoctorDocumentsState extends State<DoctorDocuments> {
  final Color appColor = const Color(0xFF199A8E);
  final Color backgroundColor = Colors.white;
  final Color titleColor = Colors.black;
  final Color textColor = const Color(0xFF333333);
  final Color borderColor = const Color(0xFFE0E0E0);

  // File tracking for each document
  File? medicalDegreeCertificate;
  File? medicalCouncilRegistration;
  File? governmentID;
  File? specializationCertificate;
  
  String? selectedSpecialization;
  final List<String> specializations = [
    'General',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedist',
    'Psychiatrist',
    'Dentist',
    'ENT Specialist',
    'Gynecologist'
  ];

  // File names for display
  String? medicalDegreeFileName;
  String? councilRegistrationFileName;
  String? governmentIDFileName;
  String? specializationFileName;

  // Text controllers for input fields
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _hospitalAffiliationController = TextEditingController();

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _hospitalAffiliationController.dispose();
    super.dispose();
  }

  Future<void> pickFile(Function(File?, String?) onFilePicked) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        final String fileName = result.files.single.name;
        if (foundation.kIsWeb) {
          // On Web, we don't have a file path. We'd use bytes if we needed to upload.
          // For now, just return null for the File object but provide the name.
          onFilePicked(null, fileName);
        } else if (result.files.single.path != null) {
          onFilePicked(File(result.files.single.path!), fileName);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _registerDoctor() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Split full name
      String firstName = widget.fullName?.split(' ').first ?? "Doctor";
      String lastName = "";
      if (widget.fullName != null && widget.fullName!.contains(' ')) {
        lastName = widget.fullName!.substring(widget.fullName!.indexOf(' ') + 1);
      }

      final body = {
        "firstName": firstName,
        "lastName": lastName,
        "email": widget.email,
        "phone": widget.mobile,
        "password": widget.password,
        "specialization": selectedSpecialization ?? "General",
        "description": "Experienced specialist in ${selectedSpecialization ?? 'General Medicine'}",
        "experienceYears": 5, 
        "hospital": _hospitalAffiliationController.text,
        "rating": 4.5,
        "consultationFee": 500.0,
        "photoUrl": "assets/D10.png"
      };

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/doctors/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (mounted) Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        
        // Auto-login
        final loginBody = {
          "email": widget.email,
          "password": widget.password,
        };
        
        final loginResponse = await http.post(
             Uri.parse("${ApiConfig.baseUrl}/doctors/login"),
             headers: {"Content-Type": "application/json"},
             body: jsonEncode(loginBody),
        );

        if (loginResponse.statusCode == 200) {
           final data = jsonDecode(loginResponse.body);
           final session = DoctorSession();
           session.token = data['token'];
           session.doctorId = data['doctorId'];
           session.firstName = data['firstName'];
           session.lastName = data['lastName'];
           session.email = widget.email;
           session.phone = widget.mobile;
           session.specialization = data['specialization'];
           session.photoUrl = data['photoUrl'];
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration failed: ${response.body}")),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 1024;
    final bool isTablet = MediaQuery.of(context).size.width > 600 && !isDesktop;
    final double horizontalPadding = isDesktop ? 80.0 : isTablet ? 40.0 : 24.0;
    final double maxWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Credentials',
          style: TextStyle(
            color: titleColor,
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  Text(
                    'Step 2: Upload Documents',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isDesktop ? 18 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 221, 236, 248),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                       color: const Color.fromARGB(255, 7, 96, 168),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your profile will be reviewed within 24-48 hours. Please ensure documents are clear.',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 7, 96, 168),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Medical Degree Certificate
                  DocumentUploadField(
                    title: 'Medical Degree Certificate',
                    isRequired: true,
                    fileName: medicalDegreeFileName,
                    appColor: appColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    onTap: () => pickFile((file, fileName) {
                      setState(() {
                        medicalDegreeCertificate = file;
                        medicalDegreeFileName = fileName;
                      });
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Medical Council Registration
                  DocumentUploadField(
                    title: 'Medical Council Registration',
                    isRequired: true,
                    fileName: councilRegistrationFileName,
                    appColor: appColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    onTap: () => pickFile((file, fileName) {
                      setState(() {
                        medicalCouncilRegistration = file;
                        councilRegistrationFileName = fileName;
                      });
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Medical Council Registration Number Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Medical Council Registration Number',
                            style: TextStyle(
                              color: textColor,
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _registrationNumberController,
                        decoration: InputDecoration(
                          hintText: 'Enter your registration number',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: isDesktop ? 15 : 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isDesktop ? 16 : 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: appColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Government ID
                  DocumentUploadField(
                    title: 'Government ID',
                    isRequired: true,
                    fileName: governmentIDFileName,
                    appColor: appColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    onTap: () => pickFile((file, fileName) {
                      setState(() {
                        governmentID = file;
                        governmentIDFileName = fileName;
                      });
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Specialization Certificate
                  DocumentUploadField(
                    title: 'Specialization Certificate',
                    isRequired: false,
                    fileName: specializationFileName,
                    appColor: appColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    onTap: () => pickFile((file, fileName) {
                      setState(() {
                        specializationCertificate = file;
                        specializationFileName = fileName;
                      });
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Hospital / Clinic Affiliation Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hospital / Clinic Affiliation',
                        style: TextStyle(
                          color: textColor,
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _hospitalAffiliationController,
                        decoration: InputDecoration(
                          hintText: 'Enter hospital/clinic name',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: isDesktop ? 15 : 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isDesktop ? 16 : 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: appColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Specialization Dropdown
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Specialization',
                            style: TextStyle(
                              color: textColor,
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedSpecialization,
                        hint: const Text('Select Specialization'),
                        items: specializations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedSpecialization = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (medicalDegreeFileName == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please upload Medical Degree Certificate',
                              ),
                            ),
                          );
                          return;
                        }
                        if (councilRegistrationFileName == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please upload Medical Council Registration',
                              ),
                            ),
                          );
                          return;
                        }
                        if (governmentIDFileName == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload Government ID'),
                            ),
                          );
                          return;
                        }

                        if (selectedSpecialization == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a specialization'),
                            ),
                          );
                          return;
                        }

                        _registerDoctor();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor,
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 20 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit for Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentUploadField extends StatelessWidget {
  final String title;
  final bool isRequired;
  final String? fileName;
  final Color appColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const DocumentUploadField({
    Key? key,
    required this.title,
    required this.isRequired,
    required this.appColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
    this.fileName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 48 : 40,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: fileName != null ? appColor : borderColor,
                width: fileName != null ? 2 : 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: appColor,
                  size: isDesktop ? 48 : 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Click to upload',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'PDF, JPG or PNG (max 5MB)',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isDesktop ? 13 : 12,
                  ),
                ),
                if (fileName != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: appColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '✓ $fileName',
                      style: TextStyle(
                        color: appColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
