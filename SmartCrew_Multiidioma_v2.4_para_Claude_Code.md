# SmartCrew — Soporte Multiidioma v2.4

Lee este documento completo antes de empezar. Contiene la implementación completa
del soporte multiidioma para SmartCrew. Los cambios afectan a toda la app.
Revisa los archivos afectados antes de tocar código.

---

## CONTEXTO Y ARQUITECTURA DE LA SOLUCIÓN

SmartCrew debe soportar 5 idiomas: **Español (es), Inglés (en), Francés (fr), Ruso (ru) y Chino (zh)**.

Hay dos capas independientes de traducción:

### Capa 1 — Interfaz de usuario (i18n estándar de Flutter)
Toda la UI (botones, etiquetas, mensajes, pantallas) se traduce según el idioma
seleccionado por el usuario activo. Se implementa con `flutter_localizations` + `intl`.

### Capa 2 — Contenido de HEY YAT (traducción por IA)
Esta capa es diferente y más compleja:
- Un tripulante habla a HEY YAT en **su idioma**.
- El contenido se almacena en Supabase con el texto original Y una versión canónica en inglés.
- Cuando el gestor/admin visualiza el contenido (tareas, incidencias, inventario),
  la app lo muestra **traducido al idioma del gestor**, no al idioma del emisor.
- La traducción al idioma del gestor se genera en tiempo real mediante la API de Claude,
  usando el campo en inglés como fuente.

**Flujo completo de HEY YAT multiidioma:**

```
Tripulante (habla en español) → "hay un winche estropeado a babor"
         ↓
Speech-to-text en es-ES (reconocimiento en español)
         ↓
Claude API: clasifica + traduce al inglés
         ↓
Supabase guarda:
  - original_text: "hay un winche estropeado a babor"
  - original_language: "es"
  - canonical_english: "broken winch on port side"
  - category: "INCIDENCIA"
         ↓
Admin (idioma: inglés) ve: "Broken winch on port side"
Admin (idioma: francés) ve: "Winch cassé côté bâbord"  ← traducido en tiempo real
Admin (idioma: ruso) ve: "Сломанная лебёдка с левого борта"
```

---

## PASO 1 — Añadir dependencias en pubspec.yaml

### Archivos afectados
- `pubspec.yaml`

### Cambios

Añadir en la sección `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:    # ya incluido en flutter sdk
    sdk: flutter
  intl: ^0.19.0
```

Añadir en la sección `flutter`:

```yaml
flutter:
  generate: true            # activa la generación automática de l10n
```

---

## PASO 2 — Crear archivo de configuración l10n

### Archivos a crear
- `l10n.yaml` (raíz del proyecto, al mismo nivel que pubspec.yaml)

### Contenido

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

---

## PASO 3 — Crear archivos ARB de traducción

Los archivos ARB contienen todas las cadenas de texto de la app.
Deben estar en `lib/l10n/`.

### PASO 3a — Inglés (plantilla base): `lib/l10n/app_en.arb`

```json
{
  "@@locale": "en",

  "appName": "SmartCrew",
  "appSlogan": "Enhance your crew.",

  "login": "Login",
  "logout": "Logout",
  "changeUser": "Change user",
  "register": "Register",
  "alreadyHaveAccount": "I already have an account",
  "setupYacht": "Set up yacht",
  "enterPin": "Enter PIN",
  "confirmPin": "Confirm PIN",
  "newPin": "New PIN",
  "pinRequired": "PIN is required",
  "pinMustBe4Digits": "PIN must be exactly 4 digits",
  "pinsDontMatch": "PINs do not match",
  "wrongPin": "Incorrect PIN",
  "biometrics": "Biometrics",
  "loginWithBiometrics": "Login with biometrics",
  "changePinRequired": "You must change your PIN before continuing",

  "dashboard": "Dashboard",
  "activeTasks": "Active tasks",
  "openIncidents": "Open incidents",
  "certificateAlerts": "Certificate alerts",
  "lowStock": "Low / out of stock",
  "upcomingEvents": "Upcoming events",

  "tasks": "Tasks",
  "newTask": "New task",
  "taskTitle": "Task title",
  "taskDescription": "Description",
  "priority": "Priority",
  "priorityHigh": "High",
  "priorityMedium": "Medium",
  "priorityLow": "Low",
  "assignTo": "Assign to...",
  "instructions": "Instructions",
  "markAsCompleted": "Mark as completed",
  "reject": "Reject",
  "rejectReason": "Reason for rejection (required)",
  "reassign": "Reassign",
  "taskHistory": "Task history",
  "myTasks": "My tasks",
  "taskCompleted": "Task completed",
  "taskRejected": "Task rejected",
  "taskPending": "Pending",
  "taskAssigned": "Assigned",
  "checklist": "Checklist",
  "newChecklist": "New checklist",
  "checklistType": "Type",
  "checklistEvent": "Event",
  "checklistDaily": "Daily",
  "checklistWeekly": "Weekly",
  "filterPending": "Pending",
  "filterInProgress": "In progress",
  "filterCompleted": "Completed",
  "filterRejected": "Rejected",

  "crew": "Crew",
  "addCrewMember": "Add crew member",
  "firstName": "First name",
  "lastName": "Last name",
  "role": "Role",
  "department": "Department",
  "departmentDeck": "Deck",
  "departmentInterior": "Interior",
  "departmentCook": "Cook",
  "departmentEngine": "Engine",
  "expirationDate": "Expiration date",
  "profilePhoto": "Profile photo",
  "editCrewMember": "Edit crew member",
  "deleteCrewMember": "Delete crew member",
  "deleteConfirmation": "Delete {name}? This action cannot be undone.",
  "@deleteConfirmation": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "saveChanges": "Save changes",
  "resetPin": "Reset PIN",

  "certificates": "Certificates",
  "yachtCertificates": "Yacht",
  "crewCertificates": "Crew",
  "addCertificate": "Add certificate",
  "scanDocument": "Scan document",
  "attachFile": "Attach file",
  "uploadPhoto": "Upload photo",
  "certificateName": "Certificate name",
  "searchOrTypeCertificate": "Search or type certificate name...",
  "issueDate": "Issue date",
  "expiryDate": "Expiry date",
  "expired": "EXPIRED",
  "searchCertificates": "Search certificates...",
  "daysRemaining": "{days} days remaining",
  "@daysRemaining": {
    "placeholders": {
      "days": { "type": "int" }
    }
  },

  "inventory": "Inventory",
  "addItem": "Add item",
  "itemName": "Item name",
  "quantity": "Quantity",
  "unit": "Unit",
  "minimumLevel": "Minimum level",
  "shoppingList": "Shopping list",
  "markAsBought": "Mark as bought",
  "lowStockAlert": "Low stock",
  "outOfStock": "Out of stock",

  "incidents": "Incidents",
  "newIncident": "New incident",
  "openIncident": "Open",
  "assignedIncident": "Assigned",
  "inProgressIncident": "In progress",
  "resolvedIncident": "Resolved",

  "heyYat": "HEY YAT",
  "heyYatListening": "Listening...",
  "heyYatConfirmed": "Registered correctly",
  "heyYatPendingMessages": "{count} pending messages",
  "@heyYatPendingMessages": {
    "placeholders": {
      "count": { "type": "int" }
    }
  },

  "language": "Language",
  "selectLanguage": "Select language",
  "languageSpanish": "Spanish",
  "languageEnglish": "English",
  "languageFrench": "French",
  "languageRussian": "Russian",
  "languageChinese": "Chinese",

  "settings": "Settings",
  "yachtName": "Yacht name",
  "adminEmail": "Administrator email",
  "connected": "Connected",
  "disconnected": "No connection",
  "syncPending": "{count} pending to sync",
  "@syncPending": {
    "placeholders": {
      "count": { "type": "int" }
    }
  },

  "save": "Save",
  "cancel": "Cancel",
  "confirm": "Confirm",
  "delete": "Delete",
  "edit": "Edit",
  "back": "Back",
  "search": "Search",
  "noResults": "No results",
  "loading": "Loading...",
  "error": "Error",
  "success": "Success",
  "yes": "Yes",
  "no": "No"
}
```

