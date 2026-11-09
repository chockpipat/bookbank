class AppLocalizations {
  final String languageCode;

  const AppLocalizations(this.languageCode);

  static const Map<String, Map<String, String>> _translations = {
    // English
    'en': {
      // Header / Menu
      'header_description': 'Save your entries',
      'edit_group': 'Edit Group',
      'dark_theme': 'Dark Theme',
      'change_language': 'Change Language',
      'change_currency': 'Change Currency',
      'about': 'About',
      'app_version': 'Version',
      'app_description':
          '        An app for tracking your income and expenses that also shows spending trends, helping you plan your finances more effectively. Regarding security, your data is stored exclusively on your device.',
      'developer': 'Developer',

      // Navigation
      'home': 'Home',
      'record': 'Record',
      'charts': 'Charts',
      'settings': 'Settings',

      // Language names
      'lang_thai': 'Thai',
      'lang_english': 'English',
      'lang_chinese': 'Chinese',

      // Currency names
      'currency_baht': 'Thai Baht (\u0e3f)',
      'currency_dollar': 'US Dollar (\$)',
      'currency_yuan': 'Chinese Yuan (¥)',

      // Dashboard
      'total_balance': 'Total Balance',
      'valid_today': 'Valid today',
      'bank': 'Bank',
      'cash': 'Cash',
      'income': 'Income',
      'expense': 'Expense',
      'monthly_income': 'Monthly Income',
      'monthly_expense': 'Monthly Expense',
      'cash_box': 'Cash box',
      'transactions': 'Transactions',
      'from': 'from',

      // Charts
      'dashboard': 'Dashboard',
      'view_stats': 'View your statistics in detail.',
      'data_for_day': 'Data for this day',
      'income_expense_by_category': 'Income and expenses by category',
      'monthly_data': 'Monthly data',
      'net': 'Net',
      'not_enough_data': 'Not enough data',

      // Record screen
      'transaction_history': 'Transaction History',
      'filter': 'Filter',
      'all': 'All',
      'search': 'Search for program name...',
      'no_records': 'No records found',
      'selected': 'selected',
      'records': 'records',
      'amount': 'Amount',
      'position': 'Position',
      'date': 'Date',
      'view': 'View',
      'edit': 'Edit',
      'delete': 'Delete',

      // Add transaction
      'add_list': 'Add List',
      'money_list': 'Money List',
      'money_position': 'Money Position',
      'category': 'Category',
      'save': 'Save',

      // Transfer
      'transfer': 'Transfer',
      'alternate': 'Alternate',
      'anonymous': 'Anonymous',

      // Record detail
      'money_list_label': 'Money List',
      'money_position_label': 'Money Position',
      'group': 'Category',
      'date_label': 'Date',

      // Notebook
      'notebook': 'NoteBook',
      'notes_subtitle': 'Personal notes and reminders',
      'add': 'Add',
      'items': 'Items',
      'notes': 'Notes',
      'recorded_on': 'Recorded on',
      'confirm_delete': 'Confirm Delete',
      'confirm_delete_note': 'Are you sure you want to delete the note',
      'note_deleted': 'Note deleted successfully',
      'noRecord': 'No Records.',
      'addNotePrompt':
          'Start recording memories or important notes easily by clicking the add note button below.',

      // Action feedback
      'added_success': 'Added successfully',
      'updated_success': 'Updated successfully',
      'deleted_success': 'Deleted successfully',
      'delete_confirm': 'Are you sure you want to delete this record?',

      // Popup
      'unallocated_funds': 'Unallocated Funds',
      'all_money_in_group': 'All money in the group',
      'this_is': 'This is ',
      'out_of_total': ' out of the total',
      'target': 'Target',

      // General
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'load_failed': 'Failed to load data. Please try again.',
      'retry': 'Retry',

      // Please enter
      'please_enter_amount': '*Please enter an amount',

      // Group settings
      'icon': 'Icon',
      'color': 'Color',

      // Notebook actions
      'pin': 'Pin',
      'unpin': 'Unpin',

      // Transaction fields
      'title': 'Title',
      'content': 'Content',

      // Note editor
      'addNote': 'Add Note',
      'note_color': 'Select Color Tag',
      'enter_title': 'Please enter a title',
      'enter_note_title': 'Enter note title...',
      'enter_note_content': 'Enter note content...',
      'enter_content': 'Please enter note content',

      // Note categories
      'category_all': 'All',
      'category_general': 'General',
      'category_finance': 'Finance',
      'category_goals': 'Goals',

      // Category suggestions
      'category_food': 'Food',
      'category_transport': 'Transport',
      'category_shopping': 'Shopping',
      'category_entertainment': 'Entertainment',
      'category_bills': 'Bills',

      // Note editor
      'edit_note': 'Edit Note',
      'save_changes': 'Save Changes',
      'create_note': 'Create Note',

      // Group settings
      'enable_savings_goal': 'Enable Savings Goal',
      'savings_goal_amount': 'Savings Goal Amount',

      // Month abbreviations
      'month_jan': 'Jan',
      'month_feb': 'Feb',
      'month_mar': 'Mar',
      'month_apr': 'Apr',
      'month_may': 'May',
      'month_jun': 'Jun',
      'month_jul': 'Jul',
      'month_aug': 'Aug',
      'month_sep': 'Sep',
      'month_oct': 'Oct',
      'month_nov': 'Nov',
      'month_dec': 'Dec',

      // Onboarding
      'welcome_title': 'Welcome to the BookBank app.',
      'welcome_subtitle':
          'Conveniently record your income and expenses, and view detailed spending statistics.',
      'next': 'Next',
      'select_currency': 'Select your currency',
      'start': 'Start',
      'select_language': 'Select Language',
      'privacy_policy': 'Privacy Policy',
      'privacy_policy_title': 'Privacy Policy',
      'privacy_policy_content': '''
Data Collection:
We collect minimal data necessary for the app to function, including your financial records and app settings.

Data Storage:
All your data is stored locally on your device. We do not store any personal information on external servers.

Data Usage:
Your data is used solely for the purpose of tracking your finances and providing app functionality.

Data Sharing:
We do not share your personal data with any third parties.

Security:
We implement reasonable security measures to protect your data, but please note that no method of transmission over the internet is 100% secure.

Contact:
If you have any questions about this privacy policy, please contact the developer.
      ''',
      'privacy_policy_close': 'Close',
      'currency_baht_display': '฿ - Baht (THB)',
      'currency_dollar_display': '\$ - Dollar (USD)',
      'currency_yuan_display': '¥ - Yuan (CNY)',

      // transfer
      'transfer_amount_not_enough': 'Insufficient funds',
      'transfer_to': 'Transfer to',
      'transfer_title': 'Transfer money between groups',
      'transfer_remaining': 'Remaining balance',
      'transfer_money': 'Transfer money',
      'transfer_success': 'Transfer money success',

      // Date time picker
      'select_date_time': 'Select Date and Time',
      'time': 'Time',
    },

    // Thai
    'th': {
      // Header / Menu
      'header_description': 'บันทึกรายรับรายจ่ายของคุณ',
      'edit_group': 'แก้ไขกลุ่ม',
      'dark_theme': 'โหมดมืด',
      'change_language': 'เปลี่ยนภาษา',
      'change_currency': 'เปลี่ยนสกุลเงิน',
      'about': 'เกี่ยวกับ',
      'app_version': 'เวอร์ชั่น',
      'app_description':
          '        แอปพลิเคชันจัดการการประวัติรายรับ-รายจ่าย พร้อมบอกแนวโน้มการใช้จ่ายช้วยให้คุณสามารถวางแผนการเงินได้ดีขึ้น ในด้านความปลอดภัย เราได้จัดการข้อมูลโดยการเก็บไว้ในเครื่องของคุณเท่านั้น',
      'developer': 'ผู้พัฒนา',

      // Navigation
      'home': 'หน้าหลัก',
      'record': 'บันทึก',
      'charts': 'กราฟ',
      'settings': 'ตั้งค่า',

      // Language names
      'lang_thai': 'ไทย',
      'lang_english': 'อังกฤษ',
      'lang_chinese': 'จีน',

      // Currency names
      'currency_baht': 'บาทไทย (\u0e3f)',
      'currency_dollar': 'ดอลลาร์สหรัฐ (\$)',
      'currency_yuan': 'หยวนจีน (¥)',

      // Dashboard
      'total_balance': 'ยอดที่ใช้ได้',
      'valid_today': 'ใช้ได้วันนี้',
      'bank': 'ธนาคาร',
      'cash': 'เงินสด',
      'income': 'รายรับ',
      'expense': 'รายจ่าย',
      'monthly_income': 'รายรับรายเดือน',
      'monthly_expense': 'รายจ่ายรายเดือน',
      'cash_box': 'กล่องเก็บเงิน',
      'transactions': 'รายการ',
      'from': 'จาก',

      // Charts
      'dashboard': 'แดชบอร์ด',
      'view_stats': 'ดูสถิติของคุณในรายละเอียด',
      'data_for_day': 'ข้อมูลวันนี้',
      'income_expense_by_category': 'รายรับและรายจ่ายตามหมวดหมู่',
      'monthly_data': 'ข้อมูลรายเดือน',
      'net': 'สุทธิ',
      'not_enough_data': 'ไม่มีข้อมูล',

      // Record screen
      'transaction_history': 'ประวัติธุรกรรม',
      'filter': 'ตัวกรอง',
      'all': 'ทั้งหมด',
      'search': 'ค้นหาชื่อรายการ...',
      'no_records': 'ไม่พบรายการ',
      'selected': 'รายการที่เลือก',
      'records': 'รายการ',
      'amount': 'จำนวนเงิน',
      'position': 'ตำแหน่ง',
      'date': 'วันที่',
      'view': 'ดู',
      'edit': 'แก้ไข',
      'delete': 'ลบ',

      // Add transaction
      'add_list': 'เพิ่มรายการ',
      'money_list': 'ประเภทเงิน',
      'money_position': 'ตำแหน่งเงิน',
      'category': 'หมวดหมู่',
      'save': 'บันทึก',

      // Transfer
      'transfer': 'โอน',
      'alternate': 'สลับ',
      'anonymous': 'ไม่ระบุชื่อ',

      // Record detail
      'money_list_label': 'ประเภทเงิน',
      'money_position_label': 'ตำแหน่งเงิน',
      'group': 'หมวดหมู่',
      'date_label': 'วันที่',

      // Notebook
      'notebook': 'สมุดโน้ต',
      'notes_subtitle': 'บันทึกและการแจ้งเตือนส่วนตัว',
      'add': 'เพิ่ม',
      'items': 'รายการ',
      'notes': 'บันทึก',
      'recorded_on': 'บันทึกเมื่อ',
      'confirm_delete': 'ยืนยันการลบ',
      'confirm_delete_note': 'คุณแน่ใจหรือไม่ว่าต้องการลบโน้ต',
      'note_deleted': 'ลบโน้ตสำเร็จ',
      'noRecord': 'ไม่พบรายการ',
      'addNotePrompt':
          'เริ่มบันทึกความทรงจำหรือบันทึกสำคัญได้ง่ายๆ โดยการคลิกที่ปุ่มเพิ่มโน้ตด้านล่าง',

      // Action feedback
      'added_success': 'เพิ่มสำเร็จ',
      'updated_success': 'อัปเดตสำเร็จ',
      'deleted_success': 'ลบสำเร็จ',
      'delete_confirm': 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้?',

      // Popup
      'unallocated_funds': 'เงินที่ยังไม่จัดสรร',
      'all_money_in_group': 'เงินทั้งหมดในกลุ่ม',
      'this_is': 'นี่คือ ',
      'out_of_total': ' จากทั้งหมด',
      'target': 'เป้าหมาย',

      // General
      'cancel': 'ยกเลิก',
      'confirm': 'ยืนยัน',
      'load_failed': 'โหลดข้อมูลไม่สำเร็จ กรุณาลองใหม่อีกครั้ง',
      'retry': 'ลองใหม่',

      // Please enter
      'please_enter_amount': '*กรุณาใส่จำนวนเงิน',

      // Group settings
      'icon': 'ไอคอน',
      'color': 'สี',

      // Notebook actions
      'pin': 'ปักหมุด',
      'unpin': 'ยกเลิกปักหมุด',

      // Transaction fields
      'title': 'ชื่อเรื่อง',
      'content': 'เนื้อหา',

      // Note editor
      'addNote': 'เพิ่มโน้ต',
      'note_color': 'เลือกสีแท็ก',
      'enter_title': 'กรุณาใส่ชื่อเรื่อง',
      'enter_note_title': 'ใส่ชื่อโน้ต...',
      'enter_note_content': 'ใส่เนื้อหาโน้ต...',
      'enter_content': 'กรุณาใส่เนื้อหา',

      // Note categories
      'category_all': 'ทั้งหมด',
      'category_general': 'ทั่วไป',
      'category_finance': 'การเงิน',
      'category_goals': 'เป้าหมาย',

      // Category suggestions
      'category_food': 'อาหาร',
      'category_transport': 'การเดินทาง',
      'category_shopping': 'ช้อปปิ้ง',
      'category_entertainment': 'บันเทิง',
      'category_bills': 'บิล',

      // Note editor
      'edit_note': 'แก้ไขโน้ต',
      'save_changes': 'บันทึกการเปลี่ยนแปลง',
      'create_note': 'สร้างโน้ต',

      // Group settings
      'enable_savings_goal': 'เปิดใช้เป้าหมายการออม',
      'savings_goal_amount': 'จำนวนเงินเป้าหมายการออม',

      // Month abbreviations
      'month_jan': 'ม.ค.',
      'month_feb': 'ก.พ.',
      'month_mar': 'มี.ค.',
      'month_apr': 'เม.ย.',
      'month_may': 'พ.ค.',
      'month_jun': 'มิ.ย.',
      'month_jul': 'ก.ค.',
      'month_aug': 'ส.ค.',
      'month_sep': 'ก.ย.',
      'month_oct': 'ต.ค.',
      'month_nov': 'พ.ย.',
      'month_dec': 'ธ.ค.',

      // Onboarding
      'welcome_title': 'ยินดีต้อนรับสู่แอป BookBank',
      'welcome_subtitle':
          'บันทึกรายรับและรายจ่ายได้อย่างสะดวก และดูสถิติการใช้จ่ายโดยละเอียด',
      'next': 'ถัดไป',
      'select_currency': 'เลือกสกุลเงินของคุณ',
      'start': 'เริ่มต้น',
      'select_language': 'เลือกภาษา',
      'privacy_policy': 'นโยบายความเป็นส่วนตัว',
      'privacy_policy_title': 'นโยบายความเป็นส่วนตัว',
      'privacy_policy_content': '''
การเก็บข้อมูล:
เราเก็บข้อมูลขั้นต่ำที่จำเป็นสำหรับการทำงานของแอป รวมถึงบันทึกทางการเงินและการตั้งค่าแอปของคุณ

การจัดเก็บข้อมูล:
ข้อมูลทั้งหมดของคุณถูกจัดเก็บในเครื่องของคุณ เราไม่ได้จัดเก็บข้อมูลส่วนบุคคลใดๆ บนเซิร์ฟเวอร์ภายนอก

การใช้ข้อมูล:
ข้อมูลของคุณถูกใช้เพื่อการติดตามการเงินและให้บริการฟังก์ชันแอปเท่านั้น

การแบ่งปันข้อมูล:
เราไม่ได้แบ่งปันข้อมูลส่วนบุคคลของคุณกับบุคคลภายนอกใดๆ

ความปลอดภัย:
เราใช้มาตรการความปลอดภัยที่เหมาะสมเพื่อปกป้องข้อมูลของคุณ แต่โปรดทราบว่าไม่มีวิธีการส่งข้อมูลผ่านอินเทอร์เน็ตที่ปลอดภัย 100%

ติดต่อ:
หากคุณมีคำถามเกี่ยวกับนโยบายความเป็นส่วนตัวนี้ โปรดติดต่อผู้พัฒนา
      ''',
      'privacy_policy_close': 'ปิด',
      'currency_baht_display': '฿ - บาท (THB)',
      'currency_dollar_display': '\$ - ดอลลาร์ (USD)',
      'currency_yuan_display': '¥ - หยวน (CNY)',

      // transfer
      'transfer_amount_not_enough': 'ยอดเงินไม่พอ',
      'transfer_to': 'ย้ายไป',
      'transfer_title': 'ย้ายเงินระหว่างหมวดหมู่',
      'transfer_remaining': 'ยอดคงเหลือ',
      'transfer_money': 'ย้ายเงิน',
      'transfer_success': 'ย้ายเงินสำเร็จ',

      // Date time picker
      'select_date_time': 'เลือกวันที่และเวลา',
      'time': 'เวลา',
    },

    // Chinese (Simplified)
    'zh': {
      // Header / Menu
      'header_description': '记录您的收入和支出',
      'edit_group': '编辑分组',
      'dark_theme': '深色主题',
      'change_language': '更改语言',
      'change_currency': '更改货币',
      'about': '关于',
      'app_version': '版本',
      'app_description':
          '        款收支记账应用，可展示消费趋势，助您更高效地规划财务。在安全性方面，您的数据仅存储于您的设备中',
      'developer': '开发者',

      // Navigation
      'home': '首页',
      'record': '记录',
      'charts': '图表',
      'settings': '设置',

      // Language names
      'lang_thai': '泰语',
      'lang_english': '英语',
      'lang_chinese': '中文',

      // Currency names
      'currency_baht': '泰铢 (\u0e3f)',
      'currency_dollar': '美元 (\$)',
      'currency_yuan': '人民币 (¥)',

      // Dashboard
      'total_balance': '总余额',
      'valid_today': '今天有效',
      'bank': '银行',
      'cash': '现金',
      'income': '收入',
      'expense': '支出',
      'monthly_income': '月收入',
      'monthly_expense': '月支出',
      'cash_box': '钱箱',
      'transactions': '笔',
      'from': '来自',

      // Charts
      'dashboard': '仪表盘',
      'view_stats': '查看您的详细统计数据',
      'data_for_day': '今日数据',
      'income_expense_by_category': '按类别的收支情况',
      'monthly_data': '月度数据',
      'net': '净额',
      'not_enough_data': '没有足够数据',

      // Record screen
      'transaction_history': '交易历史',
      'filter': '筛选',
      'all': '全部',
      'search': '搜索...',
      'no_records': '未找到记录',
      'selected': '已选择',
      'records': '条记录',
      'amount': '金额',
      'position': '位置',
      'date': '日期',
      'view': '查看',
      'edit': '编辑',
      'delete': '删除',

      // Add transaction
      'add_list': '添加条目',
      'money_list': '资金类型',
      'money_position': '资金位置',
      'category': '分类',
      'save': '保存',

      // Transfer
      'transfer': '转账',
      'alternate': '切换',
      'anonymous': '匿名',

      // Record detail
      'money_list_label': '资金类型',
      'money_position_label': '资金位置',
      'group': '分类',
      'date_label': '日期',

      // Notebook
      'notebook': '笔记本',
      'notes_subtitle': '个人笔记和提醒',
      'add': '添加',
      'items': '条',
      'notes': '笔记',
      'recorded_on': '记录于',
      'confirm_delete': '确认删除',
      'confirm_delete_note': '您确定要删除笔记吗',
      'note_deleted': '笔记删除成功',
      'noRecord': '未找到记录',
      'addNotePrompt': '开始记录回忆或重要笔记，只需点击下方的添加笔记按钮。',

      // Action feedback
      'added_success': '添加成功',
      'updated_success': '更新成功',
      'deleted_success': '删除成功',
      'delete_confirm': '您确定要删除此记录吗？',

      // Popup
      'unallocated_funds': '未分配资金',
      'all_money_in_group': '分组中的所有资金',
      'this_is': '占 ',
      'out_of_total': ' 的总额',
      'target': '目标',

      // General
      'cancel': '取消',
      'confirm': '确认',
      'load_failed': '加载数据失败，请重试',
      'retry': '重试',

      // Please enter
      'please_enter_amount': '*请输入金额',

      // Group settings
      'icon': '图标',
      'color': '颜色',

      // Notebook actions
      'pin': '置顶',
      'unpin': '取消置顶',

      // Transaction fields
      'title': '标题',
      'content': '内容',

      // Note editor
      'addNote': '添加笔记',
      'note_color': '选择颜色标签',
      'enter_title': '请输入标题',
      'enter_note_title': '输入笔记标题...',
      'enter_note_content': '输入笔记内容...',
      'enter_content': '请输入笔记内容',

      // Note categories
      'category_all': '全部',
      'category_general': '一般',
      'category_finance': '财务',
      'category_goals': '目标',

      // Category suggestions
      'category_food': '餐饮',
      'category_transport': '交通',
      'category_shopping': '购物',
      'category_entertainment': '娱乐',
      'category_bills': '账单',

      // Note editor
      'edit_note': '编辑笔记',
      'save_changes': '保存更改',
      'create_note': '创建笔记',

      // Group settings
      'enable_savings_goal': '启用储蓄目标',
      'savings_goal_amount': '储蓄目标金额',

      // Month abbreviations
      'month_jan': '1月',
      'month_feb': '2月',
      'month_mar': '3月',
      'month_apr': '4月',
      'month_may': '5月',
      'month_jun': '6月',
      'month_jul': '7月',
      'month_aug': '8月',
      'month_sep': '9月',
      'month_oct': '10月',
      'month_nov': '11月',
      'month_dec': '12月',

      // Onboarding
      'welcome_title': '欢迎使用 BookBank 应用',
      'welcome_subtitle': '便捷记录您的收支，查看详细的消费统计',
      'next': '下一步',
      'select_currency': '选择您的货币',
      'start': '开始',
      'select_language': '选择语言',
      'privacy_policy': '隐私政策',
      'privacy_policy_title': '隐私政策',
      'privacy_policy_content': '''
数据收集：
我们收集应用程序运行所需的最少数据，包括您的财务记录和应用程序设置。

数据存储：
您的所有数据都存储在您的设备本地。我们不会在外部服务器上存储任何个人信息。

数据使用：
您的数据仅用于跟踪您的财务状况和提供应用程序功能。

数据共享：
我们不会与任何第三方共享您的个人数据。

安全：
我们采取合理的安全措施来保护您的数据，但请注意，没有任何互联网传输方法是100%安全的。

联系：
如果您对此隐私政策有任何疑问，请联系开发者。
      ''',
      'privacy_policy_close': '关闭',
      'currency_baht_display': '฿ - 泰铢 (THB)',
      'currency_dollar_display': '\$ - 美元 (USD)',
      'currency_yuan_display': '¥ - 人民币 (CNY)',

      // transfer
      'transfer_amount_not_enough': '余额不足',
      'transfer_to': '转到',
      'transfer_title': '转账',
      'transfer_remaining': '还剩下',
      'transfer_money': '转账',
      'transfer_success': '转账成功',

      // Date time picker
      'select_date_time': '选择日期和时间',
      'time': '时间',
    },
  };

  String translate(String key) {
    return _translations[languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  // Header / Menu
  String get headerDescription => translate('header_description');
  String get editGroup => translate('edit_group');
  String get darkTheme => translate('dark_theme');
  String get changeLanguage => translate('change_language');
  String get changeCurrency => translate('change_currency');
  String get about => translate('about');
  String get appVersion => translate('app_version');
  String get appDescription => translate('app_description');
  String get developer => translate('developer');

  // Navigation
  String get home => translate('home');
  String get record => translate('record');
  String get charts => translate('charts');
  String get settings => translate('settings');

  // Language names
  String get langThai => translate('lang_thai');
  String get langEnglish => translate('lang_english');
  String get langChinese => translate('lang_chinese');

  // Currency names
  String get currencyBaht => translate('currency_baht');
  String get currencyDollar => translate('currency_dollar');
  String get currencyYuan => translate('currency_yuan');

  // Dashboard
  String get totalBalance => translate('total_balance');
  String get validToday => translate('valid_today');
  String get bank => translate('bank');
  String get cash => translate('cash');
  String get income => translate('income');
  String get expense => translate('expense');
  String get monthlyIncome => translate('monthly_income');
  String get monthlyExpense => translate('monthly_expense');
  String get cashBox => translate('cash_box');
  String get transactions => translate('transactions');
  String get from => translate('from');

  // Charts
  String get dashboard => translate('dashboard');
  String get viewStats => translate('view_stats');
  String get dataForDay => translate('data_for_day');
  String get incomeExpenseByCategory => translate('income_expense_by_category');
  String get monthlyData => translate('monthly_data');
  String get net => translate('net');
  String get notEnoughData => translate('not_enough_data');

  // Record screen
  String get transactionHistory => translate('transaction_history');
  String get filter => translate('filter');
  String get all => translate('all');
  String get search => translate('search');
  String get noRecords => translate('no_records');
  String get selected => translate('selected');
  String get records => translate('records');
  String get amount => translate('amount');
  String get position => translate('position');
  String get date => translate('date');
  String get view => translate('view');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get loadFailed => translate('load_failed');
  String get retry => translate('retry');

  // Add transaction
  String get addList => translate('add_list');
  String get moneyList => translate('money_list');
  String get moneyPosition => translate('money_position');
  String get category => translate('category');
  String get save => translate('save');

  // Transfer
  String get transfer => translate('transfer');
  String get alternate => translate('alternate');
  String get anonymous => translate('anonymous');

  // Record detail
  String get moneyListLabel => translate('money_list_label');
  String get moneyPositionLabel => translate('money_position_label');
  String get group => translate('group');
  String get dateLabel => translate('date_label');

  // Notebook
  String get notebook => translate('notebook');
  String get notesSubtitle => translate('notes_subtitle');
  String get add => translate('add');
  String get items => translate('items');
  String get notes => translate('notes');
  String get recordedOn => translate('recorded_on');
  String get confirmDelete => translate('confirm_delete');
  String get confirmDeleteNote => translate('confirm_delete_note');
  String get noteDeleted => translate('note_deleted');
  String get noRecord => translate('noRecord');
  String get addNotePrompt => translate('addNotePrompt');

  // Action feedback
  String get addedSuccess => translate('added_success');
  String get updatedSuccess => translate('updated_success');
  String get deletedSuccess => translate('deleted_success');
  String get deleteConfirm => translate('delete_confirm');

  // Popup
  String get unallocatedFunds => translate('unallocated_funds');
  String get allMoneyInGroup => translate('all_money_in_group');
  String get thisIs => translate('this_is');
  String get outOfTotal => translate('out_of_total');
  String get target => translate('target');

  // General
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get pleaseEnterAmount => translate('please_enter_amount');

  // Group settings
  String get icon => translate('icon');
  String get color => translate('color');

  // Notebook actions
  String get pin => translate('pin');
  String get unpin => translate('unpin');

  // Transaction fields
  String get title => translate('title');
  String get content => translate('content');

  // Note editor
  String get addNote => translate('addNote');
  String get noteColor => translate('note_color');
  String get enterTitle => translate('enter_title');
  String get enterNoteTitle => translate('enter_note_title');
  String get enterNoteContent => translate('enter_note_content');
  String get enterContent => translate('enter_content');

  // Note categories
  String get categoryAll => translate('category_all');
  String get categoryGeneral => translate('category_general');
  String get categoryFinance => translate('category_finance');
  String get categoryGoals => translate('category_goals');

  // Category suggestions
  String get categoryFood => translate('category_food');
  String get categoryTransport => translate('category_transport');
  String get categoryShopping => translate('category_shopping');
  String get categoryEntertainment => translate('category_entertainment');
  String get categoryBills => translate('category_bills');

  // Note editor
  String get editNote => translate('edit_note');
  String get saveChanges => translate('save_changes');
  String get createNote => translate('create_note');

  // Group settings
  String get enableSavingsGoal => translate('enable_savings_goal');
  String get savingsGoalAmount => translate('savings_goal_amount');

  // Month abbreviations
  String get monthJan => translate('month_jan');
  String get monthFeb => translate('month_feb');
  String get monthMar => translate('month_mar');
  String get monthApr => translate('month_apr');
  String get monthMay => translate('month_may');
  String get monthJun => translate('month_jun');
  String get monthJul => translate('month_jul');
  String get monthAug => translate('month_aug');
  String get monthSep => translate('month_sep');
  String get monthOct => translate('month_oct');
  String get monthNov => translate('month_nov');
  String get monthDec => translate('month_dec');

  // Onboarding
  String get welcomeTitle => translate('welcome_title');
  String get welcomeSubtitle => translate('welcome_subtitle');
  String get next => translate('next');
  String get selectCurrency => translate('select_currency');
  String get start => translate('start');
  String get selectLanguage => translate('select_language');
  String get privacyPolicy => translate('privacy_policy');
  String get privacyPolicyTitle => translate('privacy_policy_title');
  String get privacyPolicyContent => translate('privacy_policy_content');
  String get privacyPolicyClose => translate('privacy_policy_close');
  String get currencyBahtDisplay => translate('currency_baht_display');
  String get currencyDollarDisplay => translate('currency_dollar_display');
  String get currencyYuanDisplay => translate('currency_yuan_display');

  // transfer
  String get transferAmountNotEnough => translate('transfer_amount_not_enough');
  String get transferTo => translate('transfer_to');
  String get transferTitle => translate('transfer_title');
  String get transferRemaining => translate('transfer_remaining');
  String get transferMoney => translate('transfer_money');
  String get transferSuccess => translate('transfer_success');

  // Date time picker
  String get selectDateTime => translate('select_date_time');
  String get time => translate('time');
}
