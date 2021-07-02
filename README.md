# ImageSearchThe objective of the app is to display images search result.
Use Pixabay search API https://pixabay.com/api/docs/ 
Example for search get request: https://pixabay.com/api/?q=kittens&key=12055825-e70cbf6e70297050349021fe0

The app will show a search text box at the top, and search button in action bar, pressing on the search button will call the search API and display the results on a grid.

The height of each image will be fixed depending on the screen size (use whatever algorithm you want), the width should be proportional to the height.
You can get the default image sizes from the API.

The API support paging, when the user scrolls to the bottom of the images grid, you should create additional request to fetch more images, you can read it on their API documentation.

Pressing on an image will push new screen that display the image over all the screen.
On the new screen, swipe right/left will lead you to the next/previous image.

Pay attention to spinners, reusable cells, error handling, etc.

The objective of the assignment is code design, so be aware to code modulation.