### PASO 3b — Español: `lib/l10n/app_es.arb`

```json
{
  "@@locale": "es",

  "appName": "SmartCrew",
  "appSlogan": "Enhance your crew.",

  "login": "Entrar",
  "logout": "Cerrar sesión",
  "changeUser": "Cambiar de usuario",
  "register": "Registrar",
  "alreadyHaveAccount": "Ya tengo cuenta",
  "setupYacht": "Configurar yate",
  "enterPin": "Introduce tu PIN",
  "confirmPin": "Confirma el PIN",
  "newPin": "Nuevo PIN",
  "pinRequired": "El PIN es obligatorio",
  "pinMustBe4Digits": "El PIN debe tener exactamente 4 dígitos",
  "pinsDontMatch": "Los PINs no coinciden",
  "wrongPin": "PIN incorrecto",
  "biometrics": "Biometría",
  "loginWithBiometrics": "Entrar con biometría",
  "changePinRequired": "Debes cambiar tu PIN antes de continuar",

  "dashboard": "Dashboard",
  "activeTasks": "Tareas activas",
  "openIncidents": "Incidencias abiertas",
  "certificateAlerts": "Certificados con alerta",
  "lowStock": "Stock bajo / agotado",
  "upcomingEvents": "Próximos eventos",

  "tasks": "Tareas",
  "newTask": "Nueva tarea",
  "taskTitle": "Título de la tarea",
  "taskDescription": "Descripción",
  "priority": "Prioridad",
  "priorityHigh": "Alta",
  "priorityMedium": "Media",
  "priorityLow": "Baja",
  "assignTo": "Asignar a...",
  "instructions": "Instrucciones",
  "markAsCompleted": "Marcar como completada",
  "reject": "Rechazar",
  "rejectReason": "Motivo del rechazo (obligatorio)",
  "reassign": "Reasignar",
  "taskHistory": "Historial de tareas",
  "myTasks": "Mis tareas",
  "taskCompleted": "Tarea completada",
  "taskRejected": "Tarea rechazada",
  "taskPending": "Pendiente",
  "taskAssigned": "Asignada",
  "checklist": "Checklist",
  "newChecklist": "Nuevo checklist",
  "checklistType": "Tipo",
  "checklistEvent": "Evento",
  "checklistDaily": "Diario",
  "checklistWeekly": "Semanal",
  "filterPending": "Pendientes",
  "filterInProgress": "En curso",
  "filterCompleted": "Completadas",
  "filterRejected": "Rechazadas",

  "crew": "Tripulación",
  "addCrewMember": "Añadir tripulante",
  "firstName": "Nombre",
  "lastName": "Apellidos",
  "role": "Cargo",
  "department": "Departamento",
  "departmentDeck": "Deck",
  "departmentInterior": "Interior",
  "departmentCook": "Cook",
  "departmentEngine": "Engine",
  "expirationDate": "Fecha de expiración",
  "profilePhoto": "Foto de perfil",
  "editCrewMember": "Editar tripulante",
  "deleteCrewMember": "Eliminar tripulante",
  "deleteConfirmation": "¿Eliminar a {name}? Esta acción no se puede deshacer.",
  "@deleteConfirmation": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "saveChanges": "Guardar cambios",
  "resetPin": "Resetear PIN",

  "certificates": "Certificados",
  "yachtCertificates": "Barco",
  "crewCertificates": "Tripulantes",
  "addCertificate": "Añadir certificado",
  "scanDocument": "Escanear documento",
  "attachFile": "Adjuntar archivo",
  "uploadPhoto": "Subir foto",
  "certificateName": "Nombre del certificado",
  "searchOrTypeCertificate": "Buscar o escribir nombre del certificado...",
  "issueDate": "Fecha de emisión",
  "expiryDate": "Fecha de caducidad",
  "expired": "VENCIDO",
  "searchCertificates": "Buscar certificados...",
  "daysRemaining": "{days} días restantes",
  "@daysRemaining": {
    "placeholders": {
      "days": { "type": "int" }
    }
  },

  "inventory": "Inventario",
  "addItem": "Añadir item",
  "itemName": "Nombre del item",
  "quantity": "Cantidad",
  "unit": "Unidad",
  "minimumLevel": "Nivel mínimo",
  "shoppingList": "Lista de compras",
  "markAsBought": "Marcar como comprado",
  "lowStockAlert": "Stock bajo",
  "outOfStock": "Agotado",

  "incidents": "Incidencias",
  "newIncident": "Nueva incidencia",
  "openIncident": "Abierta",
  "assignedIncident": "Asignada",
  "inProgressIncident": "En progreso",
  "resolvedIncident": "Resuelta",

  "heyYat": "HEY YAT",
  "heyYatListening": "Escuchando...",
  "heyYatConfirmed": "Registrado correctamente",
  "heyYatPendingMessages": "{count} mensajes pendientes",
  "@heyYatPendingMessages": {
    "placeholders": {
      "count": { "type": "int" }
    }
  },

  "language": "Idioma",
  "selectLanguage": "Seleccionar idioma",
  "languageSpanish": "Español",
  "languageEnglish": "Inglés",
  "languageFrench": "Francés",
  "languageRussian": "Ruso",
  "languageChinese": "Chino",

  "settings": "Ajustes",
  "yachtName": "Nombre del yate",
  "adminEmail": "Email del administrador",
  "connected": "Conectado",
  "disconnected": "Sin conexión",
  "syncPending": "{count} pendiente(s) de sincronizar",
  "@syncPending": {
    "placeholders": {
      "count": { "type": "int" }
    }
  },

  "save": "Guardar",
  "cancel": "Cancelar",
  "confirm": "Confirmar",
  "delete": "Eliminar",
  "edit": "Editar",
  "back": "Volver",
  "search": "Buscar",
  "noResults": "Sin resultados",
  "loading": "Cargando...",
  "error": "Error",
  "success": "Hecho",
  "yes": "Sí",
  "no": "No"
}
```

