## CSS box-sizing

It is a property that defines how the total width and height of an element are calculated. It fundamentally alters how the CSS box model is interpreted for dimensioning elements.

### content-box (default):
  - With content-box, the width and height properties apply only to the element's content area.
  - Any padding and border applied to the element are added on top of the specified width and height, increasing the overall dimensions of the element on the page.
  - The actual rendered width of an element is calculated as: width + padding-left + padding-right + border-left-width + border-right-width.
  - The actual rendered height is calculated similarly for vertical dimensions.

### border-box:
  - With border-box, the width and height properties include the element's padding and border within the specified dimensions.
  - This means that if you set an element's width to 300px, the padding and border will be included within that 300px, and the content area will shrink accordingly to accommodate them.
  - This model often leads to more intuitive and predictable layouts, as the declared width and height directly correspond to the visual space the element occupies on the page.

```css
.container {
    display: flex;
    height: 100vh;
}

.item {
    width: calc(33.33333333% - 20px);
    margin: 10px;
}
```

## Grid Layout

Explicit Grid: Defined by grid-template-rows and grid-template-columns, which creates a fixed number of tracks (rows and columns) with specific sizes.

Implicit Grid: Automatically created by the browser when content is placed outside of the explicit grid, adding extra rows or columns as needed. The behavior is control by grid-auto-rows and grid-auto-columns.


## Animation: Transition and Transform

CSS transitions and transforms work together to create smooth, animated visual effects on web elements.
- **Transforms** modify the visual appearance of an element in 2D or 3D space. Common transform functions include:
  - translate(): Moves an element
  - rotate(): Rotates an element
  - scale(): Resizes an element
  - skew(): Tilts an element.
- **Transitions** allow you to control the animation speed and timing when a CSS property, including transform, changes its value. Instead of an immediate change, the transition causes the property change to occur smoothly over a specified duration.

To apply a transition to a transform:
- Define the initial transform state: for an element.
- Define the target transform state, typically within a pseudo-class like :hover or a class that gets added/removed.
- Apply the transition property: to the element, specifying:
  - transition-property: Set to transform (or all to transition all changing properties).
  - transition-duration: The time the transition takes (e.g., 0.5s).
  - transition-timing-function: The speed curve of the transition (e.g., ease-in-out).
  - transition-delay: An optional delay before the transition starts.

```css
.box {
  width: 100px;
  height: 100px;
  background-color: blue;
  transition: transform 0.3s ease-in-out; /* Apply transition to transform */
}

.box:hover {
  transform: translateX(50px) rotate(45deg); /* Change transform on hover */
}
```

In this example, when the user hovers over the .box element, it will smoothly translate 50 pixels to the right and rotate 45 degrees over 0.3 seconds, using an ease-in-out timing function.


## Filter

Filters provide a way to apply visual effects to HTML elements, similar to image editing software. These effects are applied to an element's rendering before it is displayed in the browser. The filter property accepts one or more filter functions as its value, separated by spaces. Common filter functions include:
- blur(): Applies a Gaussian blur to the element. The argument specifies the blur radius (e.g., blur(5px)).
- brightness(): Adjusts the brightness of the element. Values are typically percentages or decimal numbers (e.g., brightness(150%) or brightness(1.5)).
- contrast(): Adjusts the contrast of the element (e.g., contrast(200%) or contrast(2)).
- drop-shadow(): Applies a drop shadow effect (e.g., drop-shadow(2px 2px 5px black)).
- grayscale(): Converts the element to grayscale (e.g., grayscale(1) for full grayscale, grayscale(0.5) for 50%).
- hue-rotate(): Rotates the hue of the element's colors (e.g., hue-rotate(90deg)).
- invert(): Inverts the colors of the element (e.g., invert(1) for full inversion).
- opacity(): Adjusts the transparency of the element (e.g., opacity(0.7)).
- saturate(): Adjusts the color saturation of the element (e.g., saturate(200%) or saturate(2)).
- sepia(): Applies a sepia tone effect (e.g., sepia(1)).
- url(): References an SVG filter for more complex custom effects.

```css
.filtered-image {
  filter: grayscale(0.8) blur(2px) brightness(1.2);
}

.blurred-text {
  filter: blur(1px);
}
```

Filters can be applied to various HTML elements, including images, backgrounds, borders, and even entire div containers. The backdrop-filter property offers similar effects but applies them to the area behind an element, requiring the element itself to be transparent or semi-transparent to reveal the effect.

## isolate

The **isolation** controls whether an element creates a new **stacking context**. When set to **isolate**, it prevents the element's content from blending with its background, especially when using CSS blend modes or managing **Z-index** layering in complex layouts. This ensures that effects like mix-blend-mode are confined within the isolated element and do not affect elements outside of it.

## inset

It is a shorthand that corresponds to the top, right, bottom, and/or left properties. It has the same multi-value syntax of the margin shorthand.  For this property to take effect it has to have the position property specified.
