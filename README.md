<div align="center">

# DermaLogic

**AI-powered skincare routine engine that adapts to your skin, your products, and the weather around you.**

[![Python](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://www.python.org/)
[![Flet](https://img.shields.io/badge/UI-Flet-purple.svg)](https://flet.dev/)
[![Gemini](https://img.shields.io/badge/AI-Google%20Gemini-4285F4.svg)](https://ai.google.dev/)
[![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Android-lightgrey.svg)](#installation)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## Overview

DermaLogic is a cross-platform skincare assistant that builds personalized **morning and evening routines** by combining three signals:

1. **Your skin profile** — skin type, age range, allergies, conditions, goals, current stress level.
2. **Your product collection** — actives, textures, intended uses, incompatibilities.
3. **Live environmental data** — UV index, humidity, PM2.5 air quality, temperature, and a 3-day forecast for your city.

Those signals are sent to **Google Gemini**, which returns a structured routine with step-by-step instructions, alerts, and daily advice tailored to today's conditions.

## Features

- **AI-generated routines** powered by Google Gemini 2.5 Flash
- **Two analysis modes** — *Quick* (profile + products + weather) and *Detailed* (adds daily notes and current stress level)
- **Real-time environmental context** — UV, humidity, PM2.5, temperature, 3-day forecast
- **Smart product management** — manual entry or AI-assisted lookup that auto-fills product data from a name
- **Weather-aware activity tips** matched to your profile
- **Full user profile** — skin type, age, allergies, conditions, goals
- **Analysis history** with full routine details
- **Favorite cities** with cached weather
- **JSON export** of all your data
- **Responsive UI** — desktop and mobile layouts, dark theme
- **Cross-platform** — Windows, macOS, Linux, and Android (APK build supported)

## Installation

### Requirements

- Python 3.10 or higher
- An internet connection (Open-Meteo and Gemini APIs)
- A free [Google AI Studio](https://aistudio.google.com/) API key

### Desktop (Windows / macOS / Linux)

```bash
git clone https://github.com/S-Mopty/DermaLogic.git
cd DermaLogic

python -m venv venv
# Windows
venv\Scripts\activate
# macOS / Linux
source venv/bin/activate

pip install -r requirements.txt
python main.py
```

### Android (APK)

A prebuilt `DermaLogic.apk` is available at the root of the repository. To build your own:

```bash
pip install flet
flet build apk --project "DermaLogic" --org "com.dermalogic"
# Output: build/apk/
```

> The Android SDK must be installed and configured for `flet build apk` to succeed.

## Configuration

The Gemini API key is managed entirely from inside the app — no `.env` file required.

1. Generate a free key on [Google AI Studio](https://aistudio.google.com/).
2. Launch DermaLogic.
3. Open the **Settings** tab.
4. Paste your key and click **Save**.
5. Click **Test connection** to confirm.

The key is stored locally in the platform's user-data directory:

| Platform | Path |
|----------|------|
| Windows  | `%APPDATA%/DermaLogic/settings.json` |
| macOS    | `~/Library/Application Support/DermaLogic/settings.json` |
| Linux    | `~/.dermalogic/settings.json` |
| Android  | App-private internal storage |

## Usage

1. **Set up your profile** — *Profile* tab: skin type, age range, stress level, conditions, allergies, goals.
2. **Add your products** — *My Products* tab: manual entry or *Add with AI* (enter a name, Gemini fills the fields).
3. **Pick your city** — click the city name in the navigation bar to open the city picker; search or pick a favorite.
4. **Run an analysis** — *Analysis* tab:
   - **Quick** — routine based on profile, products, and weather.
   - **Detailed** — adds today's notes and your current stress level.

Results include a morning routine, evening routine, alerts, and daily advice.

## Architecture

```
DermaLogic/
├── main.py                          # Flet entry point
├── requirements.txt                 # Python dependencies (flet, requests)
├── DermaLogic.apk                   # Prebuilt Android binary
├── LICENSE
├── README.md
│
├── api/                             # External API clients
│   ├── open_meteo.py                # Weather, air quality, geocoding
│   └── gemini.py                    # Google Gemini (product analysis + routines)
│
├── core/                            # Business logic
│   ├── models.py                    # Enums and dataclasses (SkinType, DermaProduct, ...)
│   ├── analyseur.py                 # AI analysis orchestrator
│   ├── storage.py                   # Cross-platform storage (Windows/macOS/Linux/Android)
│   ├── config.py                    # City and favorites
│   ├── profil.py                    # User profile
│   ├── historique.py                # Analysis history
│   └── settings.py                  # API key management
│
└── gui/                             # Flet user interface
    ├── app.py                       # Main orchestrator (navigation, callbacks)
    ├── state.py                     # Global app state
    ├── theme.py                     # Colors, fonts, UI constants
    ├── data.py                      # Product persistence (JSON)
    ├── pages/
    │   ├── page_accueil.py          # Analysis + weather conditions
    │   ├── page_produits.py         # Product management
    │   ├── page_profil.py           # User profile
    │   ├── page_historique.py       # Analysis history
    │   └── page_parametres.py       # API key + export
    ├── dialogs/
    │   ├── formulaire_produit.py    # Product add/edit form
    │   ├── fenetre_recherche_ia.py  # AI product lookup
    │   └── fenetre_selection_ville.py
    └── components/
        ├── nav_bar.py               # Desktop + mobile navigation
        └── carte_environnement.py   # Weather card (UV, humidity, ...)
```

User data files (`settings.json`, `profile.json`, `produits_derma.json`, `historique.json`, `config.json`) are auto-generated in the platform's data directory on first run.

## APIs

### Open-Meteo (free, no key)

| Endpoint | Data |
|----------|------|
| `api.open-meteo.com/v1/forecast` | UV, humidity, temperature |
| `air-quality-api.open-meteo.com/v1/air-quality` | PM2.5 |
| `geocoding-api.open-meteo.com/v1/search` | City search |

### Google Gemini (key required)

| Model | Use |
|-------|-----|
| `gemini-2.0-flash` | Analyze a cosmetic product's properties |
| `gemini-2.5-flash` | Generate a personalized skincare routine |

## License

Released under the MIT License — see [LICENSE](LICENSE).