### PASO 3c — Francés: `lib/l10n/app_fr.arb`

```json
{
  "@@locale": "fr",
  "appName": "SmartCrew",
  "appSlogan": "Enhance your crew.",
  "login": "Connexion",
  "logout": "Se déconnecter",
  "changeUser": "Changer d'utilisateur",
  "register": "S'inscrire",
  "alreadyHaveAccount": "J'ai déjà un compte",
  "setupYacht": "Configurer le yacht",
  "enterPin": "Entrez votre code PIN",
  "confirmPin": "Confirmez le code PIN",
  "newPin": "Nouveau code PIN",
  "pinRequired": "Le code PIN est obligatoire",
  "pinMustBe4Digits": "Le code PIN doit avoir exactement 4 chiffres",
  "pinsDontMatch": "Les codes PIN ne correspondent pas",
  "wrongPin": "Code PIN incorrect",
  "biometrics": "Biométrie",
  "loginWithBiometrics": "Se connecter avec la biométrie",
  "changePinRequired": "Vous devez changer votre code PIN avant de continuer",
  "dashboard": "Tableau de bord",
  "activeTasks": "Tâches actives",
  "openIncidents": "Incidents ouverts",
  "certificateAlerts": "Alertes certificats",
  "lowStock": "Stock bas / épuisé",
  "upcomingEvents": "Événements à venir",
  "tasks": "Tâches",
  "newTask": "Nouvelle tâche",
  "taskTitle": "Titre de la tâche",
  "taskDescription": "Description",
  "priority": "Priorité",
  "priorityHigh": "Haute",
  "priorityMedium": "Moyenne",
  "priorityLow": "Basse",
  "assignTo": "Assigner à...",
  "instructions": "Instructions",
  "markAsCompleted": "Marquer comme terminée",
  "reject": "Rejeter",
  "rejectReason": "Motif du rejet (obligatoire)",
  "reassign": "Réassigner",
  "taskHistory": "Historique des tâches",
  "myTasks": "Mes tâches",
  "taskCompleted": "Tâche terminée",
  "taskRejected": "Tâche rejetée",
  "taskPending": "En attente",
  "taskAssigned": "Assignée",
  "checklist": "Liste de contrôle",
  "newChecklist": "Nouvelle liste de contrôle",
  "checklistType": "Type",
  "checklistEvent": "Événement",
  "checklistDaily": "Quotidien",
  "checklistWeekly": "Hebdomadaire",
  "filterPending": "En attente",
  "filterInProgress": "En cours",
  "filterCompleted": "Terminées",
  "filterRejected": "Rejetées",
  "crew": "Équipage",
  "addCrewMember": "Ajouter un membre d'équipage",
  "firstName": "Prénom",
  "lastName": "Nom",
  "role": "Poste",
  "department": "Département",
  "departmentDeck": "Pont",
  "departmentInterior": "Intérieur",
  "departmentCook": "Cuisine",
  "departmentEngine": "Moteur",
  "expirationDate": "Date d'expiration",
  "profilePhoto": "Photo de profil",
  "editCrewMember": "Modifier le membre",
  "deleteCrewMember": "Supprimer le membre",
  "deleteConfirmation": "Supprimer {name} ? Cette action est irréversible.",
  "@deleteConfirmation": { "placeholders": { "name": { "type": "String" } } },
  "saveChanges": "Enregistrer les modifications",
  "resetPin": "Réinitialiser le PIN",
  "certificates": "Certificats",
  "yachtCertificates": "Yacht",
  "crewCertificates": "Équipage",
  "addCertificate": "Ajouter un certificat",
  "scanDocument": "Scanner le document",
  "attachFile": "Joindre un fichier",
  "uploadPhoto": "Télécharger une photo",
  "certificateName": "Nom du certificat",
  "searchOrTypeCertificate": "Rechercher ou saisir le nom du certificat...",
  "issueDate": "Date d'émission",
  "expiryDate": "Date d'expiration",
  "expired": "EXPIRÉ",
  "searchCertificates": "Rechercher des certificats...",
  "daysRemaining": "{days} jours restants",
  "@daysRemaining": { "placeholders": { "days": { "type": "int" } } },
  "inventory": "Inventaire",
  "addItem": "Ajouter un article",
  "itemName": "Nom de l'article",
  "quantity": "Quantité",
  "unit": "Unité",
  "minimumLevel": "Niveau minimum",
  "shoppingList": "Liste de courses",
  "markAsBought": "Marquer comme acheté",
  "lowStockAlert": "Stock bas",
  "outOfStock": "Épuisé",
  "incidents": "Incidents",
  "newIncident": "Nouvel incident",
  "openIncident": "Ouvert",
  "assignedIncident": "Assigné",
  "inProgressIncident": "En cours",
  "resolvedIncident": "Résolu",
  "heyYat": "HEY YAT",
  "heyYatListening": "Écoute en cours...",
  "heyYatConfirmed": "Enregistré correctement",
  "heyYatPendingMessages": "{count} messages en attente",
  "@heyYatPendingMessages": { "placeholders": { "count": { "type": "int" } } },
  "language": "Langue",
  "selectLanguage": "Sélectionner la langue",
  "languageSpanish": "Espagnol",
  "languageEnglish": "Anglais",
  "languageFrench": "Français",
  "languageRussian": "Russe",
  "languageChinese": "Chinois",
  "settings": "Paramètres",
  "yachtName": "Nom du yacht",
  "adminEmail": "Email de l'administrateur",
  "connected": "Connecté",
  "disconnected": "Hors ligne",
  "syncPending": "{count} en attente de synchronisation",
  "@syncPending": { "placeholders": { "count": { "type": "int" } } },
  "save": "Enregistrer",
  "cancel": "Annuler",
  "confirm": "Confirmer",
  "delete": "Supprimer",
  "edit": "Modifier",
  "back": "Retour",
  "search": "Rechercher",
  "noResults": "Aucun résultat",
  "loading": "Chargement...",
  "error": "Erreur",
  "success": "Succès",
  "yes": "Oui",
  "no": "Non"
}
```

