// ==================== ENUMS ====================

enum UserRole { gestor, tripulante }

enum AccountStatus { active, expired, blocked }

enum TaskStatus { pendiente, enProgreso, completada, rechazada }

enum TaskPriority { alta, media, baja }

enum IncidentStatus { abierta, asignada, enProgreso, resuelta }

enum InventoryStatus { ok, bajo, sinStock }

enum OwnerPreferenceType { comida, bebida, temperatura, musica, eventos, otro }

enum AlertLevel { none, days90, days60, days30, days15, expired }

// ==================== USER ====================

class AppUser {
  final String id;
  final String name;
  final UserRole role;
  final String pin;
  final bool isAdmin;
  final String? yachtId;
  final String? yachtName;
  final DateTime? accountExpiresAt;
  final AccountStatus accountStatus;
  final bool mustChangePIN;
  final String? email;

  AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.pin = '',
    this.isAdmin = false,
    this.yachtId,
    this.yachtName,
    this.accountExpiresAt,
    this.accountStatus = AccountStatus.active,
    this.mustChangePIN = false,
    this.email,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'pin': pin,
        'isAdmin': isAdmin,
        'yachtId': yachtId,
        'yachtName': yachtName,
        'accountExpiresAt': accountExpiresAt?.toIso8601String(),
        'accountStatus': accountStatus.name,
        'mustChangePIN': mustChangePIN,
        'email': email,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.tripulante,
        ),
        pin: json['pin'] ?? '',
        isAdmin: json['isAdmin'] ?? false,
        yachtId: json['yachtId'],
        yachtName: json['yachtName'],
        accountExpiresAt: json['accountExpiresAt'] != null
            ? DateTime.tryParse(json['accountExpiresAt'])
            : null,
        accountStatus: AccountStatus.values.firstWhere(
          (e) => e.name == (json['accountStatus'] ?? 'active'),
          orElse: () => AccountStatus.active,
        ),
        mustChangePIN: json['mustChangePIN'] ?? false,
        email: json['email'],
      );
}

// ==================== YACHT CONFIG ====================

class YachtConfig {
  final String id;
  final String name;
  final String adminId;
  final DateTime createdAt;
  YachtConfig({required this.id, required this.name, required this.adminId, required this.createdAt});
  factory YachtConfig.fromJson(Map<String, dynamic> j) => YachtConfig(id: j['id'], name: j['name'], adminId: j['adminId'], createdAt: DateTime.parse(j['createdAt']));
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'adminId': adminId, 'createdAt': createdAt.toIso8601String()};
}

// ==================== CHECKLIST ITEM ====================

class ChecklistItem {
  final String id;
  String text;
  bool done;
  ChecklistItem({required this.id, required this.text, this.done = false});
  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'done': done};
  factory ChecklistItem.fromJson(Map<String, dynamic> j) =>
      ChecklistItem(id: j['id'], text: j['text'], done: j['done'] ?? false);
}

// ==================== TASK ====================

class Task {
  final String id;
  String title;
  String description;
  String? assignedToId;
  String? assignedToName;
  TaskStatus status;
  TaskPriority priority;
  DateTime createdAt;
  DateTime? dueDate;
  DateTime? completedAt;
  String? rejectionReason;

  String? completionComment;
  String? actionBy;
  DateTime? actionAt;
  List<ChecklistItem> checklist;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.assignedToId,
    this.assignedToName,
    this.status = TaskStatus.pendiente,
    this.priority = TaskPriority.media,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.rejectionReason,
    this.completionComment,
    this.actionBy,
    this.actionAt,
    List<ChecklistItem>? checklist,
  }) : checklist = checklist ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'assignedToId': assignedToId,
        'assignedToName': assignedToName,
        'status': status.name,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'completionComment': completionComment,
        'actionBy': actionBy,
        'actionAt': actionAt?.toIso8601String(),
        'checklist': checklist.map((c) => c.toJson()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        assignedToId: json['assignedToId'],
        assignedToName: json['assignedToName'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TaskStatus.pendiente,
        ),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.media,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        rejectionReason: json['rejectionReason'],
        completionComment: json['completionComment'],
        actionBy: json['actionBy'],
        actionAt: json['actionAt'] != null ? DateTime.tryParse(json['actionAt']) : null,
        checklist: (json['checklist'] as List? ?? [])
            .map((j) => ChecklistItem.fromJson(j as Map<String, dynamic>))
            .toList(),
      );
}

