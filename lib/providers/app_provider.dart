import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/secure_auth_storage.dart';
import '../services/connectivity_service.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SupabaseService _cloud = SupabaseService();

  AppUser? _currentUser;
  List<Task> _tasks = [];
  List<CrewMember> _crew = [];
  List<Certificate> _certificates = [];
  List<InventoryItem> _inventory = [];
  List<OwnerPreference> _ownerPreferences = [];
  List<Incident> _incidents = [];
  List<VoiceCommand> _voiceCommands = [];
  List<AppUser> _users = [];
  YachtConfig? _yachtConfig;
  List<PendingVoiceMessage> _pendingVoiceMessages = [];
  List<ScannedDocument> _scannedDocuments = [];
  ConnectivityService? _connectivityService;
  bool _isLoading = false;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;

  // Getters
  AppUser? get currentUser => _currentUser;
  List<Task> get tasks => _tasks;
  List<CrewMember> get crew => _crew;
  List<Certificate> get certificates => _certificates;
  List<InventoryItem> get inventory => _inventory;
  List<OwnerPreference> get ownerPreferences => _ownerPreferences;
  List<Incident> get incidents => _incidents;
  List<VoiceCommand> get voiceCommands => _voiceCommands;
  List<AppUser> get users => _users;
  YachtConfig? get yachtConfig => _yachtConfig;
  List<PendingVoiceMessage> get pendingVoiceMessages => _pendingVoiceMessages;
  List<ScannedDocument> get scannedDocuments => _scannedDocuments;
  ConnectivityService? get connectivityService => _connectivityService;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;

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

  int get rejectedTasks =>
      _tasks.where((t) => t.status == TaskStatus.rechazada).length;

  // ==================== INIT ====================

  void setConnectivityService(ConnectivityService service) {
    _connectivityService = service;
    // Sincronizar automáticamente al recuperar conexión
    service.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (_connectivityService?.isOnline == true && _yachtConfig != null) {
      syncWithCloud();
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // 1. Carga local primero (instantánea)
    _tasks = await _storage.loadTasks();
    _crew = await _storage.loadCrew();
    _certificates = await _storage.loadCertificates();
    _inventory = await _storage.loadInventory();
    _ownerPreferences = await _storage.loadOwnerPreferences();
    _incidents = await _storage.loadIncidents();
    _voiceCommands = await _storage.loadVoiceCommands();
    _users = await _storage.loadUsers();
    _yachtConfig = await _storage.loadYachtConfig();
    _pendingVoiceMessages = await _storage.loadPendingVoiceMessages();
    _scannedDocuments = await _storage.loadScannedDocuments();

    if (_crew.isEmpty) {
      _loadDemoData();
    }

    _isLoading = false;
    notifyListeners();

    // 2. Pull desde Supabase en segundo plano si hay conexión
    if (_yachtConfig != null &&
        _connectivityService?.isOnline != false) {
      syncWithCloud();
    }
  }

  /// Sincronización bidireccional con Supabase.
  /// Estrategia: pull desde nube → merge con local (nube gana en conflictos) → save local.
  Future<void> syncWithCloud() async {
    final yachtId = _yachtConfig?.id;
    if (yachtId == null) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final snapshot = await _cloud.pullAll(yachtId);

      if (snapshot != null) {
        // Merge: la nube tiene prioridad sobre local para datos compartidos.
        // Los datos locales que no están en la nube se suben.
        _mergeFromCloud(snapshot);
        await _saveAllLocal();
      }

      // Sube datos locales que puedan faltar en la nube
      await _cloud.pushAll(
        yacht: _yachtConfig!,
        users: _users,
        tasks: _tasks,
        crew: _crew,
        certificates: _certificates,
        inventory: _inventory,
        preferences: _ownerPreferences,
        incidents: _incidents,
        voiceCommands: _voiceCommands,
        pendingMessages: _pendingVoiceMessages,
        scannedDocuments: _scannedDocuments,
        currentUserId: _currentUser?.id,
      );

      _lastSyncAt = DateTime.now();
    } catch (_) {
      // Sync falla silenciosamente — la app sigue funcionando offline
    }

    _isSyncing = false;
    notifyListeners();
  }

  void _mergeFromCloud(CloudSnapshot snap) {
    // Para cada entidad: si la nube tiene registros, reemplaza local.
    // Si la nube está vacía (primer sync desde este dispositivo), mantiene local.
    if (snap.tasks.isNotEmpty) _tasks = snap.tasks;
    if (snap.crew.isNotEmpty) _crew = snap.crew;
    if (snap.certificates.isNotEmpty) _certificates = snap.certificates;
    if (snap.inventory.isNotEmpty) _inventory = snap.inventory;
    if (snap.preferences.isNotEmpty) _ownerPreferences = snap.preferences;
    if (snap.incidents.isNotEmpty) _incidents = snap.incidents;
    if (snap.voiceCommands.isNotEmpty) _voiceCommands = snap.voiceCommands;
    if (snap.users.isNotEmpty) _users = snap.users;

    // Mensajes pendientes: merge por ID para no perder los locales
    final cloudPvmIds = snap.pendingMessages.map((m) => m.id).toSet();
    final localOnly = _pendingVoiceMessages
        .where((m) => !cloudPvmIds.contains(m.id))
        .toList();
    _pendingVoiceMessages = [...snap.pendingMessages, ...localOnly];

    if (snap.scannedDocuments.isNotEmpty) {
      _scannedDocuments = snap.scannedDocuments;
    }
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

    _saveAllLocal();
    notifyListeners();
  }

  Future<void> _saveAllLocal() async {
    await Future.wait([
      _storage.saveTasks(_tasks),
      _storage.saveCrew(_crew),
      _storage.saveCertificates(_certificates),
      _storage.saveInventory(_inventory),
      _storage.saveOwnerPreferences(_ownerPreferences),
      _storage.saveIncidents(_incidents),
      _storage.saveVoiceCommands(_voiceCommands),
      _storage.saveUsers(_users),
      _storage.savePendingVoiceMessages(_pendingVoiceMessages),
      _storage.saveScannedDocuments(_scannedDocuments),
    ]);
  }

  // ==================== AUTH ====================

  void login(AppUser user) {
    _currentUser = user;
    notifyListeners();
    unawaited(_signInSupabaseAuth(user.id));
  }

  Future<void> _signInSupabaseAuth(String userId) async {
    try {
      final creds = await SecureAuthStorage.readCredentials(userId);
      if (creds != null) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: creds['email']!,
          password: creds['password']!,
        );
      }
    } catch (_) {}
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
    Supabase.instance.client.auth.signOut().ignore();
  }

  Future<String?> registerAdmin({
    required String name,
    required String pin,
    required String yachtName,
    String? email,
  }) async {
    // Si no hay email real, generamos uno interno para Supabase Auth
    final authEmail = (email != null && email.isNotEmpty)
        ? email
        : 'admin-${DateTime.now().millisecondsSinceEpoch}@smartcrew.internal';
    final authPassword = AuthService.generateSecurePassword();

    // Intentar crear cuenta en Supabase Auth; si falla, seguimos con ID local
    String userId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: authEmail,
        password: authPassword,
      );
      if (authResponse.user != null) {
        userId = authResponse.user!.id;
        await SecureAuthStorage.saveCredentials(userId, authEmail, authPassword);
      }
    } catch (_) {}

    final hashedPin = AuthService.hashPin(pin);
    final yachtId = 'y_$userId';

    final yachtCfg = YachtConfig(
      id: yachtId,
      name: yachtName,
      adminId: userId,
      createdAt: DateTime.now(),
    );

    final admin = AppUser(
      id: userId,
      name: name,
      role: UserRole.gestor,
      pin: hashedPin,
      isAdmin: true,
      yachtId: yachtId,
      yachtName: yachtName,
      accountStatus: AccountStatus.active,
      email: email,
    );

    _users.add(admin);
    _yachtConfig = yachtCfg;
    await _storage.saveUsers(_users);
    await _storage.saveYachtConfig(yachtCfg);
    unawaited(_cloud.upsertYacht(yachtCfg));
    unawaited(_cloud.upsertUser(admin));
    notifyListeners();
    return null;
  }

  AppUser? loginWithPIN(String identifier, String pin) {
    final user = _users.where((u) => u.name.toLowerCase() == identifier.toLowerCase()).firstOrNull;
    if (user == null) return null;
    if (!AuthService.verifyPin(pin, user.pin)) return null;
    if (user.accountStatus == AccountStatus.blocked) return null;
    if (user.accountExpiresAt != null && user.accountExpiresAt!.isBefore(DateTime.now())) return null;
    _currentUser = user;
    notifyListeners();
    return user;
  }

  Future<void> createCrewMember({
    required String name,
    required String role,
    required String pin,
    DateTime? accountExpiresAt,
    String? email,
    String? notes,
    String? department,
    String? photoPath,
  }) async {
    // Email interno para Supabase Auth — el tripulante nunca lo ve
    final internalEmail =
        'crew-${DateTime.now().millisecondsSinceEpoch}@smartcrew.internal';
    final authPassword = AuthService.generateSecurePassword();

    // Intentar crear cuenta en Supabase Auth; si falla, seguimos con ID local
    String userId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: internalEmail,
        password: authPassword,
      );
      if (authResponse.user != null) {
        userId = authResponse.user!.id;
        await SecureAuthStorage.saveCredentials(
            userId, internalEmail, authPassword);
      }
    } catch (_) {}

    final hashedPin = AuthService.hashPin(pin);

    final user = AppUser(
      id: userId,
      name: name,
      role: UserRole.tripulante,
      pin: hashedPin,
      isAdmin: false,
      yachtId: _yachtConfig?.id,
      yachtName: _yachtConfig?.name,
      accountExpiresAt: accountExpiresAt,
      accountStatus: AccountStatus.active,
      mustChangePIN: true,
      email: email,
    );

    final member = CrewMember(
      id: userId,
      name: name,
      role: role,
      notes: notes,
      department: department,
      photoPath: photoPath,
    );

    _users.add(user);
    _crew.add(member);
    await _storage.saveUsers(_users);
    await _storage.saveCrew(_crew);
    unawaited(_cloud.upsertUser(user));
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertCrew(member, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> updateAccountExpiry(String userId, DateTime? expiry) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final u = _users[idx];
    _users[idx] = AppUser(
      id: u.id,
      name: u.name,
      role: u.role,
      pin: u.pin,
      isAdmin: u.isAdmin,
      yachtId: u.yachtId,
      yachtName: u.yachtName,
      accountExpiresAt: expiry,
      accountStatus: u.accountStatus,
      mustChangePIN: u.mustChangePIN,
      email: u.email,
    );
    await _storage.saveUsers(_users);
    notifyListeners();
  }

  Future<void> blockAccount(String userId) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final u = _users[idx];
    _users[idx] = AppUser(
      id: u.id,
      name: u.name,
      role: u.role,
      pin: u.pin,
      isAdmin: u.isAdmin,
      yachtId: u.yachtId,
      yachtName: u.yachtName,
      accountExpiresAt: u.accountExpiresAt,
      accountStatus: AccountStatus.blocked,
      mustChangePIN: u.mustChangePIN,
      email: u.email,
    );
    await _storage.saveUsers(_users);
    notifyListeners();
  }

  Future<void> unblockAccount(String userId) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final u = _users[idx];
    _users[idx] = AppUser(
      id: u.id,
      name: u.name,
      role: u.role,
      pin: u.pin,
      isAdmin: u.isAdmin,
      yachtId: u.yachtId,
      yachtName: u.yachtName,
      accountExpiresAt: u.accountExpiresAt,
      accountStatus: AccountStatus.active,
      mustChangePIN: u.mustChangePIN,
      email: u.email,
    );
    await _storage.saveUsers(_users);
    notifyListeners();
  }

  Future<void> resetCrewPinByAdmin(String userId, String tempPin) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final u = _users[idx];
    _users[idx] = AppUser(
      id: u.id,
      name: u.name,
      role: u.role,
      pin: AuthService.hashPin(tempPin),
      isAdmin: u.isAdmin,
      yachtId: u.yachtId,
      yachtName: u.yachtName,
      accountExpiresAt: u.accountExpiresAt,
      accountStatus: u.accountStatus,
      mustChangePIN: true,
      email: u.email,
    );
    await _storage.saveUsers(_users);
    unawaited(_cloud.upsertUser(_users[idx]));
    notifyListeners();
  }

  Future<void> resetCrewPin(String userId, String newPin) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final u = _users[idx];
    _users[idx] = AppUser(
      id: u.id,
      name: u.name,
      role: u.role,
      pin: AuthService.hashPin(newPin),
      isAdmin: u.isAdmin,
      yachtId: u.yachtId,
      yachtName: u.yachtName,
      accountExpiresAt: u.accountExpiresAt,
      accountStatus: u.accountStatus,
      mustChangePIN: false,
      email: u.email,
    );
    await _storage.saveUsers(_users);
    unawaited(_cloud.upsertUser(_users[idx]));
    notifyListeners();
  }

  // ==================== TASKS ====================

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    await _storage.saveTasks(_tasks);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertTask(task, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      await _storage.saveTasks(_tasks);
      if (_yachtConfig != null) {
        unawaited(_cloud.upsertTask(task, _yachtConfig!.id));
      }
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _storage.saveTasks(_tasks);
    unawaited(_cloud.deleteTask(id));
    notifyListeners();
  }

  Future<void> completeTask(String id, String comment) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final t = _tasks[idx];
    t.status = TaskStatus.completada;
    t.completedAt = DateTime.now();
    t.completionComment = comment;
    t.actionBy = _currentUser?.name;
    t.actionAt = DateTime.now();
    await _storage.saveTasks(_tasks);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertTask(t, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> rejectTask(String id, String reason) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final t = _tasks[idx];
    t.status = TaskStatus.rechazada;
    t.rejectionReason = reason;
    t.actionBy = _currentUser?.name;
    t.actionAt = DateTime.now();
    await _storage.saveTasks(_tasks);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertTask(t, _yachtConfig!.id));
    }
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
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertCrew(member, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> deleteCrewMember(String id) async {
    _crew.removeWhere((c) => c.id == id);
    await _storage.saveCrew(_crew);
    unawaited(_cloud.deleteCrew(id));
    // BUG-008: Deactivate (not delete) the user account
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final u = _users[idx];
      _users[idx] = AppUser(
        id: u.id,
        name: u.name,
        role: u.role,
        pin: u.pin,
        isAdmin: u.isAdmin,
        yachtId: u.yachtId,
        yachtName: u.yachtName,
        accountExpiresAt: u.accountExpiresAt,
        accountStatus: AccountStatus.blocked,
        mustChangePIN: u.mustChangePIN,
        email: u.email,
      );
      await _storage.saveUsers(_users);
      unawaited(_cloud.upsertUser(_users[idx]));
    }
    notifyListeners();
  }

  // BUG-009: Update crew member data
  Future<void> updateCrewMember({
    required String memberId,
    required String name,
    required String role,
    String? department,
    String? photoPath,
    DateTime? accountExpiresAt,
  }) async {
    final crewIdx = _crew.indexWhere((c) => c.id == memberId);
    if (crewIdx != -1) {
      _crew[crewIdx] = CrewMember(
        id: memberId,
        name: name,
        role: role,
        notes: _crew[crewIdx].notes,
        department: department,
        photoPath: photoPath,
      );
      await _storage.saveCrew(_crew);
      if (_yachtConfig != null) {
        unawaited(_cloud.upsertCrew(_crew[crewIdx], _yachtConfig!.id));
      }
    }
    final userIdx = _users.indexWhere((u) => u.id == memberId);
    if (userIdx != -1) {
      final u = _users[userIdx];
      _users[userIdx] = AppUser(
        id: u.id,
        name: name,
        role: u.role,
        pin: u.pin,
        isAdmin: u.isAdmin,
        yachtId: u.yachtId,
        yachtName: u.yachtName,
        accountExpiresAt: accountExpiresAt,
        accountStatus: u.accountStatus,
        mustChangePIN: u.mustChangePIN,
        email: u.email,
      );
      await _storage.saveUsers(_users);
      unawaited(_cloud.upsertUser(_users[userIdx]));
    }
    notifyListeners();
  }

  // ==================== CERTIFICATES ====================

  Future<void> addCertificate(Certificate cert) async {
    _certificates.add(cert);
    await _storage.saveCertificates(_certificates);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertCertificate(cert, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> updateCertificate(Certificate cert) async {
    final idx = _certificates.indexWhere((c) => c.id == cert.id);
    if (idx != -1) {
      _certificates[idx] = cert;
      await _storage.saveCertificates(_certificates);
      if (_yachtConfig != null) {
        unawaited(_cloud.upsertCertificate(cert, _yachtConfig!.id));
      }
      notifyListeners();
    }
  }

  Future<void> deleteCertificate(String id) async {
    _certificates.removeWhere((c) => c.id == id);
    await _storage.saveCertificates(_certificates);
    unawaited(_cloud.deleteCertificate(id));
    notifyListeners();
  }

  // ==================== INVENTORY ====================

  Future<void> addInventoryItem(InventoryItem item) async {
    _inventory.add(item);
    await _storage.saveInventory(_inventory);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertInventoryItem(item, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final idx = _inventory.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _inventory[idx] = item;
      await _storage.saveInventory(_inventory);
      if (_yachtConfig != null) {
        unawaited(_cloud.upsertInventoryItem(item, _yachtConfig!.id));
      }
      notifyListeners();
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    _inventory.removeWhere((i) => i.id == id);
    await _storage.saveInventory(_inventory);
    unawaited(_cloud.deleteInventoryItem(id));
    notifyListeners();
  }

  // ==================== OWNER PREFERENCES ====================

  Future<void> addOwnerPreference(OwnerPreference pref) async {
    _ownerPreferences.insert(0, pref);
    await _storage.saveOwnerPreferences(_ownerPreferences);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertOwnerPreference(pref, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> deleteOwnerPreference(String id) async {
    _ownerPreferences.removeWhere((p) => p.id == id);
    await _storage.saveOwnerPreferences(_ownerPreferences);
    unawaited(_cloud.deleteOwnerPreference(id));
    notifyListeners();
  }

  // ==================== INCIDENTS ====================

  Future<void> addIncident(Incident incident) async {
    _incidents.insert(0, incident);
    await _storage.saveIncidents(_incidents);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertIncident(incident, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> updateIncident(Incident incident) async {
    final idx = _incidents.indexWhere((i) => i.id == incident.id);
    if (idx != -1) {
      _incidents[idx] = incident;
      await _storage.saveIncidents(_incidents);
      if (_yachtConfig != null) {
        unawaited(_cloud.upsertIncident(incident, _yachtConfig!.id));
      }
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
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertVoiceCommand(
          cmd, _yachtConfig!.id, _currentUser?.id));
    }
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
        // BUG-006: Apply quantity action (restar/sumar/alerta) correctly
        final producto = _str(result.datosExtraidos['item_name']) ??
            _str(result.datosExtraidos['producto']) ?? '';
        final accion = _str(result.datosExtraidos['action']) ??
            _str(result.datosExtraidos['accion']) ?? 'alerta';
        final rawQty = result.datosExtraidos['quantity'] ??
            result.datosExtraidos['cantidad'];
        final cantidad = rawQty != null
            ? (rawQty is num ? rawQty.toDouble() : double.tryParse('$rawQty') ?? 0.0)
            : 0.0;

        final matchedId = _str(result.datosExtraidos['matched_inventory_id']);
        InventoryItem? match;
        if (matchedId != null) {
          match = _inventory.where((i) => i.id == matchedId).firstOrNull;
        }
        match ??= _inventory
            .where((i) =>
                i.name.toLowerCase().contains(producto.toLowerCase()) &&
                producto.isNotEmpty)
            .firstOrNull;

        if (match != null && accion != 'alerta') {
          if (accion == 'restar') {
            match.quantity =
                (match.quantity - cantidad).clamp(0.0, double.infinity);
          } else if (accion == 'sumar') {
            match.quantity = match.quantity + cantidad;
          }
          await updateInventoryItem(match);
        }
        break;
      case 'CONSULTA_INVENTARIO':
        // BUG-007: Just record the voice command; actual response is built by getShoppingListResponse()
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

  // BUG-007: Generate shopping list from low-stock items
  String getShoppingListResponse() {
    final lowStock = _inventory
        .where((i) => i.status != InventoryStatus.ok)
        .toList();
    if (lowStock.isEmpty) {
      return 'El inventario está completo. No hay artículos por comprar.';
    }
    final items = lowStock.map((i) {
      if (i.status == InventoryStatus.sinStock) {
        return '${i.name} (agotado)';
      }
      return '${i.name} (quedan ${i.quantity} ${i.unit}, mínimo ${i.minLevel})';
    }).join(', ');
    return 'Necesitas comprar: $items';
  }

  // ==================== PENDING VOICE MESSAGES ====================

  Future<void> addPendingVoiceMessage(PendingVoiceMessage msg) async {
    _pendingVoiceMessages.insert(0, msg);
    await _storage.savePendingVoiceMessages(_pendingVoiceMessages);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertPendingVoiceMessage(
          msg, _yachtConfig!.id, _currentUser?.id));
    }
    notifyListeners();
  }

  Future<void> processPendingMessages(
      Future<AiClassificationResult> Function(String) classify) async {
    final unprocessed = _pendingVoiceMessages.where((m) => !m.processed).toList();
    for (final msg in unprocessed) {
      try {
        final result = await classify(msg.transcript);
        final cmd = VoiceCommand(
          id: msg.id,
          transcript: msg.transcript,
          category: result.categoria,
          priority: result.prioridad,
          extractedData: result.datosExtraidos,
          userResponse: result.respuestaUsuario,
          timestamp: msg.recordedAt,
        );
        await processVoiceCommand(cmd, result);
        msg.processed = true;
      } catch (e) {
        msg.processingError = e.toString();
      }
    }
    await _storage.savePendingVoiceMessages(_pendingVoiceMessages);
    notifyListeners();
  }

  // ==================== SCANNED DOCUMENTS ====================

  Future<void> addScannedDocument(ScannedDocument doc) async {
    _scannedDocuments.insert(0, doc);
    await _storage.saveScannedDocuments(_scannedDocuments);
    if (_yachtConfig != null) {
      unawaited(_cloud.upsertScannedDocument(doc, _yachtConfig!.id));
    }
    notifyListeners();
  }

  Future<void> updateScannedDocument(ScannedDocument doc) async {
    final idx = _scannedDocuments.indexWhere((d) => d.id == doc.id);
    if (idx != -1) {
      _scannedDocuments[idx] = doc;
      await _storage.saveScannedDocuments(_scannedDocuments);
      if (_yachtConfig != null) {
        unawaited(_cloud.upsertScannedDocument(doc, _yachtConfig!.id));
      }
      notifyListeners();
    }
  }

  Future<void> deleteScannedDocument(String id) async {
    _scannedDocuments.removeWhere((d) => d.id == id);
    await _storage.saveScannedDocuments(_scannedDocuments);
    unawaited(_cloud.deleteScannedDocument(id));
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService?.removeListener(_onConnectivityChanged);
    super.dispose();
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
