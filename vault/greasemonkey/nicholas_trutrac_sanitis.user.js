// ==UserScript==
// @name           Nicholas' Trutrac Sanitiser Thing
// @namespace      trac.trutap.net
// @description    This
// @include        http://trac.trutap.net/*
// @version        1.1
// ==/UserScript==

function addGlobalStyle(css) {
    var head, style;
    head = document.getElementsByTagName('head')[0];
    if (!head) { return; }
    style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = css;
    head.appendChild(style);
}


//document.getElementById('mainnav').style.display = 'none';

if (document.getElementById('content')){
	document.getElementById('content').style.marginLeft = '1em'
}

addGlobalStyle('#mainnav , #mainnav ul li, #mainnav ul, #mainnav ul li a{ display: inline !important; }');
addGlobalStyle('#mainnav { position: absolute; top: 50px; left: 100px; }');
addGlobalStyle('#mainnav ul li { padding-right: 2em; }');


if (document.getElementById('h_owner')){
	owner = document.getElementById('h_owner').nextSibling.nextSibling.innerHTML.replace(/^\s*(.*?)\s*$/,"$1");

	for (index in document.getElementById('leave_reassign_owner').childNodes){
		
		option = document.getElementById('leave_reassign_owner')[index];
				
		if (option.value == owner){
			document.getElementById('leave_reassign_owner').selectedIndex = index;
			break;
		}
	}
	
}

///////////////////////////////////////////

actions = document.getElementById('action');

if(actions){
	processFlowLink = document.createElement('a');
	
	processFlowLink.href = '/cgi-bin/trac.cgi/wiki/TrutapTicketWorkflow';
	processFlowLink.textContent = 'Workflow Diagram';
	
	actions.childNodes[1].appendChild(document.createTextNode('  ['));
	actions.childNodes[1].appendChild(processFlowLink);
	actions.childNodes[1].appendChild(document.createTextNode(']'));
	
	//actions.insertBefore(processFlowLink, actions.childNodes[1].childNodes[2]);

}