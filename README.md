# QuickKart

QuickKart is a quick-commerce shopping app built with Flutter. Daily essentials,
fresh produce and household items are delivered to your door in minutes.

## Highlights

- QuickKart branded app icon, splash screen and onboarding experience
- Superstore catalog — 16 categories and 78 grocery items with crisp Google
  Noto Emoji product imagery (works offline, identical on all devices);
  home shows popular items, everyday essentials and fresh picks
- Product details screen with hero image, description, price and trust
  bullets, opened by tapping any product tile in home, categories or search
- Promo code `quick20` — flat 20% off, valid only on the first order
  (cancelled orders do not consume it); applied inline in checkout with a
  friendly rejection message for unknown or used codes
- Signup with name, mobile number and password, then secure password login
- Continue with Google using a locally saved Google profile
- "Edit profile name, mobile number, Google email and gallery profile photo"
- Working product search with keyword filtering, category chips and empty state
- Browse categories, add products to cart and check out
- Working payment step: card, JazzCash and Easypaisa pay before the order
  confirmation; cash on delivery skips the payment step
- My Orders with item, payment and delivery details, saved across app restarts
- Cancel a confirmed order from My Orders; paid orders are marked for refund
- AI Shopping Assistant chat with product suggestions and one-tap add to cart;
  the assistant always replies in English. Runs on the free Gemini API key or
  a built-in demo matcher
- Clear cart button on the cart screen that empties the cart in one tap
- Stay logged in between app restarts; logout clears the saved session
- Saved addresses with add, edit, delete and default selection, stored on the
  device across app restarts; editing saves on the first tap without
  validation blockers
- Help & Support with the QuickKart helpline (`0340 6632190`)
- About QuickKart screen with brand and product information
- Order confirmation and empty-cart states

> The login session, placed orders and saved addresses are all saved on the
> device and survive closing and reopening the app.

## Accounts and login

QuickKart uses a local signup and password login flow.

- **Create account** asks for a full name, a Pakistani mobile number
  (`0300 1234567` or `3001234567`) and a password of at least 6 characters.
  Signup only creates the account and returns to the login screen with the
  mobile number filled in.
- **Login** accepts the registered mobile number and password. A successful
  login opens the shopping home screen and the account tab shows the
  registered name and number.
- **Continue with Google** opens an account chooser. Enter a name and Google
  email the first time, then reuse the saved Google profile for later logins.
  This is a local demo flow, not a real Google OAuth connection.
- **Search** opens from the home header. It filters products live by name,
  unit or category, supports popular search terms and category chips, and shows
  an empty state with a clear-search action when nothing matches.
- **Superstore catalog** — beyond the original categories there are
  `Atta, Rice & Dal`, `Spices & Sauces`, `Meat & Fish`, `Instant & Frozen`,
  `Tea & Coffee`, `Baby Care`, `Pet Care` and `Pharmacy`. Product and category
  tiles show Google Noto Emoji images (Apache 2.0) bundled in
  `assets/products/`; refresh them with `dart run tool/fetch_product_images.dart`.
- **Payment step** — choosing a card, JazzCash or Easypaisa at checkout opens a
  payment screen first. Card payments ask for the 16-digit number, MM/YY
  expiry, CVV and cardholder name; wallets ask for the mobile wallet number and
  MPIN. The payment is validated and processed before the order confirmation,
  and paid orders show a `Paid` status with a masked reference (for example
  `•••• 4242`). Cancelling the payment screen keeps the cart intact. Cash on
  delivery skips the payment step and is marked `Pay on delivery`.
- **Cancel order** — every confirmed order in My Orders shows a `Cancel order`
  button. Confirming the dialog marks the order as `Cancelled` and the change
  is saved locally; cancelled cards turn red and paid orders show a refund
  note. A cancelled order cannot be cancelled again.
- **Edit profile** opens from the account card. Phone accounts can update their
  name and mobile number; Google accounts can update their name and Google
  email. Both account types can pick a profile photo from the gallery or remove
  it. Photos are compressed, stored locally and reflected across the app.
- **Stay logged in** — closing and reopening the app reopens the last logged-in
  account automatically. The session is stored in `quickkart_session.json`
  next to the accounts file, and logging out clears it.
- **Log out** clears the active session and returns to the login screen.

Accounts are stored in the app's private storage as
`quickkart_accounts.json` through a small native `MethodChannel`, placed
orders are stored as `quickkart_orders.json` and saved addresses as
`quickkart_addresses.json`. No SMS gateway or backend is required.
Passwords are stored locally in plain text for this demo build; move
authentication to a secure backend before a public production release.

## AI Shopping Assistant (free Gemini)

The home header shows an AI button and an `AI Assistant` chip that open an AI
chat. Ask for groceries in your own words — for example `Fruits under Rs 300` —
and the assistant replies in English with product cards that can be added to
the cart one by one or all together.

- **Free API key:** create a key at [aistudio.google.com](https://aistudio.google.com)
  (Google account → *Get API key* → *Create API key*). The free tier is enough
  for a demo; no credit card is required.
- **Use the key:** open the AI chat, tap the key icon (or `Add key` on the demo
  banner), paste the key and save. Requests go directly to Google's
  `generativelanguage.googleapis.com` endpoint using the `gemini-2.5-flash`
  model, and the key is stored on the device only.
- **Compile-time key (never committed):** the repository contains no Gemini
  key. Keep yours in `config/ai_key.json` (git-ignored; template in
  `config/ai_key.example.json`) and pass it at build/run time:
  `flutter run --dart-define-from-file=config/ai_key.json` or
  `flutter build apk --dart-define-from-file=config/ai_key.json`. This key
  always wins over the key saved on the device.
- **Demo mode:** without a key (or when the request fails) the assistant falls
  back to a local matcher that understands product names and budgets, and the
  chat shows a demo banner. The feature never breaks; it just answers smarter
  with a real key.
- **Security note:** the key lives in the app's private storage or in the
  git-ignored config file — never hardcode it in `lib/`. Do not ship a key
  inside a production APK either; embedding secrets in the app binary is not
  safe. Use a small backend proxy that keeps the key server-side if you
  publish the app.

## Run

```sh
flutter pub get
flutter run
```

## Brand assets

- `assets/icon/quickkart_icon.png` - launcher icon
- `assets/icon/quickkart_icon_foreground.png` - adaptive icon foreground
- `assets/images/quickkart_splash_lockup.png` - splash lockup
- `assets/images/quickkart_logo.png` - in-app brand mark

Regenerate the platform launcher icons with:

```sh
dart run flutter_launcher_icons
```

The splash screens are already generated and committed. To regenerate them,
temporarily add `flutter_native_splash` to `dev_dependencies` and run:

```sh
dart run flutter_native_splash:create
```

