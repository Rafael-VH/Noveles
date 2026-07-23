## Exploration: Books Module Visual Improvement

### Current State

#### 1. SliverAppBarBook (`sliver_app_bar_book.dart`)

**Strengths:**
- Full-bleed cover image creates immersive hero section
- Gradient overlay (surface 50% → 70% → 100%) provides smooth visual transition to scroll content
- Centered thumbnail + title + author in a clear hierarchy
- Transparent AppBar background avoids color clash

**Weaknesses:**
- **BackdropFilter blur sigma 10 is a performance liability** — `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` triggers expensive render-frame repaints on every scroll frame. On lower-end devices this causes visible jank.
- **Collapsed title is generic** — `const Text('Details')` doesn't use the book name. The transparent AppBar without a scrolled background means the title floats over content.
- **No stretch/parallax** — no `stretch: true` or hero-style overscroll effect, which the carousel already shows is a pattern in the app.
- **Fixed expandedHeight: 360** — not responsive to screen size. On smaller devices the hero takes too much space; on tablets it's too small.
- **Thumbnail aspect ratio broken** — `Expanded(flex: 10)` stretches the cover thumbnail to fill vertical space without preserving its 3/4 aspect ratio.
- **No scroll-driven opacity/scale** — title and author fade out abruptly via the default SliverAppBar collapse rather than a smooth parallax.

#### 2. BookDetailContent (`book_detail_content.dart`)

**Strengths:**
- CardInfoDetail rows provide structured metadata presentation
- Genre Wrap with spaced chips is visually clear
- Source section conditionally shown only when data exists
- FavoriteButton integrated into the header row

**Weaknesses:**
- **Description typography is too small** — uses `fontSize: 14` with `onSurfaceVariant`. For a primary reading section on a detail page, `bodyLarge` (16px, `onSurface`) would improve readability.
- **FavoriteButton pushes title off-center** — the Row uses `mainAxisAlignment: MainAxisAlignment.center` but the FavoriteButton sits at the end, so the "Descripción" title and the icon do not visually balance.
- **No visual section rhythm** — all children of a flat `Column` with no dividers, spacing groups, or card groupings. Sections blend into each other.
- **Inconsistent padding** — mixes `all(10.0)`, `all(6.0)`, and `EdgeInsets.only` without a spacing scale.
- **Transition from SliverAppBar** — only `SizedBox(height: 22)` separates the hero from content. Could benefit from a staggered entrance or a visual cue that content has started.
- **Genre chips use InkWell with empty onTap** — `onTap: () {}` provides no tap feedback and no action. The chips are impossible to tap with any result.

#### 3. CardInfoDetail (`card_info_detail.dart`)

**Strengths:**
- Two-column layout efficiently presents paired metadata
- Clear label/value hierarchy (bodySmall label, bodyMedium bold value)
- Consistent surface background

**Weaknesses:**
- **Hardcoded elevation: 6.0 overrides theme** — the global `cardTheme` uses `elevation: 0` with a subtle border. These cards jump out with strong shadows, creating visual inconsistency.
- **Spacer(flex: 1) is awkward** — using a flex-based spacer for the gap between columns is unconventional. A simple `SizedBox(width: 8)` would be cleaner and more predictable.
- **Three identical CardInfoDetail rows back-to-back** — creates repetitive visual rhythm without differentiation. The cards could be merged into a single 6-item grid or styled differently.

#### 4. Genre Chips (in `book_detail_content.dart`)

**Strengths:**
- Wrap layout handles overflow gracefully
- Chip widget provides standard Material Design interaction

**Weaknesses:**
- **elevation: 8.0 is extreme** — no chip in Material Design needs 8dp elevation. Creates visual noise.
- **GenreChipStyled exists but isn't used here** — the main screen uses a polished pill-shaped chip with icons (`GenreChipStyled`), while the detail page uses raw `Chip` widgets with elevation. Visual inconsistency.
- **Empty onTap** — chips appear interactive but do nothing, which is a UX anti-pattern.

#### 5. Book Cards — Vertical & Horizontal

**Strengths:**
- Vertical: clean 3/4 aspect ratio cover, 2-line title truncation, consistent 140px width
- Horizontal: good compact layout with cover + text + tomo count, 120px height consistent with list density
- Both use `Clip.antiAlias` for clean cover cropping
- Both use the theme's card shape (borderRadius 16) for consistency

**Weaknesses:**
- **Zero shadow depth** — theme card elevation is 0 with only a 0.5px outlineVariant border. Cards appear flat against the background with no hierarchy.
- **Text area in vertical card is cramped** — `padding: EdgeInsets.fromLTRB(8, 2, 8, 2)` gives only 2px vertical breathing room. Title and author practically touch.
- **Horizontal card cover width is fixed 80px** — not aspect-ratio-preserving. If the image is taller than 120px, it gets cropped differently than the vertical card layout.
- **No visual hover/selection state** — no scale or elevation change on press for feedback.

#### 6. Carousel (`carousel_appbar_sliver.dart`)

