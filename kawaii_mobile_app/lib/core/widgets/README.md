# UI 组件库规范

## 设计原则

### 1. 一致性 (Consistency)
- 所有组件遵循统一的设计语言
- 使用 `AppTheme` 中定义的颜色、间距、圆角
- 保持交互行为的一致性

### 2. 可复用性 (Reusability)
- 组件高度抽象，支持多种配置
- 通过参数控制外观和行为
- 避免硬编码样式

### 3. 可访问性 (Accessibility)
- 支持屏幕阅读器
- 适当的点击区域大小（最小44x44）
- 清晰的视觉反馈

### 4. 性能优化 (Performance)
- 使用 `const` 构造函数
- 避免不必要的 rebuild
- 合理使用 `StatelessWidget` 和 `StatefulWidget`

---

## 组件分类

### 基础组件 (Basic Components)

#### 1. 按钮类
- `AppButton` - 主按钮
- `AppOutlinedButton` - 描边按钮
- `AppTextButton` - 文本按钮
- `AppIconButton` - 图标按钮

#### 2. 输入类
- `AppTextField` - 通用输入框
- `AppPasswordField` - 密码输入框
- `AppSearchField` - 搜索输入框
- `AppPinCodeField` - PIN码输入框

#### 3. 展示类
- `AppCard` - 卡片
- `AppAvatar` - 头像
- `AppBadge` - 徽章
- `AppChip` - 标签
- `AppDivider` - 分割线

### 反馈组件 (Feedback Components)

- `AppToast` - 轻提示
- `AppDialog` - 对话框
- `AppBottomSheet` - 底部弹窗
- `AppLoading` - 加载指示器
- `AppEmptyState` - 空状态

### 导航组件 (Navigation Components)

- `AppTabBar` - 标签栏
- `AppBottomNavigation` - 底部导航
- `AppAppBar` - 顶部导航栏

### 业务组件 (Business Components)

- `AssetCard` - 资产卡片
- `TransactionItem` - 交易列表项
- `WalletCard` - 钱包卡片
- `QRCodeWidget` - 二维码组件
- `AddressDisplay` - 地址展示

---

## 使用规范

### 命名规范

```dart
// ✅ 好的命名
class AppButton extends StatelessWidget {}
class AssetCard extends StatelessWidget {}

// ❌ 不好的命名
class MyButton extends StatelessWidget {}
class Card1 extends StatelessWidget {}
```

### 参数规范

```dart
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed, // required 参数在前
    required this.child,
    this.type = ButtonType.primary, // 可选参数在后，提供默认值
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
}
```

### 主题适配

所有组件应自动适配浅色/深色主题：

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Container(
    color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
    child: ...,
  );
}
```

---

## 常用组件示例

### AppButton

```dart
// 主按钮
AppButton(
  onPressed: () {},
  child: const Text('确认'),
)

// 加载状态
AppButton(
  isLoading: true,
  onPressed: () {},
  child: const Text('提交中...'),
)

// 禁用状态
AppButton(
  isDisabled: true,
  onPressed: null,
  child: const Text('已提交'),
)
```

### AppTextField

```dart
AppTextField(
  label: '邮箱地址',
  hintText: '请输入邮箱',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }
    return null;
  },
)
```

### AppCard

```dart
AppCard(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('卡片内容'),
    ],
  ),
)
```

---

## 间距使用指南

使用 `AppTheme` 中定义的标准间距：

```dart
// ❌ 避免魔法数字
Padding(padding: EdgeInsets.all(16))

// ✅ 使用主题间距
Padding(padding: EdgeInsets.all(AppTheme.spacingMd))

// 常用间距
SizedBox(height: AppTheme.spacingSm)   // 8
SizedBox(height: AppTheme.spacingMd)   // 16
SizedBox(height: AppTheme.spacingLg)   // 24
```

---

## 颜色使用指南

```dart
// 品牌色
Container(color: AppTheme.primaryColor)

// 功能色
Text('成功', style: TextStyle(color: AppTheme.successColor))
Text('错误', style: TextStyle(color: AppTheme.errorColor))

// 文字色
Text('主文字', style: TextStyle(color: AppTheme.textPrimary))
Text('次文字', style: TextStyle(color: AppTheme.textSecondary))

// 资产涨跌
Text('+2.34%', style: TextStyle(color: AppTheme.priceUp))
Text('-1.23%', style: TextStyle(color: AppTheme.priceDown))
```

---

## 圆角使用指南

```dart
BorderRadius.circular(AppTheme.radiusSm)   // 8 - 小组件
BorderRadius.circular(AppTheme.radiusMd)   // 12 - 卡片、按钮
BorderRadius.circular(AppTheme.radiusLg)   // 16 - 大卡片
BorderRadius.circular(AppTheme.radiusFull) // 999 - 圆形
```

---

## 阴影使用指南

```dart
Container(
  decoration: BoxDecoration(
    boxShadow: AppTheme.shadowSm, // 小阴影
    // boxShadow: AppTheme.shadowMd, // 中阴影
    // boxShadow: AppTheme.shadowLg, // 大阴影
  ),
)
```
