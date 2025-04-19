class EmergencyContact {
  final String id;
  final String name;
  final String relation;
  final String phone;
  final String priority;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.priority,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> data, String id) {
    return EmergencyContact(
      id: id,
      name: data['name'] ?? '',
      relation: data['relation'] ?? '',
      phone: data['phone'] ?? '',
      priority: data['priority'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relation': relation,
      'phone': phone,
      'priority': priority,
    };
  }
}