**Strengths:**
- Auto-play with animated dot indicators creates a dynamic hero
- Gradient overlay (transparent → surface 90% → surface) ensures text readability on any cover
- Clamped responsive height (200-300) works across phone sizes
- LabelBadge provides genre/label context at a glance

**Weaknesses:**
- **Title uses `labelLarge` (14px)** — too small for a hero carousel. Should use at least `titleLarge` or `headlineSmall`.
- **Dot indicators overlap text** — positioned at `bottom: 8` with `mainAxisAlignment: spaceAround` can cause overlap with long book names or multiple label badges.
- **LabelBadge fontSize: 10 is tiny** — hard to read, especially on the dark gradient overlay.
- **No page indicator text** — no "1/5" type indicator. Dots alone don't communicate total carousel length effectively.
- **No parallax on scroll** — the carousel scrolls away with the SliverAppBar without any additional visual effect.

#### 7. Overall Visual Cohesion

**Strengths:**
- Color palette is consistent (green primary, lavender secondary, teal tertiary)
- Surface hierarchy is well-defined across both themes
- Section headers on main screen use a consistent `SectionHeader` widget
- CupertinoPageTransitionsBuilder for smooth page transitions

**Weaknesses:**
- **Two header widget systems** — `TitleWidget` (accent bar + text, used in book detail) vs `SectionHeader` (icon + title, used in main screen). Different visual languages.
- **No elevation scale** — each widget hardcodes its own elevation (0, 6, 8) with no system.
- **No spacing scale** — padding values of 2, 4, 6, 8, 10, 12, 16 appear seemingly at random.
- **Book detail has no content grouping** — description, metadata cards, genres, and source are all direct children of a Column with no visual grouping (no card wrapping sections, no dividers).
- **Dark theme may show elevation inconsistencies more starkly** — on `#24243C` surface, shadow opacity behaves differently than on white.

### Affected Areas

| File | Reason |
|------|--------|
| `lib/features/books/presentation/screens/widgets/sliver_app_bar_book.dart` | Blur sigma, parallax, collapsed title, aspect ratio, responsive height |
| `lib/features/books/presentation/screens/widgets/book_detail_content.dart` | Typography, spacing, section grouping, genre chips, FavoriteButton alignment |
| `lib/features/books/presentation/screens/widgets/card_info_detail.dart` | Elevation consistency, layout pattern |
| `lib/features/books/presentation/screens/widgets/book_took_list.dart` | Card elevation to match theme (inherited, may need adjustment) |
| `lib/features/books/presentation/screens/book_screen.dart` | Content structure may change if sections are grouped |
| `lib/features/app/presentation/widgets/book_card_vertical.dart` | Shadow/depth, text padding, press state |
| `lib/features/app/presentation/widgets/book_card_horizontal.dart` | Shadow/depth, cover aspect ratio, press state |
| `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart` | Title typography, dot overlap, label readability |
| `lib/core/presentation/widgets/title_widget.dart` | Consider unifying with SectionHeader |
| `lib/features/app/presentation/widgets/section_header.dart` | Consider unifying with TitleWidget |
| `lib/features/book/presentation/screens/widgets/*.dart` | Genre chips swapped for GenreChipStyled |
| `lib/core/utils/theme/light_theme.dart` | Card elevation, chip elevation defaults |
| `lib/core/utils/theme/dark_theme.dart` | Card elevation, chip elevation defaults |

### Approaches

#### 1. **Surface Polish + Elevation/Spacing Standardization** — Medium-low effort

Standardize the elevation and spacing systems, fix the most obvious visual bugs, and reduce performance risk.

**What it includes:**
- Remove hardcoded elevation from CardInfoDetail and genre chips; rely on theme defaults
- Reduce BackdropFilter sigma from 10 to 3-5 (still provides blur, vastly cheaper)
- Change collapsed title from "Details" to the actual book name (with overflow)
- Fix thumbnail aspect ratio in SliverAppBarBook (use AspectRatio widget)
- Replace Spacer(flex: 1) in CardInfoDetail with SizedBox
- Increase vertical card text padding (2px → 4-6px)
- Increase description font to 16px (bodyLarge) with onSurface color
- Replace detail genre Chips with GenreChipStyled for consistency
- Remove empty onTap from genre chips (make them truly static or add genre screen navigation)
- Pull FavoriteButton out of the title row (place it in the AppBar actions or below the description)

**Pros:**
- Quick wins with immediate visual improvement
- Significant performance improvement (blur reduction)
- Low risk, no architectural changes
- Consistent elevations across the module

**Cons:**
- Does not address the SliverAppBar's lack of parallax/stretch
- Does not fix the carousel's typography hierarchy
- Does not create section grouping in book detail
- Leaves the two header widget systems as-is

**Effort: Low-Medium** (8-12 files, each change is small and contained)

---

#### 2. **Performance + Cohesion Pass** — Medium effort

Everything in Approach 1, plus SliverAppBar enhancements and unified component patterns.