// ==================== CREW MEMBER ====================

class CrewMember {
  final String id;
  String name;
  String role;
  String? notes;
  String? department;
  String? photoPath;

  CrewMember({
    required this.id,
    required this.name,
    required this.role,
    this.notes,
    this.department,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'notes': notes,
        'department': department,
        'photoPath': photoPath,
      };

  factory CrewMember.fromJson(Map<String, dynamic> json) => CrewMember(
        id: json['id'],
        name: json['name'],
        role: json['role'],
        notes: json['notes'],
        department: json['department'],
        photoPath: json['photoPath'],
      );
}

// ==================== CERTIFICATE ====================

class Certificate {
  final String id;
  String name;
  String issuer;
  String type;
  DateTime expiryDate;
  String? notes;
  String certCategory; // 'barco' or 'tripulante'
  String? crewMemberId;
  String? crewMemberName;

  Certificate({
    required this.id,
    required this.name,
    required this.issuer,
    required this.type,
    required this.expiryDate,
    this.notes,
    this.certCategory = 'barco',
    this.crewMemberId,
    this.crewMemberName,
  });

  int get daysUntilExpiry =>
      expiryDate.difference(DateTime.now()).inDays;

  AlertLevel get alertLevel {
    final diff = daysUntilExpiry;
    if (diff < 0) return AlertLevel.expired;
    if (diff <= 15) return AlertLevel.days15;
    if (diff <= 30) return AlertLevel.days30;
    if (diff <= 60) return AlertLevel.days60;
    if (diff <= 90) return AlertLevel.days90;
    return AlertLevel.none;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'issuer': issuer,
        'type': type,
        'expiryDate': expiryDate.toIso8601String(),
        'notes': notes,
        'certCategory': certCategory,
        'crewMemberId': crewMemberId,
        'crewMemberName': crewMemberName,
      };

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
        id: json['id'],
        name: json['name'],
        issuer: json['issuer'],
        type: json['type'],
        expiryDate: DateTime.parse(json['expiryDate']),
        notes: json['notes'],
        certCategory: json['certCategory'] ?? 'barco',
        crewMemberId: json['crewMemberId'],
        crewMemberName: json['crewMemberName'],
      );
}

// ==================== INVENTORY ITEM ====================

class InventoryItem {
  final String id;
  String name;
  String category;
  double quantity;
  String unit;
  double minLevel;
  String? location;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minLevel,
    this.location,
  });

  InventoryStatus get status {
    if (quantity <= 0) return InventoryStatus.sinStock;
    if (quantity < minLevel) return InventoryStatus.bajo;
    return InventoryStatus.ok;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'minLevel': minLevel,
        'location': location,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
        minLevel: (json['minLevel'] as num).toDouble(),
        location: json['location'],
      );
}

// ==================== OWNER PREFERENCE ====================

class OwnerPreference {
  final String id;
  OwnerPreferenceType type;
  String detail;
  bool isPositive;
  String? notes;
  DateTime createdAt;
  bool viaHeyYat;

  OwnerPreference({
    required this.id,
    required this.type,
    required this.detail,
    required this.isPositive,
    this.notes,
    required this.createdAt,
    this.viaHeyYat = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'detail': detail,
        'isPositive': isPositive,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'viaHeyYat': viaHeyYat,
      };

  factory OwnerPreference.fromJson(Map<String, dynamic> json) =>
      OwnerPreference(
        id: json['id'],
        type: OwnerPreferenceType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => OwnerPreferenceType.otro,
        ),
        detail: json['detail'],
        isPositive: json['isPositive'] ?? true,
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
        viaHeyYat: json['viaHeyYat'] ?? false,
      );
}

// ==================== INCIDENT ====================

class Incident {
  final String id;
  String title;
  String description;
  String? location;
  TaskPriority priority;
  IncidentStatus status;
  String reportedBy;
  DateTime reportedAt;
  String? resolution;
  String? assignedToId;
  String? assignedToName;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.priority,
    this.status = IncidentStatus.abierta,
    required this.reportedBy,
    required this.reportedAt,
    this.resolution,
    this.assignedToId,
    this.assignedToName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'priority': priority.name,
        'status': status.name,
        'reportedBy': reportedBy,
        'reportedAt': reportedAt.toIso8601String(),
        'resolution': resolution,
        'assignedToId': assignedToId,
        'assignedToName': assignedToName,
      };

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        location: json['location'],
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.media,
        ),
        status: IncidentStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => IncidentStatus.abierta,
        ),
        reportedBy: json['reportedBy'],
        reportedAt: DateTime.parse(json['reportedAt']),
        resolution: json['resolution'],
        assignedToId: json['assignedToId'],
        assignedToName: json['assignedToName'],
      );
}

