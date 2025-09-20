# KawaiiChain Wallet 登录功能测试指南

## 测试概述

本文档详细说明如何测试 KawaiiChain Wallet 移动应用的登录功能，包括后端API和前端UI的集成测试。

## 环境准备

### 1. 后端服务启动

确保以下服务已启动并运行在正确端口：

- **PostgreSQL**: 端口 5432
- **Redis**: 端口 6379
- **kawaii-user**: 端口 8082
- **kawaii-gateway**: 端口 8080

```bash
# 1. 启动数据库服务
docker-compose up -d postgres redis

# 2. 启动用户服务
cd kawaii-server/kawaii-user
mvn spring-boot:run

# 3. 启动网关服务 (如果已配置)
cd kawaii-server/kawaii-gateway
mvn spring-boot:run
```

### 2. 移动端环境

```bash
cd kawaii-mobile/kawaii_mobile_app

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## 测试用例

### 一、用户注册测试

#### 1.1 手机号注册
- [ ] 输入有效手机号
- [ ] 点击"获取验证码"
- [ ] 检查后端日志确认验证码发送
- [ ] 输入正确验证码和用户信息
- [ ] 验证注册成功并自动登录

#### 1.2 邮箱注册
- [ ] 输入有效邮箱地址
- [ ] 点击"获取验证码"
- [ ] 检查后端日志确认验证码发送
- [ ] 输入正确验证码和用户信息
- [ ] 验证注册成功并自动登录

#### 1.3 注册验证
- [ ] 用户名格式验证
- [ ] 密码强度验证
- [ ] 确认密码匹配验证
- [ ] 用户协议勾选验证

### 二、用户登录测试

#### 2.1 密码登录
- [ ] 使用用户名 + 密码登录
- [ ] 使用邮箱 + 密码登录
- [ ] 使用手机号 + 密码登录
- [ ] 验证"记住我"功能
- [ ] 测试错误密码处理
- [ ] 测试账户锁定机制

#### 2.2 OTP登录
- [ ] 输入注册手机号
- [ ] 点击"获取验证码"
- [ ] 检查验证码发送
- [ ] 输入正确验证码登录
- [ ] 测试验证码过期处理
- [ ] 测试错误验证码处理

#### 2.3 生物识别登录
- [ ] 首次登录后提示启用生物识别
- [ ] 用户选择启用，验证生物识别设置
- [ ] 后续登录显示生物识别选项
- [ ] 点击指纹/面部识别按钮
- [ ] 验证生物识别认证流程
- [ ] 测试生物识别登录成功
- [ ] 测试生物识别登录失败处理

### 三、安全功能测试

#### 3.1 Token管理
- [ ] 验证JWT Token生成
- [ ] 验证Token过期处理
- [ ] 验证Refresh Token机制
- [ ] 验证Token自动刷新

#### 3.2 审计日志
- [ ] 检查登录成功日志记录
- [ ] 检查登录失败日志记录
- [ ] 检查账户锁定日志记录
- [ ] 验证敏感信息脱敏

#### 3.3 账户安全
- [ ] 测试连续登录失败锁定
- [ ] 验证锁定时间计算
- [ ] 测试锁定自动解除
- [ ] 验证IP地址记录

### 四、UI/UX测试

#### 4.1 界面响应
- [ ] 登录表单输入验证
- [ ] 错误消息显示
- [ ] 加载状态指示
- [ ] 按钮状态切换

#### 4.2 导航流程
- [ ] 登录成功跳转到主页
- [ ] "注册"按钮跳转到注册页面
- [ ] "忘记密码"按钮跳转功能
- [ ] 返回按钮功能

#### 4.3 生物识别UI
- [ ] 生物识别按钮显示状态
- [ ] 未启用时的提示信息
- [ ] 启用生物识别的对话框
- [ ] 生物识别认证界面

### 五、错误处理测试

#### 5.1 网络错误
- [ ] 无网络连接时的处理
- [ ] 服务器连接超时处理
- [ ] API请求失败处理

#### 5.2 数据验证错误
- [ ] 无效手机号格式
- [ ] 无效邮箱格式
- [ ] 弱密码提示
- [ ] 必填字段验证

#### 5.3 业务逻辑错误
- [ ] 用户不存在
- [ ] 密码错误
- [ ] 账户被锁定
- [ ] 验证码错误/过期

## API测试

### 1. 注册API测试

```bash
# 发送注册验证码
curl -X POST http://localhost:8080/users/register/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "target": "13800138000",
    "type": "phone",
    "purpose": "register"
  }'

