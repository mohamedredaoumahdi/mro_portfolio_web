# Firebase Login Steps

## Step 1: Logout from Current Account
```bash
firebase logout
```

## Step 2: Login with Correct Account
```bash
firebase login
```

This will open a browser window. Make sure to:
1. Log in with: **medredaoumahdi@gmail.com**
2. Authorize Firebase CLI access

## Step 3: Verify Login
```bash
firebase projects:list
```

You should see your portfolio project: **myportfolio-594b1**

## Step 4: Set Active Project
```bash
firebase use myportfolio-594b1
```

## Step 5: Verify Project is Set
```bash
firebase projects:list
```

You should see an asterisk (*) next to myportfolio-594b1 indicating it's the active project.

## Step 6: Deploy Rules and Indexes
```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

---

**Note:** If you have multiple Google accounts, make sure to select the correct one (medredaoumahdi@gmail.com) when the browser opens for authentication.

