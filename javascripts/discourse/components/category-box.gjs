import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import CategoryLogo from "discourse/components/category-logo";
import CategoryTitleBefore from "discourse/components/category-title-before";
import CategoryTitleLink from "discourse/components/category-title-link";
import PluginOutlet from "discourse/components/plugin-outlet";
import borderColor from "discourse/helpers/border-color";
import categoryLink from "discourse/helpers/category-link";
import icon from "discourse/helpers/d-icon";
import htmlSafe0 from "discourse/helpers/html-safe";
import lazyHash from "discourse/helpers/lazy-hash";

export default class extends Component {
  get backgroundColor() {
    return htmlSafe(`background-color: #${this.args.category.color}`);
  }

  get getAbbreviation() {
    let abbr = this.args.category.name.replace(" and", "").split(" ");

    if (abbr.length > 1) {
      abbr = abbr[0].charAt(0).toUpperCase() + abbr[1].charAt(0).toLowerCase();
    } else {
      abbr = abbr[0].charAt(0).toUpperCase() + abbr[0].charAt(1).toLowerCase();
    }

    return abbr;
  }

  get unreadCount() {
    const category = this.args.category;

    return (
      category.unreadTopics ??
      category.unread_topics ??
      category.unread_count ??
      category.unread ??
      0
    );
  }

  get newCount() {
    const category = this.args.category;

    return (
      category.newTopics ??
      category.new_topics ??
      category.new_count ??
      category.newTopicsCount ??
      0
    );
  }

  get hasActivity() {
    return this.unreadCount > 0 || this.newCount > 0;
  }

  get activityTitle() {
    if (this.newCount > 0 && this.unreadCount > 0) {
      return `${this.newCount} nouveau(x) et ${this.unreadCount} non lu(s)`;
    }

    if (this.newCount > 0) {
      return `${this.newCount} nouveau(x)`;
    }

    if (this.unreadCount > 0) {
      return `${this.unreadCount} non lu(s)`;
    }

    return "Nouveaux contenus dans cette catégorie";
  }

  get debugCategory() {
    // DEBUG TEMPORAIRE :
    // Ouvrez la console du navigateur sur la page catégories
    // pour voir quelles propriétés sont réellement disponibles
    // sur l'objet @category.
    console.log("CATEGORY BOX DATA", this.args.category);
    return null;
  }

  <template>
    {{! template-lint-disable no-nested-interactive }}

    {{! DEBUG TEMPORAIRE : supprimer cette ligne après vérification console }}
    {{this.debugCategory}}

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
        {{#if this.hasActivity}}
          <span
            class="category-activity-dot"
            title={{this.activityTitle}}
            aria-label={{this.activityTitle}}
          ></span>
        {{/if}}

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
              <h3>
                <CategoryTitleBefore @category={{@category}} />
                {{#if @category.read_restricted}}
                  {{icon "lock"}}
                {{/if}}
                {{@category.name}}
              </h3>
            </a>
          </div>

          <div class="description">
            <p>{{htmlSafe0 @category.description_excerpt}}</p>
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
