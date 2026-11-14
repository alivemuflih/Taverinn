# Taverinn Visual System

## Scope and audit basis

This document defines the visual direction for the existing Flutter application. It is a design specification for the visual polish phase. It does not authorize product feature changes or changes to Supabase, authentication, party lifecycle, follow behavior, statistics, or chat behavior.

The audit below is source-based. The current project was not rendered during this phase, so responsive and accessibility observations are implementation targets, not claims of verified runtime behavior.

## 1. Brand direction

Taverinn is a modern guild hall where players find a party and coordinate a session. It should feel like a well-run gaming community with the warmth of a tavern notice board, expressed through editorial typography, orderly information, restrained brass details, and a recognizable guild seal.

**Design signature:** a quiet ivory field, espresso text, walnut structure, and a small brass T seal make game recruitment read like a clear guild notice. The interface stays practical and familiar while the party room gets the strongest sense of shared place.

**Design Read:** social LFG product for gamers who need to scan recruitment details and coordinate a party, using a refined guild-hall visual language, with ENERGY 2 / RHYTHM 2 / MOTION 1.

- **ENERGY 2:** confident hierarchy and one deliberate brand accent, without theatrical or game-HUD styling.
- **RHYTHM 2:** predictable task layouts with occasional editorial breaks for the party room, profile identity, and recruitment notices.
- **MOTION 1:** short state feedback only; no ornamental entrance or looping motion.

## 2. Visual principles

- Let game, rank, mode, player count, host, and next action lead. Decoration follows those facts.
- Use typography, alignment, grouping, and whitespace before adding containers.
- Reserve the most recognizable treatment for the Taverinn seal, brass rules, and the Party Room header.
- Use flat surfaces and fine borders for most information. Elevation marks a true overlay or active layer.
- Keep touch and keyboard behavior consistent with Flutter Material 3 and the platform.
- Keep content language concise and consistent. Use Indonesian for app instructions and actions, while preserving common game terms such as rank names and Ready when the surrounding UI already uses them.

## 3. Color tokens

Use both palettes through `TaverinnTheme`. Light keeps the warm identity and gives brass a specific role. Dark uses espresso and walnut surfaces with parchment text; it is designed as its own palette, not an inversion. Recheck rendered component combinations against the contrast targets during visual QA.

| Token | Value | Use |
| --- | --- | --- |
| `ink` | `#2B241F` | Main text and the deepest neutral |
| `walnut` | `#49372C` | Secondary dark surfaces and structural emphasis |
| `paper` | `#FCFAF5` | Main content surface |
| `parchment` | `#F2EDE3` | App canvas and quiet grouped areas |
| `brass` | `#785A25` | Primary action, seal, and occasional divider emphasis |
| `line` | `#948570` | Warm separators and control outlines with 3:1 contrast |
| `mutedText` | `#62584E` | Secondary copy, only where contrast is sufficient |
| `wine` | `#74474A` | Destructive or consequential state only |
| `forest` | `#3F5D4B` | Ready/success state only |
| `night` | `#211D1A` | Dark app canvas |
| `darkSurface` | `#2E2823` | Dark content and navigation surface |
| `darkElevated` | `#39312A` | Dark selected or elevated surface |
| `parchmentText` | `#F1E8DA` | Dark primary text |
| `mutedParchment` | `#C7B9A5` | Dark secondary text |
| `nightBorder` | `#91806E` | Dark border and divider with 3:1 contrast |
| `nightBrass` | `#D1B16F` | Dark primary action and mark |
| `nightWine` | `#E0A4A0` | Dark destructive state |
| `nightForest` | `#A0C1A5` | Dark success/ready state |

`wine` and `forest` are state colors, not additional decorative accents. Pair either with a label or icon so meaning never depends on hue alone. Avoid brass for small text on paper unless measured contrast passes WCAG AA. Do not add gradients as a default surface treatment.

The parchment and paper relationship remains the light theme's guild-notice identity. Dark mode uses a deep espresso canvas, warmer charcoal surfaces, parchment text, muted brass actions, and warm neutral borders. Do not spread brass beyond high-value actions and the small brand mark. Semantic roles are mapped through `ColorScheme` so screen controls can respond to the selected palette.

## 4. Typography hierarchy

- **Brand and screen display:** a restrained serif face, used for the Taverinn wordmark and the most important screen or game heading. Use the platform serif fallback already available until a licensed font asset is explicitly added.
- **Section heading:** serif or the established display role for a small number of high-level headings, not every card title.
- **Body and controls:** readable system sans-serif for forms, messages, metadata, buttons, navigation, and long content.
- **Metadata:** body sans-serif with clear contrast and stable size. Do not depend on tiny caps or wide tracking.
- **Numbers:** use consistent weight and alignment for party counts and activity statistics.

