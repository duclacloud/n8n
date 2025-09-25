# 🔧 Hướng Dẫn Sử Dụng N8N-Offline Demo Workflow

## 🎯 Tổng Quan Workflow

Workflow này minh họa khả năng của N8N-Offline trong việc:
- ✅ Nhận dữ liệu qua Webhook
- ✅ Xử lý và validate dữ liệu
- ✅ Tạo Google Sheets tự động
- ✅ Gửi thông báo qua Slack
- ✅ Trả về response JSON

## 🏗️ Kiến Trúc Workflow

```
Webhook → Log Start → Check Action → Process Data → Create Sheet → Append Data → Notify Slack → Response
                           ↓
                    Error Response
```

## 📥 Cách Import Workflow

### Bước 1: Truy cập N8N
```bash
# Khởi động N8N-Offline
./n8n.sh start

# Truy cập
http://localhost:5678
```

### Bước 2: Import Workflow
1. Đăng nhập vào N8N
2. Click **"Add workflow"**
3. Click menu **"⋯"** → **"Import from file"**
4. Chọn file `sample-workflow.json`
5. Click **"Import"**

## ⚙️ Cấu Hình Credentials

### 1. Google Sheets API
```bash
# Tạo Google Cloud Project
1. Truy cập: https://console.cloud.google.com
2. Tạo project mới
3. Enable Google Sheets API
4. Tạo Service Account
5. Download JSON key file
```

**Trong N8N:**
- Credentials → Add → Google Sheets API
- Upload JSON key file
- Test connection

### 2. Slack Integration
```bash
# Tạo Slack App
1. Truy cập: https://api.slack.com/apps
2. Create New App
3. Add Bot Token Scopes: chat:write
4. Install to Workspace
5. Copy Bot User OAuth Token
```

**Trong N8N:**
- Credentials → Add → Slack
- Paste OAuth Token
- Test connection

## 🚀 Test Workflow

### Bước 1: Activate Workflow
1. Mở workflow đã import
2. Click **"Active"** toggle
3. Copy Webhook URL

### Bước 2: Test với cURL
```bash
# Test thành công
curl -X POST http://localhost:5678/webhook/webhook-demo \
  -H "Content-Type: application/json" \
  -d '{
    "action": "process_data",
    "data": [
      {
        "id": 1,
        "name": "Nguyễn Văn A",
        "email": "nguyenvana@example.com"
      },
      {
        "id": 2,
        "name": "Trần Thị B",
        "email": "tranthib@example.com"
      }
    ]
  }'

# Test lỗi (action không hợp lệ)
curl -X POST http://localhost:5678/webhook/webhook-demo \
  -H "Content-Type: application/json" \
  -d '{
    "action": "invalid_action",
    "data": []
  }'
```

### Bước 3: Kiểm Tra Kết Quả
- ✅ Google Sheets được tạo tự động
- ✅ Dữ liệu được append vào sheet
- ✅ Thông báo gửi đến Slack
- ✅ Response JSON trả về

## 📊 Dữ Liệu Mẫu

### Input Format
```json
{
  "action": "process_data",
  "data": [
    {
      "id": 1,
      "name": "Tên người dùng",
      "email": "email@example.com",
      "phone": "0123456789",
      "department": "IT"
    }
  ]
}
```

### Output Format
```json
{
  "success": true,
  "message": "Dữ liệu đã được xử lý thành công",
  "processedCount": 2,
  "spreadsheetUrl": "https://docs.google.com/spreadsheets/d/...",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## 🔧 Tùy Chỉnh Workflow

### 1. Thêm Validation Rules
```javascript
// Trong node "Process Data"
if (!data.name || data.name.length < 2) {
  processed.errors = processed.errors || [];
  processed.errors.push('Tên phải có ít nhất 2 ký tự');
}

if (!data.phone || !/^[0-9]{10,11}$/.test(data.phone)) {
  processed.errors = processed.errors || [];
  processed.errors.push('Số điện thoại không hợp lệ');
}
```

### 2. Thêm Database Storage
```yaml
# Thêm vào docker-compose.yml
postgres:
  image: postgres:15-alpine
  environment:
    - POSTGRES_DB=n8n_data
    - POSTGRES_USER=n8n
    - POSTGRES_PASSWORD=secure_password
```

### 3. Thêm Email Notification
```javascript
// Thêm node "Send Email"
{
  "parameters": {
    "fromEmail": "noreply@company.com",
    "toEmail": "admin@company.com",
    "subject": "N8N Workflow Completed",
    "emailFormat": "html",
    "message": "<h2>Workflow hoàn thành</h2><p>Đã xử lý {{$node['Process Data'].json.length}} records</p>"
  },
  "name": "Send Email",
  "type": "n8n-nodes-base.emailSend"
}
```

## 📈 Monitoring & Debugging

### 1. Xem Execution History
- Workflow → Executions tab
- Click vào execution để xem chi tiết
- Kiểm tra data flow giữa các nodes

### 2. Debug Mode
```javascript
// Thêm vào đầu mỗi Code node
console.log('Node Input:', JSON.stringify($input.all(), null, 2));
console.log('Node Parameters:', JSON.stringify($node.parameters, null, 2));
```

### 3. Error Handling
```javascript
// Wrap code trong try-catch
try {
  // Main logic here
  return processedData;
} catch (error) {
  console.error('Error in node:', error.message);
  return [{
    json: {
      error: true,
      message: error.message,
      timestamp: new Date().toISOString()
    }
  }];
}
```

## 🚨 Troubleshooting

### Lỗi Thường Gặp

#### 1. Webhook không hoạt động
```bash
# Kiểm tra container
docker compose ps
docker compose logs n8n

# Kiểm tra port
netstat -tulpn | grep 5678
```

#### 2. Google Sheets API lỗi
- Kiểm tra Service Account permissions
- Verify API enabled trong Google Cloud Console
- Test credentials trong N8N

#### 3. Slack notification không gửi
- Kiểm tra Bot Token
- Verify bot được add vào channel
- Test với channel public trước

### Performance Tips

#### 1. Optimize cho Large Data
```javascript
// Xử lý batch thay vì từng item
const batchSize = 100;
const batches = [];

for (let i = 0; i < inputData.length; i += batchSize) {
  batches.push(inputData.slice(i, i + batchSize));
}

// Process each batch
for (const batch of batches) {
  // Process batch logic
}
```

#### 2. Caching Results
```javascript
// Cache kết quả để tránh xử lý lại
const cacheKey = `processed_${JSON.stringify(data).hashCode()}`;
const cached = $workflow.static.cache?.[cacheKey];

if (cached) {
  return cached;
}

// Process and cache
const result = processData(data);
$workflow.static.cache = $workflow.static.cache || {};
$workflow.static.cache[cacheKey] = result;

return result;
```

## 🎯 Mở Rộng Workflow

### 1. Multi-step Approval
- Thêm node Manual Trigger cho approval
- Lưu pending requests vào database
- Email notification cho approvers

### 2. File Processing
- Upload files qua webhook
- Process CSV/Excel files
- Generate reports

### 3. Integration với ERP/CRM
- Connect với SAP, Salesforce
- Sync data bidirectional
- Real-time updates

## 📚 Tài Liệu Tham Khảo

- [N8N Official Docs](https://docs.n8n.io/)
- [Google Sheets API](https://developers.google.com/sheets/api)
- [Slack API](https://api.slack.com/)
- [Docker Compose](https://docs.docker.com/compose/)

---

**🎉 Chúc bạn thành công với N8N-Offline!**