# 验证OTP并注册
curl -X POST http://localhost:8080/users/register/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "target": "13800138000",
    "type": "phone",
    "otpCode": "123456",
    "username": "testuser",
    "password": "Test123!@#",
    "confirmPassword": "Test123!@#",
    "agreeToTerms": true
  }'
```

### 2. 登录API测试

```bash
# 密码登录
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "testuser",
    "password": "Test123!@#"
  }'

# 发送登录验证码
curl -X POST http://localhost:8080/auth/send-login-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "13800138000"
  }'

# OTP登录
curl -X POST http://localhost:8080/auth/login/otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "13800138000",
    "otpCode": "123456"
  }'

# 刷新Token
curl -X POST http://localhost:8080/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN"
  }'

# 登出
curl -X POST http://localhost:8080/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 3. 用户信息API测试

```bash
# 获取用户信息
curl -X GET http://localhost:8080/users/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 数据库验证

### 1. 用户数据验证

```sql
-- 检查用户记录
SELECT user_id, username, phone, email, status, created_at
FROM users
WHERE username = 'testuser';

-- 检查用户资料
SELECT profile_id, user_id, display_name, language, timezone
FROM user_profiles
WHERE user_id = 'USER_ID';
```

### 2. 审计日志验证

```sql
-- 检查登录日志
SELECT log_id, user_id, action, resource_type, success, ip_address, created_at
FROM audit_logs
WHERE user_id = 'USER_ID'
ORDER BY created_at DESC
LIMIT 10;
```

## 性能测试

### 1. 响应时间测试
- [ ] 登录API响应时间 < 2秒
- [ ] 注册API响应时间 < 3秒
- [ ] Token刷新响应时间 < 1秒

### 2. 并发测试
- [ ] 50个并发登录请求
- [ ] 验证数据库连接池
- [ ] 验证Redis缓存性能

## 安全测试

### 1. 认证安全
- [ ] SQL注入防护
- [ ] XSS防护
- [ ] CSRF防护
- [ ] 暴力破解防护

### 2. 数据安全
- [ ] 密码哈希验证
- [ ] 敏感数据脱敏
- [ ] 生物识别数据加密
- [ ] 通信加密(HTTPS)

## 移动端特定测试

### 1. 设备兼容性
- [ ] Android 8.0+ 设备
- [ ] iOS 12.0+ 设备
- [ ] 不同屏幕尺寸适配

### 2. 生物识别
- [ ] 指纹识别设备
- [ ] 面部识别设备
- [ ] 权限申请流程
- [ ] 生物识别失败处理

### 3. 离线处理
- [ ] 网络断开时的用户反馈
- [ ] 缓存数据处理
- [ ] 重连后数据同步

## 测试报告模板

### 测试执行记录

| 测试用例 | 执行结果 | 实际结果 | 预期结果 | 备注 |
|---------|---------|---------|---------|------|
| 用户名密码登录 | ✅ | 登录成功，跳转主页 | 登录成功，跳转主页 | - |
| 手机号OTP登录 | ✅ | 登录成功，跳转主页 | 登录成功，跳转主页 | - |
| 生物识别登录 | ✅ | 指纹认证成功登录 | 生物识别认证成功 | - |
| 连续登录失败 | ✅ | 5次失败后账户锁定 | 达到限制后锁定账户 | - |

### 问题记录

| 问题ID | 问题描述 | 严重程度 | 状态 | 修复说明 |
|--------|---------|---------|------|---------|
| BUG-001 | 网络超时时loading不消失 | 中 | 已修复 | 添加超时处理 |

### 测试结论

- **总体评估**: ✅ 通过
- **核心功能**: ✅ 正常
- **安全功能**: ✅ 正常
- **性能表现**: ✅ 达标
- **用户体验**: ✅ 良好

**建议**: 功能实现完整，安全措施得当，可以进入下一开发阶段。

## 注意事项

1. **测试数据**: 使用测试环境数据，避免污染生产数据
2. **安全性**: 测试完成后清理测试用户和敏感数据
3. **文档更新**: 发现问题时及时更新测试用例
4. **自动化**: 考虑将核心测试用例自动化
5. **监控**: 在测试过程中监控系统资源使用情况

## 自动化测试建议

```bash
# 运行Flutter集成测试
flutter test integration_test/

# 运行后端单元测试
cd kawaii-server/kawaii-user
mvn test

# 运行API测试
newman run postman-collection.json
```