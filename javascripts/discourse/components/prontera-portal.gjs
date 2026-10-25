import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";

// `settings` is the theme-settings global injected by Discourse into theme JS.
/* global settings */

const numberFormat = new Intl.NumberFormat("en-US");
const dateFormat = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
});

// Each hub publishes GET /api/portal/feed (esharu/printera,
// server/api/portal/feed.get.ts): who it is, how big its database is and
// its latest news — public, cached and CORS-open for exactly this component.
async function loadFeed(hubUrl) {
  const base = (hubUrl || "").replace(/\/+$/, "");
  if (!base) {
    return null;
  }
  try {
    const response = await fetch(`${base}/api/portal/feed`, {
      credentials: "omit",
    });
    return response.ok ? await response.json() : null;
  } catch {
    // A hub that is down must not take the forum homepage with it: the
    // card keeps its static copy from the settings.
    return null;
  }
}

function totalsLine(totals) {
  if (!totals) {
    return null;
  }
  return [
    [totals.mobs, "Monsters"],
    [totals.items, "Items"],
    [totals.cards, "Cards"],
  ]
    .filter(([n]) => Number.isFinite(n) && n > 0)
    .map(([n, label]) => `${numberFormat.format(n)} ${label}`)
    .join(" · ");
}

function latestNews(feed) {
  const item = feed?.news?.[0];
  if (!item) {
    return null;
  }
  const date = new Date(item.created_at);
  return {
    title: item.title,
    url: item.url,
    date: Number.isNaN(date.getTime()) ? "" : dateFormat.format(date),
  };
}

export default class PronteraPortal extends Component {
  @service router;
  @service currentUser;

  @tracked feeds = {};

  constructor() {
    super(...arguments);
    if (settings.portal_enabled) {
      this.loadFeeds();
    }
  }

  async loadFeeds() {
    const [ro3, roz] = await Promise.all([
      settings.ro3_enabled ? loadFeed(settings.ro3_url) : null,
      settings.roz_enabled ? loadFeed(settings.roz_url) : null,
    ]);
    if (!this.isDestroying && !this.isDestroyed) {
      this.feeds = { ro3, roz };
    }
  }

  // Only render on the site homepage ("/"), and only when enabled.
  get show() {
    if (!settings.portal_enabled) {
      return false;
    }
    if (settings.hide_hero_for_members && this.currentUser) {
      return false;
    }
    const url = this.router.currentURL || "/";
    return url === "/" || url.startsWith("/?");
  }

  get showEmblem() {
    return settings.hero_emblem;
  }
  get eyebrow() {
    return settings.hero_eyebrow;
  }
  get title() {
    return settings.hero_title;
  }
  get subtitle() {
    return settings.hero_subtitle;
  }

  get ctaLabel() {
    return (settings.hero_cta_label || "").trim();
  }
  get ctaUrl() {
    return settings.hero_cta_url || "/latest";
  }
  get ctaSecondaryLabel() {
    return (settings.hero_cta_secondary_label || "").trim();
  }
  get ctaSecondaryUrl() {
    return settings.hero_cta_secondary_url || "/categories";
  }

  // Instance cards: static copy from settings, enriched with the hub's live
  // database size and latest news once its feed has answered.
  get instances() {
    const list = [];
    const card = (key, seal, accent) => {
      const feed = this.feeds[key];
      return {
        key,
        name: settings[`${key}_name`],
        tagline: settings[`${key}_tagline`],
        url: settings[`${key}_url`],
        seal,
        accent,
        totals: totalsLine(feed?.totals),
        news: latestNews(feed),
      };
    };
    if (settings.ro3_enabled) {
      list.push(card("ro3", "3", "banner-red"));
    }
    if (settings.roz_enabled) {
      list.push(card("roz", "Z", "gold"));
    }
    return list;
  }

