# 💰 Google Play Subscription Payments - How It Works

## 📋 Overview

When users buy premium subscriptions through your app, Google Play handles all payments and you receive payouts monthly. Here's the complete process.

---

## 💳 How Payments Work

### 1. **User Purchases Subscription**

```
User clicks "Subscribe"
        ↓
Google Play Payment Sheet
        ↓
User pays via:
- Credit/Debit Card
- Google Pay
- Carrier Billing
- Gift Cards
        ↓
Payment processed by Google
        ↓
User gets Premium Access
```

---

## 💰 Where Does the Money Go?

### Payment Flow:

```
User Pays Rs. 50/month
        ↓
Google Play takes 15-30% commission*
        ↓
Your Share: Rs. 35-42.50
        ↓
Held by Google for ~30 days
        ↓
Paid to your bank account monthly
```

**Commission Structure:**

- **First Year:** Google takes 30% (you get 70%)
- **After 1 Year:** Google takes 15% (you get 85%)

### Example Calculation:

#### Monthly Subscription (Rs. 50):

- **User Pays:** Rs. 50
- **Google's Cut (30%):** Rs. 15
- **Your Earnings (70%):** Rs. 35
- **After 1 year (15%):** Rs. 42.50

#### Yearly Subscription (Rs. 300):

- **User Pays:** Rs. 300
- **Google's Cut (30%):** Rs. 90
- **Your Earnings (70%):** Rs. 210
- **After 1 year (15%):** Rs. 255

---

## 🏦 How to Receive Payments

### Step 1: Set Up Merchant Account

1. **Go to Google Play Console**
   - URL: https://play.google.com/console
   - Login with your developer account

2. **Navigate to Payments Profile**

   ```
   Play Console → Setup → Payments Profile
   ```

3. **Complete Payment Setup**
   - Click "Setup a payments profile"
   - Enter your business/personal information
   - Add bank account details

---

### Step 2: Add Bank Account Details

#### Required Information:

**For Pakistan:**

- ✅ Bank Name
- ✅ Account Holder Name (must match Play Console name)
- ✅ IBAN Number (International Bank Account Number)
- ✅ Swift Code (for international transfers)
- ✅ Branch Code
- ✅ Tax Information (NTN if registered)

**Supported Pakistani Banks:**

- ✅ HBL (Habib Bank Limited)
- ✅ UBL (United Bank Limited)
- ✅ MCB (Muslim Commercial Bank)
- ✅ Allied Bank
- ✅ Bank Alfalah
- ✅ Meezan Bank
- ✅ And all major banks

#### How to Add Bank Account:

1. **Go to Payments Profile**
2. **Click "Add Bank Account"**
3. **Select Country:** Pakistan
4. **Select Currency:** PKR (Pakistani Rupee) or USD
5. **Enter Bank Details:**
   ```
   Bank Name: [Your Bank]
   Account Holder Name: [Your Name]
   IBAN: PK47XXXXXXXXXXXXXXXXXXXX
   Swift Code: [Bank Swift Code]
   Branch Code: [Your Branch Code]
   ```
6. **Submit for Verification**

#### Verification Process:

- Google sends a small test deposit (Rs. 1-10)
- Check your bank statement
- Enter the exact amount in Play Console
- Account verified ✅

---

### Step 3: Set Payment Threshold

**Minimum Payout Threshold:**

- **Default:** $100 USD or equivalent
- **Once you reach $100:** Payment is automatically processed
- **You can't withdraw before $100**

**How to Change Threshold:**

```
Play Console → Payments Profile → Payment Schedule
→ Set threshold: $100, $200, $500, etc.
```

---

## 📅 Payment Schedule

### When You Get Paid:

**Google's Payment Timeline:**

```
Month 1: User subscribes
        ↓
~15 days: Google verifies payment
        ↓
~30 days: Revenue calculated
        ↓
Next month 15th: Payment issued
        ↓
2-5 business days: Money in your account
```

### Example Timeline:

```
Jan 1: User buys subscription (Rs. 50)
Jan 15: Google verifies payment
Feb 1: Revenue added to your balance
Feb 15: Google issues payment (if > $100)
Feb 20: Money arrives in your bank account
```

### Actual Payout Dates:

- **Around 15th of each month**
- **For previous month's earnings**
- **Only if balance ≥ $100**

---

## 📊 Where to See Your Earnings

### 1. **Google Play Console - Financial Reports**

**Navigate to:**

```
Play Console → Earnings → Financial Reports
```

**What You'll See:**

- 💰 Total revenue this month
- 📈 Revenue by product (monthly/yearly subscriptions)
- 👥 Number of active subscribers
- 📊 Revenue by country
- 💳 Payment status

**Example Report:**

```
╔════════════════════════════════════════╗
║  January 2026 Earnings                ║
╠════════════════════════════════════════╣
║  Monthly Subscriptions: Rs. 15,000    ║
║  Yearly Subscriptions:  Rs. 42,000    ║
║  Total Revenue:         Rs. 57,000    ║
║  Google's Fee (30%):    Rs. 17,100    ║
║  Your Earnings (70%):   Rs. 39,900    ║
║                                        ║
║  Active Subscribers: 412               ║
║  New Subscribers: 67                   ║
║  Cancelled: 12                         ║
╚════════════════════════════════════════╝
```

---

### 2. **Firebase Analytics (Optional)**

**Track in Real-Time:**

```dart
// When user subscribes
FirebaseAnalytics.instance.logEvent(
  name: 'subscription_purchased',
  parameters: {
    'product_id': 'pk_premium_monthly',
    'price': 50,
    'currency': 'PKR',
  },
);
```

**View in Firebase Console:**

- Real-time subscriber count
- Conversion rates
- Revenue analytics

---

### 3. **Google AdMob (for Ad Revenue)**

**Separate from subscriptions:**

- AdMob shows ad revenue
- Subscriptions shown in Play Console
- Both can be linked for combined view

---

## 💸 How to Withdraw Money

### Automatic Withdrawal:

**Google automatically sends money when:**

1. ✅ Balance reaches $100 (or your threshold)
2. ✅ Around 15th of each month
3. ✅ Bank account verified
4. ✅ No payment holds/issues

**You don't need to do anything!**

- Money automatically transfers to your bank
- Email notification sent
- Visible in bank statement as "Google Payment"

---

### Manual Actions:

**Check Your Balance:**

```
Play Console → Payments Profile → Current Balance
```

**View Payment History:**

```
Play Console → Payments Profile → Transaction History
```

**Download Invoice:**

```
Play Console → Payments Profile → Invoices
→ Download PDF for tax purposes
```

---

## 🏦 Bank Statement Entry

### What You'll See:

```
Date: 20 Feb 2026
Description: Google Payment Corp
Amount: Rs. 39,900
Reference: GOOGLEPAY-JAN2026
```

### Payment Methods:

- **Wire Transfer** (most common)
- **Direct Bank Deposit**
- **3-5 business days** to reflect

---

## 📈 Revenue Tracking

### Monthly Revenue Calculation:

```
Total Subscribers × Subscription Price = Gross Revenue
Gross Revenue × 0.70 (or 0.85 after 1 year) = Your Earnings
Your Earnings ÷ 1.18 (if VAT applicable) = Net Earnings
```

### Example with 100 Subscribers:

**Monthly Plan (Rs. 50/month):**

```
100 subscribers × Rs. 50 = Rs. 5,000
Rs. 5,000 × 0.70 = Rs. 3,500 (your share)
Rs. 3,500 - taxes = Rs. 2,966 (net)
```

**Yearly Plan (Rs. 300/year):**

```
50 subscribers × Rs. 300 = Rs. 15,000
Rs. 15,000 × 0.70 = Rs. 10,500 (your share)
Rs. 10,500 - taxes = Rs. 8,898 (net)
```

---

## 💡 Tips to Maximize Revenue

### 1. **Wait for First Year Bonus**

- After 1 year: Commission drops from 30% → 15%
- Keep subscribers happy to retain them

### 2. **Promote Yearly Plans**

```
Yearly: Rs. 300 (Rs. 25/month)
vs
Monthly: Rs. 50/month

Yearly saves users Rs. 300/year
= Better value = More yearly subscribers
```

### 3. **Track Metrics**

- Monitor active subscribers
- Track cancellation rate
- Optimize pricing based on data

