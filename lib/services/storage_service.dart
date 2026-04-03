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
  static const _usersKey = 'users';
  static const _yachtConfigKey = 'yacht_config';
  static const _pendingVoiceKey = 'pending_voice_messages';
  static const _scannedDocsKey = 'scanned_documents';

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

  // Users
  Future<List<AppUser>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => AppUser.fromJson(e)).toList();
  }

  Future<void> saveUsers(List<AppUser> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _usersKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Yacht Config
  Future<YachtConfig?> loadYachtConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_yachtConfigKey);
    if (raw == null) return null;
    return YachtConfig.fromJson(jsonDecode(raw));
  }

  Future<void> saveYachtConfig(YachtConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_yachtConfigKey, jsonEncode(config.toJson()));
  }

  // Pending Voice Messages
  Future<List<PendingVoiceMessage>> loadPendingVoiceMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingVoiceKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => PendingVoiceMessage.fromJson(e))
        .toList();
  }

  Future<void> savePendingVoiceMessages(List<PendingVoiceMessage> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _pendingVoiceKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Scanned Documents
  Future<List<ScannedDocument>> loadScannedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scannedDocsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => ScannedDocument.fromJson(e))
        .toList();
  }

  Future<void> saveScannedDocuments(List<ScannedDocument> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _scannedDocsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
