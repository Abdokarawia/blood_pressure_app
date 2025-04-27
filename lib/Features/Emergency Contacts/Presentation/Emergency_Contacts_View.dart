import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Data/emergency_model.dart';
import 'manger/emergency_cubit.dart';
import 'manger/emergency_state.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddContactBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<EmergencyContactsCubit>(),
        child: FadeInUp(
          duration: Duration(milliseconds: 500),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
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
                  FadeInLeft(
                    duration: Duration(milliseconds: 600),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Contact Name',
                        prefixIcon: Icon(Iconsax.user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInRight(
                    duration: Duration(milliseconds: 600),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Iconsax.call),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInLeft(
                    duration: Duration(milliseconds: 600),
                    child: TextField(
                      controller: relationController,
                      decoration: InputDecoration(
                        labelText: 'Relation',
                        prefixIcon: Icon(Iconsax.people),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ZoomIn(
                    duration: Duration(milliseconds: 500),
                    child: BlocConsumer<EmergencyContactsCubit, EmergencyContactsState>(
                      listener: (context, state) {
                        if (state is EmergencyContactsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: state is EmergencyContactsLoading
                              ? null
                              : () {
                            if (nameController.text.isNotEmpty &&
                                phoneController.text.isNotEmpty &&
                                relationController.text.isNotEmpty) {
                              context.read<EmergencyContactsCubit>().addContact(
                                EmergencyContact(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: nameController.text,
                                  phone: phoneController.text,
                                  relation: relationController.text,
                                  priority: 'Medium',
                                ),
                              );
                              Navigator.pop(sheetContext);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          child: state is EmergencyContactsLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'Add Contact',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 350;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Header Section
                SliverToBoxAdapter(
                  child: FadeInDown(
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      margin: EdgeInsets.all(isNarrowScreen ? 10 : 20),
                      padding: EdgeInsets.all(isNarrowScreen ? 15 : 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.redAccent.withOpacity(0.2),
                            Colors.white.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Container(
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
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency Contacts',
                                  style: GoogleFonts.poppins(
                                    fontSize: isNarrowScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent.shade700,
                                  ),
                                ),
                                Text(
                                  'Manage your emergency support network',
                                  style: GoogleFonts.poppins(
                                    fontSize: isNarrowScreen ? 10 : 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Contacts List Title
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FadeInLeft(
                      duration: Duration(milliseconds: 500),
                      child: Text(
                        'Your Emergency Contacts',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Contacts List
                BlocConsumer<EmergencyContactsCubit, EmergencyContactsState>(
                  listener: (context, state) {
                    if (state is EmergencyContactsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is EmergencyContactsLoading) {
                      return SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (state is EmergencyContactsError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            state.message,
                            style: GoogleFonts.poppins(color: Colors.redAccent),
                          ),
                        ),
                      );
                    } else if (state is EmergencyContactsLoaded) {
                      if (state.contacts.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              'No contacts added yet.',
                              style: GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return ContactCard(
                              contact: state.contacts[index],
                              onDelete: () {
                                context
                                    .read<EmergencyContactsCubit>()
                                    .deleteContact(state.contacts[index].id);
                              },
                            );
                          },
                          childCount: state.contacts.length,
                        ),
                      );
                    }
                    return SliverToBoxAdapter(child: Container());
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FadeInUp(
          duration: Duration(milliseconds: 500),
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            onPressed: () => _showAddContactBottomSheet(context),
            child: Icon(Iconsax.profile_add),
          ),
        ),
    );
  }
}

// ContactCard Widget
class ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onDelete;

  const ContactCard({
    Key? key,
    required this.contact,
    required this.onDelete,
  }) : super(key: key);

  void _launchPhoneCall(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone call'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideInRight(
      duration: Duration(milliseconds: 500),
      child: Container(
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
            contact.name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${contact.relation} • ${contact.phone}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Iconsax.call,
                  color: Colors.green.shade400,
                ),
                onPressed: () => _launchPhoneCall(context, contact.phone),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.trash,
                  color: Colors.redAccent.shade200,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}