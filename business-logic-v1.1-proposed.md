# Business Logic v1.1 — Proposed

> Proposal for a focused, web-first MVP. This document sharpens the product promise and resolves scope gaps in v1.0; it is not evidence that any feature is implemented or approved.

- **Allowed platforms:** Responsive web on desktop and mobile browsers, including Android. A native Android app is out of scope for MVP.
- **Team name:** `Cookmunity`
- **Project code name:** Glider
- **Project short code:** GD

## Product positioning

**Glider helps home cooks find recipes, cook them, and share what happened.** Unlike a general-purpose social feed, Glider connects a recipe to real attempts: cooks can post a result that credits the original recipe and shows their rating, notes, and changes. This makes practical learning and trustworthy recipe discovery the core product loop.

- **Primary audience:** Home cooks and cooking enthusiasts who want practical recipes and ideas from other cooks.
- **Core problem:** Recipes are easy to find, but it is difficult to tell how they work in a real kitchen, what other cooks changed, and whether a recipe is worth trying.
- **MVP promise:** Discover public recipes, follow cooks, save recipes, and share a credited cooking attempt in one simple web experience.
- **MVP product loop:** Discover a recipe → cook it → publish a Cooked It! attempt → help the next cook decide what to try.

## Project details

- **Short description:** A cooking community for sharing structured recipes and the real cooking attempts that help others make them.
- **Long description:** Glider combines public cooking posts, structured recipes, and lightweight social discovery. Contributors publish recipes with ingredients and ordered instructions, follow cooks, and save recipes for later. After trying a recipe, a contributor can publish a Cooked It! attempt linked to the source recipe, with a photo, rating, notes, and changes. The original creator remains credited so readers can move between the recipe and its attempts. MVP discovery uses recent public content, simple search, and followed cooks rather than a recommendation algorithm.

## User levels

| User level | MVP responsibilities and access |
| --- | --- |
| Guest | Browse public profiles, posts, recipes, and Cooked It! attempts; search public recipes. Must sign in to publish or interact. |
| Contributor | Manage own profile and content; publish posts, recipes, and attempts; follow contributors; like, comment, save recipes, and report content. |
| Moderator | Review reports; hide content that violates guidelines; document an action and escalate account-level cases to an administrator. |
| Administrator | Assign moderator access, manage accounts and platform settings, and review moderation activity. Administrative actions are restricted and auditable. |
| System operator | Operate infrastructure, storage, security configuration, and backups outside normal app permissions. This is an operational responsibility, not a routine in-app user role. |

## System requirements

1. **Sign-in and account lifecycle:** Users can sign in with Google. A first sign-in creates a contributor account; signing out and account deletion are available. Protected actions require an authenticated account.
2. **Profiles:** Contributors can set a unique username, profile photo, and short biography. MVP profiles and published content are public; do not collect unnecessary personal details.
3. **Cooking posts:** Contributors can publish, edit, and delete a caption with one or more supported images. A post may be a general cooking post or contain one structured recipe.
4. **Structured recipes:** A recipe has a title, ingredient list with quantity and unit where applicable, ordered instructions, servings, preparation time, and cooking time. A contributor can edit or delete their own recipe. Validation identifies missing required fields and invalid values before publishing.
5. **Recipe discovery:** Guests and contributors can browse recent public cooking content and search recipes by title or ingredient. Contributors can view a feed of followed cooks; where that feed is empty, provide recent public recipes as a useful next step. No ranking or personalization algorithm is required.
6. **Basic interactions:** Authenticated contributors can follow or unfollow a cook, like or unlike a post, comment on a post, save or remove a saved recipe, and report content. Each interaction is attributable to its acting account and cannot be duplicated where it represents a single user-to-item relationship.
7. **Cooked It! attempts:** A contributor can publish an attempt linked to an existing recipe, with an optional photo, a rating, notes, and changes made. The attempt links back to the source and the source displays its attempts. Attribution remains understandable if the source recipe is later deleted.
8. **Moderation and administration:** Moderators can review reports and hide violating posts, recipes, comments, or attempts. Administrators can manage accounts and roles. Actions are authorized on the server and recorded with actor, target, action, and time.
9. **Responsive and accessible use:** Core browse, recipe-reading, sign-in, publishing, and Cooked It! flows work on desktop and Android-sized browsers, with keyboard access, readable contrast, and clear validation and error feedback.

## Required solution layers