// ==================== VOICE COMMAND ====================

class VoiceCommand {
  final String id;
  String transcript;
  String category;
  String priority;
  Map<String, dynamic> extractedData;
  String userResponse;
  bool confirmed;
  DateTime timestamp;

  VoiceCommand({
    required this.id,
    required this.transcript,
    required this.category,
    required this.priority,
    required this.extractedData,
    required this.userResponse,
    this.confirmed = false,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'transcript': transcript,
        'category': category,
        'priority': priority,
        'extractedData': extractedData,
        'userResponse': userResponse,
        'confirmed': confirmed,
        'timestamp': timestamp.toIso8601String(),
      };

  factory VoiceCommand.fromJson(Map<String, dynamic> json) => VoiceCommand(
        id: json['id'],
        transcript: json['transcript'],
        category: json['category'],
        priority: json['priority'],
        extractedData: Map<String, dynamic>.from(json['extractedData'] ?? {}),
        userResponse: json['userResponse'] ?? '',
        confirmed: json['confirmed'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
      );
}

// ==================== AI RESULT ====================

class AiClassificationResult {
  final String categoria;
  final String prioridad;
  final Map<String, dynamic> datosExtraidos;
  final String respuestaUsuario;

  AiClassificationResult({
    required this.categoria,
    required this.prioridad,
    required this.datosExtraidos,
    required this.respuestaUsuario,
  });

  factory AiClassificationResult.fromJson(Map<String, dynamic> json) =>
      AiClassificationResult(
        categoria: json['categoria'] ?? 'TAREA',
        prioridad: json['prioridad'] ?? 'media',
        datosExtraidos:
            Map<String, dynamic>.from(json['datos_extraidos'] ?? {}),
        respuestaUsuario: json['respuesta_usuario'] ?? '',
      );
}

// ==================== PENDING VOICE MESSAGE ====================

class PendingVoiceMessage {
  final String id;
  final String transcript;
  final DateTime recordedAt;
  bool processed;
  String? processingError;
  PendingVoiceMessage({required this.id, required this.transcript, required this.recordedAt, this.processed = false, this.processingError});
  factory PendingVoiceMessage.fromJson(Map<String, dynamic> j) => PendingVoiceMessage(id: j['id'], transcript: j['transcript'], recordedAt: DateTime.parse(j['recordedAt']), processed: j['processed'] ?? false, processingError: j['processingError']);
  Map<String, dynamic> toJson() => {'id': id, 'transcript': transcript, 'recordedAt': recordedAt.toIso8601String(), 'processed': processed, 'processingError': processingError};
}

// ==================== SCANNED DOCUMENT ====================

class ScannedDocument {
  final String id;
  String type;
  String description;
  String? holderName;
  DateTime? issuedAt;
  DateTime? expiresAt;
  String status;
  final List<String> imagePaths;
  final DateTime scannedAt;
  final String scannedBy;
  String? notes;
  ScannedDocument({required this.id, required this.type, required this.description, this.holderName, this.issuedAt, this.expiresAt, required this.status, required this.imagePaths, required this.scannedAt, required this.scannedBy, this.notes});
  factory ScannedDocument.fromJson(Map<String, dynamic> j) => ScannedDocument(id: j['id'], type: j['type'], description: j['description'], holderName: j['holderName'], issuedAt: j['issuedAt'] != null ? DateTime.parse(j['issuedAt']) : null, expiresAt: j['expiresAt'] != null ? DateTime.parse(j['expiresAt']) : null, status: j['status'], imagePaths: List<String>.from(j['imagePaths'] ?? []), scannedAt: DateTime.parse(j['scannedAt']), scannedBy: j['scannedBy'], notes: j['notes']);
  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'description': description, 'holderName': holderName, 'issuedAt': issuedAt?.toIso8601String(), 'expiresAt': expiresAt?.toIso8601String(), 'status': status, 'imagePaths': imagePaths, 'scannedAt': scannedAt.toIso8601String(), 'scannedBy': scannedBy, 'notes': notes};
}