Use `TextTheme` roles as the source for repeated styles. Preserve text scaling and allow labels, usernames, and game names to wrap. Use ellipsis only when the complete value remains available from the detail surface or accessible label.

## 5. Spacing system

Use a compact 4 dp base scale: `4, 8, 12, 16, 24, 32, 40`.

- 4 to 8 dp: icon-to-label and closely related metadata.
- 12 to 16 dp: content within a row or notice.
- 24 dp: screen edge inset on compact phones and form group spacing.
- 32 dp: distinct sections and wider layouts.
- 40 dp: occasional separation before a new screen-level area.

Align section headings, fields, and list content to a shared leading edge. Use the same gap for equivalent relationships. Responsive layouts may reduce outer insets on narrow screens but must not compress target sizes.

## 6. Border and radius system

- 0 to 4 dp: dividers, notice frames, and compact structural corners.
- 8 dp: inputs, small controls, and compact grouped surfaces.
- 10 dp: primary content surfaces where a container improves scanning.
- 999 dp: avatars and circular marks only.
- Avoid pill geometry for general buttons, cards, status labels, and navigation.

Use thin `line` borders to group dense information. Avoid outlining every nested row.

## 7. Elevation and shadow rules

Keep feed notices, profile content, forms, and member lists flat. Use a subtle shadow only for an overlay that must appear above the page, such as a modal sheet or menu. Do not use shadow to make every card float. Preserve clear focus and selected states independently from elevation.

## 8. Button system

- **Primary:** filled brass with an accessible high-contrast foreground. Use for the current screen's main action, such as creating a party or joining one.
- **Secondary:** outlined or text action with ink/walnut foreground and a visible pressed/focused state.
- **Destructive:** wine treatment with an explicit action label and confirmation when the existing behavior already provides one. Do not change lifecycle behavior as part of styling.
- Keep Android targets at least 48 by 48 dp. Icon-only controls need a tooltip/semantic label and a full-size hit region.
- Use sentence case and action-specific labels. Keep Ready, Leave, and End Party wording consistent across the Party Room and related feedback.

## 9. Input and form system

Keep persistent visible labels. Place validation and recovery guidance beside the field that needs attention. Group Create Party fields by the existing workflow: game and mode, player requirements, then time and description. This groups existing data only and must not add fields or alter validation behavior.

Inputs use a paper fill when contrast helps distinguish the editable area, a fine line border, and a clearly visible brass focus border with a non-color focus cue. Preserve keyboard types, submission actions, and scroll-to-field behavior. Allow fields and validation messages to grow with text scaling.

## 10. Card and surface system

Not every group is a card. Use whitespace and dividers for related rows, and use a bordered surface when content is independently actionable or benefits from a distinct reading area. Avoid nested cards and repetitive identical containers. Keep one shared surface inset and align the contents to it.

## 11. Party card system

Treat a feed party as a guild recruitment notice. The scan order is:

1. Game identity and open/full state.
2. Rank and mode.
3. Language and play time.
4. Player count and host.
5. Description.
6. Join action in the existing detail flow.

Use a restrained brass rule or small seal detail as the notice signature, not a decorative left stripe. Put metadata in compact aligned groups. Keep descriptions readable and permit longer names and descriptions to wrap. Open/full must have text and an additional visual cue, not color alone. Preserve the current card tap and join flow.

## 12. Profile system

Lead with player identity, then follower/following relationships, activity counts, game dashboard action, and game records. Treat statistics as activity facts, not ratings or trust scores. Use a clear player heading and grouped data instead of giving every number a matching prominent card. Preserve all current profile data and actions, including other-player Follow/Unfollow and profile navigation.

## 13. Navigation system

Keep exactly four primary destinations: Home, Create, Party, and Profile. Keep labels visible. Mark the active destination with a small brass rule around the existing icon/label relationship; do not use a large rounded selection pill. Maintain a stable focus indicator and a minimum 48 dp target. At tablet and desktop widths (840 dp and above), present the same four destinations in a left navigation rail; use the bottom bar below that width. Keep labels visible in both layouts.

## 13a. Settings and localization

Settings is reached from the signed-in user's Profile screen and does not add a primary navigation destination. It contains only Theme and Language. Theme supports System, Light, and Dark; the selected value is persisted in `SharedPreferences`, loaded before the first app frame, and reflected immediately through `MaterialApp.themeMode`. The display language supports Bahasa Indonesia (`id`) and English (`en`), stored separately from the theme selection. ARB resources in `lib/l10n/` own application UI copy. User-created descriptions, chat messages, usernames, game names, and ranks stay in their original language.

## 14. Status, ready, and open states

