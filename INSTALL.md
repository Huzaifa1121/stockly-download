# Installing Stockly on a shop's computer

Stockly runs on the shop's own computer. The shop's data never leaves that
machine. No internet is needed to sell.

One computer holds the data. Phones and tablets open it through the shop's
own secure link, in the shop or from anywhere (see **Phones and tablets**).

---

## What you need

- A Windows PC or a Mac that stays on while the shop is open
- An internet connection **for the install only** — after that, selling works offline

Setup installs everything else itself, including Node.js, which Stockly runs
on. It asks first, then asks for the computer's password, because installing
software always does. There is no database to install.

---

## Install it

### Mac — one line, no warnings

1. Open **Terminal**: press ⌘ + Space, type `Terminal`, press Enter.
2. Paste this line and press Enter:

   ```
   /bin/bash -c "$(curl -fsSL https://huzaifa1121.github.io/stockly-download/install.sh)"
   ```

3. Answer its questions (it may ask to install Node.js and for the Mac's
   password, and whether Stockly should start by itself — say yes). The first
   time takes a few minutes.

Stockly installs into a **Stockly** folder in your home folder, adds
**Stockly** to Applications and Launchpad, and opens. Paste the same line
again any time to update: the shop's records, settings and licence are kept.

> Why a line in Terminal: macOS blocks downloaded files from developers who
> haven't paid Apple to sign them ("Apple could not verify…"). This way
> nothing is blocked and there is nothing to approve in System Settings.

### Windows — one line, no warnings

1. Right-click the **Start** button and choose **Terminal** (or **Windows
   PowerShell**).
2. Paste this line and press Enter:

   ```
   irm https://huzaifa1121.github.io/stockly-download/install-windows.ps1 | iex
   ```

3. Answer its questions (it may install Node.js, and asks whether Stockly
   should start by itself — say yes).

Stockly installs into a **Stockly** folder in your user folder, adds
**Stockly** to the Start menu, and opens. Paste the same line again to
update; the shop's records are kept.

**Or from the downloaded zip:**

1. Open **Downloads**, right-click **stockly.zip** and choose **Extract
   all…** (opening the zip and double-clicking inside it does not work —
   Windows asks to "Extract all" first).
2. Choose **Documents** as the place, tick **Show extracted files when
   complete**, press **Extract**.
3. Open the new **stockly-…** folder and double-click **Start Stockly**.
4. If a blue box says **Windows protected your PC**, press **More info**,
   then **Run anyway**. Only the first time.

---

## Start it

If you said yes to "start automatically" during setup, there is nothing to
do: Stockly is already running in the background from the moment the
computer turns on, with no window to close by mistake. On a Mac, open it
from **Stockly** in Applications or Launchpad; on Windows from the Start
menu, or at `http://localhost:3000`.

Otherwise, open **Stockly** from Applications (Mac), or double-click
**Start Stockly** in the Stockly folder. A black window opens; **leave it
open** — closing it stops Stockly.

To stop Stockly whichever way it was started, double-click **Stop Stockly**
in the Stockly folder.

---

## The first screen

The very first screen is the **Licence** screen. It shows this computer's
**computer code**, like `1A2B-3C4D-5E6F`.

1. Send that code to your supplier on WhatsApp (there is a Copy button).
2. They send back a **licence key** made for this computer only.
3. Paste the key and press **Activate Stockly**.

It is only asked once, on this computer, and needs no internet. A key made
for another computer will not work here.

Then, the first time only, Stockly asks for:

- **Shop name** — appears on receipts
- **Your name** and an **email** — the email is just the sign-in name; no email is ever sent
- **A password** — **write it down**; there is no email here to reset it with
- **Currency** and **timezone**
- **Shop type** — pick the closest:
  - **General shop** — kiryana, hardware, stationery
  - **Cloth or boutique** — sell by the metre, the roll or the piece
  - **Pharmacy** — adds expiry dates, batch numbers and human/animal
  - **Fertilizer or seed** — sell by the kilo or the bag, with batch numbers

Then it opens the dashboard and the shop is ready.

---

## Make it an app

Stockly can live on the computer like any other program: its own icon in the
Dock or Start menu, its own window, no browser bars around it.

- **Chrome or Edge:** click **Install as an app** at the bottom of the
  Stockly menu. If that button is not there, click the install icon at the
  right end of the address bar.
- **Safari on a Mac:** File → **Add to Dock…**
- **iPhone or iPad:** Share → **Add to Home Screen**

**Settings → Use Stockly as an app** shows the right steps for whatever
device you are on. Once installed, **Start Stockly** opens that window
instead of a browser tab.

---

## Day to day

| Task | How |
|---|---|
| Start Stockly | Double-click **Start Stockly** (or nothing, if it starts automatically) |
| Stop it | Double-click **Stop Stockly** |
| Stop it starting automatically | Double-click **Stop starting automatically** |
| Add staff | **Users** → Add user. Cashiers can sell but not see profit, stock editing or expenses |
| Sell on udhar | **Udhar khata** → **Sell on udhar**. Same products; pick the customer, then all on udhar or part paid now |
| Customer pays udhar | **Udhar khata** → the customer → **Receive payment** (cash, Easypaisa, JazzCash or bank) |
| Remind a customer | The customer's page → **WhatsApp reminder** opens WhatsApp with the amount filled in |
| Bring over the paper register | **Udhar khata** → **+ Add customer** → "Already owes" (owner only) |
| Change shop details | **Settings** |
| Put your shop's logo on screen and receipts | **Settings** → Shop logo → Choose picture, then **Save** |
| Back up | Automatic. See **Backups** in the menu, and connect Google Drive (see below) |

