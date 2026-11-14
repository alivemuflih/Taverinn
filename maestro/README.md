# Maestro test preparation

This folder is reserved for Maestro mobile flows for the existing Taverinn UI.

No runnable YAML flow is checked in yet. The local audit could not build the APK because Android SDK Manager could not install NDK `28.2.13676358`, and the Maestro CLI is not available on PATH. Text selectors are visible in Flutter source but still need confirmation against the Android accessibility hierarchy before they are encoded as flows.

Use [../MOBILE_TESTING_READINESS.md](../MOBILE_TESTING_READINESS.md) for the 15 recommended flows, account roles, prerequisites, expected results, and realtime requirements. Never commit account passwords or Supabase secrets.
