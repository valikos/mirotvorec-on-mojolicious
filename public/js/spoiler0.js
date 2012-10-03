function splr(Objctn,nText, nOpen, nClose, nLast){
Objctt = get_nextSibling(Objctn);
Objcttst = Objctt.style;

with(Objctn)
if (innerHTML==nText+nOpen+nLast) {
    innerHTML=nText+nClose+nLast;
	Objctt.innerHTML = str_replace("<!--", "", Objctt.innerHTML);
	Objctt.innerHTML = str_replace("--&gt;", "", Objctt.innerHTML); 
	Objcttst.display='block';
    }
    else {
    innerHTML=nText+nOpen+nLast;
	Objcttst.display='none';
	}
}
function str_replace(search, replace, subject) {
    return subject.split(search).join(replace);
}
function get_nextSibling(n) {
    x=n.nextSibling;
    while (x.nodeType!=1) {
      x=x.nextSibling;
    }
    return x;
}