# 💰 Quick Payment Setup Guide - Step by Step

## 🚀 How to Get Paid for Your Subscriptions

Follow these simple steps to receive subscription payments:

---

## Step 1: Complete Payments Profile (5 minutes)

### Go to Google Play Console

1. Open: https://play.google.com/console
2. Login with your developer account
3. Click on **"Setup"** in left menu
4. Click on **"Payments profile"**

### Fill Required Information

```
╔════════════════════════════════════════╗
║  Business/Personal Information         ║
╠════════════════════════════════════════╣
║  Name: [Your Full Name]                ║
║  Address: [Your Complete Address]      ║
║  Country: Pakistan                     ║
║  Phone: [Your Mobile Number]           ║
╚════════════════════════════════════════╝
```

---

## Step 2: Add Bank Account (10 minutes)

### Required Details

**Get from Your Bank:**

- ✅ **IBAN Number** (24 digits starting with PK)
- ✅ **Swift Code** (8-11 characters)
- ✅ **Branch Code**
- ✅ **Account Title** (must match your name)

**Where to Find:**

- Check your **bank statement**
- Or login to **online banking**
- Or call your **bank's helpline**
- Or visit your **bank branch**

### Enter in Play Console

```
╔════════════════════════════════════════╗
║  Add Bank Account                      ║
╠════════════════════════════════════════╣
║  Country: Pakistan                     ║
║  Currency: PKR                         ║
║  Bank Name: [Select your bank]         ║
║  Account Holder: [Your Name]           ║
║  IBAN: PK47XXXXXXXXXXXXXXXXXXXX        ║
║  Swift Code: [Bank Swift Code]         ║
║  Branch Code: [Your Branch]            ║
╚════════════════════════════════════════╝
```

**Common Pakistani Bank Swift Codes:**

- HBL: HABBPKKAXXX
- UBL: UNILPKKAXXX
- MCB: MUCBPKKAXXX
- Allied Bank: ABPAPKKAXXX
- Bank Alfalah: ALFHPKKAXXX

---

## Step 3: Verify Bank Account (2-3 days)

### Google sends test deposit

```
Day 1: Google sends Rs. 1-10 to your account
Day 2-3: Check your bank statement
Day 3: Enter exact amount in Play Console
✅ Account Verified!
```

### How to Verify:

1. Wait for email from Google
2. Check your bank statement
3. Look for deposit from "GOOGLE PAYMENT"
4. Go back to Play Console → Payments Profile
5. Click "Verify"
6. Enter the **exact amount** you received
7. Click "Confirm"

---

## Step 4: Tax Information (5 minutes)

### For Pakistan (Non-US Residents)

**Fill W-8BEN Form:**

```
Play Console → Payments Profile → Tax Info
→ Select "Individual"
→ Country: Pakistan
→ Fill W-8BEN form
```

**Required Information:**

- Full Name
- Pakistani Address
- NTN (National Tax Number) - if you have one
- Check box: "I certify..."
- Sign digitally

**Why this is important:**

- ✅ Without tax info: Google withholds 30% US tax
- ✅ With W-8BEN: No US tax, only Pakistani tax applies

---

## Step 5: Create Subscriptions in Play Console

### Already Done! ✅

You need to create 4 subscription products:

- `pk_premium_monthly` - Rs. 50/month
- `pk_premium_yearly` - Rs. 300/year
- `intl_premium_monthly` - $1/month
- `intl_premium_yearly` - $6/year

**See:** `SUBSCRIPTION_SETUP_GUIDE.md` for details

---

## Step 6: Wait for First Payment

### Timeline:

```
┌────────────────────────────────────────┐
│  January 1-31: Users subscribe         │
│  • 50 monthly subscribers × Rs. 50     │
│  • Total revenue: Rs. 2,500            │
│  • Your share (70%): Rs. 1,750         │
└────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────┐
│  February 1-14: Google calculates      │
│  • Revenue verified                    │
│  • Commission deducted                 │
│  • Balance: Rs. 1,750 added            │
└────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────┐
│  February 15: Payment threshold check  │
│  • Current balance: Rs. 1,750          │
│  • Threshold: $100 (~Rs. 28,000)      │
│  • Not reached, carry forward          │
└────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────┐
│  March (after 2 months): Threshold hit │
│  • Total balance: Rs. 30,000+          │
│  • ✅ Payment issued!                  │
└────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────┐
│  March 20: Money in your bank! 💰      │
│  • Bank notification received          │
│  • Amount: Rs. 30,000+                 │
│  • Description: "Google Payment"       │
└────────────────────────────────────────┘
```

---

## 📊 How to Track Your Earnings

### Daily/Weekly Check:

**Go to Play Console:**

```
Play Console → Your App → Monetize → Subscriptions
```

**You'll see:**

- 📈 Active subscribers count
- 💰 Revenue this month
- 👥 New subscribers
- 📉 Cancelled subscriptions

### Monthly Financial Report:

**Go to:**

```
Play Console → Earnings → Financial Reports
```

**Download Excel/CSV:**

