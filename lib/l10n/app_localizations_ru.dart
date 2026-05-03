// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'SmartYat';

  @override
  String get appSlogan => 'Enhance your crew.';

  @override
  String get login => 'Войти';

  @override
  String get logout => 'Выйти';

  @override
  String get changeUser => 'Сменить пользователя';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get alreadyHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get setupYacht => 'Настроить яхту';

  @override
  String get enterPin => 'Введите PIN';

  @override
  String get confirmPin => 'Подтвердите PIN';

  @override
  String get newPin => 'Новый PIN';

  @override
  String get pinRequired => 'PIN обязателен';

  @override
  String get pinMustBe4Digits => 'PIN должен содержать ровно 4 цифры';

  @override
  String get pinsDontMatch => 'PIN-коды не совпадают';

  @override
  String get wrongPin => 'Неверный PIN';

  @override
  String get biometrics => 'Биометрия';

  @override
  String get loginWithBiometrics => 'Войти с помощью биометрии';

  @override
  String get changePinRequired => 'Вы должны сменить PIN перед продолжением';

  @override
  String get dashboard => 'Панель управления';

  @override
  String get activeTasks => 'Активные задачи';

  @override
  String get openIncidents => 'Открытые инциденты';

  @override
  String get certificateAlerts => 'Оповещения по сертификатам';

  @override
  String get lowStock => 'Низкий запас / отсутствует';

  @override
  String get upcomingEvents => 'Предстоящие события';

  @override
  String get tasks => 'Задачи';

  @override
  String get newTask => 'Новая задача';

  @override
  String get taskTitle => 'Название задачи';

  @override
  String get taskDescription => 'Описание';

  @override
  String get priority => 'Приоритет';

  @override
  String get priorityHigh => 'Высокий';

  @override
  String get priorityMedium => 'Средний';

  @override
  String get priorityLow => 'Низкий';

  @override
  String get assignTo => 'Назначить...';

  @override
  String get instructions => 'Инструкции';

  @override
  String get markAsCompleted => 'Отметить как выполненное';

  @override
  String get reject => 'Отклонить';

  @override
  String get rejectReason => 'Причина отказа (обязательно)';

  @override
  String get reassign => 'Переназначить';

  @override
  String get taskHistory => 'История';

  @override
  String get myTasks => 'Мои задачи';

  @override
  String get taskCompleted => 'Задача выполнена';

  @override
  String get taskRejected => 'Задача отклонена';

  @override
  String get taskPending => 'Ожидает';

  @override
  String get taskAssigned => 'Назначено';

  @override
  String get checklist => 'Контрольный список';

  @override
  String get newChecklist => 'Новый список';

  @override
  String get checklistType => 'Тип';

  @override
  String get checklistEvent => 'Событие';

  @override
  String get checklistDaily => 'Ежедневный';

  @override
  String get checklistWeekly => 'Еженедельный';

  @override
  String get filterAll => 'Все';

  @override
  String get filterPending => 'Ожидающие';

  @override
  String get filterInProgress => 'В процессе';

  @override
  String get filterCompleted => 'Завершённые (48ч)';

  @override
  String get filterRejected => 'Отклонённые';

  @override
  String get crew => 'Экипаж';

  @override
  String get addCrewMember => 'Добавить члена экипажа';

  @override
  String get firstName => 'Полное имя';

  @override
  String get role => 'Должность';

  @override
  String get department => 'Отдел';

  @override
  String get departmentDeck => 'Палуба';

  @override
  String get departmentInterior => 'Интерьер';

  @override
  String get departmentCook => 'Кухня';

  @override
  String get departmentEngine => 'Машинное отделение';

  @override
  String get expirationDate => 'Дата истечения';

  @override
  String get profilePhoto => 'Фото профиля';

  @override
  String get editCrewMember => 'Редактировать';

  @override
  String get deleteCrewMember => 'Удалить члена';

  @override
  String deleteConfirmation(String name) {
    return 'Удалить $name? Это действие необратимо.';
  }

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get resetPin => 'Сбросить PIN';

  @override
  String get certificates => 'Сертификаты';

  @override
  String get yachtCertificates => 'Яхта';

  @override
  String get crewCertificates => 'Экипаж';

  @override
  String get addCertificate => 'Добавить сертификат';

  @override
  String get scanDocument => 'Сканировать документ';

  @override
  String get attachFile => 'Прикрепить файл';

  @override
  String get uploadPhoto => 'Загрузить фото';

  @override
  String get certificateName => 'Название сертификата';

  @override
  String get searchOrTypeCertificate => 'Поиск или ввод названия...';

  @override
  String get issueDate => 'Дата выдачи';

  @override
  String get expiryDate => 'Дата истечения';

  @override
  String get expired => 'ПРОСРОЧЕН';

  @override
  String get searchCertificates => 'Поиск сертификатов...';

  @override
  String daysRemaining(int days) {
    return 'Осталось $days дней';
  }

  @override
  String get inventory => 'Инвентарь';

  @override
  String get addItem => 'Добавить товар';

  @override
  String get itemName => 'Название товара';

  @override
  String get quantity => 'Количество';

  @override
  String get unit => 'Единица';

  @override
  String get minimumLevel => 'Минимальный уровень';

  @override
  String get shoppingList => 'Список покупок';

  @override
  String get markAsBought => 'Отметить как купленное';

  @override
  String get lowStockAlert => 'Мало запасов';

  @override
  String get outOfStock => 'Нет в наличии';

  @override
  String get incidents => 'Инциденты';

  @override
  String get newIncident => 'Новый инцидент';

  @override
  String get openIncident => 'Открыт';

  @override
  String get assignedIncident => 'Назначен';

  @override
  String get inProgressIncident => 'В процессе';

  @override
  String get resolvedIncident => 'Решён';

  @override
  String get heyYat => 'HEY YAT';

  @override
  String get heyYatSubtitle => 'Интеллектуальный голосовой помощник';

  @override
  String get heyYatListening => 'СЛУШАЮ...';

  @override
  String get heyYatClassifying => 'КЛАССИФИКАЦИЯ...';

  @override
  String get heyYatConfirmed => 'ЗАРЕГИСТРИРОВАНО!';

  @override
  String heyYatPendingMessages(int count) {
    return '$count сообщение(й) в очереди';
  }

  @override
  String get heyYatProcessingOffline => 'Обработка офлайн-сообщений...';

  @override
  String get heyYatTypeManually => 'Написать вручную';

  @override
  String get heyYatHideKeyboard => 'Скрыть клавиатуру';

  @override
  String get heyYatSavedInSystem => 'Сохранено в системе';

  @override
  String get heyYatSpeakNow => 'Говорите...';

  @override
  String get heyYatSendMessage => 'Отправить сообщение';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageChinese => 'Китайский';

  @override
  String get settings => 'Настройки';

  @override
  String get yachtName => 'Название яхты';

  @override
  String get adminEmail => 'Email администратора';

  @override
  String get online => 'Подключено';

  @override
  String get offline => 'Нет подключения';

  @override
  String get offlineBanner => 'Нет подключения · Офлайн режим';

  @override
  String syncPending(int count) {
    return '$count ожидают синхронизации';
  }

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get back => 'Назад';

  @override
  String get search => 'Поиск';

  @override
  String get noResults => 'Нет результатов';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get success => 'Успешно';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get viewAll => 'Все';

  @override
  String get seeAll => 'Смотреть все';

  @override
  String get create => 'Создать';

  @override
  String get add => 'Добавить';

  @override
  String get assign => 'Назначить';

  @override
  String get reassignTask => 'Переназначить задачу';

  @override
  String get complete => 'Выполнено';

  @override
  String get resolve => 'Решить';

  @override
  String get inProgress => 'В процессе';

  @override
  String get moreOptions => 'Больше параметров';

  @override
  String get activeIncidents => 'АКТИВНЫЕ ИНЦИДЕНТЫ';

  @override
  String get urgentCertificates => 'СРОЧНЫЕ СЕРТИФИКАТЫ';

  @override
  String get noStock => 'НЕТ В НАЛИЧИИ';

  @override
  String get recentTasks => 'ПОСЛЕДНИЕ ЗАДАЧИ';

  @override
  String get noActiveTasks => 'Нет задач в этой категории';

  @override
  String get noRejectedTasks => 'Нет отклонённых задач';

  @override
  String get noCompletedTasks => 'Нет завершённых задач';

  @override
  String get searchHistory => 'Поиск в истории...';

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get allTime => 'Всё';

  @override
  String get pinFirstAccess =>
      'Первый доступ. В целях безопасности необходимо сменить PIN.';

  @override
  String get introduceNewPin => 'ВВЕДИТЕ НОВЫЙ PIN';

  @override
  String get confirmNewPin => 'ПОДТВЕРДИТЕ НОВЫЙ PIN';

  @override
  String get pinRepeatToConfirm => 'Повторите PIN для подтверждения';

  @override
  String get pinNotZeros => 'PIN не может быть 0000';

  @override
  String get pinNoMatch => 'PIN-коды не совпадают. Попробуйте снова.';
}
