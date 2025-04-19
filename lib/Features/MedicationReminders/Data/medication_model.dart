import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final DateTime time;
  final List<int> selectedDays;
  final bool isActive;
  final String frequency;
  final String colorHex;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.selectedDays = const [0, 1, 2, 3, 4, 5, 6],
    this.isActive = true,
    this.frequency = 'Daily',
    required this.colorHex,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      time: (json['time'] as Timestamp).toDate(),
      selectedDays: List<int>.from(json['selectedDays'] as List<dynamic>),
      isActive: json['isActive'] as bool,
      frequency: json['frequency'] as String,
      colorHex: json['colorHex'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': Timestamp.fromDate(time),
      'selectedDays': selectedDays,
      'isActive': isActive,
      'frequency': frequency,
      'colorHex': colorHex,
    };
  }

  @override
  List<Object> get props => [id, name, dosage, time, selectedDays, isActive, frequency, colorHex];
}