# Learn & Earn - Deployment Guide

## 🚀 Changes Successfully Committed

All fixes have been committed and pushed to GitHub:
- **Commit**: `ba2ccd4` - "Fix API endpoints and improve security"
- **Repository**: https://github.com/Dawinz/learn-and-earn
- **Branch**: main

---

## 📦 What Was Changed

### Backend (`learn-earn-backend`)
✅ Fixed API endpoint structure
✅ Added Version model and controller
✅ Added Admin model with bcrypt authentication
✅ Added createAdmin script
✅ Updated package.json with new script

### Mobile App (`learn_earn_mobile`)
✅ Fixed API endpoint paths
✅ Standardized health check endpoint

### Admin Panel (`learn-earn-admin`)
✅ Version Management page added
✅ Analytics improvements

---

## 🔄 Render Deployment Status

**Current Backend URL**: https://learn-and-earn-04ok.onrender.com

### Auto-Deployment
Render should automatically detect the GitHub push and start deploying within 1-2 minutes.

### Manual Trigger (if needed)
1. Go to https://dashboard.render.com
2. Find "learn-earn-backend" service
3. Click "Manual Deploy" → "Deploy latest commit"

### Checking Deployment Status
```bash
# Check if backend is healthy
curl https://learn-and-earn-04ok.onrender.com/health

# Check if new version endpoint exists (after deployment)
curl https://learn-and-earn-04ok.onrender.com/api/version
```

---

## 👤 Creating Admin User (After Deployment)

### Option 1: Render Shell (Recommended)

1. **Access Render Dashboard**
   - Go to https://dashboard.render.com
   - Select `learn-earn-backend` service

2. **Open Shell**
   - Click "Shell" tab in the service dashboard
   - This gives you terminal access to the deployed container

3. **Run Create Admin Command**
   ```bash
   npm run create:admin <username> <email> <password> <role>

   # Example:
   npm run create:admin dawson admin@learnearn.com YourSecurePassword123! super_admin
   ```

4. **Save Credentials Securely**
   - Username: `dawson`
   - Email: `admin@learnearn.com`
   - Password: `YourSecurePassword123!` (change this!)
   - Role: `super_admin`

### Option 2: MongoDB Direct Insert

If Render Shell doesn't work, you can directly insert into MongoDB:

1. **Connect to MongoDB Atlas**
   - Get connection string from Render dashboard environment variables

2. **Insert Admin Document**
   ```javascript
   // First, hash the password using bcrypt
   const bcrypt = require('bcryptjs');
   const password = 'YourSecurePassword123!';
   const hashedPassword = await bcrypt.hash(password, 10);

   // Then insert into admins collection
   db.admins.insertOne({
     username: "dawson",
     email: "admin@learnearn.com",
     password: hashedPassword,
     role: "super_admin",
     isActive: true,
     createdAt: new Date()
   });
   ```

### Option 3: Local Script with Production DB

1. **Update local `.env`**
   ```env
   MONGO_URL=<your_production_mongodb_url>
   JWT_SECRET=<your_production_jwt_secret>
   ```

2. **Run Create Admin Script**
   ```bash
   cd learn-earn-backend
   npm run create:admin dawson admin@learnearn.com YourSecurePassword123! super_admin
   ```

3. **Restore local `.env`**
   - Change back to local MongoDB URL

---

## 🧪 Testing After Deployment

### 1. Test Version Endpoint (Public)
```bash
curl https://learn-and-earn-04ok.onrender.com/api/version
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "minimumVersion": "1.0.0",
    "minimumBuildNumber": 1,
    "latestVersion": "1.0.0",
    "latestBuildNumber": 1,
    "forceUpdate": false,
    ...
  }
}
```

### 2. Test Admin Login
```bash
curl -X POST https://learn-and-earn-04ok.onrender.com/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"dawson","password":"YourSecurePassword123!"}'
```

**Expected Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "...",
    "username": "dawson",
    "email": "admin@learnearn.com",
    "role": "super_admin"
  }
}
```

### 3. Test Protected Endpoint (with token)
```bash
# Save token from login response
TOKEN="eyJhbGciOiJIUzI1NiIs..."

