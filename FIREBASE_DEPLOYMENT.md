# Firebase Deployment Guide

This guide explains how to deploy Firestore security rules and indexes to your Firebase project.

## Prerequisites

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project (if not already done):
   ```bash
   firebase init
   ```
   - Select "Firestore" when prompted
   - Use existing project: `myportfolio-594b1`

## Deploy Security Rules

1. Review the security rules in `firestore.rules`

2. Deploy the rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

3. Verify deployment:
   - Go to Firebase Console → Firestore Database → Rules
   - Check that your rules are active

## Deploy Indexes

1. Review the indexes in `firestore.indexes.json`

2. Deploy the indexes:
   ```bash
   firebase deploy --only firestore:indexes
   ```

3. **Important:** Index creation can take several minutes. Check status:
   ```bash
   firebase firestore:indexes
   ```

4. Wait for indexes to be built:
   - Go to Firebase Console → Firestore Database → Indexes
   - Wait for all indexes to show "Enabled" status
   - This can take 5-10 minutes

## Setting Up Admin Access

To enable admin access for authenticated users:

1. Go to Firebase Console → Authentication → Users
2. Find your user account
3. Go to Firebase Console → Functions → Custom Claims (or use Admin SDK)
4. Set custom claim `admin: true` for your user

**Using Firebase Admin SDK (Node.js):**
```javascript
const admin = require('firebase-admin');
admin.initializeApp();

admin.auth().setCustomUserClaims('USER_UID', { admin: true });
```

## Environment Variables

For production, use environment variables instead of hardcoded defaults:

1. Create a `.env` file (add to `.gitignore`):
   ```
   FIREBASE_API_KEY=your_api_key
   FIREBASE_AUTH_DOMAIN=your_auth_domain
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_STORAGE_BUCKET=your_storage_bucket
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   FIREBASE_APP_ID=your_app_id
   ```

2. Run with environment variables:
   ```bash
   flutter run --dart-define=FIREBASE_API_KEY=your_key \
              --dart-define=FIREBASE_AUTH_DOMAIN=your_domain \
              --dart-define=FIREBASE_PROJECT_ID=your_project_id \
              --dart-define=FIREBASE_STORAGE_BUCKET=your_bucket \
              --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
              --dart-define=FIREBASE_APP_ID=your_app_id
   ```

## Testing

After deployment, test your security rules:

1. Try accessing Firestore from an unauthenticated user (should fail for writes)
2. Try accessing as an authenticated non-admin user (should fail for admin operations)
3. Verify public reads work correctly

## Troubleshooting

### Index Build Fails
- Check that all fields in queries exist in your documents
- Verify field types match (string vs number)
- Check Firebase Console for specific error messages

### Security Rules Not Working
- Check Firebase Console → Firestore → Rules for syntax errors
- Use Rules Playground in Firebase Console to test rules
- Check that custom claims are set correctly

### Environment Variables Not Working
- Verify `--dart-define` flags are correct
- Check that `String.fromEnvironment` is used correctly
- For web builds, use `--dart-define-from-file` with a JSON file