### PASO 3d — Ruso: `lib/l10n/app_ru.arb`

```json
{
  "@@locale": "ru",
  "appName": "SmartCrew",
  "appSlogan": "Enhance your crew.",
  "login": "Войти",
  "logout": "Выйти",
  "changeUser": "Сменить пользователя",
  "register": "Зарегистрироваться",
  "alreadyHaveAccount": "У меня уже есть аккаунт",
  "setupYacht": "Настроить яхту",
  "enterPin": "Введите PIN",
  "confirmPin": "Подтвердите PIN",
  "newPin": "Новый PIN",
  "pinRequired": "PIN обязателен",
  "pinMustBe4Digits": "PIN должен содержать ровно 4 цифры",
  "pinsDontMatch": "PIN-коды не совпадают",
  "wrongPin": "Неверный PIN",
  "biometrics": "Биометрия",
  "loginWithBiometrics": "Войти с помощью биометрии",
  "changePinRequired": "Вы должны сменить PIN перед продолжением",
  "dashboard": "Панель управления",
  "activeTasks": "Активные задачи",
  "openIncidents": "Открытые инциденты",
  "certificateAlerts": "Оповещения по сертификатам",
  "lowStock": "Низкий запас / отсутствует",
  "upcomingEvents": "Предстоящие события",
  "tasks": "Задачи",
  "newTask": "Новая задача",
  "taskTitle": "Название задачи",
  "taskDescription": "Описание",
  "priority": "Приоритет",
  "priorityHigh": "Высокий",
  "priorityMedium": "Средний",
  "priorityLow": "Низкий",
  "assignTo": "Назначить...",
  "instructions": "Инструкции",
  "markAsCompleted": "Отметить как выполненное",
  "reject": "Отклонить",
  "rejectReason": "Причина отказа (обязательно)",
  "reassign": "Переназначить",
  "taskHistory": "История задач",
  "myTasks": "Мои задачи",
  "taskCompleted": "Задача выполнена",
  "taskRejected": "Задача отклонена",
  "taskPending": "Ожидает",
  "taskAssigned": "Назначено",
  "checklist": "Контрольный список",
  "newChecklist": "Новый список",
  "checklistType": "Тип",
  "checklistEvent": "Событие",
  "checklistDaily": "Ежедневный",
  "checklistWeekly": "Еженедельный",
  "filterPending": "Ожидающие",
  "filterInProgress": "В процессе",
  "filterCompleted": "Завершённые",
  "filterRejected": "Отклонённые",
  "crew": "Экипаж",
  "addCrewMember": "Добавить члена экипажа",
  "firstName": "Имя",
  "lastName": "Фамилия",
  "role": "Должность",
  "department": "Отдел",
  "departmentDeck": "Палуба",
  "departmentInterior": "Интерьер",
  "departmentCook": "Кухня",
  "departmentEngine": "Машинное отделение",
  "expirationDate": "Дата истечения",
  "profilePhoto": "Фото профиля",
  "editCrewMember": "Редактировать члена",
  "deleteCrewMember": "Удалить члена",
  "deleteConfirmation": "Удалить {name}? Это действие необратимо.",
  "@deleteConfirmation": { "placeholders": { "name": { "type": "String" } } },
  "saveChanges": "Сохранить изменения",
  "resetPin": "Сбросить PIN",
  "certificates": "Сертификаты",
  "yachtCertificates": "Яхта",
  "crewCertificates": "Экипаж",
  "addCertificate": "Добавить сертификат",
  "scanDocument": "Сканировать документ",
  "attachFile": "Прикрепить файл",
  "uploadPhoto": "Загрузить фото",
  "certificateName": "Название сертификата",
  "searchOrTypeCertificate": "Поиск или ввод названия сертификата...",
  "issueDate": "Дата выдачи",
  "expiryDate": "Дата истечения",
  "expired": "ПРОСРОЧЕН",
  "searchCertificates": "Поиск сертификатов...",
  "daysRemaining": "Осталось {days} дней",
  "@daysRemaining": { "placeholders": { "days": { "type": "int" } } },
  "inventory": "Инвентарь",
  "addItem": "Добавить товар",
  "itemName": "Название товара",
  "quantity": "Количество",
  "unit": "Единица",
  "minimumLevel": "Минимальный уровень",
  "shoppingList": "Список покупок",
  "markAsBought": "Отметить как купленное",
  "lowStockAlert": "Мало запасов",
  "outOfStock": "Нет в наличии",
  "incidents": "Инциденты",
  "newIncident": "Новый инцидент",
  "openIncident": "Открыт",
  "assignedIncident": "Назначен",
  "inProgressIncident": "В процессе",
  "resolvedIncident": "Решён",
  "heyYat": "HEY YAT",
  "heyYatListening": "Слушаю...",
  "heyYatConfirmed": "Зарегистрировано успешно",
  "heyYatPendingMessages": "{count} сообщений в очереди",
  "@heyYatPendingMessages": { "placeholders": { "count": { "type": "int" } } },
  "language": "Язык",
  "selectLanguage": "Выбрать язык",
  "languageSpanish": "Испанский",
  "languageEnglish": "Английский",
  "languageFrench": "Французский",
  "languageRussian": "Русский",
  "languageChinese": "Китайский",
  "settings": "Настройки",
  "yachtName": "Название яхты",
  "adminEmail": "Email администратора",
  "connected": "Подключено",
  "disconnected": "Нет подключения",
  "syncPending": "{count} ожидают синхронизации",
  "@syncPending": { "placeholders": { "count": { "type": "int" } } },
  "save": "Сохранить",
  "cancel": "Отмена",
  "confirm": "Подтвердить",
  "delete": "Удалить",
  "edit": "Редактировать",
  "back": "Назад",
  "search": "Поиск",
  "noResults": "Нет результатов",
  "loading": "Загрузка...",
  "error": "Ошибка",
  "success": "Успешно",
  "yes": "Да",
  "no": "Нет"
}
```

