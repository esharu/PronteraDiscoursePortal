import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";
import { countdown, leadWoe } from "../lib/prontera-woe";

// The homepage's live section under the hub cards: the forum's newest topics
// beside a rail that mirrors the hub home — "Right now" (launch day, War of
// Emperium countdown, next release beat) and the newest marketplace
// listings. Hub data comes from each hub's /api/portal/feed (passed in as
// @feeds by the portal); rows whose data is missing are simply left out.

const SEALS = { ro3: "3", roz: "Z" };
const monthFormat = new Intl.DateTimeFormat("en-US", {
  month: "long",
  year: "numeric",
  timeZone: "UTC",
});
const dayFormat = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  timeZone: "UTC",
});
const priceFormat = new Intl.NumberFormat("en-US");

function ago(iso) {
  const ms = Date.now() - new Date(iso).getTime();
  if (!Number.isFinite(ms)) {
    return "";
  }
  const min = Math.floor(ms / 60_000);
  if (min < 60) {
    return `${Math.max(1, min)}m`;
  }
  const h = Math.floor(min / 60);
  if (h < 24) {
    return `${h}h`;
  }
  const d = Math.floor(h / 24);
  return d < 30 ? `${d}d` : dayFormat.format(new Date(iso));
}

function milestoneWhen(m) {
  if (m.official_month) {
    return monthFormat.format(new Date(`${m.official_month}-01T00:00:00Z`));
  }
  if (m.predicted_date) {
    return `~ ${dayFormat.format(new Date(`${m.predicted_date}T00:00:00Z`))}`;
  }
  return "";
}

export default class PronteraHomeLive extends Component {
  @tracked now = Date.now();
  @tracked topics = [];

  timer = null;

  constructor() {
    super(...arguments);
    this.loadTopics();
    this.timer = setInterval(() => (this.now = Date.now()), 1000);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearInterval(this.timer);
  }

  async loadTopics() {
    try {
      const data = await ajax("/latest.json");
      const list = data?.topic_list?.topics ?? [];
      if (!this.isDestroying && !this.isDestroyed) {
        this.topics = list
          .filter((t) => !t.pinned_globally)
          .slice(0, 7)
          .map((t) => {
            const category = Category.findById(t.category_id);
            return {
              rawTitle: t.title,
              url: `/t/${t.slug}/${t.id}`,
              unread: !!(t.unseen || t.unread_posts),
              replies: Math.max(0, (t.posts_count || 1) - 1),
              when: ago(t.bumped_at || t.last_posted_at || t.created_at),
              category: category?.name ?? "",
              // Category colours are 3/6-digit hex from core; anything else
              // falls back rather than reaching a style attribute.
              dotStyle: htmlSafe(
                `background:#${/^[0-9a-f]{3,6}$/i.test(category?.color || "") ? category.color : "31465c"}`
              ),
            };
          });
      }
    } catch {
      // The live list is a bonus on top of the category list below it.
    }
  }

  get hubs() {
    const feeds = this.args.feeds || {};
    return ["roz", "ro3"]
      .map((key) => ({ key, feed: feeds[key] }))
      .filter((h) => h.feed);
  }

  // One "Right now" block per hub that has something to say.
  get rightNow() {
    return this.hubs
      .map(({ key, feed }) => {
        const rows = [];
        const woe = leadWoe(feed.woe, this.now);
        if (woe) {
          const open = woe.next.status === "open";
          rows.push({
            kind: "woe",
            title: `War of Emperium · ${woe.region}`,
            clock: countdown((open ? woe.next.end : woe.next.start) - this.now),
            meta: open ? "running · ends in" : "starts in",
            open,
          });
        }
        if (feed.next_milestone) {
          rows.push({
            kind: "milestone",
            title: `Next: ${feed.next_milestone.title}`,
            meta: milestoneWhen(feed.next_milestone),
          });
        }
        let day = null;
        if (feed.launch_date) {
          const days = Math.floor(
            (this.now - new Date(feed.launch_date).getTime()) / 86_400_000
          );
          day = days >= 0 ? days : null;
        }
        return {
          key,
          seal: SEALS[key],
          name: feed.site?.game || feed.site?.name || key,
          url: feed.site?.url,
          day,
          rows,
        };
      })
      .filter((block) => block.rows.length || block.day !== null);
  }

