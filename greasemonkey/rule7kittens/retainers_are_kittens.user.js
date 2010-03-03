// Turn retainers into kittens
// version 1
// 2008-08-31
// Copyright (c) 2008, Nicholas Avenell
// Released under the GPL license
// http://www.gnu.org/copyleft/gpl.html
//
// --------------------------------------------------------------------
//
// This is a Greasemonkey user script.  To install it, you need
// Greasemonkey 0.3 or later: http://greasemonkey.mozdev.org/
// Then restart Firefox and revisit this script.
// Under Tools, there will be a new menu item to "Install User Script".
// Accept the default configuration and install.
//
// To uninstall, go to Tools/Manage User Scripts,
// select "Retainers Are Kittens", and click Uninstall.
//
// --------------------------------------------------------------------
//
// ==UserScript==
// @name          Retainers Are Kittens
// @namespace     http://www.aquarionics.com/projects/greasemonkey
// @description   Turn all instances of Retainer into Kitten on Rule7
// @include       http://forums.rule7.co.uk/F*
// @include       http://forums.rule7.co.uk/T*
// @include       http://forums.rule7.co.uk/
// ==/UserScript==

document.getElementsByTagName('body')[0].innerHTML = document.getElementsByTagName('body')[0].innerHTML.replace(/retainer/gi,'kitten');