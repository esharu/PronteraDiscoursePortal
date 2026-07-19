import Component from "@glimmer/component";
import { service } from "@ember/service";

// `settings` is the theme-settings global injected by Discourse into theme JS.
/* global settings */

export default class PronteraPortal extends Component {
  @service router;

  // Only render on the site homepage ("/"), and only when enabled.
  get show() {
    if (!settings.portal_enabled) {
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
    return settings.hero_cta_label;
  }
  get ctaUrl() {
    return settings.hero_cta_url || "/latest";
  }
  get ctaSecondaryLabel() {
    return settings.hero_cta_secondary_label;
  }
  get ctaSecondaryUrl() {
    return settings.hero_cta_secondary_url || "/categories";
  }

  // Instance cards, driven entirely by settings so copy/links stay code-free.
  get instances() {
    const list = [];
    if (settings.ro3_enabled) {
      list.push({
        name: settings.ro3_name,
        tagline: settings.ro3_tagline,
        url: settings.ro3_url,
        seal: "3",
        accent: "banner-red",
      });
    }
    if (settings.roz_enabled) {
      list.push({
        name: settings.roz_name,
        tagline: settings.roz_tagline,
        url: settings.roz_url,
        seal: "Z",
        accent: "gold",
      });
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
                viewBox="0 0 120 122"
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
                <a class="prontera-portal__btn prontera-portal__btn--primary" href={{this.ctaUrl}}>
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
            <a
              class="prontera-card"
              data-accent={{inst.accent}}
              href={{inst.url}}
            >
              <span class="prontera-card__seal" data-accent={{inst.accent}}>
                {{inst.seal}}
              </span>
              <span class="prontera-card__text">
                <span class="prontera-card__name">{{inst.name}}</span>
                <span class="prontera-card__tagline">{{inst.tagline}}</span>
              </span>
              <span class="prontera-card__go" aria-hidden="true">→</span>
            </a>
          {{/each}}
        </div>
      </section>
    {{/if}}
  </template>
}
