var abaaso=function(){var array={contains:function(instance,arg){try{arg=(arg.toString().indexOf(",")>-1)?arg.split(","):arg;if(arg instanceof Array){var indexes=[],i=args.length;while(i--){indexes[i]=instance.index(arg[i]);}
return indexes;}
else{return instance.index(arg);}}
catch(e){error(e);return undefined;}},index:function(instance,arg){try{if(instance instanceof Array){var i=instance.length;while(i--){if(instance[i]==arg){return i;}}
return-1;}
else{throw label.error.expectedArray;}}
catch(e){error(e);return-1;}},remove:function(obj,start,end){try{start=start||0;obj.fire("beforeRemove");var remaining=obj.slice((end||start)+1||obj.length);obj.length=(start<0)?(obj.length+start):start;obj.push.apply(obj,remaining);obj.fire("afterRemove");return obj;}
catch(e){error(e);return undefined;}}};var cache={items:[],get:function(uri,expire){try{expire=(expire===false)?false:true;if(this.items[uri]===undefined){return false;}
else{if(this.items[uri].headers!==undefined){if(((this.items[uri].headers.Pragma!==undefined)&&(this.items[uri].headers.Pragma=="no-cache")&&(expire))||((this.items[uri].headers.Expires!==undefined)&&(new Date(this.items[uri].headers.Expires)<new Date())&&(expire))||((client.ms>0)&&(expire)&&(this.items[uri].headers.Date!==undefined)&&(new Date(this.items[uri].headers.Date).setMilliseconds(new Date(this.items[uri].headers.Date).getMilliseconds()+client.ms)>new Date()))||((client.ms>0)&&(expire)&&(new Date(this.items[uri].epoch).setMilliseconds(new Date(this.items[uri].epoch).getMilliseconds()+client.ms)>new Date()))){delete this.items[uri];return false;}
else{return this.items[uri];}}
else{return this.items[uri];}}}
catch(e){error(e);return undefined;}},set:function(uri,property,value){try{(this.items[uri]===undefined)?this.items[uri]={}:void(0);this.items[uri][property]=value;}
catch(e){error(e);}}};var calendar={date:{c:new Date(),clear:null,d:null,destination:null,label:null,n:new Date(),p:new Date(),pattern:"yyyy/mm/dd"},create:function(target,destination,clear){try{if((!$(target))||((destination!==undefined)&&(!$(destination)))){throw label.error.elementNotFound;}
var args={id:"abaaso_calendar"},o=calendar.date,obj=null,objDestination=$(destination),objTarget=$(target);o.clear=((destination!==undefined)&&(clear===undefined))?false:validate.bool(clear);o.destination=((destination!==undefined)&&(objDestination))?destination:null;o.c=((destination!==undefined)&&(objDestination.value!=""))?new Date(objDestination.value):o.c;objTarget.blur();((o.destination!==null)&&(objDestination.value==label.error.invalidDate))?objDestination.clear():void(0);if(o.destination!==null){var pos=objTarget.position();args.style="top:"+pos[1]+"px;left:"+pos[0]+"px;position:absolute;z-index:9999;";obj=el.create("div",args);}
else{obj=el.create("div",args,target);}
if(!calendar.render(obj.id,o.c)){obj.destroy();throw label.error.elementNotCreated;}
else{return obj;}}
catch(e){error(e);return undefined;}},day:function(target,dateStamp){try{dateStamp=(dateStamp!==undefined)?new Date(dateStamp):null;if((dateStamp!=null)&&(!isNaN(dateStamp.getYear()))){var o=calendar.date.c,d=dateStamp.getDate(),args={id:"href_day_"+d,innerHTML:d};args["class"]=((dateStamp.getDate()==o.getDate())&&(dateStamp.getMonth()==o.getMonth())&&(dateStamp.getFullYear()==o.getFullYear()))?"current":"weekend";el.create("div",{id:"div_day_"+d,"class":"day"},target);el.create("a",args,"div_day_"+d);if(calendar.date.destination!==null){$(args.id).un("click").on("click",function(){var date=new Date(abaaso.calendar.date.c),day=this.innerHTML.match(/^\d{1,2}$/);date.setDate(day[0]);abaaso.calendar.date.c=date;date=abaaso.calendar.format(date);($(abaaso.calendar.date.destination))?$(abaaso.calendar.date.destination).update({innerHTML:date,value:date}):void(0);$("abaaso_calendar").destroy();},args.id);}}
else{el.create("div",{"class":"day"},target);}}
catch(e){error(e);}},days:function(month,year){try{return(32-new Date(year,month,32).getDate());}
catch(e){error(e);return undefined;}},format:function(dateStamp){try{var output=calendar.date.pattern,outputDate=new Date(dateStamp);output=output.replace(/dd/,outputDate.getDate());output=output.replace(/mm/,outputDate.getMonth()+1);output=output.replace(/yyyy/,outputDate.getFullYear());return output;}
catch(e){error(e);return undefined;}},render:function(target,dateStamp){try{var obj=$(target);if(obj!==undefined){obj.fire("beforeRender");obj.clear();var o=calendar.date;o.c=new Date(dateStamp);o.p=new Date(dateStamp);o.n=new Date(dateStamp);o.d=calendar.days(o.c.getMonth(),o.c.getFullYear());switch(o.c.getMonth()){case 0:o.p.setMonth(11);o.p.setFullYear(o.c.getFullYear()-1);o.n.setMonth(o.c.getMonth()+1);o.n.setFullYear(o.c.getFullYear());break;case 10:o.p.setMonth(o.c.getMonth()-1);o.p.setFullYear(o.c.getFullYear());o.n.setMonth(o.c.getMonth()+1);o.n.setFullYear(o.c.getFullYear());break;case 11:o.p.setMonth(o.c.getMonth()-1);o.p.setFullYear(o.c.getFullYear());o.n.setMonth(0);o.n.setFullYear(o.c.getFullYear()+1);break;default:o.p.setMonth(o.c.getMonth()-1);o.p.setFullYear(o.c.getFullYear());o.n.setMonth(o.c.getMonth()+1);o.n.setFullYear(o.c.getFullYear());break;}
o.label=label.months[(o.c.getMonth()+1).toString()];el.create("div",{id:"calendarTop"},target);if(o.clear){el.create("a",{id:"calendarClear",innerHTML:label.common.clear},"calendarTop");$("calendarClear").un("click").on("click",function(){var o=abaaso.calendar.date;((o.destination!==null)&&$(o.destination))?$(o.destination).clear():void(0);o.c=new Date();o.p=o.c;o.n=o.c;abaaso.destroy("abaaso_calendar");});}
el.create("a",{id:"calendarClose",innerHTML:label.common.close},"calendarTop");$("calendarClose").un("click").on("click",function(){abaaso.destroy("abaaso_calendar");});el.create("div",{id:"calendarHeader"},target);el.create("a",{id:"calendarPrev",innerHTML:"<"},"calendarHeader");$("calendarPrev").un("click").on("click",function(){abaaso.calendar.render("abaaso_calendar",abaaso.calendar.date.p);});el.create("span",{id:"calendarMonth",innerHTML:o.label+" "+dateStamp.getFullYear().toString()},"calendarHeader");el.create("a",{id:"calendarNext",innerHTML:">"},"calendarHeader");$("calendarNext").un("click").on("click",function(){abaaso.calendar.render("abaaso_calendar",abaaso.calendar.date.n);});el.create("div",{id:"calendarDays"},target);dateStamp.setDate(1);var i=null,loop=dateStamp.getDay();for(i=1;i<=loop;i++){calendar.day("calendarDays");}
loop=o.d;for(i=1;i<=loop;i++){calendar.day("calendarDays",dateStamp.setDate(i));}
$(target).fire("afterRender");return true;}
else{throw label.error.elementNotFound;}}
catch(e){error(e);return false;}}};var client={css3:(function(){if((this.chrome)&&(parseInt(client.version)>=6)){return true;}
if((this.firefox)&&(parseInt(client.version)>=3)){return true;}
if((this.ie)&&(parseInt(client.version)>=9)){return true;}
if((this.opera)&&(parseInt(client.version>=9))){return true;}
if((this.safari)&&(parseInt(client.version>=5))){return true;}
else{return false;}}),chrome:(navigator.userAgent.toLowerCase().indexOf("chrome")>-1)?true:false,firefox:(navigator.userAgent.toLowerCase().indexOf("firefox")>-1)?true:false,ie:(navigator.userAgent.toLowerCase().indexOf("msie")>-1)?true:false,ms:0,opera:(navigator.userAgent.toLowerCase().indexOf("opera")>-1)?true:false,safari:(navigator.userAgent.toLowerCase().indexOf("safari")>-1)?true:false,version:(function(){if(this.chrome){return navigator.userAgent.replace(/(.*Chrome\/|Safari.*)/gi,"");}
if(this.firefox){return navigator.userAgent.replace(/(.*Firefox\/)/gi,"");}
if(this.ie){return navigator.userAgent.replace(/(.*MSIE|;.*)/gi,"");}
if(this.opera){return navigator.userAgent.replace(/(.*Opera\/|\(.*)/gi,"");}
if(this.safari){return navigator.userAgent.replace(/(.*Version\/|Safari.*)/gi,"");}
else{return parseInt(navigator.appVersion);}}),del:function(uri,fn){try{uri.toString().fire("beforeDelete");if((uri=="")||(!fn instanceof Function)){throw label.error.invalidArguments;}
client.request(uri,fn,"DELETE");}
catch(e){error(e);}},get:function(uri,fn){try{uri.toString().fire("beforeGet");if((uri=="")||(!fn instanceof Function)){throw label.error.invalidArguments;}
var cached=cache.get(uri);(!cached)?client.request(uri,fn,"GET"):fn(cached.response);}
catch(e){error(e);}},put:function(uri,fn,args){try{uri.toString().fire("beforePut");if((uri=="")||(!fn instanceof Function)||(args===undefined)||(typeof args!="object")){throw label.error.invalidArguments;}
client.request(uri,fn,"PUT",args);}
catch(e){error(e);}},post:function(uri,fn,args){try{uri.toString().fire("beforePost");if((uri=="")||(!fn instanceof Function)||(args=="")){throw label.error.invalidArguments;}
client.request(uri,fn,"POST",args);}
catch(e){error(e);}},request:function(uri,fn,type,args){try{if(((type.toLowerCase()=="post")||(type.toLowerCase()=="put"))&&(typeof args!="object")){throw label.error.invalidArguments;}
uri.toString().fire("beforeXHR");var xhr=new XMLHttpRequest(),payload=((type.toLowerCase()=="post")||(type.toLowerCase()=="put"))?args:null,cached=cache.get(uri,false);xhr.onreadystatechange=function(){client.response(xhr,uri,fn,type);};xhr.open(type.toUpperCase(),uri,true);(payload!==null)?xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded; charset=UTF-8"):void(0);((cached!==false)&&(cached.headers.ETag!==undefined))?xhr.setRequestHeader("ETag",cached.headers.ETag):void(0);xhr.send(payload);}
catch(e){error(e);}},response:function(xhr,uri,fn,type){try{if(xhr.readyState==2){var headers=xhr.getAllResponseHeaders().split("\n"),i=null,loop=headers.length,items={};for(i=0;i<loop;i++){if(headers[i]!=""){var header=headers[i].toString(),value=header.substr((header.indexOf(':')+1),header.length).replace(/\s/,"");header=header.substr(0,header.indexOf(':')).replace(/\s/,"");items[header]=value;}}
cache.set(uri,"headers",items);}
else if(xhr.readyState==4){if((xhr.status==200)&&(xhr.responseText!="")){var state=null,s=abaaso.state;cache.set(uri,"epoch",new Date());cache.set(uri,"response",xhr.responseText);uri.toString().fire("afterXHR");uri.toString().fire("after"+type.toLowerCase().capitalize());uri=cache.get(uri,false);if((s.header!==null)&&(state=uri.headers[s.header])&&(state!==undefined)){s.previous=s.current;s.current=state;((s.previous!==null)&&(s.current!==null))?observer.replace(abaaso,state,s.previous,s.current,s.current):void(0);abaaso.fire(state);}
(fn!==undefined)?fn(uri):void(0);}
else{throw label.error.serverError;}}}
catch(e){error(e);}}};var data={records:[],del:function(){},insert:function(){},search:function(){},select:function(){},update:function(){}};var el={clear:function(obj){try{obj=(typeof obj=="object")?obj:$(obj);if(obj!==null){obj.fire("beforeClear");if(typeof obj.reset=="function"){obj.reset();}
else if(obj.value!==undefined){obj.update({innerHTML:"",value:""});}
else{obj.update({innerHTML:""});}
obj.fire("afterClear");return obj;}
else{throw label.error.elementNotFound;}}
catch(e){error(e);return undefined;}},create:function(type,args,id){try{if(args instanceof Object){var obj=document.createElement(type);(args.id===undefined)?obj.genID():obj.id=args.id;obj.fire("beforeCreate");obj.update(args);((id!==undefined)&&($(id)!==undefined))?$(id).appendChild(obj):document.body.appendChild(obj);obj.fire("afterCreate");return obj;}
else{throw label.error.expectedObject;}}
catch(e){error(e);return undefined;}},destroy:function(arg){try{var args=arg.split(","),i=args.length,obj=null;while(i--){obj=$(args[i]);if(obj!==undefined){obj.fire("beforeDestroy");observer.remove(obj.id);obj.parentNode.removeChild(obj);obj.fire("afterDestroy");}}}
catch(e){error(e);}},disable:function(arg){try{var args=arg.split(","),i=args.length,instances=[],obj=null;while(i--){obj=$(args[i]);if((obj!==undefined)&&(obj.disabled!==undefined)){obj.fire("beforeDisable");obj.disabled=true;obj.fire("afterDisable");instances.push(obj);}}
return(instances.length==0)?obj:((instances.length==1)?instances[0]:instances);}
catch(e){error(e);return undefined;}},enable:function(arg){try{var args=arg.split(","),i=args.length,instances=[],obj=null;while(i--){obj=$(args[i]);if((obj!==undefined)&&(obj.disabled!==undefined)){obj.fire("beforeEnable");obj.disabled=false;obj.fire("afterEnable");instances.push(obj);}}
return(instances.length==0)?obj:((instances.length==1)?instances[0]:instances);}
catch(e){error(e);return undefined;}},eventID:function(e,obj){return(window.event)?window.event.srcElement.id:obj.id;},position:function(obj){obj=(typeof obj=="object")?obj:$(obj);if(obj===undefined){throw label.error.invalidArguments;}
var left=null,top=null;if(obj.offsetParent){left=obj.offsetLeft;top=obj.offsetTop;while(obj=obj.offsetParent){left+=obj.offsetLeft;top+=obj.offsetTop;}}
return[left,top];},update:function(obj,args){try{obj=(typeof obj=="object")?obj:$(obj);args=args||{};if(obj===undefined){throw label.error.invalidArguments;}
obj.fire("beforeUpdate");if(obj){for(var i in args){switch(i){case"class":((client.ie)&&(client.version<8))?obj.setAttribute("className",args[i]):obj.setAttribute("class",args[i]);break;case"innerHTML":case"type":case"src":obj[i]=args[i];break;case"opacity":obj.opacity(args[i]);break;case"id":var o=observer.listeners;if(o[obj.id]!==undefined){o[args[i]]=[].concat(o[obj.id]);delete o[obj.id];}
default:obj.setAttribute(i,args[i]);break;}}
obj.fire("afterUpdate");return obj;}
else{throw label.error.elementNotFound;}}
catch(e){error(e);return undefined;}}};var fx={bounce:function(obj,ms,height){try{obj=(typeof obj=="object")?obj:$(obj);if((obj===undefined)||(isNaN(ms))||(isNaN(height))){throw label.error.invalidArguments;}
obj.fire("beforeBounce");obj.fire("afterBounce");return obj;}
catch(e){error(e);return undefined;}},fade:function(obj,ms,end){try{obj=(typeof obj=="object")?obj:$(obj);if((obj===undefined)||(isNaN(ms))||((end!==undefined)&&(isNaN(end)))){throw label.error.invalidArguments;}
var start=obj.opacity();end=end||((obj.opacity()===0)?100:0);obj.fire("beforeFade");fx.opacityChange(obj,start,end,ms);return obj;}
catch(e){error(e);return undefined;}},fall:function(obj,pos,ms){try{obj=(typeof obj=="object")?obj:$(obj);if(obj===undefined){throw label.error.invalidArguments;}
obj.fire("beforeFall");var i=null,speed=Math.round(ms/100),timer=0;for(i=start;i>=end;i--){if(i==end){setTimeout("$(\""+obj.id+"\").move("+i+");$(\""+obj.id+"\").fire(\"afterFall\")",(timer*speed));}
else{setTimeout("$(\""+obj.id+"\").move("+i+")",(timer*speed));}
timer++;}
return o;}
catch(e){error(e);return undefined;}},move:function(obj,pos){try{obj=(typeof obj=="object")?obj:$(obj);if((obj===undefined)||(!pos instanceof Array)||(isNaN(pos[0]))||(isNaN(pos[1]))){throw label.error.invalidArguments;}
var p=obj.position();p[0]+=pos[0];p[1]+=pos[1];(obj.style.position!="absolute")?obj.style.position="absolute":void(0);obj.style.left=p[0]+"px";obj.style.top=p[1]+"px";return obj;}
catch(e){error(e);return undefined;}},opacity:function(obj,opacity){try{obj=(typeof obj=="object")?obj:$(obj);if(obj!==null){if((opacity!==undefined)||(!isNaN(opacity))){(client.ie)?obj.style.filter="alpha(opacity="+opacity+")":obj.style.opacity=(parseInt(opacity)/100);return parseInt(opacity);}
else{return(client.ie)?parseInt(obj.style.filter.toString().replace(/(.*\=|\))/gi,"")):parseInt(obj.style.opacity);}}
else{return undefined;}}
catch(e){error(e);return undefined;}},opacityChange:function(obj,start,end,ms){try{obj=(typeof obj=="object")?obj:$(obj);if(obj===undefined){throw label.error.invalidArguments;}
var fn=null,speed=Math.round(ms/100),timer=0,i=null;if(start>end){for(i=start;i>=end;i--){if(i==end){setTimeout("$(\""+obj.id+"\").opacity("+i+");$(\""+obj.id+"\").fire(\"afterFade\")",(timer*speed));}
else{setTimeout("$(\""+obj.id+"\").opacity("+i+")",(timer*speed));}
timer++;}}
else{for(i=start;i<=end;i++){if(i==end){setTimeout("$(\""+obj.id+"\").opacity("+i+");$(\""+obj.id+"\").fire(\"afterFade\")",(timer*speed));}
else{setTimeout("$(\""+obj.id+"\").opacity("+i+")",(timer*speed));}
timer++;}}}
catch(e){error(e);}},slide:function(obj,ms,pos,elastic,gravity){try{obj=(typeof obj=="object")?obj:$(obj);if((obj===undefined)||(isNaN(ms))||(!pos instanceof Array)||(isNaN(pos[0]))||(isNaN(pos[1]))){throw label.error.invalidArguments;}
elastic=parseInt(elastic)||0;gravity=parseInt(gravity)||0;obj.fire("beforeSlide");obj.fire("afterSlide");return obj;}
catch(e){error(e);return undefined;}}};var number={even:function(arg){try{return(((parseInt(arg)/2).toString().indexOf("."))>-1)?false:true;}
catch(e){error(e);return undefined;}},odd:function(arg){try{return(((parseInt(arg)/2).toString().indexOf("."))>-1)?true:false;}
catch(e){error(e);return undefined;}}};var json={decode:function(arg){try{return JSON.parse(arg);}
catch(e){error(e);return undefined;}},encode:function(arg){try{return JSON.stringify(arg);}
catch(e){error(e);return undefined;}}};var label={common:{back:"Back",cancel:"Cancel",clear:"Clear",close:"Close",cont:"Continue",del:"Delete",edit:"Edit",find:"Find",gen:"Generate",go:"Go",loading:"Loading",next:"Next",login:"Login",ran:"Random",save:"Save",search:"Search",submit:"Submit"},error:{databaseNotOpen:"Failed to open the Database, possibly exceeded Domain quota.",databaseNotSupported:"Client does not support local database storage.",databaseWarnInjection:"Possible SQL injection in database transaction, use the ? placeholder.",elementNotCreated:"Could not create the Element.",elementNotFound:"Could not find the Element.",expectedArray:"Expected an Array.",expectedArrayObject:"Expected an Array or Object.",expectedBoolean:"Expected a Boolean value.",expectedObject:"Expected an Object.",invalidArguments:"One or more arguments is invalid.",invalidDate:"Invalid Date.",invalidFields:"The following required fields are invalid: ",serverError:"A server error has occurred."},months:{"1":"January","2":"February","3":"March","4":"April","5":"May","6":"June","7":"July","8":"August","9":"September","10":"October","11":"November","12":"December"}};var observer={listeners:[],add:function(obj,event,fn,id,scope,standby){try{var instance=null,l=observer.listeners,o=(obj.id!==undefined)?obj.id:obj.toString();obj=(typeof obj=="object")?obj:$(obj);standby=((standby!==undefined)&&(standby===true))?true:false;if((o===undefined)||(event===undefined)||(!fn instanceof Function)||((standby)&&(id===undefined))){throw label.error.invalidArguments;}
(l[o]===undefined)?l[o]=[]:void(0);(l[o][event]===undefined)?l[o][event]=[]:void(0);(l[o][event].active===undefined)?l[o][event].active=[]:void(0);var item={fn:fn};((scope!==undefined)&&(scope!==null))?item.scope=scope:void(0);if(!standby){(id!==undefined)?l[o][event].active[id]=item:l[o][event].active.push(item);instance=(o!=="abaaso")?$(o):null;((instance!==null)&&(instance!==undefined))?((instance.addEventListener!==undefined)?instance.addEventListener(event,function(){instance.fire(event);},false):instance.attachEvent("on"+event,function(){instance.fire(event);})):void(0);}
else{(l[o][event].standby===undefined)?l[o][event].standby=[]:void(0);l[o][event].standby[id]=item;}
return obj;}
catch(e){error(e);return undefined;}},fire:function(obj,event){try{var l=observer.listeners,o=(obj.id!==undefined)?obj.id:obj.toString();obj=(typeof obj=="object")?obj:$(obj);if((o===undefined)||(o=="")||(obj===undefined)||(event===undefined)){throw label.error.invalidArguments;}
var listeners=observer.list(obj,event).active;for(var i in listeners){if((listeners[i]!==undefined)&&(listeners[i].fn)){if(listeners[i].scope!==undefined){var instance=$(listeners[i].scope),fn=listeners[i].fn,scope=(instance!==undefined)?instance:listeners[i].scope;fn.call(scope);}
else{listeners[i].fn();}}}
return obj;}
catch(e){error(e);return undefined;}},list:function(obj,event){try{if(obj===undefined){throw label.error.invalidArguments;}
var l=observer.listeners,o=(obj.id!==undefined)?obj.id:obj.toString();return(l[o]!==undefined)?(((event!==undefined)&&(l[o][event]!==undefined))?l[o][event]:l[o]):[];}
catch(e){error(e);return undefined;}},remove:function(obj,event,id){try{var instance=null,o=(obj.id!==undefined)?obj.id:obj.toString(),l=observer.listeners;obj=(typeof obj=="object")?obj:$(obj);if((o===undefined)||(event===undefined)||(l[o]===undefined)||(l[o][event]===undefined)){return obj;}
else{if(id===undefined){delete l[o][event];instance=(o!=="abaaso")?$(o):null;((instance!==null)&&(instance!==undefined))?((instance.removeEventListener)?instance.removeEventListener(event,function(){instance.fire(event);},false):instance.removeEvent("on"+event,function(){instance.fire(event);})):void(0);}
else if(l[o][event].active[id]!==undefined){delete l[o][event].active[id];if((l[o][event].standby!==undefined)&&(l[o][event].standby[id]!==undefined)){delete l[o][event].standby[id];}}
return obj;}}
catch(e){error(e);return undefined;}},replace:function(obj,event,id,sId,listener){try{var l=observer.listeners,o=(obj.id!==undefined)?obj.id:obj.toString();obj=(typeof obj=="object")?obj:$(obj);if((o===undefined)||(event===undefined)||(id===undefined)||(sId===undefined)||(l[o]===undefined)||(l[o][event]===undefined)||(l[o][event].active===undefined)||(l[o][event].active[id]===undefined)){throw label.error.invalidArguments;}
(l[o][event].standby===undefined)?l[o][event].standby=[]:void(0);if(typeof(listener)=="string"){if((l[o][event].standby[listener]===undefined)||(l[o][event].standby[listener].fn===undefined)){throw label.error.invalidArguments;}
else{listener=l[o][event].standby[listener].fn;}}
else if(!listener instanceof Function){throw label.error.invalidArguments;}
l[o][event].standby[sId]={"fn":l[o][event].active[id].fn};l[o][event].active[id]={"fn":listener};return obj;}
catch(e){error(e);return undefined;}}};var utility={$:function(arg){try{arg=(arg.toString().indexOf(",")>-1)?arg.split(","):arg;if(arg instanceof Array){var instances=[],i=arg.length;while(i--){instances.push($(arg[i]));}
return instances;}
var obj=document.getElementById(arg);obj=(obj===null)?undefined:obj;return obj;}
catch(e){error(e);return undefined;}},error:function(e){var err={name:((typeof e=="object")?e.name:"TypeError"),message:(typeof e=="object")?e.message:e};(e.number!==undefined)?(err.number=(e.number&0xFFFF)):void(0);((!client.ie)&&(console!==undefined))?console.error(err.message):void(0);(error.events===undefined)?error.events=[]:void(0);error.events.push(err);},domID:function(id){try{return id.replace(/(\&|,|(\s)|\/)/gi,"").toLowerCase();}
catch(e){error(e);return undefined;}},genID:function(obj){try{if(obj===undefined){throw label.error.invalidArguments;}
if(obj.id!=""){return obj;}
var id="abaaso_"+Math.floor(Math.random()*1000000000);obj.id=($(id)===undefined)?id:id+Math.floor(Math.random()*1000);return obj;}
catch(e){error(e);return undefined;}},loading:function(id){try{var obj=$(id);if(obj===undefined){throw label.error.invalidArguments;}
if(abaaso.loading.image===undefined){abaaso.loading.image=new Image();abaaso.loading.image.src=abaaso.loading.url;}
obj.clear();abaaso.create("div",{id:id+"_loading",style:"text-align:center"},id);abaaso.create("img",{alt:label.common.loading,src:abaaso.loading.image.src},id+"_loading");return obj;}
catch(e){error(e);return undefined;}},proto:function(obj,type){try{if(typeof obj!="object"){throw label.error.invalidArguments;}
var apply=function(obj,collection){var i=collection.length;while(i--){(obj[collection[i].name]=collection[i].fn);}}
var methods={array:[{name:"contains",fn:function(arg){return abaaso.array.contains(this,arg);}},{name:"index",fn:function(arg){return abaaso.array.index(this,arg);}},{name:"remove",fn:function(arg){return abaaso.array.remove(this,arg);}}],element:[{name:"bounce",fn:function(ms,height){this.genID();abaaso.fx.bounce(this.id,ms,height);}},{name:"destroy",fn:function(){this.genID();abaaso.destroy(this.id);}},{name:"disable",fn:function(){this.genID();return abaaso.el.disable(this.id);}},{name:"enable",fn:function(){this.genID();return abaaso.el.enable(this.id);}},{name:"fade",fn:function(arg){abaaso.fx.fade(this.id,arg);}},{name:"fall",fn:function(){void(0);}},{name:"get",fn:function(uri){this.fire("beforeGet");var cached=cache.get(uri);if(!cached){uri.toString().on("afterGet",function(){var response=cache.get(uri,false).response;(this.value!==undefined)?this.update({value:response}):this.update({innerHTML:response});uri.toString().un("afterGet","get");this.fire("afterGet");},"get",this);abaaso.get(uri);}
else{(this.value!==undefined)?this.update({value:cached.response}):this.update({innerHTML:cached.response});this.fire("afterGet");}
return this;}},{name:"hide",fn:function(){this.genID();(this.old===undefined)?this.old={}:void(0);this.old.display=this.style.display;this.style.display="none";return this;}},{name:"loading",fn:function(){this.genID();return abaaso.loading.create(this.id);}},{name:"move",fn:function(pos,ms){this.genID();abaaso.fx.move(this,pos,ms);}},{name:"opacity",fn:function(arg){return abaaso.fx.opacity(this,arg);}},{name:"position",fn:function(){this.genID();return abaaso.el.position(this.id);}},{name:"show",fn:function(){this.genID();this.style.display=((this.old!==undefined)&&(this.old.display!==undefined)&&(this.old.display!=""))?this.old.display:"inherit";return this;}},{name:"slide",fn:function(ms,pos,elastic){this.genID();abaaso.fx.slide(this.id,ms,pos,elastic);}},{name:"update",fn:function(args){this.genID();abaaso.update(this,args);}}],number:[{name:"even",fn:function(){return abaaso.number.even(this);}},{name:"odd",fn:function(){return abaaso.number.odd(this);}}],shared:[{name:"clear",fn:function(){((typeof this=="object")&&((this.id===undefined)||(this.id=="")))?this.genID():void(0);(this instanceof String)?(this.constructor=new String("")):abaaso.clear(this);return this;}},{name:"domID",fn:function(){if(!this instanceof String){this.genID();return abaaso.domID(this.id);}
return abaaso.domID(this);}},{name:"fire",fn:function(event){((!this instanceof String)&&((this.id===undefined)||(this.id=="")))?this.genID():void(0);return abaaso.fire(this,event);}},{name:"genID",fn:function(){return abaaso.genID(this);}},{name:"listeners",fn:function(event){((!this instanceof String)&&((this.id===undefined)||(this.id=="")))?this.genID():void(0);return abaaso.listeners(this,event);}},{name:"on",fn:function(event,listener,id,scope,standby){scope=scope||this;((!this instanceof String)&&((this.id===undefined)||(this.id=="")))?this.genID():void(0);return abaaso.on(this,event,listener,id,scope,standby);}},{name:"un",fn:function(event,id){((!this instanceof String)&&((this.id===undefined)||(this.id=="")))?this.genID():void(0);return abaaso.un(this,event,id);}}],string:[{name:"capitalize",fn:function(){return this.charAt(0).toUpperCase()+this.slice(1);}}]};apply(obj,methods[type]);apply(obj,methods.shared);}
catch(e){error(e);}}};var validate={pattern:{domain:/^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$/,ip:/^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})$/,integer:/(^-?\d\d*$)/,email:/^([0-9a-zA-Z]+([_.-]?[0-9a-zA-Z]+)*@[0-9a-zA-Z]+[0-9,a-z,A-Z,.,-]*(.){1}[a-zA-Z]{2,4})+$/,number:/(^-?\d\d*\.\d*$)|(^-?\d\d*$)|(^-?\.\d\d*$)/,notEmpty:/\S/,phone:/^\([1-9]\d{2}\)\s?\d{3}\-\d{4}$/,string:/\w/},bool:function(arg){switch(arg){case true:case false:return arg;default:return false;}},test:function(args){try{var exception=false,invalid=[],pattern=validate.pattern,value=null;for(var i in args){value=($(i).value)?$(i).value:$(i).innerHTML;switch(args[i]){case"boolean":if(!validate.bool(value)){invalid.push(i);exception=true;}
break;case"date":value=new String(value);if((!pattern.notEmpty.test(value))||(!new Date(value))){invalid.push(i);exception=true;}
break;case"domainip":value=new String(value);if((!pattern.domain.test(value))||(!pattern.ip.test(value))){invalid.push(i);exception=true;}
break;default:value=new String(value);var p=(pattern[args[i]])?pattern[args[i]]:args[i];if(!p.test(value)){invalid.push(i);exception=true;}
break;}}
return{pass:!exception,invalid:invalid};}
catch(e){error(e);return{pass:false,invalid:{}};}}};var $=utility.$,error=utility.error;return{array:array,calendar:calendar,client:{css3:client.css3,chrome:client.chrome,firefox:client.firefox,ie:client.ie,ms:client.ms,opera:client.opera,safari:client.safari,version:client.version,del:client.del,get:client.get,post:client.post,put:client.put},el:el,fx:{bounce:fx.bounce,fade:fx.fade,fall:fx.fall,opacity:fx.opacity,slide:fx.slide},json:json,label:label,loading:{create:utility.loading,url:null},number:number,observer:{add:observer.add,fire:observer.fire,list:observer.list,remove:observer.remove},state:{current:null,header:null,previous:null},validate:validate,$:utility.$,clear:el.clear,create:el.create,del:client.del,destroy:el.destroy,domID:utility.domID,error:utility.error,fire:function(){var obj=(arguments[1]===undefined)?abaaso:arguments[0],event=(arguments[1]===undefined)?arguments[0]:arguments[1];return abaaso.observer.fire(obj,event);},genID:utility.genID,get:client.get,id:"abaaso",init:function(){abaaso.ready=true;utility.proto(Array.prototype,"array");utility.proto(Element.prototype,"element");(client.ie)?utility.proto(HTMLDocument.prototype,"element"):void(0);utility.proto(Number.prototype,"number");utility.proto(String.prototype,"string");window.$=function(arg){return abaaso.$(arg);};window.onresize=function(){abaaso.fire("resize");};abaaso.fire("ready").un("ready");if(!client.ie){window.onload=function(){abaaso.fire("render").un("render");};}
delete abaaso.init;},listeners:function(){var all=(arguments[1]!==undefined)?true:false;var obj=(all)?arguments[0]:abaaso,event=(all)?arguments[1]:arguments[0];return abaaso.observer.list(obj,event);},position:el.position,post:client.post,put:client.put,on:function(){var all=(arguments[2]instanceof Function)?true:false;var obj=(all)?arguments[0]:abaaso,event=(all)?arguments[1]:arguments[0],listener=(all)?arguments[2]:arguments[1],id=(all)?arguments[3]:arguments[2],scope=(all)?arguments[4]:arguments[3],standby=(all)?arguments[5]:arguments[4];return abaaso.observer.add(obj,event,listener,id,scope,standby);},ready:false,un:function(){var all=(typeof arguments[0]=="string")?false:true;var obj=(all)?arguments[0]:abaaso,event=(all)?arguments[1]:arguments[0],id=(all)?arguments[2]:arguments[1];return abaaso.observer.remove(obj,event,id);},update:el.update,version:"beta"};}();if((abaaso.client.chrome)||(abaaso.client.firefox)||(abaaso.client.safari)){window.addEventListener("DOMContentLoaded",function(){abaaso.init();},false);}
else{abaaso.ready=setInterval(function(){if((document.readyState=="loaded")||(document.readyState=="complete")){clearInterval(abaaso.ready);abaaso.init();abaaso.fire("render").un("render");}},300);}
