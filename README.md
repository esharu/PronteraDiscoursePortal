# Prontera Portal (Discourse theme component)

Homepage hero + RO3/ROZ instance cards for the Prontera root domain
(**prontera.info**). Install as a **component** of the
[Prontera theme](https://github.com/esharu/PronteraDiscourse) — it relies on
the brand tokens that theme declares, with hex fallbacks so it degrades
safely on its own.

- Renders only on the site homepage (`/`) and only while `portal_enabled` is on.
- Injected above the discovery list via the `above-main-container` outlet.
- Each instance card shows the hub's live database size and latest news,
  fetched from the hub's public `/api/portal/feed` (cached, CORS-open). If a
  hub is down the card keeps its static copy.
- Under the cards, a live section: the forum's latest topics beside a rail
  with each hub's "Right now" (day since launch, War of Emperium countdown,
  next release beat) and the newest marketplace listings — the hub home's
  panel, from the same feed. Core's welcome banner is hidden on the homepage
  while it is on (setting `live_section_enabled`).
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