### PASO 3e — Chino simplificado: `lib/l10n/app_zh.arb`

```json
{
  "@@locale": "zh",
  "appName": "SmartCrew",
  "appSlogan": "Enhance your crew.",
  "login": "登录",
  "logout": "退出登录",
  "changeUser": "切换用户",
  "register": "注册",
  "alreadyHaveAccount": "我已有账户",
  "setupYacht": "设置游艇",
  "enterPin": "输入PIN码",
  "confirmPin": "确认PIN码",
  "newPin": "新PIN码",
  "pinRequired": "PIN码为必填项",
  "pinMustBe4Digits": "PIN码必须恰好为4位数字",
  "pinsDontMatch": "PIN码不匹配",
  "wrongPin": "PIN码错误",
  "biometrics": "生物识别",
  "loginWithBiometrics": "使用生物识别登录",
  "changePinRequired": "继续之前必须更改您的PIN码",
  "dashboard": "仪表板",
  "activeTasks": "进行中任务",
  "openIncidents": "待处理事故",
  "certificateAlerts": "证书警报",
  "lowStock": "库存不足/已耗尽",
  "upcomingEvents": "即将发生的事件",
  "tasks": "任务",
  "newTask": "新任务",
  "taskTitle": "任务标题",
  "taskDescription": "描述",
  "priority": "优先级",
  "priorityHigh": "高",
  "priorityMedium": "中",
  "priorityLow": "低",
  "assignTo": "分配给...",
  "instructions": "说明",
  "markAsCompleted": "标记为已完成",
  "reject": "拒绝",
  "rejectReason": "拒绝原因（必填）",
  "reassign": "重新分配",
  "taskHistory": "任务历史",
  "myTasks": "我的任务",
  "taskCompleted": "任务已完成",
  "taskRejected": "任务已拒绝",
  "taskPending": "待处理",
  "taskAssigned": "已分配",
  "checklist": "检查清单",
  "newChecklist": "新检查清单",
  "checklistType": "类型",
  "checklistEvent": "活动",
  "checklistDaily": "每日",
  "checklistWeekly": "每周",
  "filterPending": "待处理",
  "filterInProgress": "进行中",
  "filterCompleted": "已完成",
  "filterRejected": "已拒绝",
  "crew": "船员",
  "addCrewMember": "添加船员",
  "firstName": "名",
  "lastName": "姓",
  "role": "职位",
  "department": "部门",
  "departmentDeck": "甲板",
  "departmentInterior": "内舱",
  "departmentCook": "厨房",
  "departmentEngine": "机舱",
  "expirationDate": "过期日期",
  "profilePhoto": "个人照片",
  "editCrewMember": "编辑船员",
  "deleteCrewMember": "删除船员",
  "deleteConfirmation": "删除 {name}？此操作无法撤销。",
  "@deleteConfirmation": { "placeholders": { "name": { "type": "String" } } },
  "saveChanges": "保存更改",
  "resetPin": "重置PIN码",
  "certificates": "证书",
  "yachtCertificates": "游艇",
  "crewCertificates": "船员",
  "addCertificate": "添加证书",
  "scanDocument": "扫描文件",
  "attachFile": "附加文件",
  "uploadPhoto": "上传照片",
  "certificateName": "证书名称",
  "searchOrTypeCertificate": "搜索或输入证书名称...",
  "issueDate": "签发日期",
  "expiryDate": "到期日期",
  "expired": "已过期",
  "searchCertificates": "搜索证书...",
  "daysRemaining": "剩余 {days} 天",
  "@daysRemaining": { "placeholders": { "days": { "type": "int" } } },
  "inventory": "库存",
  "addItem": "添加物品",
  "itemName": "物品名称",
  "quantity": "数量",
  "unit": "单位",
  "minimumLevel": "最低库存",
  "shoppingList": "购物清单",
  "markAsBought": "标记为已购买",
  "lowStockAlert": "库存不足",
  "outOfStock": "已耗尽",
  "incidents": "事故",
  "newIncident": "新事故",
  "openIncident": "待处理",
  "assignedIncident": "已分配",
  "inProgressIncident": "处理中",
  "resolvedIncident": "已解决",
  "heyYat": "HEY YAT",
  "heyYatListening": "正在听...",
  "heyYatConfirmed": "已正确记录",
  "heyYatPendingMessages": "{count} 条待处理消息",
  "@heyYatPendingMessages": { "placeholders": { "count": { "type": "int" } } },
  "language": "语言",
  "selectLanguage": "选择语言",
  "languageSpanish": "西班牙语",
  "languageEnglish": "英语",
  "languageFrench": "法语",
  "languageRussian": "俄语",
  "languageChinese": "中文",
  "settings": "设置",
  "yachtName": "游艇名称",
  "adminEmail": "管理员邮箱",
  "connected": "已连接",
  "disconnected": "无连接",
  "syncPending": "{count} 个待同步",
  "@syncPending": { "placeholders": { "count": { "type": "int" } } },
  "save": "保存",
  "cancel": "取消",
  "confirm": "确认",
  "delete": "删除",
  "edit": "编辑",
  "back": "返回",
  "search": "搜索",
  "noResults": "无结果",
  "loading": "加载中...",
  "error": "错误",
  "success": "成功",
  "yes": "是",
  "no": "否"
}
```

