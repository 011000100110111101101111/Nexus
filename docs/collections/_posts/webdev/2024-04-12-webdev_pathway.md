---
layout: post
title: Documenting my web development pathway
date: 2024-04-12
summary: This post will be continously updated as I continue my journey to learn web development.
categories: discussions
---

## About

I initially found it a bit overwhelming starting to learn the technologies for web development, and wished there was a simple roadmap or discussion to follow that had previous failures and tips for advancement. I didn't find one... but I will leave one behind for the next person! This post will be in chronological order of what I learned, why I learned it, if it was useful and any hardships I ran into along the path. I hope this helps someone else down the line. Lets get into the pathway.

### HTML + CSS

I kicked my journey off with HTML and CSS. In my opinion it was extremely helpful to learn these side by side compared to consecutively because when it clicked it really clicked. It also gives the advantage of reinforcing the other language while learning. What I mean is if you introduce a new HTML element to the page, you can then apply what you have already learned from CSS to that element, reinforcing the knowledge. This is compared to making an entire HTML page, then apply CSS to it once as you are learning it. Obviously this is just my two cents, but I found it accelerated my learning.

Here are some great resources I used during this process.

- [W3Schools HTML](https://www.w3schools.com/html/)
- [W3Schools CSS](https://www.w3schools.com/css/)
- [FreeCodeCamp HTML Video](https://www.youtube.com/watch?v=916GWv2Qs08&list=PLWKjhJtqVAbmMuZ3saqRIBimAKIMYkt0E&index=3)
- [FreeCodeCamp CSS Video](https://www.youtube.com/watch?v=OXGznpKZ_sA&list=PLWKjhJtqVAbmMuZ3saqRIBimAKIMYkt0E&index=3)

The following videos REALLY made it click once I had some basic knowledge.

- [Modern Website From Scratch (DesignCourse)](https://www.youtube.com/watch?v=6ln_PFw_dYU&t=2868s)

Another topic I would mention is design. When you are learning, for all means go all out. It teaches you more and is fun. However, at some point I realized that more is not better. A simple website with great colors looks WAY better than a overcomplex design with shading and tons of colors and everything else. It looks professional, and it looks CLEAN. This was important to take my website design from something that looked like it belonged in 2005, to a trendy current site.

### React + Material UI

As of writing this I have stopped updating the current site as I decided to learn React and rebuild the site with that instead. So far, it has been great, and although it took a lot more work, it looks MUCH better. At first I was pretty confused what React actually was, but from my still early understanding, it essentially allows you to build reusable elements for a website using JSX. To make this click more, lets say you have a button you want to add to your site with normal Javascript + CSS + HTML. You would need to add all three of those components each time you create a button, but in React you can build it once and reuse it by calling something as simple as ```<CommonButton />```. To then build on this idea, Material UI essentially is a collection or library of these predefined components like ```<CommonButton />``` that you can further combine and customize to build a site and build more intricate components. It. Is. Amazing. It was so cool remaking the library page with the functionality React provides out of the box.

Here is a sneak peak from what I have been doing so far. Keep in mind this is only after around a week of exposure to React.

#### Old header

This is the current (old) header made from pure html and css.

![Old header](../../../images/blog/oldSiteHeader.png)

#### New Header

This is the new header built from React+Material UI. The menu bar is nicely toggable and everything just looks.. better.

![Old header](../../../images/blog/newSiteHeader1.png)

![Old header](../../../images/blog/newSiteHeader2.png)

#### Library Page

This is a rough implementation of the library page. It will allow (mainly me) to quickly add books and rate them, then have them displayed on cards in this searchable menu. I am looking forwards with getting this integrated into a database compared to using manual file imports.

![Old header](../../../images/blog/newSiteAddBook1.png)

![Old header](../../../images/blog/newSiteAddBook2.png)

To further the previous explanation of React, the New Book screenshot is a reusable component that has a title (New Book) and two buttons at the bottom (Submit, Cancel). You can call this component in another file, and pass the title to it, and it will display this with your title. The other components are passed as children (The two input boxes and the ratings). These elements themselves are MaterialUI elements (TextFields and Ratings).

So essentially, you have a generic thing you make, lets call it Menu. This is the base one that only has the titles and the buttons. Then you create a more specific component that we will name AddBookMenu, which uses the generic Menu, and adds elements to it. We could then FURTHER this with more elements and so on.

This is the series I have been following which has been really great. However, I would suggest following along while applying it to your own project as it makes the information stick when you have to adapt it, compared to just copying code.

[The Atypical Developer](https://www.youtube.com/watch?v=h9KevTtI5O0)

I will continue to update this blog as I progress and expect to fully swap out to the React version within the month.
