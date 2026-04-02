// ==================== ENUMS ====================

enum UserRole { gestor, tripulante }

enum TaskStatus { pendiente, enProgreso, completada, rechazada }

enum TaskPriority { alta, media, baja }

enum IncidentStatus { abierta, enProgreso, resuelta }

enum InventoryStatus { ok, bajo, sinStock }

enum OwnerPreferenceType { comida, bebida, temperatura, musica, eventos, otro }

enum AlertLevel { none, days90, days60, days30, days15, expired }

// ==================== USER ====================

class AppUser {
  final String id;
  final String name;
  final UserRole role;

  AppUser({required this.id, required this.name, required this.role});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.tripulante,
        ),
      );
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
  });

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
      );
}

// ==================== CREW MEMBER ====================

class CrewMember {
  final String id;
  String name;
  String role;
  String? notes;

  CrewMember({
    required this.id,
    required this.name,
    required this.role,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'notes': notes,
      };

  factory CrewMember.fromJson(Map<String, dynamic> json) => CrewMember(
        id: json['id'],
        name: json['name'],
        role: json['role'],
        notes: json['notes'],
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

  Certificate({
    required this.id,
    required this.name,
    required this.issuer,
    required this.type,
    required this.expiryDate,
    this.notes,
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
      };

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
        id: json['id'],
        name: json['name'],
        issuer: json['issuer'],
        type: json['type'],
        expiryDate: DateTime.parse(json['expiryDate']),
        notes: json['notes'],
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

  OwnerPreference({
    required this.id,
    required this.type,
    required this.detail,
    required this.isPositive,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'detail': detail,
        'isPositive': isPositive,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
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
