// Let the javascript libs start their behaviour. These are all included at the
// end of the document so the browser will first render the document before
// requesting the javascripts.

Event.observe(document, 'dom:loaded', function() {
  PC.Room.watch();
});

// Event.observe(window, 'load', function() {
// });