- **Open/full:** text label plus a restrained shape or border difference.
- **Ready/not ready:** readable label and an appropriate check/schedule symbol; green is reserved for Ready.
- **Loading:** keep the surrounding task context when possible and show progress near the affected content.
- **Success:** concise confirmation tied to the completed action.
- **Error:** explain the failed action and a recovery step. Do not display raw exceptions or stack details to users.
- **Disabled:** reduce emphasis and explain why when the reason is not obvious.

Do not alter when party status, Ready, chat, or lifecycle state changes. This section defines presentation only.

## 15. Iconography rules

Use the supplied Taverinn icon family wherever it exists. No separate Taverinn icon kit is currently present in the repository; existing files are limited to the web/app launcher icons in `web/icons/`, `web/favicon.png`, and Android launcher mipmaps. `lib/widgets/taverinn_icon.dart` centralizes icon sizing and labels for the current Material fallback so the official screen assets can replace its renderer when they are supplied. Keep icon weight and size consistent, pair less familiar icons with text, and avoid unrelated fantasy imagery.

## 16. Empty, loading, and error states

- Empty states state what is missing and offer one relevant next step when one already exists.
- Filtered empty feed states distinguish no matching results from a first-use empty feed and retain the existing clear-filter action.
- Loading indicators stay close to the content being loaded and avoid unnecessary full-screen replacement for local updates.
- Errors use plain language and an actionable retry where the current screen supports retry. Keep technical details out of visible messages.
- Do not add demo content, new recovery flows, or new product actions as visual filler.

## 17. Accessibility rules

- Use Material controls with native semantics where possible. Custom interactive compositions need a clear label, role, value, and state without duplicate announcements.
- Maintain 48 by 48 dp touch targets on Android. Keep visible keyboard focus on web and desktop.
- Verify WCAG AA contrast for all text and important controls. Normal text needs 4.5:1 and large text needs 3:1.
- Support text scaling without clipping, fixed-height text, or hidden actions.
- Do not convey Ready, open/full, selected, error, or disabled state by color alone.
- Give icons accessible names, announce meaningful asynchronous state changes, and exclude purely decorative marks from semantics.
- Preserve stable keys for login, fields, create-party action, party notice, join action, Ready, chat input/send, leave/end, follow/unfollow, profile navigation, and game dashboard. Keys must derive from stable entity identity where list items need unique selectors, never from list indexes or randomness.
- Keep existing keys where present. The audit found keys on login inputs/submit, Create Party game/mode/rank/language/time/description, feed filters/cards, My Party cards, member rows, Party Room ready/chat/leave/end, profile follow/counts, follow rows, and some Game Dashboard fields. Some fields and actions still need stable keys during implementation, including Create Party max players and the remaining Game Dashboard inputs/save action. Add dedicated keys for primary profile navigation and other important controls when their implementation is touched.

## 18. Android responsive rules

- Treat narrow portrait phones as the primary layout. Use a 16 dp minimum content inset and scrollable content rather than fixed screen-height composition.
- Keep the four-destination bottom navigation reachable and visible above system insets and the keyboard.
- In the Party Room, keep the composer and primary party actions reachable when the keyboard opens. Let the member area yield space before chat content or actions become inaccessible.
- Do not rely on fixed heights for text or member rows. Handle long game names, usernames, descriptions, and messages with wrapping and flexible constraints.
- Check portrait and landscape, keyboard open/closed, and enlarged text. Keep controls at least 48 dp high/wide.

## 19. Web responsive rules

- Keep reading widths bounded on wide screens. Existing screen constraints near 430 to 760 dp are useful starting points, not universal constants.
- Use available width for hierarchy and useful parallel content, not stretched phone controls.
- Preserve the four primary destinations and visible labels. Adapt navigation placement only when the available window width warrants it.
- Support pointer hover, keyboard traversal, visible focus, browser zoom, and narrow browser windows.
- Check boundary widths around each chosen breakpoint, long content, and short viewport heights. Do not infer input mode from width alone.

## 20. Do / Don't

### Do

- Use the T seal and fine brass rules as the restrained, repeatable identity motif.
- Make party details easy to scan before the user joins.
- Use serif typography for a few brand and screen moments, with sans-serif for controls and dense content.
- Prefer whitespace, alignment, and thin borders over repeated cards.
- Keep state labels, actions, and accessibility semantics clear.
- Verify contrast and real rendered behavior before calling the visual implementation complete.

### Don't

- Turn Taverinn into an RPG interface, fantasy HUD, cosplay page, cartoon tavern, or pirate theme.
- Apply parchment or wood textures across the whole app.
- Add decorative swords, shields, mugs, helmets, fantasy glow, or stock medieval illustrations.
- Put every element in a rounded card, chip, or pill.
- Use gradients, shadows, or brass accents everywhere.
- Use decorative medieval fonts for body text or tiny widely tracked labels for hierarchy.
- Add fields, destinations, status types, backend behavior, or product functionality in the name of polish.