1. **Security and privacy:** Use least-privilege access, server-side authorization, protected secrets, and reasonable safeguards for account and user content. Provide a clear privacy notice, collect only information needed for the MVP, define retention and account-deletion behavior, and obtain appropriate review of obligations under the [Philippine Data Privacy Act](https://officialgazette.gov.ph/2012/08/15/republic-act-no-10173/) before launch. Do not treat this specification as legal advice or proof of compliance.
2. **Authentication and authorization:** Google sign-in establishes identity; application roles control moderator and administrator actions. Users may change only their own profile and content, while moderator powers are limited to documented moderation actions.
3. **Content and community safety:** Publish concise community rules covering spam, harassment, unsafe or misleading cooking claims, and image misuse. Provide reporting, review status, hide/remove actions, and an appeal/contact path. Moderation applies to all user-generated content, not only posts.
4. **Data integrity:** Preserve ownership and links among accounts, posts, recipes, ingredients, comments, saves, follows, reports, and attempts. Enforce required fields, valid references, unique usernames, and one follow/like/save per account and target as appropriate.
5. **Media handling:** Accept image uploads only, with defined file type and size limits, safe storage, and ownership checks. Do not support video in MVP.
6. **Reliability and recovery:** Handle failed reads, writes, and uploads without losing user-entered work where practical. Configure backups and document a basic restore procedure before public launch; verify restore rather than assuming a backup is usable.
7. **Usability and accessibility:** Keep recipe instructions readable while cooking, make primary actions clear on small screens, and provide labels, keyboard operation, and feedback for form errors and loading states.

## MVP features and access

| Feature | Guest | Contributor | Moderator | Administrator |
| --- |:---:|:---:|:---:|:---:|
| Browse public posts, recipes, profiles, and attempts | ✓ | ✓ | ✓ | ✓ |
| Search public recipes by title or ingredient | ✓ | ✓ | ✓ | ✓ |
| Sign in and manage own profile | — | ✓ | ✓ | ✓ |
| Publish and manage own posts and recipes | — | ✓ | ✓ | ✓ |
| Follow, like, comment, and save recipes | — | ✓ | ✓ | ✓ |
| Publish a credited Cooked It! attempt | — | ✓ | ✓ | ✓ |
| Report content | — | ✓ | ✓ | ✓ |
| Review reports and hide violating content | — | — | ✓ | ✓ |
| Manage accounts and assign moderator access | — | — | — | ✓ |

System operations, including backups and infrastructure configuration, are restricted to authorized operators and are not exposed as ordinary contributor features.

## MVP completion criteria

The MVP is ready for stakeholder acceptance when a user can complete each of these end-to-end flows on desktop and mobile browsers:

1. A guest discovers and reads a public recipe, then searches by a title or ingredient.
2. A contributor signs in, creates a profile, publishes and edits a valid recipe, and can later find it publicly.
3. A contributor saves a recipe, follows its author, and sees recent content from followed cooks.
4. A contributor publishes a Cooked It! attempt linked to the recipe; readers can see the attribution, rating, notes, and changes.
5. A user reports inappropriate content; a moderator reviews the report and hides the content; an unauthorized user cannot perform moderator actions.
6. An account owner can request account deletion, and the product follows its documented retention and deletion behavior.

## Scope boundaries

**Included:** Google sign-in, public profiles and content, image posts, structured recipes, recent and followed-cook feeds, title/ingredient search, follows, likes, comments, saves, Cooked It! attempts, reports, basic moderation, and account deletion.

**Excluded from MVP:** Native Android app, private profiles or messaging, video, livestreaming, meal planning, grocery lists, nutrition tracking, monetization, AI-generated recipes, advanced recommendations, and detailed analytics dashboards. Reconsider only when user evidence shows these are needed to support the core product loop.

## Notes and decisions

- The recipe is structured content attached to a cooking post; a post may omit a recipe. A Cooked It! attempt is a distinct content record linked to one source recipe, not a new copy of that recipe.
- A source recipe should retain its author and attribution in existing attempts when it is deleted; display that the source is unavailable rather than implying the attempt is the original recipe.
- Keep the initial experience public and simple. Private accounts, audience controls, and multiple visibility states would add policy and moderation complexity without being necessary to validate the core loop.
- The feed is chronological and based on followed cooks, with recent public recipes as a discovery fallback. This gives users a useful feed without requiring opaque ranking or recommendation infrastructure.
- Ratings and comments are user opinions, not guarantees of recipe safety, nutritional accuracy, or results. Community rules should require care with food-safety claims and prohibit presenting unverified medical or dietary claims as fact.
- Before implementation, confirm team identity, supported image limits, username rules, report resolution states, account-deletion/retention details, and the privacy notice with stakeholders. Keep these decisions small and document only what the MVP needs.
