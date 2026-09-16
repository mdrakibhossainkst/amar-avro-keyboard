# Amar Avro Keyboard for macOS

Amar Avro Keyboard is a native, system-wide phonetic Bangla input method for
macOS. It works offline and supports both Apple Silicon and Intel Macs.

## Requirements

- macOS 11 or later
- Xcode Command Line Tools
- Rust toolchain with the macOS targets

```bash
rustup target add aarch64-apple-darwin x86_64-apple-darwin
```

## Build and install

Build the Universal app and install it for the current user:

```bash
make install
```

The input method is installed at:

```text
~/Library/Input Methods/Amar Avro Keyboard.app
```

To create the installer files:

```bash
make build
bash scripts/create_dmg.sh
```

The generated DMG and PKG files are placed in `build/`.

## Add the input source

1. Open **System Settings → Keyboard → Text Input → Edit**.
2. Click **+** and open the **Bengali** category.
3. Select **Amar Avro Keyboard** and click **Add**.
4. Switch input sources with **Control + Space** or the Globe key.

If it does not appear immediately after the first installation, log out once
and log back in.

## Typing modes

- **Phonetic-first** — keeps the direct phonetic conversion selected while
  alternatives remain available.
- **Smart Suggestions** — prioritizes results using the dictionary, autocorrect
  and previous selections.
- **Phonetic-only** — performs direct conversion without a candidate window.

## Privacy

Typing and suggestions are processed locally. The app does not send typed text,
usage data or telemetry to an external service.

## Troubleshooting

Verify the installed location, Bundle ID and code signature:

```bash
bash scripts/diagnose-install.sh
```

The required identifiers are:

```text
Input Method: com.amaravrokeyboard.inputmethod.AmarAvroKeyboard
Installer:    com.amaravrokeyboard.pkg
```

## Test and uninstall

```bash
make test
make uninstall
```

## Project structure

- `AmarAvroKeyboard/` — Swift and InputMethodKit application
- `engine/` — native transliteration engine bridge
- `data/` — dictionary, autocorrect and layout data
- `scripts/` — build, installation, diagnostics and packaging scripts

## Developer

Developed by **Md Rakib Hossain**.

- [GitHub](https://github.com/mdrakibhossainkst/)
- [Facebook](https://www.facebook.com/itsrakiblxp)

## License

This project is distributed under the Mozilla Public License 2.0. Required
third-party copyright and source notices are included with the repository and
must be preserved when distributing modified builds.