- Revenue by day
- Revenue by product
- Subscriber count
- Commission deducted
- Your earnings

---

## 💳 Payment Schedule

### When You Get Paid:

| Your Earnings | When Payment Issued | When Money Arrives |
| ------------- | ------------------- | ------------------ |
| Month 1       | Month 2 (15th)      | Month 2 (20th)     |
| Month 2       | Month 3 (15th)      | Month 3 (20th)     |
| Month 3       | Month 4 (15th)      | Month 4 (20th)     |

### Important:

- ✅ **Minimum $100** balance required
- ✅ **15th of month** - payment issued
- ✅ **3-5 business days** - money in bank
- ✅ **Automatic** - no action needed from you

---

## 🏦 What to Expect in Bank Statement

### Bank Entry Example:

```
DATE: 20 Mar 2026
DESCRIPTION: Google Payment Corp
CREDIT: Rs. 32,450.00
REF: GOOGLEPAY-FEB2026
```

### Payment Details:

- **From:** Google Payment Corp
- **Type:** International Wire Transfer
- **Currency:** PKR (Pakistani Rupees)
- **Time:** 3-5 business days

---

## 💰 Revenue Calculator

### Quick Estimate:

**Formula:**

```
Active Subscribers × Price × 0.70 = Monthly Earnings
(0.70 = 70% after Google's 30% commission)
```

**Examples:**

**50 subscribers (Rs. 50/month):**

```
50 × 50 × 0.70 = Rs. 1,750/month
```

**200 subscribers (Rs. 50/month):**

```
200 × 50 × 0.70 = Rs. 7,000/month
```

**500 subscribers (mixed):**

```
300 monthly (Rs. 50) = Rs. 15,000 × 0.70 = Rs. 10,500
200 yearly (Rs. 300) = Rs. 60,000 × 0.70 = Rs. 42,000
Total per month = Rs. 52,500
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: Payment Delayed

**Reasons:**

- Balance not reached $100
- Bank account not verified
- Tax info missing
- Payment hold

**Solution:**

1. Check balance: Play Console → Payments Profile
2. Verify bank account
3. Submit tax form (W-8BEN)
4. Contact support if needed

---

### Issue 2: Wrong Amount

**Reasons:**

- Commission calculation (30% or 15%)
- Currency conversion
- Refunds deducted
- Taxes applied

**Solution:**

- Download financial report
- Check individual transactions
- Verify commission rate
- Contact support with details

---

### Issue 3: Bank Rejected

**Reasons:**

- Wrong IBAN
- Name mismatch
- Bank doesn't accept international transfers
- Account closed

**Solution:**

- Verify IBAN is correct
- Name must match exactly
- Contact your bank
- Try different bank account

---

## 📞 Need Help?

### Google Play Support:

**For Payment Questions:**

1. Go to: https://support.google.com/googleplay/android-developer
2. Click "Contact Us"
3. Select: "Payments & Financial Reports"
4. Describe your issue
5. Get response in 24-48 hours

**For Banking Issues:**

- Contact your **bank's customer service**
- Ask about **international wire transfers**
- Provide Google's payment reference

---

## ✅ Final Checklist

Before you can receive payments, ensure all are done:

### Account Setup:

- [ ] Play Console account active
- [ ] Developer fee ($25) paid
- [ ] App published on Play Store

### Payment Setup:

- [ ] Payments Profile completed
- [ ] Bank account added
- [ ] Bank account verified (test deposit)
- [ ] Tax information submitted (W-8BEN)
- [ ] Payment threshold: $100 (default)

### Subscriptions:

- [ ] 4 subscription products created
- [ ] All subscriptions ACTIVE
- [ ] Base plans configured
- [ ] Pricing set correctly

### App:

- [ ] Subscription code integrated
- [ ] In-app purchase packages added
- [ ] Tested with test account
- [ ] App published/updated

### Ready to Earn! ✅

- [ ] Users can see subscriptions
- [ ] Users can purchase
- [ ] Revenue showing in reports
- [ ] Waiting for $100 threshold
- [ ] First payment expected in 2-3 months

---

## 🎯 Quick Tips

### 1. Start Marketing Early

- Promote app before reaching $100
- More users = faster threshold
- $100 ≈ 57 yearly subscribers OR 285 monthly subscribers

### 2. Monitor Daily

- Check subscriber count
- Track cancellations
- Fix issues quickly
- Respond to feedback

### 3. Be Patient

- First payment takes 2-3 months
- Need $100 minimum
- Google holds for 30 days
- Normal business practice

### 4. Plan for Taxes

- Set aside 15-20% for Pakistani taxes
- Keep all invoices
- Consult a tax professional
- File taxes annually

---

## 🎉 Success!

Once everything is set up:

- ✅ Users can buy subscriptions
- ✅ Revenue tracked automatically
- ✅ Monthly payments issued automatically
- ✅ Money deposited to your bank
- ✅ You just focus on building great app!

**Congratulations on monetizing your app!** 🚀💰

---

**Created:** 28 January 2026  
**Topic:** Quick Payment Setup Guide  
**Time Required:** 30 minutes setup + wait for verification
