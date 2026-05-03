// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'SmartYat';

  @override
  String get appSlogan => 'Enhance your crew.';

  @override
  String get login => '登录';

  @override
  String get logout => '退出登录';

  @override
  String get changeUser => '切换用户';

  @override
  String get register => '注册';

  @override
  String get alreadyHaveAccount => '我已有账户';

  @override
  String get setupYacht => '设置游艇';

  @override
  String get enterPin => '输入PIN码';

  @override
  String get confirmPin => '确认PIN码';

  @override
  String get newPin => '新PIN码';

  @override
  String get pinRequired => 'PIN码为必填项';

  @override
  String get pinMustBe4Digits => 'PIN码必须恰好为4位数字';

  @override
  String get pinsDontMatch => 'PIN码不匹配';

  @override
  String get wrongPin => 'PIN码错误';

  @override
  String get biometrics => '生物识别';

  @override
  String get loginWithBiometrics => '使用生物识别登录';

  @override
  String get changePinRequired => '继续之前必须更改您的PIN码';

  @override
  String get dashboard => '仪表板';

  @override
  String get activeTasks => '进行中任务';

  @override
  String get openIncidents => '待处理事故';

  @override
  String get certificateAlerts => '证书警报';

  @override
  String get lowStock => '库存不足/已耗尽';

  @override
  String get upcomingEvents => '即将发生的事件';

  @override
  String get tasks => '任务';

  @override
  String get newTask => '新任务';

  @override
  String get taskTitle => '任务标题';

  @override
  String get taskDescription => '描述';

  @override
  String get priority => '优先级';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String get assignTo => '分配给...';

  @override
  String get instructions => '说明';

  @override
  String get markAsCompleted => '标记为已完成';

  @override
  String get reject => '拒绝';

  @override
  String get rejectReason => '拒绝原因（必填）';

  @override
  String get reassign => '重新分配';

  @override
  String get taskHistory => '历史';

  @override
  String get myTasks => '我的任务';

  @override
  String get taskCompleted => '任务已完成';

  @override
  String get taskRejected => '任务已拒绝';

  @override
  String get taskPending => '待处理';

  @override
  String get taskAssigned => '已分配';

  @override
  String get checklist => '检查清单';

  @override
  String get newChecklist => '新检查清单';

  @override
  String get checklistType => '类型';

  @override
  String get checklistEvent => '活动';

  @override
  String get checklistDaily => '每日';

  @override
  String get checklistWeekly => '每周';

  @override
  String get filterAll => '全部';

  @override
  String get filterPending => '待处理';

  @override
  String get filterInProgress => '进行中';

  @override
  String get filterCompleted => '已完成 (48h)';

  @override
  String get filterRejected => '已拒绝';

  @override
  String get crew => '船员';

  @override
  String get addCrewMember => '添加船员';

  @override
  String get firstName => '全名';

  @override
  String get role => '职位';

  @override
  String get department => '部门';

  @override
  String get departmentDeck => '甲板';

  @override
  String get departmentInterior => '内舱';

  @override
  String get departmentCook => '厨房';

  @override
  String get departmentEngine => '机舱';

  @override
  String get expirationDate => '过期日期';

  @override
  String get profilePhoto => '个人照片';

  @override
  String get editCrewMember => '编辑船员';

  @override
  String get deleteCrewMember => '删除船员';

  @override
  String deleteConfirmation(String name) {
    return '删除 $name？此操作无法撤销。';
  }

  @override
  String get saveChanges => '保存更改';

  @override
  String get resetPin => '重置PIN码';

  @override
  String get certificates => '证书';

  @override
  String get yachtCertificates => '游艇';

  @override
  String get crewCertificates => '船员';

  @override
  String get addCertificate => '添加证书';

  @override
  String get scanDocument => '扫描文件';

  @override
  String get attachFile => '附加文件';

  @override
  String get uploadPhoto => '上传照片';

  @override
  String get certificateName => '证书名称';

  @override
  String get searchOrTypeCertificate => '搜索或输入证书名称...';

  @override
  String get issueDate => '签发日期';

  @override
  String get expiryDate => '到期日期';

  @override
  String get expired => '已过期';

  @override
  String get searchCertificates => '搜索证书...';

  @override
  String daysRemaining(int days) {
    return '剩余 $days 天';
  }

  @override
  String get inventory => '库存';

  @override
  String get addItem => '添加物品';

  @override
  String get itemName => '物品名称';

  @override
  String get quantity => '数量';

  @override
  String get unit => '单位';

  @override
  String get minimumLevel => '最低库存';

  @override
  String get shoppingList => '购物清单';

  @override
  String get markAsBought => '标记为已购买';

  @override
  String get lowStockAlert => '库存不足';

  @override
  String get outOfStock => '已耗尽';

  @override
  String get incidents => '事故';

  @override
  String get newIncident => '新事故';

  @override
  String get openIncident => '待处理';

  @override
  String get assignedIncident => '已分配';

  @override
  String get inProgressIncident => '处理中';

  @override
  String get resolvedIncident => '已解决';

  @override
  String get heyYat => 'HEY YAT';

  @override
  String get heyYatSubtitle => '智能语音助手';

  @override
  String get heyYatListening => '正在听...';

  @override
  String get heyYatClassifying => '分类中...';

  @override
  String get heyYatConfirmed => '已记录！';

  @override
  String heyYatPendingMessages(int count) {
    return '$count 条待处理消息';
  }

  @override
  String get heyYatProcessingOffline => '正在处理离线消息...';

  @override
  String get heyYatTypeManually => '手动输入';

  @override
  String get heyYatHideKeyboard => '隐藏键盘';

  @override
  String get heyYatSavedInSystem => '已保存到系统';

  @override
  String get heyYatSpeakNow => '请说话...';

  @override
  String get heyYatSendMessage => '发送消息';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageChinese => '中文';

  @override
  String get settings => '设置';

  @override
  String get yachtName => '游艇名称';

  @override
  String get adminEmail => '管理员邮箱';

  @override
  String get online => '已连接';

  @override
  String get offline => '无连接';

  @override
  String get offlineBanner => '无连接 · 离线模式';

  @override
  String syncPending(int count) {
    return '$count 个待同步';
  }

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get back => '返回';

  @override
  String get search => '搜索';

  @override
  String get noResults => '无结果';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get viewAll => '查看全部';

  @override
  String get seeAll => '查看全部';

  @override
  String get create => '创建';

  @override
  String get add => '添加';

  @override
  String get assign => '分配';

  @override
  String get reassignTask => '重新分配任务';

  @override
  String get complete => '已完成';

  @override
  String get resolve => '解决';

  @override
  String get inProgress => '进行中';

  @override
  String get moreOptions => '更多选项';

  @override
  String get activeIncidents => '活跃事故';

  @override
  String get urgentCertificates => '紧急证书';

  @override
  String get noStock => '无库存';

  @override
  String get recentTasks => '最近任务';

  @override
  String get noActiveTasks => '该类别中没有任务';

  @override
  String get noRejectedTasks => '没有被拒绝的任务';

  @override
  String get noCompletedTasks => '没有已完成的任务';

  @override
  String get searchHistory => '搜索历史...';

  @override
  String get thisWeek => '本周';

  @override
  String get thisMonth => '本月';

  @override
  String get allTime => '全部';

  @override
  String get pinFirstAccess => '首次访问。出于安全考虑，您必须更改PIN码。';

  @override
  String get introduceNewPin => '输入新PIN码';

  @override
  String get confirmNewPin => '确认新PIN码';

  @override
  String get pinRepeatToConfirm => '重复PIN码以确认';

  @override
  String get pinNotZeros => 'PIN码不能为0000';

  @override
  String get pinNoMatch => 'PIN码不匹配。请重试。';
}
