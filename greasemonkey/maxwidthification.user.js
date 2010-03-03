// ==UserScript==
// @name          Bloglines/Livejournal Image MaxWidthification
// @namespace     http://www.aquarionics.com/projects/greasemonkey/
// @author	  Nicholas 'Aquarion' Avenell
//
// @include       http://bloglines.com/*
// @include       http://www.bloglines.com/*
// @include       http://*.livejounal.com/*
// @include       http://www.livejounal.com/*

// ==/UserScript==

// This script makes all images on the page fit on the page.
// Explaination:
// <http://www.aquarionics.com/article/name/Max_Width_and_the_mutant_GreaseMonkey>

(function() {

imgs = document.getElementsByTagName("img");
	for(i=0;i<imgs.length;i++){
		imgs[i].style.maxWidth="100%";
	}
})();
