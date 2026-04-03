import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Capa de acceso a Supabase.
/// Todas las operaciones son fire-and-forget seguras:
/// cualquier error de red se captura y se ignora silenciosamente
/// para no interrumpir el flujo offline-first de la app.
class SupabaseService {
  static SupabaseClient get _db => Supabase.instance.client;

  // ─────────────────────────────────────────────
  // HELPERS de mapeo Flutter ↔ Supabase (snake_case)
  // ─────────────────────────────────────────────

  static Map<String, dynamic> _yachtRow(YachtConfig y) => {
        'id': y.id,
        'name': y.name,
        'admin_id': y.adminId,
        'created_at': y.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _userRow(AppUser u) => {
        'id': u.id,
        'name': u.name,
        'email': u.email,
        'role': u.role.name,
        'pin_hash': u.pin,
        'is_admin': u.isAdmin,
        'yacht_id': u.yachtId,
        'yacht_name': u.yachtName,
        'account_expires_at': u.accountExpiresAt?.toIso8601String(),
        'account_status': u.accountStatus.name,
        'must_change_pin': u.mustChangePIN,
      };

  static Map<String, dynamic> _taskRow(Task t, String yachtId) => {
        'id': t.id,
        'yacht_id': yachtId,
        'title': t.title,
        'description': t.description,
        'assigned_to_id': t.assignedToId,
        'assigned_to_name': t.assignedToName,
        'status': t.status.name,
        'priority': t.priority.name,
        'due_date': t.dueDate?.toIso8601String(),
        'completed_at': t.completedAt?.toIso8601String(),
        'rejection_reason': t.rejectionReason,
        'completion_comment': t.completionComment,
        'action_by': t.actionBy,
        'action_at': t.actionAt?.toIso8601String(),
        'created_at': t.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _crewRow(CrewMember c, String yachtId) => {
        'id': c.id,
        'yacht_id': yachtId,
        'name': c.name,
        'role': c.role,
        'notes': c.notes,
      };

  static Map<String, dynamic> _certRow(Certificate c, String yachtId) => {
        'id': c.id,
        'yacht_id': yachtId,
        'name': c.name,
        'issuer': c.issuer,
        'type': c.type,
        'expiry_date': c.expiryDate.toIso8601String(),
        'notes': c.notes,
      };

  static Map<String, dynamic> _invRow(InventoryItem i, String yachtId) => {
        'id': i.id,
        'yacht_id': yachtId,
        'name': i.name,
        'category': i.category,
        'quantity': i.quantity,
        'unit': i.unit,
        'min_level': i.minLevel,
        'location': i.location,
      };

  static Map<String, dynamic> _prefRow(OwnerPreference p, String yachtId) => {
        'id': p.id,
        'yacht_id': yachtId,
        'type': p.type.name,
        'detail': p.detail,
        'is_positive': p.isPositive,
        'notes': p.notes,
        'via_hey_yat': p.viaHeyYat,
        'created_at': p.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _incidentRow(Incident i, String yachtId) => {
        'id': i.id,
        'yacht_id': yachtId,
        'title': i.title,
        'description': i.description,
        'location': i.location,
        'priority': i.priority.name,
        'status': i.status.name,
        'reported_by': i.reportedBy,
        'reported_at': i.reportedAt.toIso8601String(),
        'resolution': i.resolution,
      };

  static Map<String, dynamic> _vcRow(
          VoiceCommand v, String yachtId, String? userId) =>
      {
        'id': v.id,
        'yacht_id': yachtId,
        'user_id': userId,
        'transcript': v.transcript,
        'category': v.category,
        'priority': v.priority,
        'extracted_data': v.extractedData,
        'user_response': v.userResponse,
        'confirmed': v.confirmed,
        'timestamp': v.timestamp.toIso8601String(),
      };

  static Map<String, dynamic> _pvmRow(
          PendingVoiceMessage m, String yachtId, String? userId) =>
      {
        'id': m.id,
        'yacht_id': yachtId,
        'user_id': userId,
        'transcript': m.transcript,
        'recorded_at': m.recordedAt.toIso8601String(),
        'processed': m.processed,
        'processing_error': m.processingError,
      };

  static Map<String, dynamic> _docRow(ScannedDocument d, String yachtId) => {
        'id': d.id,
        'yacht_id': yachtId,
        'scanned_by': d.scannedBy,
        'type': d.type,
        'description': d.description,
        'holder_name': d.holderName,
        'issued_at': d.issuedAt?.toIso8601String(),
        'expires_at': d.expiresAt?.toIso8601String(),
        'status': d.status,
        'image_paths': d.imagePaths,
        'notes': d.notes,
        'scanned_at': d.scannedAt.toIso8601String(),
      };

  // ─────────────────────────────────────────────
  // MAPEO Supabase → modelos Flutter
  // ─────────────────────────────────────────────

  static AppUser _userFromRow(Map<String, dynamic> r) => AppUser(
        id: r['id'],
        name: r['name'],
        email: r['email'],
        role: UserRole.values.firstWhere((e) => e.name == r['role'],
            orElse: () => UserRole.tripulante),
        pin: r['pin_hash'] ?? '',
        isAdmin: r['is_admin'] ?? false,
        yachtId: r['yacht_id'],
        yachtName: r['yacht_name'],
        accountExpiresAt: r['account_expires_at'] != null
            ? DateTime.tryParse(r['account_expires_at'])
            : null,
        accountStatus: AccountStatus.values.firstWhere(
            (e) => e.name == (r['account_status'] ?? 'active'),
            orElse: () => AccountStatus.active),
        mustChangePIN: r['must_change_pin'] ?? false,
      );

  static YachtConfig _yachtFromRow(Map<String, dynamic> r) => YachtConfig(
        id: r['id'],
        name: r['name'],
        adminId: r['admin_id'],
        createdAt: DateTime.parse(r['created_at']),
      );

  static Task _taskFromRow(Map<String, dynamic> r) => Task(
        id: r['id'],
        title: r['title'],
        description: r['description'] ?? '',
        assignedToId: r['assigned_to_id'],
        assignedToName: r['assigned_to_name'],
        status: TaskStatus.values.firstWhere((e) => e.name == r['status'],
            orElse: () => TaskStatus.pendiente),
        priority: TaskPriority.values.firstWhere(
            (e) => e.name == r['priority'],
            orElse: () => TaskPriority.media),
        createdAt: DateTime.parse(r['created_at']),
        dueDate:
            r['due_date'] != null ? DateTime.tryParse(r['due_date']) : null,
        completedAt: r['completed_at'] != null
            ? DateTime.tryParse(r['completed_at'])
            : null,
        rejectionReason: r['rejection_reason'],
        completionComment: r['completion_comment'],
        actionBy: r['action_by'],
        actionAt:
            r['action_at'] != null ? DateTime.tryParse(r['action_at']) : null,
      );

  static CrewMember _crewFromRow(Map<String, dynamic> r) => CrewMember(
        id: r['id'],
        name: r['name'],
        role: r['role'],
        notes: r['notes'],
      );

  static Certificate _certFromRow(Map<String, dynamic> r) => Certificate(
        id: r['id'],
        name: r['name'],
        issuer: r['issuer'] ?? '',
        type: r['type'] ?? '',
        expiryDate: DateTime.parse(r['expiry_date']),
        notes: r['notes'],
      );

  static InventoryItem _invFromRow(Map<String, dynamic> r) => InventoryItem(
        id: r['id'],
        name: r['name'],
        category: r['category'] ?? '',
        quantity: (r['quantity'] as num).toDouble(),
        unit: r['unit'] ?? 'ud',
        minLevel: (r['min_level'] as num).toDouble(),
        location: r['location'],
      );

  static OwnerPreference _prefFromRow(Map<String, dynamic> r) =>
      OwnerPreference(
        id: r['id'],
        type: OwnerPreferenceType.values.firstWhere((e) => e.name == r['type'],
            orElse: () => OwnerPreferenceType.otro),
        detail: r['detail'],
        isPositive: r['is_positive'] ?? true,
        notes: r['notes'],
        createdAt: DateTime.parse(r['created_at']),
        viaHeyYat: r['via_hey_yat'] ?? false,
      );

  static Incident _incidentFromRow(Map<String, dynamic> r) => Incident(
        id: r['id'],
        title: r['title'],
        description: r['description'] ?? '',
        location: r['location'],
        priority: TaskPriority.values.firstWhere(
            (e) => e.name == r['priority'],
            orElse: () => TaskPriority.media),
        status: IncidentStatus.values.firstWhere(
            (e) => e.name == r['status'],
            orElse: () => IncidentStatus.abierta),
        reportedBy: r['reported_by'] ?? '',
        reportedAt: DateTime.parse(r['reported_at']),
        resolution: r['resolution'],
      );

  static VoiceCommand _vcFromRow(Map<String, dynamic> r) => VoiceCommand(
        id: r['id'],
        transcript: r['transcript'],
        category: r['category'],
        priority: r['priority'] ?? 'media',
        extractedData: Map<String, dynamic>.from(r['extracted_data'] ?? {}),
        userResponse: r['user_response'] ?? '',
        confirmed: r['confirmed'] ?? false,
        timestamp: DateTime.parse(r['timestamp']),
      );

  static PendingVoiceMessage _pvmFromRow(Map<String, dynamic> r) =>
      PendingVoiceMessage(
        id: r['id'],
        transcript: r['transcript'],
        recordedAt: DateTime.parse(r['recorded_at']),
        processed: r['processed'] ?? false,
        processingError: r['processing_error'],
      );

  static ScannedDocument _docFromRow(Map<String, dynamic> r) => ScannedDocument(
        id: r['id'],
        type: r['type'],
        description: r['description'] ?? '',
        holderName: r['holder_name'],
        issuedAt:
            r['issued_at'] != null ? DateTime.tryParse(r['issued_at']) : null,
        expiresAt:
            r['expires_at'] != null ? DateTime.tryParse(r['expires_at']) : null,
        status: r['status'] ?? 'Pendiente',
        imagePaths: List<String>.from(r['image_paths'] ?? []),
        scannedAt: DateTime.parse(r['scanned_at']),
        scannedBy: r['scanned_by'] ?? '',
        notes: r['notes'],
      );

  // ─────────────────────────────────────────────
  // ESCRITURA (upsert / delete) — fire-and-forget
  // ─────────────────────────────────────────────

  Future<void> upsertYacht(YachtConfig y) async {
    try {
      await _db.from('yachts').upsert(_yachtRow(y));
    } catch (_) {}
  }

  Future<void> upsertUser(AppUser u) async {
    try {
      await _db.from('users').upsert(_userRow(u));
    } catch (_) {}
  }

  Future<void> upsertTask(Task t, String yachtId) async {
    try {
      await _db.from('tasks').upsert(_taskRow(t, yachtId));
    } catch (_) {}
  }

  Future<void> deleteTask(String id) async {
    try {
      await _db.from('tasks').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> upsertCrew(CrewMember c, String yachtId) async {
    try {
      await _db.from('crew_members').upsert(_crewRow(c, yachtId));
    } catch (_) {}
  }

  Future<void> deleteCrew(String id) async {
    try {
      await _db.from('crew_members').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> upsertCertificate(Certificate c, String yachtId) async {
    try {
      await _db.from('certificates').upsert(_certRow(c, yachtId));
    } catch (_) {}
  }

  Future<void> deleteCertificate(String id) async {
    try {
      await _db.from('certificates').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> upsertInventoryItem(InventoryItem i, String yachtId) async {
    try {
      await _db.from('inventory_items').upsert(_invRow(i, yachtId));
    } catch (_) {}
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      await _db.from('inventory_items').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> upsertOwnerPreference(OwnerPreference p, String yachtId) async {
    try {
      await _db.from('owner_preferences').upsert(_prefRow(p, yachtId));
    } catch (_) {}
  }

  Future<void> deleteOwnerPreference(String id) async {
    try {
      await _db.from('owner_preferences').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> upsertIncident(Incident i, String yachtId) async {
    try {
      await _db.from('incidents').upsert(_incidentRow(i, yachtId));
    } catch (_) {}
  }

  Future<void> upsertVoiceCommand(
      VoiceCommand v, String yachtId, String? userId) async {
    try {
      await _db.from('voice_commands').upsert(_vcRow(v, yachtId, userId));
    } catch (_) {}
  }

  Future<void> upsertPendingVoiceMessage(
      PendingVoiceMessage m, String yachtId, String? userId) async {
    try {
      await _db
          .from('pending_voice_messages')
          .upsert(_pvmRow(m, yachtId, userId));
    } catch (_) {}
  }

  Future<void> deletePendingVoiceMessage(String id) async {
    try {
      await _db.from('pending_voice_messages').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> upsertScannedDocument(ScannedDocument d, String yachtId) async {
    try {
      await _db.from('scanned_documents').upsert(_docRow(d, yachtId));
    } catch (_) {}
  }

  Future<void> deleteScannedDocument(String id) async {
    try {
      await _db.from('scanned_documents').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> upsertUsers(List<AppUser> users) async {
    if (users.isEmpty) return;
    try {
      await _db.from('users').upsert(users.map(_userRow).toList());
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // LECTURA — pull completo para un yate
  // ─────────────────────────────────────────────

  Future<YachtConfig?> fetchYacht(String yachtId) async {
    try {
      final row = await _db
          .from('yachts')
          .select()
          .eq('id', yachtId)
          .maybeSingle();
      return row != null ? _yachtFromRow(row) : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<AppUser>> fetchUsers(String yachtId) async {
    try {
      final rows = await _db
          .from('users')
          .select()
          .eq('yacht_id', yachtId);
      return (rows as List).map((r) => _userFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Task>> fetchTasks(String yachtId) async {
    try {
      final rows = await _db
          .from('tasks')
          .select()
          .eq('yacht_id', yachtId)
          .order('created_at', ascending: false);
      return (rows as List).map((r) => _taskFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<CrewMember>> fetchCrew(String yachtId) async {
    try {
      final rows = await _db
          .from('crew_members')
          .select()
          .eq('yacht_id', yachtId);
      return (rows as List).map((r) => _crewFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Certificate>> fetchCertificates(String yachtId) async {
    try {
      final rows = await _db
          .from('certificates')
          .select()
          .eq('yacht_id', yachtId)
          .order('expiry_date');
      return (rows as List).map((r) => _certFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<InventoryItem>> fetchInventory(String yachtId) async {
    try {
      final rows = await _db
          .from('inventory_items')
          .select()
          .eq('yacht_id', yachtId);
      return (rows as List).map((r) => _invFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OwnerPreference>> fetchOwnerPreferences(String yachtId) async {
    try {
      final rows = await _db
          .from('owner_preferences')
          .select()
          .eq('yacht_id', yachtId)
          .order('created_at', ascending: false);
      return (rows as List).map((r) => _prefFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Incident>> fetchIncidents(String yachtId) async {
    try {
      final rows = await _db
          .from('incidents')
          .select()
          .eq('yacht_id', yachtId)
          .order('reported_at', ascending: false);
      return (rows as List).map((r) => _incidentFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<VoiceCommand>> fetchVoiceCommands(String yachtId) async {
    try {
      final rows = await _db
          .from('voice_commands')
          .select()
          .eq('yacht_id', yachtId)
          .order('timestamp', ascending: false)
          .limit(50);
      return (rows as List).map((r) => _vcFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<PendingVoiceMessage>> fetchPendingVoiceMessages(
      String yachtId) async {
    try {
      final rows = await _db
          .from('pending_voice_messages')
          .select()
          .eq('yacht_id', yachtId)
          .eq('processed', false);
      return (rows as List).map((r) => _pvmFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ScannedDocument>> fetchScannedDocuments(String yachtId) async {
    try {
      final rows = await _db
          .from('scanned_documents')
          .select()
          .eq('yacht_id', yachtId)
          .order('scanned_at', ascending: false);
      return (rows as List).map((r) => _docFromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // PUSH COMPLETO — sube todos los datos locales
  // ─────────────────────────────────────────────

  Future<void> pushAll({
    required YachtConfig yacht,
    required List<AppUser> users,
    required List<Task> tasks,
    required List<CrewMember> crew,
    required List<Certificate> certificates,
    required List<InventoryItem> inventory,
    required List<OwnerPreference> preferences,
    required List<Incident> incidents,
    required List<VoiceCommand> voiceCommands,
    required List<PendingVoiceMessage> pendingMessages,
    required List<ScannedDocument> scannedDocuments,
    String? currentUserId,
  }) async {
    final yId = yacht.id;
    await Future.wait([
      upsertYacht(yacht),
      upsertUsers(users),
      if (tasks.isNotEmpty)
        _db
            .from('tasks')
            .upsert(tasks.map((t) => _taskRow(t, yId)).toList())
            .then((_) {})
            .catchError((_) {}),
      if (crew.isNotEmpty)
        _db
            .from('crew_members')
            .upsert(crew.map((c) => _crewRow(c, yId)).toList())
            .then((_) {})
            .catchError((_) {}),
      if (certificates.isNotEmpty)
        _db
            .from('certificates')
            .upsert(certificates.map((c) => _certRow(c, yId)).toList())
            .then((_) {})
            .catchError((_) {}),
      if (inventory.isNotEmpty)
        _db
            .from('inventory_items')
            .upsert(inventory.map((i) => _invRow(i, yId)).toList())
            .then((_) {})
            .catchError((_) {}),
      if (preferences.isNotEmpty)
        _db
            .from('owner_preferences')
            .upsert(preferences.map((p) => _prefRow(p, yId)).toList())
            .then((_) {})
            .catchError((_) {}),
      if (incidents.isNotEmpty)
        _db
            .from('incidents')
            .upsert(incidents.map((i) => _incidentRow(i, yId)).toList())
            .then((_) {})
            .catchError((_) {}),
      if (voiceCommands.isNotEmpty)
        _db
            .from('voice_commands')
            .upsert(voiceCommands
                .map((v) => _vcRow(v, yId, currentUserId))
                .toList())
            .then((_) {})
            .catchError((_) {}),
      if (pendingMessages.isNotEmpty)
        _db
            .from('pending_voice_messages')
            .upsert(pendingMessages
                .map((m) => _pvmRow(m, yId, currentUserId))
                .toList())
            .then((_) {})
            .catchError((_) {}),
      if (scannedDocuments.isNotEmpty)
        _db
            .from('scanned_documents')
            .upsert(scannedDocuments.map((d) => _docRow(d, yId)).toList())
            .then((_) {})
            .catchError((_) {}),
    ]);
  }

  // ─────────────────────────────────────────────
  // PULL COMPLETO — descarga todo para un yate
  // ─────────────────────────────────────────────

  Future<CloudSnapshot?> pullAll(String yachtId) async {
    try {
      final results = await Future.wait([
        fetchYacht(yachtId),
        fetchUsers(yachtId),
        fetchTasks(yachtId),
        fetchCrew(yachtId),
        fetchCertificates(yachtId),
        fetchInventory(yachtId),
        fetchOwnerPreferences(yachtId),
        fetchIncidents(yachtId),
        fetchVoiceCommands(yachtId),
        fetchPendingVoiceMessages(yachtId),
        fetchScannedDocuments(yachtId),
      ]);

      final yacht = results[0] as YachtConfig?;
      if (yacht == null) return null;

      return CloudSnapshot(
        yacht: yacht,
        users: results[1] as List<AppUser>,
        tasks: results[2] as List<Task>,
        crew: results[3] as List<CrewMember>,
        certificates: results[4] as List<Certificate>,
        inventory: results[5] as List<InventoryItem>,
        preferences: results[6] as List<OwnerPreference>,
        incidents: results[7] as List<Incident>,
        voiceCommands: results[8] as List<VoiceCommand>,
        pendingMessages: results[9] as List<PendingVoiceMessage>,
        scannedDocuments: results[10] as List<ScannedDocument>,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Snapshot completo descargado desde Supabase.
class CloudSnapshot {
  final YachtConfig yacht;
  final List<AppUser> users;
  final List<Task> tasks;
  final List<CrewMember> crew;
  final List<Certificate> certificates;
  final List<InventoryItem> inventory;
  final List<OwnerPreference> preferences;
  final List<Incident> incidents;
  final List<VoiceCommand> voiceCommands;
  final List<PendingVoiceMessage> pendingMessages;
  final List<ScannedDocument> scannedDocuments;

  CloudSnapshot({
    required this.yacht,
    required this.users,
    required this.tasks,
    required this.crew,
    required this.certificates,
    required this.inventory,
    required this.preferences,
    required this.incidents,
    required this.voiceCommands,
    required this.pendingMessages,
    required this.scannedDocuments,
  });
}
