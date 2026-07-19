# Prontera Portal (Discourse theme component)

Homepage hero + RO3/ROZ instance cards for the Prontera root domain
(**prontera.info**). Install as a **component** of the
[Prontera theme](https://github.com/esharu/PronteraDiscourse) — it relies on
the brand tokens that theme declares, with hex fallbacks so it degrades
safely on its own.

- Renders only on the site homepage (`/`) and only while `portal_enabled` is on.
- Injected above the discovery list via the `above-main-container` outlet.
- All copy and both instance cards (name, tagline, URL, enable/disable) are
  theme settings — see `settings.yml`. No code changes needed to retune the
  homepage.

## Install

**Admin → Customize → Themes → Install → From a git repository**:

```
https://github.com/esharu/PronteraDiscoursePortal.git
```

Then add it as a component of the **Prontera** theme under *Included
components*.

## Design

Uses the Prontera brand tokens (color scheme, Cinzel/Inter typography, card
vocabulary) established by the parent theme. Instance seals: **3** in Banner
Red (RO3), **Z** in Gold (ROZ), matching the hub emblem in `esharu/printera`.