  <template>
    {{#if this.show}}
      <section class="prontera-portal">
        <div class="prontera-portal__band">
          <div class="prontera-portal__hero">
            {{#if this.showEmblem}}
              <svg
                class="prontera-portal__emblem"
                viewBox="0 0 120 136"
                aria-hidden="true"
              >
                <path
                  d="M60,6 C86,6 105,21 105,47 C105,85 79,111 60,133 C41,111 15,85 15,47 C15,21 34,6 60,6 Z"
                  fill="var(--p-midnight, #1d2d3f)"
                  stroke="#31465c"
                  stroke-width="2"
                />
                <rect x="27" y="68" width="16" height="40" fill="var(--p-parchment, #f4ead2)" />
                <path d="M24,68 L35,49 L46,68 Z" fill="var(--p-verdigris, #37877b)" />
                <rect x="77" y="68" width="16" height="40" fill="var(--p-parchment, #f4ead2)" />
                <path d="M74,68 L85,49 L96,68 Z" fill="var(--p-verdigris, #37877b)" />
                <rect x="49" y="52" width="22" height="56" fill="var(--p-parchment, #f4ead2)" />
                <path d="M45,52 L60,25 L75,52 Z" fill="var(--p-verdigris, #37877b)" />
                <path d="M54,108 L54,94 A6,6 0 0 1 66,94 L66,108 Z" fill="var(--p-midnight, #1d2d3f)" />
                <rect x="24" y="106" width="72" height="2.6" fill="var(--p-gold, #d9a441)" />
                <path
                  d="M78,93.2 C79,91.4 80.8,91.4 81.2,92.9 C84.2,94.1 86.2,96.7 86.2,99.8 C86.2,103.5 82.7,105.9 78,105.9 C73.3,105.9 69.8,103.5 69.8,99.8 C69.8,96.7 71.8,94.1 74.8,92.9 C75.2,91.4 77,91.4 78,93.2 Z"
                  fill="var(--p-poring, #f08ba5)"
                />
                <circle cx="75.4" cy="99.6" r="1.35" fill="var(--p-midnight, #1d2d3f)" />
                <circle cx="80.6" cy="99.6" r="1.35" fill="var(--p-midnight, #1d2d3f)" />
                <rect x="58.7" y="10" width="2.6" height="17" rx="1.3" fill="var(--p-gold, #d9a441)" />
                <path d="M61,11 L80,16 L61,21 Z" fill="var(--p-banner-red, #c4453c)" />
              </svg>
            {{/if}}

            <p class="prontera-portal__eyebrow">{{this.eyebrow}}</p>
            <h1 class="prontera-portal__title">{{this.title}}</h1>
            <p class="prontera-portal__subtitle">{{this.subtitle}}</p>

            <div class="prontera-portal__cta">
              {{#if this.ctaLabel}}
                <a
                  class="prontera-portal__btn prontera-portal__btn--primary"
                  href={{this.ctaUrl}}
                >
                  {{this.ctaLabel}}
                </a>
              {{/if}}
              {{#if this.ctaSecondaryLabel}}
                <a class="prontera-portal__btn" href={{this.ctaSecondaryUrl}}>
                  {{this.ctaSecondaryLabel}}
                </a>
              {{/if}}
            </div>
          </div>
        </div>

        <div class="prontera-portal__cards">
          {{#each this.instances as |inst|}}
            <div class="prontera-card" data-accent={{inst.accent}}>
              <a class="prontera-card__main" href={{inst.url}}>
                <span class="prontera-card__seal" data-accent={{inst.accent}}>
                  {{inst.seal}}
                </span>
                <span class="prontera-card__text">
                  <span class="prontera-card__name">{{inst.name}}</span>
                  <span class="prontera-card__tagline">{{inst.tagline}}</span>
                  {{#if inst.totals}}
                    <span class="prontera-card__totals">{{inst.totals}}</span>
                  {{/if}}
                </span>
                <span class="prontera-card__go" aria-hidden="true">→</span>
              </a>
              {{#if inst.news}}
                <a class="prontera-card__news" href={{inst.news.url}}>
                  <span class="prontera-card__news-date">{{inst.news.date}}</span>
                  <span class="prontera-card__news-title">{{inst.news.title}}</span>
                </a>
              {{/if}}
            </div>
          {{/each}}
        </div>
      </section>
    {{/if}}
  </template>
}