### 4. **Reduce Churn**

- Provide great value
- Regular app updates
- Responsive support
- Keep users happy

---

## 📊 Expected Earnings

### Conservative Estimate (5,000 users, 3% conversion):

**150 subscribers:**

- 100 monthly (Rs. 50) = Rs. 5,000
- 50 yearly (Rs. 300) = Rs. 15,000
- **Total/month:** Rs. 20,000
- **Google's cut (30%):** Rs. 6,000
- **Your earnings (70%):** Rs. 14,000/month
- **Yearly:** Rs. 168,000

### Moderate Estimate (10,000 users, 5% conversion):

**500 subscribers:**

- 300 monthly = Rs. 15,000
- 200 yearly = Rs. 60,000
- **Total/month:** Rs. 75,000
- **Google's cut (30%):** Rs. 22,500
- **Your earnings (70%):** Rs. 52,500/month
- **Yearly:** Rs. 630,000

### Optimistic Estimate (20,000 users, 7% conversion):

**1,400 subscribers:**

- 800 monthly = Rs. 40,000
- 600 yearly = Rs. 180,000
- **Total/month:** Rs. 220,000
- **Google's cut (30%):** Rs. 66,000
- **Your earnings (70%):** Rs. 154,000/month
- **Yearly:** Rs. 1,848,000

---

## 🛡️ Important Notes

### Tax Considerations:

**In Pakistan:**

- Register for **NTN** (National Tax Number)
- Declare income to **FBR** (Federal Board of Revenue)
- Pay applicable taxes on earnings
- Keep invoices for tax filing

**Google Withholds Tax:**

- If you don't provide tax info
- Google may withhold 30% for US tax
- Provide W-8BEN form (for non-US residents)

### Payment Issues:

**If payment delayed:**

1. Check bank account verification
2. Verify payment threshold reached
3. Check for payment holds
4. Contact Google Play support

**Common Holds:**

- Unverified bank account
- Tax information missing
- Account under review
- Policy violations

---

## 📞 Getting Help

### Google Play Support:

**For Payment Issues:**

```
Play Console → Help → Contact Support
→ Select "Payments & Financial Reports"
```

**Resources:**

- Play Console Help: https://support.google.com/googleplay/android-developer
- Payment Center: https://payments.google.com
- Developer Forum: https://support.google.com/googleplay/android-developer/community

---

## ✅ Setup Checklist

**Before Your First Payout:**

- [ ] Play Console account created
- [ ] Payments Profile completed
- [ ] Bank account added
- [ ] Bank account verified (test deposit)
- [ ] Tax information provided (W-8BEN for Pakistan)
- [ ] Payment threshold set (default $100)
- [ ] Subscriptions created and ACTIVE in Play Console
- [ ] App published with subscriptions
- [ ] First subscribers paying
- [ ] Revenue showing in Financial Reports
- [ ] Waiting for balance to reach $100
- [ ] Payment issued on 15th of month
- [ ] Money received in bank account ✅

---

## 🎯 Quick Summary

### How It Works:

1. ✅ User buys subscription
2. ✅ Google processes payment
3. ✅ Google takes 15-30% commission
4. ✅ Your share added to balance
5. ✅ When balance reaches $100, payment issued
6. ✅ Money sent to your bank account monthly
7. ✅ You receive payment around 15th of each month

### Your Action Items:

1. **Setup Payments Profile** in Play Console
2. **Add bank account** details
3. **Verify account** with test deposit
4. **Provide tax information** (W-8BEN)
5. **Create subscriptions** in Play Console
6. **Launch app** with subscriptions
7. **Wait for balance** to reach $100
8. **Receive automatic payment** monthly

### Key Dates:

- **15th of each month:** Payment issued
- **20-25th of month:** Money in bank
- **30-day delay:** From subscription to payout

---

## 🎉 That's It!

Once setup is complete:

- ✅ **No manual withdrawal needed**
- ✅ **Automatic monthly payments**
- ✅ **Track earnings in Play Console**
- ✅ **Money in your bank account**
- ✅ **Focus on growing your app!**

---

**Created:** 28 January 2026  
**Topic:** Google Play Subscription Payment & Withdrawal Guide  
**For:** Qibla Compass Offline App Developer