## Existing UI audit

This audit reflects the code in `lib/screens/`, `lib/theme/app_theme.dart`, and `lib/main.dart` on 2026-11-14. It is not a rendered screenshot review.

| Area | Current implementation | Design implication |
| --- | --- | --- |
| Theme and tokens | `TaverinnTheme.light` already defines a warm cream/paper palette, espresso/ink, brass, wine, forest, serif headline roles, M3 component themes, 10 to 14 dp rounding, and low-elevation cards. | A foundation exists. Centralize the visual direction here rather than layering a competing theme or restyling each screen with local constants. |
| Login and registration | One centered, bounded Material card contains the Taverinn title, game icon, username/email/password fields, submit action, and mode switch. Loading and auth errors use a spinner and snack bar. | Give the brand a deliberate seal and type hierarchy while keeping the form compact, scrollable, and familiar. Auth has stable field and submit keys. |
| Home/feed | A floating app bar, search heading, three horizontal ActionChip filters, loading/error/empty states, party cards, detail sheet, and join action. Party cards use a game initial, status chip, three metadata chips, description, player count, and host. | The data is complete but presented through a generic Material card/chip stack. Reorder it as a recruitment notice and keep all current filters and join behavior. |
| Create Party | A bounded form contains game, mode, rank, language, maximum players, play time, and description, with game-load failure and submit progress. | Retain the field set and validation. Group fields by task and make the existing create action visually primary. |
| My Party | Refreshable list with loading, retry, empty, and party rows. Rows use a card, leading game initial, metadata, and open/full chip. | Make joined parties scan consistently with the Home notice and avoid another independent card style. |
| Party Room | App bar shows the game title; a compact metadata line sits above a fixed-height member list; chat fills the remaining column; composer and Ready/Leave/End actions sit at the bottom. Realtime updates and errors are handled in the screen. | Use as the reference screen. Reorganize visually around game identity, party members, tavern chat, composer, and actions. The current fixed member height and bottom controls need rendered keyboard and small-screen review. |
| Profile and other profile | Avatar and name lead; follower counts are tappable; own profile has activity stats, Game Dashboard action, and game cards; other profile has Follow/Unfollow. | Promote player identity, then make counts and game records easier to scan without turning every metric into a high-emphasis card. |
| Follow/Following | Loading, retry, empty state, refreshable user rows, avatars, and Follow/Following text action. | Keep row geometry plain and stable, with clear identity and an accessible follow state. |
| Game Dashboard | Bounded form for game, rank, role, games played, win rate, favorite character, followed by saved game records. It has loading, retry, save progress, and empty list states. | Separate editing from saved records through hierarchy and spacing while preserving every field and existing data. |
| Dialogs and sheets | Feed filters and party details use modal bottom sheets. No `AlertDialog` use was found in the inspected screens. | Style sheets as temporary task surfaces; keep the party detail and filter choices keyboard/touch accessible. |
| Loading, empty, and errors | Most remote-data screens have loading, error/retry, and empty states. Some action failures show snack bars, sometimes including raw exception text. | Keep relevant states, but rewrite visible errors during implementation to plain recovery guidance without changing service behavior. |
| Navigation | One `NavigationBar` provides Home, Create, Party, Profile, with icon variants and always-visible labels. | Preserve the four destinations and make selection feel branded through controlled geometry, not a large pill. |
| Semantics and automation | Many native controls and stable `ValueKey`s already exist. No explicit `Semantics` wrappers were found in the main flows. Some form fields/actions lack stable keys. | Keep native semantics, fill key gaps as the UI is touched, and verify the reading/focus order with actual accessibility tooling. |
| Spacing and typography | Theme spacing is not tokenized. Several screens use local `SizedBox` gaps and `TextStyle` overrides; headlines use a serif fallback while most controls use Material defaults. | Define shared spacing roles and use the theme's text roles consistently before adding bespoke decoration. |

### Audit coverage

The source review covered `auth_screen.dart`, `home_screen.dart`, `create_lfg_screen.dart`, `party_screen.dart`, `party_room_screen.dart`, `profile_screen.dart`, `follow_list_screen.dart`, `game_dashboard_screen.dart`, `main_screen.dart`, `main.dart`, and `app_theme.dart`. It also checked dialogs/sheets, buttons, forms, cards, typography, icons, spacing, loading/error/empty branches, navigation, and current automation keys. Runtime contrast, screen-reader output, actual touch geometry, keyboard behavior, and visual wrapping remain to be checked when the redesign is implemented and rendered.
