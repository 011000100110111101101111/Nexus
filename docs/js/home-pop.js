/* Occurs after content has loaded */
document.addEventListener("DOMContentLoaded", function(event) {

  window.addEventListener("load", function(e) {

    /* Okay, now display the screen (This gets rid of our top level html display: none) */
    document.body.style.display = "block";

    var tl = new TimelineMax();
    /* target our sections */
    /* lasts 2 seconds */
    /* Stagger from makes each on come in .2 seconds after eachother */
    tl.staggerFrom('section', 2, {
      opacity: 0,
      scale: .5,
      /* How the animation appears over the 2 seconds */
      ease: Power2.easeOut
    }, 0.2)

    tl.staggerFrom('h1, h2', .5, {
      opacity: 0,
      y: -40,
      ease: Power2.easeInOut
    }, 0.2, "-=2")

    tl.staggerFrom('annim-panel', 1, {
      opacity: 0,
      y: -40,
      ease: Power2.easeInOut
    }, 0.2, "-=1")
  }, false);

});
