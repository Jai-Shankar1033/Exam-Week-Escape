# vercel-site (compiled website)

This folder is what Vercel publishes. It is **generated**, not hand-written.

It is filled by running the Flutter web build and copying the result here:

    # Windows (PowerShell), from the project root
    .\tools\build_vercel_site.ps1

    # macOS / Linux / Git Bash
    bash tools/build_vercel_site.sh

Then commit and push. Vercel settings:

- Root Directory: `vercel-site`
- Framework Preset: Other
- Build Command: (empty)
- Output Directory: `.`

Re-run the script (and push) every time you change the game.
