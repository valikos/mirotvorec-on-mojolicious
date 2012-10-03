var http = '' + 'parser.php?'; //Cцылко на серверную часть
var frm = 'form1'; //Имя формы :)
this.AjaxFailedAlert = "Ваш браузер не поддерживает расширенные возможности управления сайтом, мы настоятельно рекомендуем сменить браузер.\n";
var loading = '<br><div align="center"><img src="images/loading.gif" alt="идет поиск..."></div>';
var hide_results = '<br><div style="width: 100%; text-align:center" align="center"><input type="button" name="search_hide" onClick="hide(\'bf_http_request\');" value="убрать результаты поиска" style="width: 250px;"></div>';

function russ_escape(str){ //короче эскейпит наш могучий русский язык
  var trans = [];
  
  for (var i = 0x410; i <= 0x44F; i++) trans[i] = i - 0x350;
  trans[0x401] = 0xA8; 
  trans[0x451] = 0xB8; 

  var ret = [];
  for (var i = 0; i < str.length; i++)
  {
    var n = str.charCodeAt(i);
    if (typeof trans[n] != 'undefined')
      n = trans[n];
    if (n <= 0xFF)
      ret.push(n);
  }
  return escape(String.fromCharCode.apply(null, ret));
}

this.createAJAX = function() {
  try {
    this.xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
  } catch (e) {
    try {
      this.xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    } catch (err) {
      this.xmlhttp = false;
    }
  }
  
  if (!this.xmlhttp && typeof XMLHttpRequest!="undefined") {
    this.xmlhttp = new XMLHttpRequest();
  }
  
  if (!this.xmlhttp){
    alert(this.AjaxFailedAlert);
  }
  return xmlhttp;
}

this.fill_info = function(url,type){
    if(url != ''){        
        document.getElementById('bf_http_request').style.display = '';
        document.getElementById('bf_http_request').innerHTML = loading;
        
        var xmlhttp = createAJAX(); 
        xmlhttp.open("GET", http  + url, true);
        
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState == 4){
        if (xmlhttp.status == 200) {
            if (type == '1'){
                var response = xmlhttp.responseText + hide_results;
                document.getElementById('bf_http_request').innerHTML = response ;     
                 }
            if (type == '2'){
                var response = xmlhttp.responseText.split("|");
                push_response(response);
                 }
                 
            }else{
                messageError(xmlhttp.statusText);
                xmlhttp.abort();
            }
        }
        }
    
        xmlhttp.send(null);
    }
}

this.hide =function(a){
    document.getElementById(a).innerHTML = '';
}

this.push_response = function(response){
    //ну думаю тут проблем не будет :)
    document.getElementById('bf_http_request').innerHTML = '';
    document.getElementById('bf_http_request').style.display = 'none';    
    document.forms[frm].elements['bf_kp_search'].style.display = 'none';
    if(response[1]) document.forms['form1'].elements['release_date'].value = response[1];
    if(response[2]) document.forms['form1'].elements['studio'].value = response[2];
    if(response[3]) document.forms['form1'].elements['regi'].value = response[3];
    if(response[4]) document.forms[form1].elements['m_genre'].value = response[4];
    if(response[5]) document.forms[form1].elements['cast'].value = response[5];
    if(response[6]) document.forms[form1].elements['name'].value = response[6];
    if(response[7]) document.forms[form1].elements['torrent_name_orig'].value = response[7];
    if(response[8]) document.forms['form1'].elements['description'].value = response[8];
    if(response[9]) document.forms[form1].elements['time'].value = response[9];
    if(response[10]) document.forms['form1'].elements['kp'].value = response[10];
    if(response[11]) document.forms['form1'].elements['imdb'].value = response[11];
}  