---

## PASO 4 — Servicio de idioma: `lib/services/language_service.dart`

Este servicio gestiona el idioma preferido de cada usuario. Se guarda en
SharedPreferences vinculado al ID del usuario activo.

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _keyPrefix = 'user_language_';
  static const String _defaultLocale = 'en';

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
  ];

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  // Locale para speech-to-text según idioma seleccionado
  String get speechLocale {
    switch (_currentLocale.languageCode) {
      case 'es': return 'es-ES';
      case 'fr': return 'fr-FR';
      case 'ru': return 'ru-RU';
      case 'zh': return 'zh-CN';
      default:   return 'en-US';
    }
  }

  /// Carga el idioma guardado para un userId concreto
  Future<void> loadLanguageForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('$_keyPrefix$userId') ?? _defaultLocale;
    _currentLocale = Locale(savedCode);
    notifyListeners();
  }

  /// Guarda el idioma seleccionado para un userId concreto
  Future<void> setLanguage(String userId, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$userId', languageCode);
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  /// Resetea al idioma por defecto (inglés) — usar al hacer logout
  void resetToDefault() {
    _currentLocale = const Locale(_defaultLocale);
    notifyListeners();
  }
}
```

---

## PASO 5 — Integrar LanguageService en main.dart

### Archivos afectados
- `lib/main.dart`

### Cambios necesarios

1. Registrar `LanguageService` como `ChangeNotifierProvider`.
2. Añadir `localizationsDelegates` y `supportedLocales` a `MaterialApp`.
3. Usar `locale: languageService.currentLocale` en `MaterialApp`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... inicializaciones existentes ...

  runApp(
    MultiProvider(
      providers: [
        // ... providers existentes ...
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: const SmartCrewApp(),
    ),
  );
}

class SmartCrewApp extends StatelessWidget {
  const SmartCrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();

    return MaterialApp(
      title: 'SmartCrew',
      locale: languageService.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ru'),
        Locale('zh'),
      ],
      // ... resto de configuración existente ...
    );
  }
}
```

---

## PASO 6 — Cargar idioma al hacer login

### Archivos afectados
- `lib/screens/auth/login_screen.dart` (o donde se gestione el login)

### Lógica

Cuando un usuario completa el login correctamente, ANTES de navegar al dashboard,
llamar a `languageService.loadLanguageForUser(userId)` para cargar su idioma guardado.

```dart
// En el método que gestiona el login exitoso:
final languageService = context.read<LanguageService>();
await languageService.loadLanguageForUser(loggedUser.id);
// Navegar al dashboard...
```

Cuando el usuario cierra sesión o se usa "Cambiar de usuario":

```dart
final languageService = context.read<LanguageService>();
languageService.resetToDefault();
```

---

## PASO 7 — Pantalla de selección de idioma

### Archivos a crear
- `lib/screens/settings/language_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';

class LanguageScreen extends StatelessWidget {
  final String userId;

  const LanguageScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final languageService = context.watch<LanguageService>();

    return Scaffold(
      appBar: AppBar(title: Text(l.selectLanguage)),
      body: ListView.builder(
        itemCount: LanguageService.supportedLanguages.length,
        itemBuilder: (context, index) {
          final lang = LanguageService.supportedLanguages[index];
          final isSelected = languageService.currentLanguageCode == lang['code'];

          return ListTile(
            leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text(lang['name']!),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : null,
            onTap: () async {
              await languageService.setLanguage(userId, lang['code']!);
              if (context.mounted) Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
```

