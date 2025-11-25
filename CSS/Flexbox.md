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
