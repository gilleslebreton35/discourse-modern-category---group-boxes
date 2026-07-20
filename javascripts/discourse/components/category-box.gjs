import Component from "@glimmer/component";
import { trustHTML } from "@ember/template";
import CategoryLogo from "discourse/components/category-logo";
import CategoryTitleBefore from "discourse/components/category-title-before";
import CategoryTitleLink from "discourse/components/category-title-link";
import PluginOutlet from "discourse/components/plugin-outlet";
import borderColor from "discourse/helpers/border-color";
import categoryLink from "discourse/helpers/category-link";
import icon from "discourse/helpers/d-icon";
import lazyHash from "discourse/helpers/lazy-hash";

export default class extends Component {
  get backgroundColor() {
    return trustHTML(`background-color: #${this.args.category.color}`);
  }

  get getAbbreviation() {
    let abbr = this.args.category.name.replace(" and", "").split(" ");

    if (abbr.length > 1) {
      abbr =
        abbr[0].charAt(0).toUpperCase() + abbr[1].charAt(0).toLowerCase();
    } else {
      abbr =
        abbr[0].charAt(0).toUpperCase() + abbr[0].charAt(1).toLowerCase();
    }

    return abbr;
  }

  get unreadCount() {
    return this.args.category.unreadTopicsCount ?? 0;
  }

  get newCount() {
    return this.args.category.newTopicsCount ?? 0;
  }

  get hasNew() {
    return this.newCount > 0;
  }

  get hasUnread() {
    return this.unreadCount > 0;
  }

  get hasActivity() {
    return this.hasNew || this.hasUnread;
  }

  get newBadgeCount() {
    return this.newCount > 99 ? "99+" : this.newCount;
  }

  get unreadBadgeCount() {
    return this.unreadCount > 99 ? "99+" : this.unreadCount;
  }

  get newTitle() {
    return `${this.newCount} nouveau(x)`;
  }

  get unreadTitle() {
    return `${this.unreadCount} non lu(s)`;
  }

  <template>
    {{! template-lint-disable no-nested-interactive }}

    <a
      href={{@category.url}}
      data-category-id={{@category.id}}
      data-notification-level={{@category.notificationLevelString}}
      data-url={{@category.url}}
      class="category category-box category-box-{{@category.slug}}
        {{if @category.isMuted 'muted'}}
        {{if this.noCategoryStyle 'no-category-boxes-style'}}
        {{if this.hasActivity 'has-activity'}}"
    >
      <div class="category-box-inner">
        <div
          class="category-logo
            {{if @category.uploaded_logo.url '' 'no-logo-present'}}"
          style={{this.backgroundColor}}
        >
          {{#if @category.uploaded_logo.url}}
            <CategoryLogo @category={{@category}} />
          {{else}}
            <span class="category-abbreviation">
              {{this.getAbbreviation}}
            </span>
          {{/if}}
        </div>

        <div class="category-details">
          <div class="category-box-heading">
            <a class="parent-box-link" href={{@category.url}}>
              <div class="category-heading-row">
                <h3 class="category-title">
                  <span class="category-title-text">
                    <CategoryTitleBefore @category={{@category}} />
                    {{#if @category.read_restricted}}
                      {{icon "lock"}}
                    {{/if}}
                    <span class="category-name">{{@category.name}}</span>
                  </span>
                </h3>

                {{#if this.hasActivity}}
                  <span class="category-activity-badges">
                    {{#if this.hasNew}}
                      <span
                        class="category-activity-badge is-new"
                        title={{this.newTitle}}
                        aria-label={{this.newTitle}}
                      >
                        {{this.newBadgeCount}}
                      </span>
                    {{/if}}

                    {{#if this.hasUnread}}
                      <span
                        class="category-activity-badge is-unread"
                        title={{this.unreadTitle}}
                        aria-label={{this.unreadTitle}}
                      >
                        {{this.unreadBadgeCount}}
                      </span>
                    {{/if}}
                  </span>
                {{/if}}
              </div>
            </a>
          </div>

          <div class="description">
            <p>{{trustHTML @category.description_excerpt}}</p>
          </div>

          {{#if @category.isGrandParent}}
            {{#each @category.subcategories as |subcategory|}}
              <a
                href={{subcategory.url}}
                data-category-id={{subcategory.id}}
                data-notification-level={{subcategory.notificationLevelString}}
                style={{borderColor subcategory.color}}
                class="subcategory with-subcategories
                  {{if subcategory.uploaded_logo.url 'has-logo' 'no-logo'}}"
              >
                <div class="subcategory-box-inner">
                  <CategoryTitleLink @tagName="h4" @category={{subcategory}} />
                  {{#if subcategory.subcategories}}
                    <div class="subcategories">
                      {{#each subcategory.subcategories as |subsubcategory|}}
                        {{#unless subsubcategory.isMuted}}
                          <span class="subcategory">
                            <CategoryTitleBefore @category={{subsubcategory}} />
                            {{categoryLink subsubcategory hideParent="true"}}
                          </span>
                        {{/unless}}
                      {{/each}}
                    </div>
                  {{/if}}
                </div>
              </a>
            {{/each}}
          {{else if @category.subcategories}}
            <div class="subcategories">
              {{#each @category.subcategories as |sc|}}
                <a class="subcategory" href={{sc.url}}>
                  <span class="subcategory-image-placeholder">
                    <CategoryLogo @category={{sc}} />
                  </span>
                  {{categoryLink sc hideParent="true"}}
                </a>
              {{/each}}
            </div>
          {{/if}}
        </div>

        <PluginOutlet
          @name="category-box-below-each-category"
          @connectorTagName=""
          @outletArgs={{lazyHash category=@category}}
        />
      </div>
    </a>
  </template>
}
