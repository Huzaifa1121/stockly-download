# Installing Stockly on a shop's computer

Stockly runs on the shop's own computer. The shop's data never leaves that
machine. No internet is needed to sell.

One computer holds the data. Other devices in the shop — a phone, a tablet,
a second till — open it in a browser over the shop's wi-fi, or through ngrok
from anywhere (see the end of this guide).

---

## What you need

- A Windows PC or a Mac that stays on while the shop is open
- An internet connection **for the install only** — after that, selling works offline

Setup installs everything else itself, including Node.js, which Stockly runs
on. It asks first, then asks for the computer's password, because installing
software always does. There is no database to install.

---

## Install it

1. Copy the **stockly** folder onto the computer, for example into Documents.
2. Open the folder and double-click **Start Stockly**.
3. Wait. The first time it installs everything it needs and takes a few
   minutes; after that it opens in seconds.

> **Mac:** if it says the file is from an unidentified developer, right-click
> **Start Stockly** → **Open** → **Open**. You only do this once.

---

## Start it

If you said yes to "start automatically" during setup, there is nothing to
do: Stockly is already running in the background from the moment the
computer turns on, with no window to close by mistake. Open it from its icon
(see **Make it an app** below) or at `http://localhost:3000`.

Otherwise, double-click **Start Stockly** — the same file, every day. A black
window opens, and Stockly opens in its own window if it has been installed
as an app, or in the browser if not.

**Leave the black window open.** Closing it stops Stockly.

To stop Stockly whichever way it was started, double-click **Stop Stockly**.

---

## The first screen

The very first screen asks for the **licence key** that came with the
purchase. Paste it in and press Activate — it is only asked once, on this
computer, and needs no internet.

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
| Change shop details | **Settings** |
| Put your shop's logo on screen and receipts | **Settings** → Shop logo → Choose picture, then **Save** |
| Back up | Copy the `data` folder somewhere safe (see below) |

---

## Backing up — read this

Everything lives in one file: **`data/stockly.db`** inside the Stockly folder.

Copy that folder to a USB stick or cloud drive **every week**. To restore, copy
it back into place while Stockly is stopped.

There is also **Settings → Export everything**, which downloads all records as
a readable file.

> If the computer dies and you have no copy of `data`, the shop's records are
> gone. Nobody else holds them.

---

## Other devices in the shop

While Stockly is running, find the computer's address on the shop wi-fi:

- **Windows:** open the black window and type `ipconfig`; look for IPv4 Address
- **Mac:** System Settings → Network

Other devices then open `http://THAT-ADDRESS:3000`, for example
`http://192.168.1.5:3000`.

The camera barcode scanner needs either `localhost` or HTTPS, so on other
devices over plain wi-fi you can still type or use a USB scanner.

---

## Reaching the shop from anywhere (optional, ngrok)

1. Install ngrok from [ngrok.com](https://ngrok.com) and sign in to get your token.
2. `ngrok config add-authtoken YOUR_TOKEN`
3. With Stockly running, in another window: `ngrok http 3000`
4. ngrok prints an `https://…` address that works from anywhere.

**If you use ngrok, open the `.env` file in the Stockly folder and set:**

```
COOKIE_SECURE="true"
APP_URL="https://your-ngrok-address"
```

Then stop and start Stockly again.

> The address is public: anyone with it reaches your sign-in page. Use a
> strong password, and only share the link with people you trust.

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
| Nothing happens at login, or a black window still appears | Run `setup.bat` / `setup.command` again; it refreshes how Stockly starts |
| "Port 3000 is in use" | Something else uses that port. Close it, or ask the installer to change the port |
| Forgotten password | See above |
| Screen is blank after an update | Run setup again, then start |
