import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:sanatanpariwar/pdf_utils.dart';



class MembershipForm extends StatefulWidget {
  @override
  _MembershipFormState createState() => _MembershipFormState();
}

class _MembershipFormState extends State<MembershipForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _referredByController = TextEditingController();
  Country? _selectedCountry;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  bool _agreedToRules = false;
  final membershipDate =  DateTime.now().toString();



  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _referredByController.dispose();

    super.dispose();
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with submitting the data
      String name = _nameController.text;
      String email = _emailController.text;
      String dob = _dobController.text;
      String fatherName = _fatherNameController.text;
      String motherName = _motherNameController.text;
      String phone = _phoneController.text;
      String address = _addressController.text;
      String referredBy = _referredByController.text;

      // Store the data in Firebase Firestore
      FirebaseFirestore.instance.collection('members').add({
        'name': name,
        'email': email,
        'dob': dob,
        'nationality': _selectedCountry?.name,
        'gender': _selectedGender,
        'fatherName': fatherName,
        'motherName': motherName,
        'phone': phone,
        'address': address,
        'referredBy': referredBy,
        'membershipDate': DateTime.now(),
        'maritalStatus': _selectedMaritalStatus,
      }).then((docRef) {
        // Show a success message
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Membership Submitted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Thank you for submitting your membership!'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _agreedToRules
                          ? () {
                        generatePdf(name, membershipDate);
                        Navigator.of(context).pop();
                        _resetForm();
                      }
                          : null,
                      child: Text('Download'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetForm(); // Reset the form
                      },
                      child: Text('OK'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    }
  }





  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _dobController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _referredByController.clear();
    setState(() {
      _selectedCountry = null;
      _selectedGender = null;
      _selectedMaritalStatus = null;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Email validation regex pattern
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      _dobController.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Become a Member',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fatherNameController,
                    decoration: InputDecoration(
                      labelText: 'Father\'s Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your father\'s name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _motherNameController,
                    decoration: InputDecoration(
                      labelText: 'Mother\'s Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mother\'s name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    value: _selectedGender,
                    items: ['Male', 'Female', 'Other']
                        .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Marital Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    value: _selectedMaritalStatus,
                    items: ['Married', 'Unmarried']
                        .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMaritalStatus = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your marital status';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _referredByController,
                    decoration: InputDecoration(
                      labelText: 'Referred By',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    readOnly: true,
                    onTap: _selectCountry,
                    decoration: InputDecoration(
                      labelText: 'Nationality',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                          width: 1.0,
                        ),
                      ),
                      suffixIcon: Icon(Icons.keyboard_arrow_down),
                    ),
                    validator: (value) {
                      if (_selectedCountry == null) {
                        return 'Please select your nationality';
                      }
                      return null;
                    },
                    controller: TextEditingController(
                      text: _selectedCountry?.name ?? '',
                    ),
                  ),

                  SizedBox(height: 16.0),
                  Text(
                    'Membership Rules:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Adhere to Sanatan Pariwar principles.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Participate in Pariwar events and activities.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Respect and follow Pariwar decisions and guidelines.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Contribute to Pariwar growth and welfare.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Maintain harmonious relationships with members.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Promote Pariwar teachings and values.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Maintain confidentiality of sensitive information.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Strive for personal and spiritual growth.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Support charitable initiatives and social causes.'),
                  SizedBox(height: 8.0),
                  _buildRuleTile(Icons.check_circle, 'Uphold Pariwar reputation and integrity.'),
                  SizedBox(height: 16.0),
                  SizedBox(height: 16.0),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _agreedToRules,
                    onChanged: (value) {
                      setState(() {
                        _agreedToRules = value!;
                      });
                    },
                    title: Text(
                      'I agree to the above rules',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),

                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _agreedToRules ? _submitForm : null,
                    child: Text('Submit'),
                  ),


                ]),
            ),

          ),


        ),
      ),
    );
  }
}
Widget _buildRuleTile(IconData icon, String rule) {
  return ListTile(
    leading: Icon(icon),
    title: Text(
      rule,
      style: TextStyle(fontSize: 16.0),
    ),
  );
}