---

## Backing up — read this

Everything lives in one file: **`data/stockly.db`** inside the Stockly folder.

Stockly backs it up by itself. Open **Backups** in the menu (owner only):

- **On this computer:** a copy is saved in `data/backups` at the times you
  choose (9 PM unless you change it), and the last 7 are kept. If the
  computer was off at every time, Stockly backs up soon after it starts.
- **Google Drive** (when your supplier has switched it on): press **Connect Google Drive** and sign in once. Each
  backup is then uploaded to a **Stockly backups** folder in your Drive.
  Stockly can only see that folder, nothing else in your Drive.
- **Back up now** and **Download backup** do it straight away.

The dashboard warns you if there has been no backup for 3 days.

> A copy on the same computer does not survive the computer dying. Connect
> Google Drive, or copy `data/backups` to a USB stick every week.

### Restoring a backup

Use this after a mistake, or on a new computer after the old one died.

1. Open **Backups** in the menu, on the shop computer (owner only).
2. Under **Restore from a backup**, press **Choose backup file** and pick the
   backup: a `stockly-backup-….db` from **Download backup**, or a
   `stockly-backup-….db.gz` from Google Drive or a USB stick. To go back to a
   copy already on this computer, press **Restore** next to it instead.
3. Stockly shows what is inside — the shop, how many products, sales and
   khata customers, and the last sale. Check it is the right one, then press
   **Restore this backup**.
4. Double-click **Stop Stockly**, then **Start Stockly** (or restart the
   computer). The restore finishes by itself as Stockly starts.

Everything that was in Stockly before is kept as
`data/backups/before-restore-<date>.db`, so a restore can itself be undone
the same way. The licence already entered on this computer stays.

**On a new computer:** install Stockly and enter its licence first (a key
for the new computer — see "This licence belongs to another computer"
below), then restore. Connect Google Drive and phone access again afterwards.

The JSON from **Settings → Export everything** is a readable record, not a
backup: it cannot be restored.

**By hand, only if Stockly will not start:** stop Stockly, unzip the backup
and name it `stockly.db`, put it in the `data` folder in place of the old
one, **delete `stockly.db-wal` and `stockly.db-shm` from the `data` folder if
they are there** (otherwise the old changes are replayed onto the backup),
then start Stockly.

There is also **Settings → Export everything**, which downloads all records as
a readable file.

---

## Phones and tablets

Phones reach Stockly through a secure **https** link that belongs to the
shop's own free ngrok account. Stockly opens the link by itself; nothing else
is installed. The shop computer accepts no other connections.

**Set it up once, on the shop computer** (about three minutes):

1. Open **Phone access** in the menu (owner only).
2. Make a free account at ngrok.com — the page links straight to it.
3. Copy **Your Authtoken** from the ngrok dashboard and paste it in.
4. Copy your free domain from **Domains** in the ngrok dashboard and paste it
   in, so the link never changes. (Optional, but recommended.)
5. Press **Save and turn on**. The link and a QR code appear.

**On each phone:** scan the QR code or open the link, tap **Visit Site** on
the ngrok notice the first time, sign in, then **Add to Home Screen**.

Good to know:

- The computer must be on with Stockly running, and both the computer and
  the phone need internet. If the shop's internet drops, the computer keeps
  selling and phones reconnect when it is back.
- Over the link, the camera barcode scanner and "install as an app" work on
  phones too, because the link is https.
- Anyone with the link reaches the sign-in page. Use strong passwords, give
  staff their own cashier accounts, and remove them when they leave.
- First-run setup, the licence, connecting Google Drive and Phone access
  itself only work on the shop computer, never through the link.
- **Turn off** on the Phone access page closes the link at once.
- Each shop needs its own ngrok account: one account cannot run two shops.

---

## Forgotten password

On the shop's computer, open the Stockly folder in a terminal and run:

```
npm run reset-password -- owner@example.com
```

It asks for a new password and signs that account out everywhere.

---

## Updating to a newer version

1. Stop Stockly (close the black window).
2. **Copy the `data` folder somewhere safe first.**
3. Replace the program files with the new version, keeping your `data` folder
   and `.env` file.
4. Run `setup.bat` / `setup.command` again, then start as usual.

---

## When something goes wrong

| What you see | What to do |
|---|---|
| Setup says it can't download Node.js | The computer is offline. Connect it, then run setup again |
| Windows: "cannot see it yet" after installing Node | Close that window and double-click `setup.bat` again — it carries on |
| "This licence belongs to another computer" | Stockly has been moved to a different PC. Send the supplier the computer code on that screen and they will issue a new key |
| Browser says it can't connect | Stockly is not running — double-click **Start Stockly** |
| Phone link doesn't open | Check the computer is on and has internet, then **Phone access** on the computer: it says what is wrong |
| Phone access says ngrok did not accept the key | Copy the authtoken again from the ngrok dashboard and paste it in |
| "This can only be done on the shop's own computer" | Do it at the shop computer, not on the phone link |
| Nothing happens at login, or a black window still appears | Run `setup.bat` / `setup.command` again; it refreshes how Stockly starts |
| "Port 3000 is in use" | Something else uses that port. Close it, or ask the installer to change the port |
| Forgotten password | See above |
| Screen is blank after an update | Run setup again, then start |