curl https://learn-and-earn-04ok.onrender.com/api/admin/dashboard \
  -H "Authorization: Bearer $TOKEN"
```

### 4. Test Mobile App Endpoints

**Earnings (Record)**
```bash
curl -X POST https://learn-and-earn-04ok.onrender.com/api/earnings/record \
  -H "X-Device-ID: test-device-123" \
  -H "Content-Type: application/json" \
  -d '{"source":"lesson","amount":10,"timestamp":"2025-10-16T10:00:00Z"}'
```

**Earnings (History)**
```bash
curl https://learn-and-earn-04ok.onrender.com/api/earnings/history \
  -H "X-Device-ID: test-device-123"
```

**Payouts (History)**
```bash
curl https://learn-and-earn-04ok.onrender.com/api/payouts/history \
  -H "X-Device-ID: test-device-123"
```

---

## 🎯 Admin Panel Testing

### 1. Update Admin Panel Login

The admin panel may still be cached. Clear browser cache or use incognito mode.

**Login URL**: https://learn-earn-admin.vercel.app/login

**Credentials**: Use the admin credentials you created above

### 2. Test Version Management

After logging in:
1. Navigate to "Version Management" in the sidebar
2. Update minimum version to `1.0.1`
3. Save changes
4. Refresh page - verify changes persist

### 3. Test Dashboard

- View budget overview
- Check pending payouts
- Verify all stats load correctly

---

## 🔍 Troubleshooting

### Backend Not Deploying

1. **Check Render Logs**
   - Go to Render Dashboard → learn-earn-backend → Logs
   - Look for build errors

2. **Common Issues**
   - TypeScript compilation errors
   - Missing dependencies
   - Environment variable issues

3. **Force Rebuild**
   - Clear build cache in Render
   - Trigger manual deploy

### Version Endpoint Returns 404

- Deployment hasn't completed yet (wait 2-5 minutes)
- Check Render logs for errors
- Verify `/api/version` route is registered in `index.ts`

### Admin Login Fails

**Error: "Invalid credentials"**
- Admin user hasn't been created yet
- Wrong username/password
- Check MongoDB for admins collection

**Error: "Route not found"**
- Deployment hasn't completed
- Old code still running

### Mobile App Errors

**Earnings/Payouts Fail**
- Check device authentication
- Verify X-Device-ID header is sent
- Check backend logs for errors

---

## 📊 Monitoring

### Key Metrics to Watch

1. **Deployment Time**: 3-5 minutes typical
2. **Health Check**: Should return `{"status":"OK"}`
3. **Response Times**: < 500ms for most endpoints
4. **Error Rate**: Should be < 1%

### Useful Commands

```bash
# Monitor deployment (run every 30 seconds)
watch -n 30 'curl -s https://learn-and-earn-04ok.onrender.com/api/version | head -50'

# Check backend uptime
curl -s https://learn-and-earn-04ok.onrender.com/health | grep uptime

# Test all critical endpoints
bash test_endpoints.sh  # Create this script if needed
```

---

## ✅ Final Checklist

- [ ] Render deployment completed successfully
- [ ] Version endpoint returns valid JSON
- [ ] Admin user created in database
- [ ] Admin login works and returns JWT token
- [ ] Admin dashboard loads data correctly
- [ ] Version Management page works
- [ ] Mobile app endpoints (earnings, payouts) work
- [ ] Health check returns OK
- [ ] All environment variables set correctly

---

## 🔐 Security Reminders

1. **Change Default Passwords**: Use strong, unique passwords
2. **Secure JWT_SECRET**: Generate with `openssl rand -base64 32`
3. **Backup Credentials**: Store securely (1Password, etc.)
4. **Monitor Access**: Check admin login times regularly
5. **Rotate Secrets**: Change JWT_SECRET periodically

---

## 📞 Support

If you encounter issues:

1. Check FIXES_APPLIED.md for implementation details
2. Review Render logs for backend errors
3. Test endpoints with curl commands above
4. Verify MongoDB connection and data

---

**Last Updated**: October 16, 2025
**Deployment Status**: Pending Render auto-deploy
**Next Action**: Wait for Render deployment (2-5 mins) then create admin user
