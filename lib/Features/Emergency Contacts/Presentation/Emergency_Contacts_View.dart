import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final AnimationController animationController;

  const EmergencyContactsScreen({
    Key? key,
    required this.animationController
  }) : super(key: key);

  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock list of emergency contacts
  final List<Map<String, dynamic>> emergencyContacts = [
    {
      'name': 'John Doe',
      'relation': 'Family',
      'phone': '+1 (555) 123-4567',
      'priority': 'High',
      'avatar': 'https://example.com/john.jpg'
    },
    {
      'name': 'Jane Smith',
      'relation': 'Friend',
      'phone': '+1 (555) 987-6543',
      'priority': 'Medium',
      'avatar': 'https://example.com/jane.jpg'
    },
  ];

  @override
  void initState() {
    super.initState();

    // Create a separate animation controller for screen animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [

                // Header Section
                SliverToBoxAdapter(
                  child: FadeInUp(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(20, isSmallScreen ? 10 : 20, 20, 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.redAccent.withOpacity(0.2),
                            const Color(0xFFE0F2F1).withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ZoomIn(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.call,
                                color: Colors.redAccent.shade700,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Emergency Preparedness',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent.shade700,
                                      ),
                                    ),
                                    Text(
                                      'Stay connected with your support network',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: (){
                                    HapticFeedback.lightImpact();
                                    _showAddContactBottomSheet(context);
                                  },
                                  child: Icon(Iconsax.add , color: Colors.red, size: 22,),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Contacts List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Your Emergency Contacts',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // Animated Contacts List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: ContactCard(
                          contact: emergencyContacts[index],
                          onDelete: () {
                            _deleteContact(index);
                          },
                        ),
                      );
                    },
                    childCount: emergencyContacts.length,
                  ),
                ),

                // Emergency Guidelines
                SliverToBoxAdapter(
                  child: FadeInUp(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withOpacity(0.2),
                              Colors.amber.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber.shade700,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Keep your emergency contacts informed and updated about their role.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FadeIn(
        child: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAddContactBottomSheet(context);
          },
          child: const Icon(Iconsax.profile_add),
        ),
      ),
    );
  }

  void _deleteContact(int index) {
    setState(() {
      emergencyContacts.removeAt(index);
    });
  }

  void _showAddContactBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => ElasticIn(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Emergency Contact',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Name TextField with Animation
              FadeInRight(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Contact Name',
                    prefixIcon: const Icon(Iconsax.user),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Phone TextField with Animation
              FadeInRight(
                delay: const Duration(milliseconds: 100),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Iconsax.call),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Relation TextField with Animation
              FadeInRight(
                delay: const Duration(milliseconds: 200),
                child: TextField(
                  controller: relationController,
                  decoration: InputDecoration(
                    labelText: 'Relation',
                    prefixIcon: const Icon(Iconsax.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Add Contact Button with Animation
              FadeInUp(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty &&
                        relationController.text.isNotEmpty) {
                      setState(() {
                        emergencyContacts.add({
                          'name': nameController.text,
                          'phone': phoneController.text,
                          'relation': relationController.text,
                          'priority': 'Medium',
                          'avatar': null
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Add Contact',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onDelete;

  const ContactCard({
    Key? key,
    required this.contact,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          child: Icon(
            Iconsax.user,
            color: Colors.redAccent.shade700,
          ),
        ),
        title: Text(
          contact['name'] ?? '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${contact['relation'] ?? ''} • ${contact['phone'] ?? ''}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Iconsax.trash,
            color: Colors.redAccent.shade200,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}