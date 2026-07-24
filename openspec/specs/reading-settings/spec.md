# Reading Settings Specification

## Purpose

Let users control font size and reading mode (normal, sepia, night) inside the chapter reader. Settings apply only to the reader view — they do not affect the global app theme.

## Requirements

### Requirement: Font size control

The reader MUST provide controls to increase and decrease the text font size. The system SHALL persist the selected size for the session.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Increase font | reader shows chapter text | user taps increase-size button | font size grows by one step (min 14sp, max 32sp, step 2sp) |
| Decrease font | reader shows chapter text | user taps decrease-size button | font size decreases by one step |
| Minimum boundary | current size is 14sp | user taps decrease | size stays at 14sp |
| Maximum boundary | current size is 32sp | user taps increase | size stays at 32sp |

### Requirement: Reading mode toggle

The reader MUST support three modes: **normal** (white bg / dark text), **sepia** (warm beige bg / brown text), and **night** (dark bg / light text). The reader SHALL apply the mode instantly without reloading content.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Switch to sepia | reader in normal mode | user selects sepia | background changes to warm beige, text to brown tones |
| Switch to night | reader in any mode | user selects night | background changes to dark, text to light |
| Switch back | reader in night mode | user selects normal | returns to white bg / dark text |

### Constraints

- Font size and mode are scoped to chapter reader only — global theme is unaffected.
- Mode MUST NOT change AppBar, bottom nav, or system UI chrome — only the reading surface.
- Settings MAY persist to local storage for cross-session retention.

### Acceptance Criteria

- [ ] Font increase/decrease buttons exist and change text size immediately.
- [ ] Sepia mode applies warm overlay, not just a color swap.
- [ ] Night mode applies dark background with readable contrast.
- [ ] Toggling modes does not lose scroll position.
- [ ] Settings overlay dismisses without affecting reader content.
