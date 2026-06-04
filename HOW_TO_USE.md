# 📱 Family Wallet — How to Use

A complete guide to setting up and using the Family Wallet app.

---

## 1. First Time Setup

### Step 1 — Register an Account
1. Open the app → you will see the **Login** screen.
2. At the bottom tap **"Register"**.
3. Fill in:
   - **Your Display Name** (e.g. Sadik, Ahmad, Fatima)
   - **Email Address**
   - **Password** (minimum 6 characters)
4. Tap **"Create Account"**.
5. Check your email inbox → click the **confirmation link** sent by Supabase.
6. Come back to the app and **Login** with your email & password.

> ⚠️ If you don't get a confirmation email, ask the admin to disable email confirmation in Supabase Dashboard → Authentication → Email.

---

### Step 2 — Login
1. On the Login screen, enter your **Email** and **Password**.
2. Tap **Login**.
3. You will land on the **Home / Dashboard** screen.

---

## 2. Create a Family Workspace

A **Family Workspace** is a shared ledger that all family members can see and add to.

1. Go to the **Profile** tab (bottom right).
2. Under **"Multi-Family Workspaces"**, tap **"Create a Family Workspace"**.
3. Enter a name (e.g. `Sadik Family`, `Apex Household`).
4. Tap **Create**.
5. Your workspace is created. You will see an **Invite Code** (7 characters).

---

## 3. Invite Family Members

1. Go to **Profile** tab.
2. Under the invite section, copy the **Invite Code**.
3. Share this code with your family members (brothers, sisters, spouse).
4. Each member must:
   - Register their own account (see Step 1).
   - Go to Profile → tap **"Join Workspace via Invite Code"**.
   - Enter the shared code.
   - Tap **Join**.

---

## 4. Add an Expense (Money Out)

1. Tap the **+** (plus) button at the bottom center.
2. Select **"Log Money Out"**.
3. Fill in:
   - **Amount** (in Rupees ₹)
   - **Category** (Grocery, Rent, Electricity, Transport, etc.)
   - **Description** (what was bought)
   - **Date**
   - **Payment Method** (Cash, UPI, Card, etc.)
4. Tap **"Log Expense"**.

### Quick ways to add:
- **Voice**: Tap the mic icon → say e.g. *"Grocery 450 rupees for vegetables"* → fields fill automatically.
- **OCR Scan**: Tap **"Auto Scan Bill Receipt"** → take a photo of the bill → AI fills amount and details.

---

## 5. Add a Contribution (Money In)

1. Tap the **+** button at the bottom center.
2. Select **"Log Money In"**.
3. Fill in:
   - **Amount** (in Rupees ₹)
   - **Notes** (e.g. "Monthly salary deposit", "Eid gift")
   - **Date**
4. Tap **"Log Contribution"**.

---

## 6. View Ledger Timeline

1. Tap the **Ledger** tab (second from left in bottom nav).
2. You will see all **transactions** (both expenses and contributions) sorted by date.
3. Use the **Search bar** to search by category, member name, or notes.
4. Use the **filter chips** (All / Money In / Money Out) to filter.
5. Tap a transaction to view receipt details if attached.

---

## 7. View Reports & Analytics

1. Tap the **Reports** tab (third in bottom nav).
2. See:
   - **Monthly Spending Breakdown** chart by category.
   - **AI Financial Recommendations** (spending warnings and savings tips).
3. **Premium users** can tap **"Export PDF"** to download a full report.

---

## 8. AI Financial Coach (Chat)

1. From the Home screen tap **"AI Assistant"** quick tool.
2. Type any question, e.g.:
   - *"What did we spend most on this month?"*
   - *"How can we save more?"*
   - *"Show me electricity expenses."*
3. The AI coach replies based on your family ledger data.

---

## 9. Scan a Receipt (OCR)

1. From Home tap **"Scan Receipt"** quick tool.
2. Choose **Camera Capture** or **Gallery Pick**.
3. The app reads the receipt and extracts:
   - Store / Merchant name
   - Total amount
   - Date
4. Confirm details → tap **Log Expense**.

---

## 10. Change Language

1. Go to **Profile** tab.
2. Under **"App Language"** dropdown, select:
   - 🇺🇸 **English**
   - 🇮🇳 **हिन्दी (Hindi)**
3. The entire app switches language immediately.

---

## 11. Switch Dark / Light Theme

1. Go to **Profile** tab.
2. Toggle the **"Dark Obsidian Theme"** switch ON or OFF.

---

## 12. Upgrade to Premium

1. Go to **Profile** tab.
2. Tap **"Go Premium"** or look for the upgrade prompt in Reports.
3. Premium unlocks:
   - PDF report exports
   - Higher transaction limits
   - Advanced AI recommendations

---

## 13. Supabase Database Setup (Admin Only)

If you are setting up the backend for the first time:

1. Go to [supabase.com](https://supabase.com) → your project.
2. Open **SQL Editor**.
3. Paste and run the contents of `supabase_schema.sql` (in project root).
4. This creates all required tables: `users`, `families`, `family_members`, `expenses`, `contributions`, `budget_limits`, etc.
5. Go to **Authentication → Email** → disable email confirmation if needed for testing.

---

## Summary — Key Screens

| Screen | How to reach |
|--------|-------------|
| Home / Dashboard | Default after login |
| Ledger Timeline | Bottom nav → 2nd icon |
| Reports | Bottom nav → 3rd icon |
| Profile / Settings | Bottom nav → 4th icon |
| Add Expense | + button → Log Money Out |
| Add Contribution | + button → Log Money In |
| AI Chat | Home → AI Assistant |
| Receipt Scanner | Home → Scan Receipt |
| Register | Login screen → "Register" |
| Join Workspace | Profile → Join Workspace via Invite Code |

---

*Family Wallet — Built for transparent family finance management.*
