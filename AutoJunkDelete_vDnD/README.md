<div align="center">

<img src="https://img.shields.io/badge/WoW-WotLK%203.3.5-C69B6D?style=for-the-badge&logo=battle.net&logoColor=white"/>
<img src="https://img.shields.io/badge/Version-1.3-40FF40?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Lua-5.1-00007C?style=for-the-badge&logo=lua&logoColor=white"/>

<br/>

# ⚔️ AutoJunkDelete

**🌐 Language · زبان:**
&nbsp;&nbsp;[🇺🇸 English](#-english) &nbsp;|&nbsp; [🇮🇷 فارسی](#-فارسی)

<br/>

---

</div>

<br/>

## 🇺🇸 English

<div align="left">

### What is AutoJunkDelete?

AutoJunkDelete is a lightweight World of Warcraft addon for **WotLK 3.3.5** that keeps your bags clean automatically. It scans for junk-quality items, lets you build a personal blacklist, and deletes unwanted items — all without interrupting your gameplay flow.

---

### ✨ Features

| Feature | Description |
|--------|-------------|
| 🗑️ **Junk Scanner** | Scans all 5 bags for grey/white items below your sell-price threshold |
| ⬛ **Blacklist System** | Force-delete specific items automatically whenever a bag is opened or loot is taken |
| ⬜ **Whitelist Protection** | Mark important items as "never delete" — Hearthstone is always protected |
| 🖱️ **Shift + Right Click** | Instantly switches any bag item between blacklist and whitelist |
| 🔔 **Smart Socket Dialog** | Socketed items show a choice popup before switching lists |
| 🏦 **Bank Support** | Blacklist deletions also work on open bank slots |
| ⚡ **Instant Auto-Delete** | Junk and blacklisted items are deleted immediately, no confirmation popup |
| ⚙️ **In-game Settings Panel** | `Esc → Interface → AddOns → AutoJunkDelete` |
| 📌 **Movable Button** | Drag the AJD button anywhere on screen |
| 🧩 **Tooltip Hints** | Every item tooltip shows its `/ajd wl` and `/ajd bl` commands |

---

### 🚀 Installation

1. Download and extract the folder
2. Place `AutoJunkDelete/` inside:
   ```
   World of Warcraft/Interface/AddOns/
   ```
3. Launch WoW and enable the addon from the **AddOns** menu on the character select screen

---

### 🎮 How to Use

#### The AJD Button
A small draggable button appears on your screen at login.

| Click | Action |
|-------|--------|
| **Left Click** | Scan bags for junk + immediately delete all blacklisted items |
| **Right Click** | Show settings in chat |

#### Blacklist / Whitelist Switch
> **`Shift + Right Click`** any item in your bags

- Not on either list yet → added to blacklist (will be auto-deleted next time bags open or loot is taken)
- Already on blacklist → switches it to the whitelist (never deleted)
- Already on whitelist → switches it to the blacklist
- An item can only be on one list at a time
- If the item has **sockets** → a popup appears asking you to choose between opening sockets or switching lists

---

### 💬 Slash Commands

All commands use the prefix `/ajd`

```
/ajd help              Show all available commands
/ajd clean_auto_toggle Toggle automatic cleanup (junk filter + blacklist) on/off
/ajd maxq 0|1          Set max quality for junk scan (0 = grey, 1 = white)
/ajd minsell <N>       Set max vendor price in copper (items at or below this are junk)
/ajd wl <itemID>       Add/remove item from whitelist (never deleted)
/ajd bl <itemID>       Add/remove item from blacklist (force deleted)
/ajd clean_man         Immediately delete all blacklisted items in bags
/ajd unlock            Enable drag mode for AJD button
/ajd lock              Save position and exit drag mode
/ajd settings          Print current settings to chat
```

---

### ⚙️ Default Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `maxQuality` | `0` | Grey items only |
| `minSell` | `10000` | Items with sell price ≤ 10000 copper |
| `cleanAuto` | `true` | Automatic cleanup (junk filter + blacklist) on bag open / loot |

---

### 🛡️ Built-in Protections

- **Hearthstone** (Item ID: 6948) is permanently whitelisted and can never be deleted
- Locked items are always skipped
- Items in the whitelist are never touched, even if also in the blacklist

---

### 👤 Author

**Mehran Ghadirian**
🔗 [github.com/MehranQadirian](https://github.com/MehranQadirian)
📦 [World-of-Warcraft-Addons Repository](https://github.com/MehranQadirian/World-of-Warcraft-Addons)

</div>

---

<br/>

## 🇮🇷 فارسی

<div dir="rtl" align="right">

### AutoJunkDelete چیست؟

AutoJunkDelete یک افزونه سبک برای بازی World of Warcraft نسخه **WotLK 3.3.5** است که کیف‌های شما را به صورت خودکار تمیز نگه می‌دارد. این افزونه آیتم‌های بی‌کیفیت را اسکن می‌کند، به شما اجازه می‌دهد یک لیست سیاه شخصی بسازید، و آیتم‌های ناخواسته را حذف می‌کند — همه اینها بدون اینکه گیم‌پلی شما را مختل کند.

---

### ✨ ویژگی‌ها

| ویژگی | توضیح |
|-------|-------|
| 🗑️ **اسکنر آیتم‌های بی‌ارزش** | همه ۵ کیف را برای آیتم‌های خاکستری/سفید زیر آستانه قیمت فروش اسکن می‌کند |
| ⬛ **سیستم لیست سیاه** | آیتم‌های خاص را هر بار که کیف باز می‌شود یا غنیمت گرفته می‌شود، به صورت خودکار حذف می‌کند |
| ⬜ **محافظت لیست سفید** | آیتم‌های مهم را به عنوان «هرگز حذف نشود» علامت‌گذاری کنید — Hearthstone همیشه محافظت می‌شود |
| 🖱️ **Shift + کلیک راست** | هر آیتم کیف را فوری بین لیست سیاه و لیست سفید سوییچ می‌کند |
| 🔔 **دیالوگ هوشمند سوکت** | آیتم‌های دارای سوکت قبل از سوییچ لیست، یک پنجره انتخاب نشان می‌دهند |
| 🏦 **پشتیبانی از بانک** | حذف لیست سیاه روی اسلات‌های باز بانک هم کار می‌کند |
| ⚡ **حذف خودکار فوری** | آیتم‌های بی‌ارزش و لیست سیاه بدون هیچ دیالوگ تأییدی فوراً حذف می‌شوند |
| ⚙️ **پنل تنظیمات درون‌بازی** | `Esc → Interface → AddOns → AutoJunkDelete` |
| 📌 **دکمه قابل جابجایی** | دکمه AJD را به هر جایی روی صفحه بکشید |
| 🧩 **راهنمای تولتیپ** | هر تولتیپ آیتم دستورات `/ajd wl` و `/ajd bl` آن را نشان می‌دهد |

---

### 🚀 نصب

1. فولدر را دانلود و استخراج کنید
2. فولدر `AutoJunkDelete/` را درون این مسیر قرار دهید:
   ```
   World of Warcraft/Interface/AddOns/
   ```
3. وارد WoW شوید و افزونه را از منوی **AddOns** در صفحه انتخاب کاراکتر فعال کنید

---

### 🎮 نحوه استفاده

#### دکمه AJD
یک دکمه کوچک قابل کشیدن هنگام ورود به بازی روی صفحه شما ظاهر می‌شود.

| کلیک | عملکرد |
|------|---------|
| **کلیک چپ** | اسکن کیف‌ها برای آیتم‌های بی‌ارزش + حذف فوری همه آیتم‌های لیست سیاه |
| **کلیک راست** | نمایش تنظیمات در چت |

#### سوییچ بین لیست سیاه و لیست سفید
> **`Shift + کلیک راست`** روی هر آیتم در کیف‌هایتان

- اگر در هیچ لیستی نبود → به لیست سیاه اضافه می‌شود (دفعه بعد که کیف باز شود یا غنیمت بگیرید، خودکار حذف می‌شود)
- اگر در لیست سیاه بود → به لیست سفید سوییچ می‌شود (هرگز حذف نمی‌شود)
- اگر در لیست سفید بود → به لیست سیاه سوییچ می‌شود
- هر آیتم فقط می‌تواند در یکی از دو لیست باشد
- اگر آیتم **سوکت** داشت → یک پنجره ظاهر می‌شود که از شما می‌خواهد بین باز کردن سوکت یا سوییچ لیست انتخاب کنید

---

### 💬 دستورات اسلش

همه دستورات با پیشوند `/ajd` استفاده می‌شوند

```
/ajd help              نمایش همه دستورات
/ajd clean_auto_toggle روشن/خاموش کردن پاکسازی خودکار (فیلتر بی‌ارزش + لیست سیاه)
/ajd maxq 0|1          تنظیم حداکثر کیفیت برای اسکن (0 = خاکستری، 1 = سفید)
/ajd minsell <N>       تنظیم حداکثر قیمت فروش به واحد copper
/ajd wl <itemID>       اضافه/حذف آیتم از لیست سفید (هرگز حذف نمی‌شود)
/ajd bl <itemID>       اضافه/حذف آیتم از لیست سیاه (حذف اجباری)
/ajd clean_man         حذف فوری همه آیتم‌های لیست سیاه در کیف‌ها
/ajd unlock            فعال کردن حالت کشیدن دکمه AJD
/ajd lock              ذخیره موقعیت و خروج از حالت کشیدن
/ajd settings          نمایش تنظیمات فعلی در چت
```

---

### ⚙️ تنظیمات پیش‌فرض

| تنظیم | پیش‌فرض | توضیح |
|-------|---------|-------|
| `maxQuality` | `0` | فقط آیتم‌های خاکستری |
| `minSell` | `10000` | آیتم‌هایی با قیمت فروش ≤ ۱۰۰۰۰ copper |
| `cleanAuto` | `true` | پاکسازی خودکار (فیلتر بی‌ارزش + لیست سیاه) هنگام باز شدن کیف/غنیمت |

---

### 🛡️ محافظت‌های داخلی

- **Hearthstone** (شناسه آیتم: ۶۹۴۸) همیشه در لیست سفید است و هرگز حذف نمی‌شود
- آیتم‌های قفل‌شده همیشه نادیده گرفته می‌شوند
- آیتم‌های موجود در لیست سفید هرگز لمس نمی‌شوند، حتی اگر در لیست سیاه هم باشند

---

### 👤 سازنده

**Mehran Ghadirian**
🔗 [github.com/MehranQadirian](https://github.com/MehranQadirian)
📦 [مخزن World-of-Warcraft-Addons](https://github.com/MehranQadirian/World-of-Warcraft-Addons)

</div>

---

<div align="center">

<sub>Made with ❤️ for the WotLK community · با ❤️ برای جامعه WotLK ساخته شده</sub>

</div>
