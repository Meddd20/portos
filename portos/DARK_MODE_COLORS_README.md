# Dark Mode Color System for Portos

This document explains the new dark mode color system implemented in the Portos app.

## Overview

The app now supports both light and dark modes with a comprehensive color system that automatically adapts based on the user's system preference.

## Color Categories

### 1. Primary Colors

- `Color.primaryApp` - Main brand color (brown → warm beige in dark mode)
- `Color.secondaryApp` - Secondary brand color (light brown → darker brown in dark mode)

### 2. Background Colors

- `Color.backgroundApp` - Main app background (off-white → dark gray in dark mode)
- `Color.backgroundPrimary` - Primary background (white → dark gray in dark mode)
- `Color.backgroundSecondary` - Secondary background (light gray → darker gray in dark mode)

### 3. Text Colors

- `Color.textPrimary` - Primary text (black → white in dark mode)
- `Color.textSecondary` - Secondary text (dark gray → light gray in dark mode)
- `Color.textTertiary` - Tertiary text (medium gray → lighter gray in dark mode)
- `Color.textPlaceholderApp` - Placeholder text (gray → lighter gray in dark mode)

### 4. Status Colors

- `Color.greenApp` - Success/positive indicators (green → brighter green in dark mode)
- `Color.greenAppLight` - Light success backgrounds (light green → dark green in dark mode)
- `Color.redApp` - Error/negative indicators (red → brighter red in dark mode)
- `Color.redAppLight` - Light error backgrounds (light red → dark red in dark mode)

### 5. Neutral Colors

- `Color.greyApp` - Neutral gray (light gray → dark gray in dark mode)
- `Color.borderColor` - Border color (light gray → dark gray in dark mode)
- `Color.shadowColor` - Shadow color (black with opacity → black with higher opacity in dark mode)

## How to Use

### Replace Hardcoded Colors

**Before (Light mode only):**

```swift
.foregroundColor(.black)
.background(.white)
.stroke(.black.opacity(0.2))
```

**After (Dark mode compatible):**

```swift
.foregroundColor(Color.textPrimary)
.background(Color.backgroundPrimary)
.stroke(Color.borderColor.opacity(0.2))
```

### Examples

```swift
// Text styling
Text("Hello World")
    .foregroundStyle(Color.textPrimary)

// Backgrounds
Rectangle()
    .fill(Color.backgroundSecondary)

// Borders
RoundedRectangle(cornerRadius: 12)
    .stroke(Color.borderColor, lineWidth: 1)

// Status indicators
Circle()
    .fill(isPositive ? Color.greenApp : Color.redApp)
```

## Implementation Details

The dark mode support is implemented using SwiftUI's `UIColor` initializer with a trait collection closure:

```swift
init(light: Color, dark: Color) {
    self.init(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(dark)
        default:
            return UIColor(light)
        }
    })
}
```

This automatically switches between light and dark colors based on the system appearance setting.

## Testing

To test dark mode:

1. **In Simulator**: Go to Features → Appearance → Dark Appearance
2. **On Device**: Settings → Developer → Dark Appearance
3. **In Xcode**: Use the preview with `.preferredColorScheme(.dark)`

## Color Preview

Use `ColorPreviewView` to see all colors in both light and dark modes. This view shows:

- All color swatches
- Sample UI components
- Current color scheme indicator

## Migration Guide

1. **Replace hardcoded colors** with the new color constants
2. **Test in both modes** to ensure proper contrast
3. **Use semantic colors** (e.g., `textPrimary` instead of `.black`)
4. **Consider accessibility** - ensure sufficient contrast ratios

## Best Practices

- Always use the new color constants instead of hardcoded colors
- Test your UI in both light and dark modes
- Ensure sufficient contrast for accessibility
- Use semantic color names (e.g., `textPrimary` for main text)
- Consider the context when choosing between similar colors

## Notes

- The system automatically handles color scheme changes
- Colors are optimized for both light and dark modes
- All existing functionality remains unchanged
- The color system is extensible for future additions
