// War of Emperium windows as moments in time — a port of the hub's
// shared/utils/woe-schedule.ts (esharu/printera). The hub's portal feed
// sends the schedule (UTC weekdays + "HH:MM"), not a countdown, because the
// feed is cached; the clock runs here.

const DAY_MS = 86_400_000;

function clock(hhmm) {
  const [h = 0, m = 0] = String(hhmm).split(":").map(Number);
  return { h, m };
}

// { status: "open" | "upcoming", start, end } for one window, or null.
export function nextWoeOccurrence(window, now) {
  if (!window || !Array.isArray(window.days) || !window.days.length) {
    return null;
  }
  const start = clock(window.start);
  const end = clock(window.end);
  const today = Math.floor(now / DAY_MS) * DAY_MS;
  let best = null;
  for (let offset = 0; offset <= 7; offset++) {
    const dayStart = today + offset * DAY_MS;
    if (!window.days.includes(new Date(dayStart).getUTCDay())) {
      continue;
    }
    const s = dayStart + (start.h * 60 + start.m) * 60_000;
    const e = dayStart + (end.h * 60 + end.m) * 60_000;
    if (now >= s && now < e) {
      return { status: "open", start: s, end: e };
    }
    if (s > now && (!best || s < best.start)) {
      best = { status: "upcoming", start: s, end: e };
    }
  }
  return best;
}

// The siege to headline across regions: a running one first, else the
// soonest — the same ordering as the hub's Right-now panel.
export function leadWoe(windows, now) {
  return (windows || [])
    .map((w) => ({ region: w.region, next: nextWoeOccurrence(w, now) }))
    .filter((r) => r.next)
    .sort(
      (a, b) =>
        Number(b.next.status === "open") - Number(a.next.status === "open") ||
        a.next.start - b.next.start
    )[0];
}

// "1d 06:41:12" / "06:41:12"
export function countdown(ms) {
  const total = Math.max(0, Math.floor(ms / 1000));
  const d = Math.floor(total / 86_400);
  const h = Math.floor((total % 86_400) / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = total % 60;
  const pad = (n) => String(n).padStart(2, "0");
  return `${d ? `${d}d ` : ""}${pad(h)}:${pad(m)}:${pad(s)}`;
}
