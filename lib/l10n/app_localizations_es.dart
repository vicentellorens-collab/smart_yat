// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SmartYat';

  @override
  String get appSlogan => 'Enhance your crew.';

  @override
  String get login => 'Entrar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get changeUser => 'Cambiar de usuario';

  @override
  String get register => 'Registrar';

  @override
  String get alreadyHaveAccount => 'Ya tengo cuenta';

  @override
  String get setupYacht => 'Configurar yate';

  @override
  String get enterPin => 'Introduce tu PIN';

  @override
  String get confirmPin => 'Confirma el PIN';

  @override
  String get newPin => 'Nuevo PIN';

  @override
  String get pinRequired => 'El PIN es obligatorio';

  @override
  String get pinMustBe4Digits => 'El PIN debe tener exactamente 4 dígitos';

  @override
  String get pinsDontMatch => 'Los PINs no coinciden';

  @override
  String get wrongPin => 'PIN incorrecto';

  @override
  String get biometrics => 'Biometría';

  @override
  String get loginWithBiometrics => 'Entrar con biometría';

  @override
  String get changePinRequired => 'Debes cambiar tu PIN antes de continuar';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get activeTasks => 'Tareas activas';

  @override
  String get openIncidents => 'Incidencias abiertas';

  @override
  String get certificateAlerts => 'Certificados con alerta';

  @override
  String get lowStock => 'Stock bajo / agotado';

  @override
  String get upcomingEvents => 'Próximos eventos';

  @override
  String get tasks => 'Tareas';

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get taskTitle => 'Título de la tarea';

  @override
  String get taskDescription => 'Descripción';

  @override
  String get priority => 'Prioridad';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Media';

  @override
  String get priorityLow => 'Baja';

  @override
  String get assignTo => 'Asignar a...';

  @override
  String get instructions => 'Instrucciones';

  @override
  String get markAsCompleted => 'Marcar como completada';

  @override
  String get reject => 'Rechazar';

  @override
  String get rejectReason => 'Motivo del rechazo (obligatorio)';

  @override
  String get reassign => 'Reasignar';

  @override
  String get taskHistory => 'Historial';

  @override
  String get myTasks => 'Mis Tareas';

  @override
  String get taskCompleted => 'Tarea completada';

  @override
  String get taskRejected => 'Tarea rechazada';

  @override
  String get taskPending => 'Pendiente';

  @override
  String get taskAssigned => 'Asignada';

  @override
  String get checklist => 'Checklist';

  @override
  String get newChecklist => 'Nuevo checklist';

  @override
  String get checklistType => 'Tipo';

  @override
  String get checklistEvent => 'Evento';

  @override
  String get checklistDaily => 'Diario';

  @override
  String get checklistWeekly => 'Semanal';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterPending => 'Pendientes';

  @override
  String get filterInProgress => 'En Progreso';

  @override
  String get filterCompleted => 'Completadas (48h)';

  @override
  String get filterRejected => 'Rechazadas';

  @override
  String get crew => 'Tripulación';

  @override
  String get addCrewMember => 'Añadir tripulante';

  @override
  String get firstName => 'Nombre completo';

  @override
  String get role => 'Cargo';

  @override
  String get department => 'Departamento';

  @override
  String get departmentDeck => 'Deck';

  @override
  String get departmentInterior => 'Interior';

  @override
  String get departmentCook => 'Cook';

  @override
  String get departmentEngine => 'Engine';

  @override
  String get expirationDate => 'Fecha de expiración';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get editCrewMember => 'Editar tripulante';

  @override
  String get deleteCrewMember => 'Eliminar tripulante';

  @override
  String deleteConfirmation(String name) {
    return '¿Eliminar a $name? Esta acción no se puede deshacer.';
  }

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get resetPin => 'Resetear PIN';

  @override
  String get certificates => 'Certificados';

  @override
  String get yachtCertificates => 'Barco';

  @override
  String get crewCertificates => 'Tripulantes';

  @override
  String get addCertificate => 'Añadir certificado';

  @override
  String get scanDocument => 'Escanear documento';

  @override
  String get attachFile => 'Adjuntar archivo';

  @override
  String get uploadPhoto => 'Subir foto';

  @override
  String get certificateName => 'Nombre del certificado';

  @override
  String get searchOrTypeCertificate =>
      'Buscar o escribir nombre del certificado...';

  @override
  String get issueDate => 'Fecha de emisión';

  @override
  String get expiryDate => 'Fecha de caducidad';

  @override
  String get expired => 'VENCIDO';

  @override
  String get searchCertificates => 'Buscar certificados...';

  @override
  String daysRemaining(int days) {
    return '$days días restantes';
  }

  @override
  String get inventory => 'Inventario';

  @override
  String get addItem => 'Añadir item';

  @override
  String get itemName => 'Nombre del item';

  @override
  String get quantity => 'Cantidad';

  @override
  String get unit => 'Unidad';

  @override
  String get minimumLevel => 'Nivel mínimo';

  @override
  String get shoppingList => 'Lista de compras';

  @override
  String get markAsBought => 'Marcar como comprado';

  @override
  String get lowStockAlert => 'Stock bajo';

  @override
  String get outOfStock => 'Agotado';

  @override
  String get incidents => 'Incidencias';

  @override
  String get newIncident => 'Nueva incidencia';

  @override
  String get openIncident => 'Abierta';

  @override
  String get assignedIncident => 'Asignada';

  @override
  String get inProgressIncident => 'En progreso';

  @override
  String get resolvedIncident => 'Resuelta';

  @override
  String get heyYat => 'HEY YAT';

  @override
  String get heyYatSubtitle => 'Asistente de voz inteligente';

  @override
  String get heyYatListening => 'ESCUCHANDO...';

  @override
  String get heyYatClassifying => 'CLASIFICANDO...';

  @override
  String get heyYatConfirmed => '¡REGISTRADO!';

  @override
  String heyYatPendingMessages(int count) {
    return '$count mensaje(s) pendiente(s)';
  }

  @override
  String get heyYatProcessingOffline => 'Procesando mensajes offline...';

  @override
  String get heyYatTypeManually => 'Escribir manualmente';

  @override
  String get heyYatHideKeyboard => 'Ocultar teclado';

  @override
  String get heyYatSavedInSystem => 'Guardado en el sistema';

  @override
  String get heyYatSpeakNow => 'Habla ahora...';

  @override
  String get heyYatSendMessage => 'Enviar mensaje';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageRussian => 'Ruso';

  @override
  String get languageChinese => 'Chino';

  @override
  String get settings => 'Ajustes';

  @override
  String get yachtName => 'Nombre del yate';

  @override
  String get adminEmail => 'Email del administrador';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Sin conexión';

  @override
  String get offlineBanner => 'Sin conexión · Modo offline';

  @override
  String syncPending(int count) {
    return '$count pendiente(s) de sincronizar';
  }

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get back => 'Volver';

  @override
  String get search => 'Buscar';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Hecho';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get viewAll => 'Ver todas';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get create => 'Crear';

  @override
  String get add => 'Añadir';

  @override
  String get assign => 'Asignar';

  @override
  String get reassignTask => 'Reasignar tarea';

  @override
  String get complete => 'Completada';

  @override
  String get resolve => 'Resolver';

  @override
  String get inProgress => 'En Progreso';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get activeIncidents => 'INCIDENCIAS ACTIVAS';

  @override
  String get urgentCertificates => 'CERTIFICADOS URGENTES';

  @override
  String get noStock => 'SIN STOCK';

  @override
  String get recentTasks => 'TAREAS RECIENTES';

  @override
  String get noActiveTasks => 'No hay tareas en esta categoría';

  @override
  String get noRejectedTasks => 'Sin tareas rechazadas';

  @override
  String get noCompletedTasks => 'No hay tareas completadas';

  @override
  String get searchHistory => 'Buscar en historial...';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get allTime => 'Todo';

  @override
  String get pinFirstAccess =>
      'Es tu primer acceso. Por seguridad, debes cambiar tu PIN.';

  @override
  String get introduceNewPin => 'INTRODUCE EL NUEVO PIN';

  @override
  String get confirmNewPin => 'CONFIRMA EL NUEVO PIN';

  @override
  String get pinRepeatToConfirm => 'Repite el PIN para confirmarlo';

  @override
  String get pinNotZeros => 'El nuevo PIN no puede ser 0000';

  @override
  String get pinNoMatch => 'Los PINs no coinciden. Inténtalo de nuevo.';
}