  get listings() {
    return this.hubs
      .flatMap(({ feed }) => feed.listings || [])
      .slice(0, 4)
      .map((l) => ({
        ...l,
        kindLabel: String(l.kind || "").toUpperCase(),
        price:
          typeof l.price_zeny === "number"
            ? `${priceFormat.format(l.price_zeny)} z`
            : "",
        image:
          typeof l.item_image === "string" && l.item_image.startsWith("https://")
            ? l.item_image
            : null,
      }));
  }

  get marketplaceUrl() {
    const hub = this.hubs.find(({ feed }) => (feed.listings || []).length);
    return hub ? `${String(hub.feed.site?.url || "").replace(/\/+$/, "")}/marketplace` : null;
  }

  <template>
    <section class="prontera-live" aria-label="Live">
      <div class="prontera-live__main">
        <div class="prontera-live__head">
          <h2 class="prontera-live__title">Latest from the forum</h2>
          <a class="prontera-live__more" href="/latest">All topics →</a>
        </div>
        <ul class="prontera-live__topics">
          {{#each this.topics as |t|}}
            <li class="prontera-live__topic {{if t.unread '--unread'}}">
              <a class="prontera-live__topic-title" href={{t.url}}>{{t.rawTitle}}</a>
              <span class="prontera-live__topic-meta">
                <span class="prontera-live__dot" style={{t.dotStyle}}></span>
                {{t.category}}
              </span>
              <span class="prontera-live__topic-num">{{t.replies}}</span>
              <span class="prontera-live__topic-when">{{t.when}}</span>
            </li>
          {{/each}}
        </ul>
      </div>

      <aside class="prontera-live__rail">
        {{#each this.rightNow as |block|}}
          <div class="prontera-live__card">
            <p class="prontera-live__kicker">
              <span class="prontera-live__seal" data-game={{block.key}}>{{block.seal}}</span>
              Right now
              {{#if block.day}}
                · <span class="prontera-live__day">Day {{block.day}} since launch</span>
              {{/if}}
            </p>
            {{#each block.rows as |row|}}
              <div class="prontera-live__row" data-kind={{row.kind}}>
                <span class="prontera-live__row-title">{{row.title}}</span>
                <span class="prontera-live__row-meta">{{row.meta}}</span>
                {{#if row.clock}}
                  <span class="prontera-live__clock {{if row.open '--open'}}">{{row.clock}}</span>
                {{/if}}
              </div>
            {{/each}}
            {{#if block.url}}
              <a class="prontera-live__more" href={{block.url}}>Open {{block.name}} →</a>
            {{/if}}
          </div>
        {{/each}}

        {{#if this.listings.length}}
          <div class="prontera-live__card">
            <p class="prontera-live__kicker">Marketplace · new</p>
            {{#each this.listings as |l|}}
              <a class="prontera-live__listing" href={{l.url}}>
                <span class="prontera-live__art">
                  {{#if l.image}}<img src={{l.image}} alt="" loading="lazy" />{{/if}}
                </span>
                <span class="prontera-live__listing-text">
                  <span class="prontera-live__listing-name">{{l.item_name}}</span>
                  <span class="prontera-live__listing-meta">{{l.game_server}} {{l.price}}</span>
                </span>
                <span class="prontera-live__badge" data-kind={{l.kind}}>{{l.kindLabel}}</span>
              </a>
            {{/each}}
            {{#if this.marketplaceUrl}}
              <a class="prontera-live__more" href={{this.marketplaceUrl}}>All listings →</a>
            {{/if}}
          </div>
        {{/if}}
      </aside>
    </section>
  </template>
}
