import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _crewKey = 'crew';
  static const _certsKey = 'certificates';
  static const _inventoryKey = 'inventory';
  static const _prefsKey = 'owner_preferences';
  static const _incidentsKey = 'incidents';
  static const _voiceKey = 'voice_commands';

  // Tasks
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<void> saveTasks(List<Task> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _tasksKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Crew
  Future<List<CrewMember>> loadCrew() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_crewKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => CrewMember.fromJson(e))
        .toList();
  }

  Future<void> saveCrew(List<CrewMember> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _crewKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Certificates
  Future<List<Certificate>> loadCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_certsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Certificate.fromJson(e))
        .toList();
  }

  Future<void> saveCertificates(List<Certificate> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _certsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Inventory
  Future<List<InventoryItem>> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_inventoryKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => InventoryItem.fromJson(e))
        .toList();
  }

  Future<void> saveInventory(List<InventoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _inventoryKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Owner Preferences
  Future<List<OwnerPreference>> loadOwnerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => OwnerPreference.fromJson(e))
        .toList();
  }

  Future<void> saveOwnerPreferences(List<OwnerPreference> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Incidents
  Future<List<Incident>> loadIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_incidentsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Incident.fromJson(e))
        .toList();
  }

  Future<void> saveIncidents(List<Incident> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _incidentsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Voice Commands
  Future<List<VoiceCommand>> loadVoiceCommands() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_voiceKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => VoiceCommand.fromJson(e))
        .toList();
  }

  Future<void> saveVoiceCommands(List<VoiceCommand> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _voiceKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
