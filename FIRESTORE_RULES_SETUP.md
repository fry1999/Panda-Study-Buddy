# Firestore Security Rules Setup

## Problem
The "Claim Rewards" and "Back to Forest" buttons were failing with permission errors:
```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

## Solution
The app needs proper Firestore security rules to allow users to read and write their own data.

## How to Fix

### Option 1: Deploy via Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **buddy-5c0dc**
3. Navigate to **Firestore Database** in the left menu
4. Click on the **Rules** tab
5. Copy the contents of `firestore.rules` file
6. Paste into the rules editor
7. Click **Publish**

### Option 2: Deploy via Firebase CLI

If you have Firebase CLI installed:

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

## What the Rules Do

The new security rules allow:
- ✅ Users to read and write their own data
- ✅ Users to create and update their study sessions
- ✅ Users to create and update their daily stats
- ✅ Users to create and join study rooms
- ❌ Users cannot delete data (safety measure)
- ❌ Users cannot access other users' private data

## Temporary Fix

The app has been updated to handle permission errors gracefully:
- Sessions will complete even if stats fail to save
- Users can still use the app while you deploy the rules
- Errors are logged but don't block the UI

## Next Steps

1. Deploy the Firestore rules using one of the methods above
2. Test the app - the buttons should now work perfectly
3. If you need to create additional indexes, Firebase will provide links in the console

## Firebase Indexes

You **MUST** create composite indexes for the sessions query. If you see errors like:
```
The query requires an index. You can create it here: [URL]
```

### Method 1: Auto-create via Error Link (Easiest)
1. Look for the Firestore error in the console/logs
2. Click the provided URL in the error message
3. Firebase will create the index automatically

### Method 2: Manual Creation
Go to Firebase Console → Firestore Database → Indexes tab and create:

**Sessions Collection Index:**
- Collection: `sessions`
- Fields:
  - `userId` (Ascending)
  - `startTime` (Descending)
  - `__name__` (Descending)
- Query scope: Collection

This index is required for the "Today's Sessions" query to work properly.

