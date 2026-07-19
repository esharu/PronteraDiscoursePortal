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

  get eyebrow() {
    return settings.hero_eyebrow;
  }
  get title() {
    return settings.hero_title;
  }
  get subtitle() {
    return settings.hero_subtitle;
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
        <div class="prontera-portal__hero">
          <p class="prontera-portal__eyebrow">{{this.eyebrow}}</p>
          <h1 class="prontera-portal__title">{{this.title}}</h1>
          <p class="prontera-portal__subtitle">{{this.subtitle}}</p>
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