### Integración en la app

Añadir acceso a la pantalla de idioma desde:
1. El menú lateral / drawer (opción "Idioma" con el flag del idioma actual)
2. La pantalla de ajustes / settings

```dart
// En el drawer o settings:
ListTile(
  leading: Text(
    LanguageService.supportedLanguages
        .firstWhere((l) => l['code'] == languageService.currentLanguageCode)['flag']!,
    style: const TextStyle(fontSize: 20),
  ),
  title: Text(l.language),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LanguageScreen(userId: currentUser.id),
    ),
  ),
),
```

---

## PASO 8 — Actualizar HEY YAT para multiidioma

Esta es la parte más importante. Hay dos cambios:
1. El speech-to-text debe escuchar en el idioma del usuario activo.
2. El prompt de clasificación de Claude debe almacenar el texto canónico en inglés.

### PASO 8a — Speech-to-text en el idioma del usuario

### Archivos afectados
- `lib/services/hey_yat_service.dart` (o donde se inicialice speech_to_text)

```dart
// Al iniciar la escucha, usar el speechLocale del LanguageService:
final languageService = context.read<LanguageService>(); // o inyectarlo
final speechLocale = languageService.speechLocale;

await _speech.listen(
  localeId: speechLocale,   // <-- antes era 'es-ES' hardcoded
  onResult: (result) { ... },
  listenFor: const Duration(seconds: 30),
  pauseFor: const Duration(seconds: 3),
);
```

### PASO 8b — Prompt de Claude actualizado para traducción

### Archivos afectados
- `lib/services/voice_classification_service.dart` (o equivalente)

El prompt enviado a Claude debe pedir que devuelva, además de la clasificación,
una versión canónica en inglés del mensaje. Este inglés canónico se almacena
en Supabase y sirve como fuente para traducir al idioma del gestor.

```dart
String buildClassificationPrompt(String transcribedText, List<String> inventoryItems) {
  return '''
You are SmartCrew, an AI assistant for yacht management.
Classify the following message and return a JSON response.

The message may be in any language (Spanish, English, French, Russian, Chinese, or others).
You must:
1. Classify it into the correct category
2. Provide a clean English translation of the core content (for cross-language display)

Message: "$transcribedText"

Current inventory items: ${inventoryItems.join(', ')}

Return ONLY valid JSON with this exact structure:
{
  "category": "TAREA|INCIDENCIA|INVENTARIO|EVENTO|CONSULTA_INVENTARIO",
  "original_text": "$transcribedText",
  "canonical_english": "clean English translation of the message content",
  "summary": "brief summary in English (max 80 chars, for dashboard display)",
  "item_name": "matched inventory item name if category is INVENTARIO, else null",
  "quantity": null or number if mentioned,
  "unit": null or unit string if mentioned,
  "action": null or "sumar|restar|alerta" if category is INVENTARIO,
  "matched_inventory_id": null or UUID if matched to inventory item
}

Categories:
- TAREA: something that needs to be done ("fix the winch", "clean the deck")
- INCIDENCIA: a problem or malfunction ("winch is broken", "generator noise")
- INVENTARIO: stock-related ("running low on oil", "used 2 liters of oil")
- EVENTO: a scheduled event ("dinner for 8 guests tomorrow")
- CONSULTA_INVENTARIO: asking about stock ("what do we need to buy", "shopping list")

For canonical_english: translate naturally, keeping nautical terminology.
Do NOT include greetings or filler words in the canonical_english.
Example: "hey yat hay un winche estropeado a babor" → "broken winch on port side"
''';
}
```

### PASO 8c — Actualizar el modelo de datos en Supabase

Añadir las columnas necesarias a las tablas afectadas. Ejecutar en Supabase SQL Editor:

```sql
-- Tabla de comandos de voz: añadir idioma original y texto canónico en inglés
ALTER TABLE public.voice_commands
  ADD COLUMN IF NOT EXISTS original_language text DEFAULT 'en',
  ADD COLUMN IF NOT EXISTS canonical_english text;

-- Tabla de mensajes pendientes offline
ALTER TABLE public.pending_voice_messages
  ADD COLUMN IF NOT EXISTS original_language text DEFAULT 'en',
  ADD COLUMN IF NOT EXISTS canonical_english text;

-- Tabla de tareas: añadir texto canónico para tareas creadas por voz
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS canonical_english text;

-- Tabla de incidencias: añadir texto canónico
ALTER TABLE public.incidents
  ADD COLUMN IF NOT EXISTS canonical_english text;

-- Tabla de preferencias del owner: añadir texto canónico
ALTER TABLE public.owner_preferences
  ADD COLUMN IF NOT EXISTS canonical_english text;
```

### PASO 8d — Servicio de traducción bajo demanda

Cuando el gestor carga datos (tareas, incidencias, etc.) que tienen `canonical_english`,
mostrarlos en su idioma. Si el idioma del gestor es inglés, usar directamente
`canonical_english`. Para otros idiomas, traducir con Claude.

Para evitar llamadas excesivas a la API, implementar caché local:

```dart
// lib/services/translation_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _cachePrefix = 'translation_cache_';
  
  /// Traduce un texto canónico (en inglés) al idioma destino.
  /// Usa caché local para evitar llamadas repetidas a la API.
  static Future<String> translate({
    required String canonicalEnglish,
    required String targetLanguage,
    required String apiKey,
  }) async {
    // Si el destino es inglés, no traducir
    if (targetLanguage == 'en') return canonicalEnglish;
    
    // Clave de caché: hash del texto + idioma
    final cacheKey = '$_cachePrefix${canonicalEnglish.hashCode}_$targetLanguage';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    if (cached != null) return cached;

    // Llamar a Claude para traducir
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 200,
          'messages': [
            {
              'role': 'user',
              'content': '''Translate this yacht management message to ${_languageName(targetLanguage)}.
Return ONLY the translated text, nothing else. Keep nautical terms accurate.
Text: "$canonicalEnglish"'''
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['content'][0]['text'].toString().trim();
        // Guardar en caché
        await prefs.setString(cacheKey, translated);
        return translated;
      }
    } catch (e) {
      // Si falla la traducción, mostrar el inglés como fallback
    }
    return canonicalEnglish;
  }

  static String _languageName(String code) {
    switch (code) {
      case 'es': return 'Spanish';
      case 'fr': return 'French';
      case 'ru': return 'Russian';
      case 'zh': return 'Simplified Chinese';
      default:   return 'English';
    }
  }
}
```