**What it includes:**
- All of Approach 1
- Add `stretch: true` and parallax factor to SliverAppBarBook for overscroll effect
- Responsive `expandedHeight` based on `MediaQuery` (360 on phones, larger on tablets)
- Group book detail content into card-wrapped or section-separated layout
- Add consistent `Divider` or spacing sections between content blocks
- Carousel: increase title to `titleLarge`, add "1/N" text indicator, fix dot positioning
- Unify TitleWidget and SectionHeader into a single widget (icon + optional accent bar)
- Add press-animation feedback to book cards (Inkwell splash + subtle scale)

**Pros:**
- Cohesive visual language across main screen and book detail
- SliverAppBar feels polished with parallax
- Content grouping makes the detail page easier to scan
- Performance still addressed

**Cons:**
- Unifying header widgets requires updating callers across the app
- Parallax may need testing on low-end devices
- Content grouping may shift pixel-perfect layout

**Effort: Medium** (12-16 files, some refactoring of shared widgets)

---

#### 3. **Full Visual Refresh** — High effort

Redesign the Books module reading experience with a focus on immersion and content hierarchy.

**What it includes:**
- All of Approaches 1 & 2
- SliverAppBarBook redesign: alternative hero layouts (e.g., toolbar-style cover thumbnail, larger background with lower blur, scroll-away animation)
- Add staggered entrance animation for description/metadata sections on page load
- Responsive book cards: adaptive grid vs list based on screen width
- Carousel: add cover parallax within each slide (Ken Burns effect or slow zoom)
- Custom hero transition from BookCardVertical to SliverAppBarBook cover
- Unified elevation system (define a `ElevationScale` token set)
- Unified spacing system (define a `SpacingScale` token set)
- Replace raw edge insets with spacing tokens across all book widgets
- Micro-animations: favorite toggle, chapter count transitions, chip selection

**Pros:**
- Premium, polished reading experience
- Hero transition creates spatial coherence
- All inconsistencies resolved at a systemic level
- Responsive and adaptive

**Cons:**
- High effort, likely 2-3 PRs
- Hero transition and custom animations add complexity
- Elevation/spacing tokens may need to be adopted app-wide, not just books
- Staggered entrance animations may conflict with scroll-driven animations
- Testing surface area is large

**Effort: High** (18-25 files, new tokens, potential animation framework additions)

### Recommendation

**Approach 2 — Performance + Cohesion Pass** is the best balance for this exploratory phase.

**Why:**
1. **Approach 1 leaves too many visible inconsistencies** — the two header systems and flat detail page layout will remain, and users will notice the genre chip mismatch and cramped cards.
2. **Approach 3 is disproportionate for an explore phase** — the app is still in active development and a full visual refresh is best done when the feature set stabilizes. The hero transition and elevation token system are architectural decisions that need a separate proposal.
3. **Approach 2 addresses all the concerns raised in the current state analysis** without over-engineering:
   - Performance (blur reduction) ✓
   - Visual consistency (elevation, chips, headers) ✓
   - Polished SliverAppBar (parallax, responsive, collapsed title) ✓
   - Content readability (description, section grouping) ✓
   - Carousel fixes (typography, dots) ✓

**What Approach 2 does NOT address** (deferred to a future refresh):
- Hero transition from cards to detail screen
- Systemic elevation/spacing tokens across the entire app
- Carousel Ken Burns effect
- Staggered entrance animations

These are valid improvements but belong in a separate change after the quick wins land.

### Risks

- **Performance risk (Approach 2)**: Parallax in the SliverAppBar adds a `MediaQuery`-driven animation that could cause jank on 60Hz low-end devices. Mitigation: use `alwaysIncludeSemantics: false` and keep the animation simple (opacity + translateY only, no scale).
- **Collapsed title change**: Changing from "Details" to the book name requires testing with long titles. The SliverAppBar title has a fixed font size and may overflow. Mitigation: set `overflow: TextOverflow.ellipsis` and limit to 1 line.
- **BackdropFilter reduction**: Reducing sigma from 10 to 3-5 changes the visual appearance significantly. The current high blur provides strong privacy/immersion effect. Mitigation: test both values and choose the lowest that still looks good; consider `sigmaX: 5, sigmaY: 5` as starting point.
- **Header unification**: Merging TitleWidget and SectionHeader requires updating all callers. There may be callers in screens not touched by this change (e.g., settings, profile). Mitigation: keep both widgets but deprecate the old one internally; update only books module callers.
- **Genre chip navigation**: Currently the chips have empty onTap. Adding navigation to genre filtered screens would expand scope. Mitigation: make chips non-interactive (remove InkWell) in the current change; file a separate issue for genre navigation from detail page.
- **Dark mode regression**: Shadow appearance changes with elevation adjustments. Mitigation: test both themes side-by-side before merging.

### Ready for Proposal

**Yes.** The exploration has identified clear problems, measurable approaches, and a recommendation. The orchestrator should proceed to `sdd-propose` with Approach 2 as the recommended direction.

Key guidance for the proposal:
- Change name: `books-visual-improvement`
- Scope: Performance + Cohesion pass across all books UI widgets
- Exclusions: hero transitions, systemic token systems, animations
- The proposal should define whether we unify TitleWidget/SectionHeader now or defer
