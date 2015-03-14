// ==UserScript==
// @name           Show Athena Details
// @namespace      nicholas.trutap.net
// @include        http://*.dev.uk*.trutap.*/*
// ==/UserScript==

function addEventHandler(target, eventName, eventHandler)
{
	if (target.addEventListener)
		target.addEventListener(eventName, eventHandler, false);
	else if (target.attachEvent)
		target.attachEvent("on" + eventName, eventHandler);
}

if (typeof GM_xmlhttpRequest != 'function') {
	// do nothing
} else {
	if (window == top) {

		// do the first load
		// do the first load
				
		GM_xmlhttpRequest({
		    method:'GET',
		    url: 'http://'+document.domain+'/tests/svn',
			onload:function(responseDetails){
			

		
				var mybox = document.createElement("div");
				mybox.innerHTML = '<div id="svn_box" style="margin: 0 auto 0 auto; ' +
				   // 'position:absolute; right: 0; top:0; width:100%; opacity: .75; filter: alpha(opacity=75); z-index:100; ' +
					'font-size: 8pt; font-family: arial, sans-serif; background-color: #ffffff; ' +
					'border-bottom: 2px solid black; text-align: center; padding: 3px;	 ' +
					'color: #000000;" > ' +
					'<p id="svn_info"></p>' +
					'</div>';
					
				document.body.insertBefore(mybox, document.body.firstChild);
				var svninfo = document.getElementById('svn_info');
				
				txt = responseDetails.responseText.split("\n"); 
				milestone = txt[0].split("\t")[1]; 
				ticket    = txt[1].split("\t")[1]; 
				changeset = txt[2].split("\t")[1]; 
				server    = txt[3].split("\t")[1]; 
				
				
				text = document.domain+', running <a href="http://trac.trutap.net/cgi-bin/trac.cgi/milestone/'+milestone+'">'+milestone+'</a>';
				
				if (ticket != 'dev') {
					text += ' tkt #<a href="http://trac.trutap.net/cgi-bin/trac.cgi/ticket/'+ticket+'">'+ticket+'</a>';
				}
				
				text += ' [<a href="http://trac.trutap.net/cgi-bin/trac.cgi/changeset/'+changeset+'">'+changeset+'</a>]';
				
				text += ' using '+server;
				
				
				svninfo.innerHTML = text;
				
			}
		});
	}
}