### PASO 8e — Widget de texto traducido

Crear un widget reutilizable que muestre el texto traducido al idioma del gestor:

```dart
// lib/widgets/translated_text.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/translation_service.dart';

class TranslatedText extends StatefulWidget {
  final String? canonicalEnglish;
  final String? originalText;
  final TextStyle? style;
  final String apiKey;

  const TranslatedText({
    super.key,
    required this.canonicalEnglish,
    this.originalText,
    this.style,
    required this.apiKey,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String? _translatedText;

  @override
  void initState() {
    super.initState();
    _translate();
  }

  Future<void> _translate() async {
    final source = widget.canonicalEnglish ?? widget.originalText ?? '';
    if (source.isEmpty) return;

    final languageService = context.read<LanguageService>();
    final targetLang = languageService.currentLanguageCode;

    final result = await TranslationService.translate(
      canonicalEnglish: source,
      targetLanguage: targetLang,
      apiKey: widget.apiKey,
    );

    if (mounted) {
      setState(() { _translatedText = result; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translatedText ?? widget.canonicalEnglish ?? widget.originalText ?? '',
      style: widget.style,
    );
  }
}
```

---

## PASO 9 — Usar las traducciones en la UI

### Dónde reemplazar strings hardcoded

En **todos** los widgets y pantallas, reemplazar los strings literales por
referencias a `AppLocalizations`. Por ejemplo:

```dart
// ANTES:
Text('Tareas activas')
ElevatedButton(onPressed: ..., child: Text('Guardar'))
AppBar(title: Text('Certificados'))

// DESPUÉS:
final l = AppLocalizations.of(context)!;
Text(l.activeTasks)
ElevatedButton(onPressed: ..., child: Text(l.save))
AppBar(title: Text(l.certificates))
```

### Dónde usar TranslatedText (contenido de HEY YAT)

En las pantallas donde se muestra contenido generado por HEY YAT, usar
`TranslatedText` en lugar de `Text`:

```dart
// En la pantalla de tareas, al mostrar descripción de tarea creada por voz:
TranslatedText(
  canonicalEnglish: task.canonicalEnglish,
  originalText: task.description,
  apiKey: AppConfig.anthropicApiKey,
  style: Theme.of(context).textTheme.bodyMedium,
)

// En la pantalla de incidencias:
TranslatedText(
  canonicalEnglish: incident.canonicalEnglish,
  originalText: incident.description,
  apiKey: AppConfig.anthropicApiKey,
)
```

---

## PASO 10 — Confirmación de voz en el idioma del usuario

Cuando HEY YAT confirma que ha registrado el mensaje, debe hacerlo
en el idioma del usuario activo (no en español hardcoded).

### Archivos afectados
- `lib/services/hey_yat_service.dart` o donde se use `FlutterTts`

```dart
// Usar el idioma del usuario activo para la confirmación por voz
final languageService = context.read<LanguageService>();
await _tts.setLanguage(languageService.speechLocale);
await _tts.speak(confirmationMessage); // mensaje en el idioma del usuario
```

Los mensajes de confirmación deben estar en los ARB files.
Ya están incluidos como `heyYatConfirmed` y `heyYatListening`.

---

## RESUMEN DE ARCHIVOS A CREAR / MODIFICAR

### Archivos nuevos
- `l10n.yaml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_ru.arb`
- `lib/l10n/app_zh.arb`
- `lib/services/language_service.dart`
- `lib/services/translation_service.dart`
- `lib/screens/settings/language_screen.dart`
- `lib/widgets/translated_text.dart`

### Archivos a modificar
- `pubspec.yaml` — añadir dependencia intl + generate: true
- `lib/main.dart` — añadir localizationsDelegates, locale, LanguageService provider
- `lib/screens/auth/login_screen.dart` — cargar idioma al login, resetear al logout
- `lib/services/hey_yat_service.dart` — speechLocale dinámico + TTS en idioma correcto
- `lib/services/voice_classification_service.dart` — prompt actualizado con canonical_english
- Todas las pantallas — reemplazar strings hardcoded por `AppLocalizations`
- Menú lateral / drawer — añadir opción de idioma

### Migraciones SQL (ejecutar en Supabase)
- Añadir `original_language` y `canonical_english` a: `voice_commands`, `pending_voice_messages`, `tasks`, `incidents`, `owner_preferences`

---

## ORDEN DE IMPLEMENTACIÓN

1. `pubspec.yaml` + `l10n.yaml` — setup del sistema i18n
2. Crear los 5 archivos ARB
3. `flutter gen-l10n` — generar el código (o `flutter pub get` con generate:true)
4. `LanguageService` — servicio de idioma
5. `main.dart` — integrar localizaciones y provider
6. Migración SQL en Supabase — añadir columnas
7. Prompt actualizado de voice_classification — añadir canonical_english
8. `TranslationService` + `TranslatedText` widget
9. Login screen — cargar idioma al entrar
10. `LanguageScreen` — pantalla de selección
11. Menú lateral — añadir opción de idioma
12. HEY YAT — speechLocale dinámico
13. Reemplazar strings hardcoded en todas las pantallas

Después: `flutter build apk --debug`
