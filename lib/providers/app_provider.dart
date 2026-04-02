import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  AppUser? _currentUser;
  List<Task> _tasks = [];
  List<CrewMember> _crew = [];
  List<Certificate> _certificates = [];
  List<InventoryItem> _inventory = [];
  List<OwnerPreference> _ownerPreferences = [];
  List<Incident> _incidents = [];
  List<VoiceCommand> _voiceCommands = [];
  bool _isLoading = false;

  // Getters
  AppUser? get currentUser => _currentUser;
  List<Task> get tasks => _tasks;
  List<CrewMember> get crew => _crew;
  List<Certificate> get certificates => _certificates;
  List<InventoryItem> get inventory => _inventory;
  List<OwnerPreference> get ownerPreferences => _ownerPreferences;
  List<Incident> get incidents => _incidents;
  List<VoiceCommand> get voiceCommands => _voiceCommands;
  bool get isLoading => _isLoading;

  // Computed stats
  int get activeTasks => _tasks
      .where((t) =>
          t.status == TaskStatus.pendiente ||
          t.status == TaskStatus.enProgreso)
      .length;

  int get openIncidents =>
      _incidents.where((i) => i.status != IncidentStatus.resuelta).length;

  int get alertCertificates =>
      _certificates.where((c) => c.alertLevel != AlertLevel.none).length;

  int get lowStockItems =>
      _inventory.where((i) => i.status != InventoryStatus.ok).length;

  // ==================== INIT ====================

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _storage.loadTasks();
    _crew = await _storage.loadCrew();
    _certificates = await _storage.loadCertificates();
    _inventory = await _storage.loadInventory();
    _ownerPreferences = await _storage.loadOwnerPreferences();
    _incidents = await _storage.loadIncidents();
    _voiceCommands = await _storage.loadVoiceCommands();

    if (_crew.isEmpty) {
      _loadDemoData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadDemoData() {
    final now = DateTime.now();

    _crew = [
      CrewMember(id: 'c1', name: 'Carlos Ruiz', role: 'Segundo Oficial'),
      CrewMember(id: 'c2', name: 'María López', role: 'Cubierta'),
      CrewMember(id: 'c3', name: 'Juan García', role: 'Marinero'),
      CrewMember(id: 'c4', name: 'Ana Martínez', role: 'Cocinera'),
    ];

    _tasks = [
      Task(
        id: 't1',
        title: 'Revisar motor de babor',
        description: 'Inspección rutinaria del motor principal de babor.',
        assignedToId: 'c1',
        assignedToName: 'Carlos Ruiz',
        priority: TaskPriority.alta,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Task(
        id: 't2',
        title: 'Limpiar cubierta principal',
        description: 'Limpieza completa de la cubierta de popa.',
        assignedToId: 'c2',
        assignedToName: 'María López',
        priority: TaskPriority.media,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Task(
        id: 't3',
        title: 'Verificar luces de navegación',
        description: 'Comprobar el funcionamiento de todas las luces.',
        assignedToId: 'c3',
        assignedToName: 'Juan García',
        priority: TaskPriority.media,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 't4',
        title: 'Preparar menú del owner',
        description: 'Sushi y marisco. Sin carne roja.',
        assignedToId: 'c4',
        assignedToName: 'Ana Martínez',
        priority: TaskPriority.alta,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Task(
        id: 't5',
        title: 'Inventario de combustible',
        description: 'Registrar nivel actual y proyección.',
        assignedToId: 'c1',
        assignedToName: 'Carlos Ruiz',
        status: TaskStatus.completada,
        priority: TaskPriority.baja,
        createdAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(hours: 3)),
      ),
      Task(
        id: 't6',
        title: 'Mantenimiento ancla',
        description: 'Revisar cadena y mecanismo de anclaje.',
        assignedToId: 'c2',
        assignedToName: 'María López',
        status: TaskStatus.enProgreso,
        priority: TaskPriority.media,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];

    _certificates = [
      Certificate(
        id: 'cert1',
        name: 'Pasavante',
        issuer: 'Capitanía de Puerto',
        type: 'Navegación',
        expiryDate: now.add(const Duration(days: 12)),
      ),
      Certificate(
        id: 'cert2',
        name: 'Seguro de Casco',
        issuer: 'Mapfre Seguros',
        type: 'Seguro',
        expiryDate: now.add(const Duration(days: 45)),
      ),
      Certificate(
        id: 'cert3',
        name: 'Certificado de Seguridad',
        issuer: 'Registro Mercantil',
        type: 'Seguridad',
        expiryDate: now.add(const Duration(days: 78)),
      ),
      Certificate(
        id: 'cert4',
        name: 'Licencia de Radio',
        issuer: 'SEMAR',
        type: 'Comunicaciones',
        expiryDate: now.add(const Duration(days: 180)),
      ),
      Certificate(
        id: 'cert5',
        name: 'Certificado Sanitario',
        issuer: 'Sanidad Marítima',
        type: 'Salud',
        expiryDate: now.subtract(const Duration(days: 5)),
        notes: 'VENCIDO — Renovar urgentemente',
      ),
    ];

    _inventory = [
      InventoryItem(
        id: 'i1',
        name: 'Aceite de Motor',
        category: 'Mecánica',
        quantity: 3,
        unit: 'L',
        minLevel: 10,
        location: 'Sala de máquinas',
      ),
      InventoryItem(
        id: 'i2',
        name: 'Lejía',
        category: 'Limpieza',
        quantity: 2,
        unit: 'unid',
        minLevel: 5,
        location: 'Pañol limpieza',
      ),
      InventoryItem(
        id: 'i3',
        name: 'Combustible',
        category: 'Propulsión',
        quantity: 1200,
        unit: 'L',
        minLevel: 500,
        location: 'Tanques',
      ),
      InventoryItem(
        id: 'i4',
        name: 'Agua Potable',
        category: 'Consumo',
        quantity: 800,
        unit: 'L',
        minLevel: 200,
        location: 'Depósito',
      ),
      InventoryItem(
        id: 'i5',
        name: 'Bengalas de Señalización',
        category: 'Seguridad',
        quantity: 0,
        unit: 'unid',
        minLevel: 4,
        location: 'Caja seguridad',
      ),
      InventoryItem(
        id: 'i6',
        name: 'Filtros de Aceite',
        category: 'Mecánica',
        quantity: 1,
        unit: 'unid',
        minLevel: 3,
        location: 'Sala de máquinas',
      ),
    ];

    _ownerPreferences = [
      OwnerPreference(
        id: 'p1',
        type: OwnerPreferenceType.comida,
        detail: 'Le encanta el sushi y el pescado fresco',
        isPositive: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      OwnerPreference(
        id: 'p2',
        type: OwnerPreferenceType.comida,
        detail: 'No le gusta la carne roja',
        isPositive: false,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      OwnerPreference(
        id: 'p3',
        type: OwnerPreferenceType.bebida,
        detail: 'Prefiere champagne Dom Pérignon',
        isPositive: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      OwnerPreference(
        id: 'p4',
        type: OwnerPreferenceType.temperatura,
        detail: 'Cabina a 22°C, salón a 24°C',
        isPositive: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      OwnerPreference(
        id: 'p5',
        type: OwnerPreferenceType.musica,
        detail: 'Jazz en el salón durante las comidas',
        isPositive: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    _incidents = [
      Incident(
        id: 'inc1',
        title: 'Vibración en winch 3',
        description:
            'El winch número 3 presenta vibración anormal durante la operación.',
        location: 'Cubierta proa',
        priority: TaskPriority.alta,
        reportedBy: 'Carlos Ruiz',
        reportedAt: now.subtract(const Duration(hours: 3)),
      ),
      Incident(
        id: 'inc2',
        title: 'Grifo con fuga en baño proa',
        description: 'El grifo gotea constantemente.',
        location: 'Baño de proa',
        priority: TaskPriority.baja,
        status: IncidentStatus.enProgreso,
        reportedBy: 'María López',
        reportedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    _saveAll();
    notifyListeners();
  }

  Future<void> _saveAll() async {
    await Future.wait([
      _storage.saveTasks(_tasks),
      _storage.saveCrew(_crew),
      _storage.saveCertificates(_certificates),
      _storage.saveInventory(_inventory),
      _storage.saveOwnerPreferences(_ownerPreferences),
      _storage.saveIncidents(_incidents),
      _storage.saveVoiceCommands(_voiceCommands),
    ]);
  }

  // ==================== AUTH ====================

  void login(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ==================== TASKS ====================

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  List<Task> getTasksForCrew(String crewId) => _tasks
      .where((t) =>
          t.assignedToId == crewId &&
          (t.status == TaskStatus.pendiente ||
              t.status == TaskStatus.enProgreso))
      .toList();

  // ==================== CREW ====================

  Future<void> addCrewMember(CrewMember member) async {
    _crew.add(member);
    await _storage.saveCrew(_crew);
    notifyListeners();
  }

  Future<void> deleteCrewMember(String id) async {
    _crew.removeWhere((c) => c.id == id);
    await _storage.saveCrew(_crew);
    notifyListeners();
  }

  // ==================== CERTIFICATES ====================

  Future<void> addCertificate(Certificate cert) async {
    _certificates.add(cert);
    await _storage.saveCertificates(_certificates);
    notifyListeners();
  }

  Future<void> updateCertificate(Certificate cert) async {
    final idx = _certificates.indexWhere((c) => c.id == cert.id);
    if (idx != -1) {
      _certificates[idx] = cert;
      await _storage.saveCertificates(_certificates);
      notifyListeners();
    }
  }

  Future<void> deleteCertificate(String id) async {
    _certificates.removeWhere((c) => c.id == id);
    await _storage.saveCertificates(_certificates);
    notifyListeners();
  }

  // ==================== INVENTORY ====================

  Future<void> addInventoryItem(InventoryItem item) async {
    _inventory.add(item);
    await _storage.saveInventory(_inventory);
    notifyListeners();
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final idx = _inventory.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _inventory[idx] = item;
      await _storage.saveInventory(_inventory);
      notifyListeners();
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    _inventory.removeWhere((i) => i.id == id);
    await _storage.saveInventory(_inventory);
    notifyListeners();
  }

  // ==================== OWNER PREFERENCES ====================

  Future<void> addOwnerPreference(OwnerPreference pref) async {
    _ownerPreferences.insert(0, pref);
    await _storage.saveOwnerPreferences(_ownerPreferences);
    notifyListeners();
  }

  Future<void> deleteOwnerPreference(String id) async {
    _ownerPreferences.removeWhere((p) => p.id == id);
    await _storage.saveOwnerPreferences(_ownerPreferences);
    notifyListeners();
  }

  // ==================== INCIDENTS ====================

  Future<void> addIncident(Incident incident) async {
    _incidents.insert(0, incident);
    await _storage.saveIncidents(_incidents);
    notifyListeners();
  }

  Future<void> updateIncident(Incident incident) async {
    final idx = _incidents.indexWhere((i) => i.id == incident.id);
    if (idx != -1) {
      _incidents[idx] = incident;
      await _storage.saveIncidents(_incidents);
      notifyListeners();
    }
  }

  // ==================== VOICE COMMANDS ====================

  Future<void> addVoiceCommand(VoiceCommand cmd) async {
    _voiceCommands.insert(0, cmd);
    if (_voiceCommands.length > 50) {
      _voiceCommands = _voiceCommands.take(50).toList();
    }
    await _storage.saveVoiceCommands(_voiceCommands);
    notifyListeners();
  }

  Future<void> processVoiceCommand(
    VoiceCommand cmd,
    AiClassificationResult result,
  ) async {
    cmd.confirmed = true;
    await addVoiceCommand(cmd);

    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    switch (result.categoria) {
      case 'INCIDENCIA':
        await addIncident(Incident(
          id: id,
          title: _str(result.datosExtraidos['descripcion']) ?? cmd.transcript,
          description: cmd.transcript,
          location: _str(result.datosExtraidos['ubicacion']),
          priority: _parsePriority(result.prioridad),
          reportedBy: _currentUser?.name ?? 'Tripulación',
          reportedAt: now,
        ));
        break;
      case 'INVENTARIO':
        final producto = _str(result.datosExtraidos['producto']) ?? '';
        final match = _inventory.where((i) =>
            i.name.toLowerCase().contains(producto.toLowerCase())).firstOrNull;
        if (match != null) {
          match.quantity = 0;
          await updateInventoryItem(match);
        }
        break;
      case 'PREFERENCIA_OWNER':
        final tipo = _str(result.datosExtraidos['tipo']) ?? 'otro';
        final positivo = result.datosExtraidos['positivo'];
        await addOwnerPreference(OwnerPreference(
          id: id,
          type: OwnerPreferenceType.values.firstWhere(
            (e) => e.name == tipo,
            orElse: () => OwnerPreferenceType.otro,
          ),
          detail: _str(result.datosExtraidos['detalle']) ?? cmd.transcript,
          isPositive: positivo is bool ? positivo : true,
          createdAt: now,
        ));
        break;
      case 'EVENTO':
        await addTask(Task(
          id: id,
          title: 'Evento: ${_str(result.datosExtraidos["tipo_evento"]) ?? ""}',
          description: _str(result.datosExtraidos['detalle']) ?? cmd.transcript,
          priority: TaskPriority.alta,
          createdAt: now,
        ));
        break;
      case 'TAREA':
        await addTask(Task(
          id: id,
          title: _str(result.datosExtraidos['descripcion']) ?? cmd.transcript,
          description: cmd.transcript,
          priority: _parsePriority(result.prioridad),
          createdAt: now,
        ));
        break;
    }
  }

  String? _str(dynamic v) => v?.toString();

  TaskPriority _parsePriority(String p) {
    switch (p.toLowerCase()) {
      case 'alta':
        return TaskPriority.alta;
      case 'baja':
        return TaskPriority.baja;
      default:
        return TaskPriority.media;
    }
  }
}
