calc_price=0;
$(document).ready(function(){
	$("#submit").hide();
	$("dl[name=dlchoses]").each(function(g){
		var kt;				  
		$("dl[name=dlchoses]").eq(g).find("dd").each(function(t){
			//移动
			$(this).mouseover(function(){
				$(this).css("background","#89bbfa").css("color","#fff");
				$(this).eq(kt).css("background","#89bbfa").css("color","#fff");
				desctxt=$(this).next().text();
				pos=$(this).position();
				//alert(pos.left);
				if(desctxt != "")
				{
					$("#descinfo").show().css("top",pos.top+28).css("left",pos.left+10);
					$("#desccon").html(desctxt)
				}
			});
			//移出label
			$(this).mouseout(function(){
				$("dl[name=dlchoses]").eq(g).find("dd").css("background","#eee").css("color","#666");	
				$("dl[name=dlchoses]").eq(g).find("dd").eq(kt).css("background","#A40000").css("color","#fff");	
				$("#descinfo").hide()
			});		
			//点击
			$(this).click(function(){
				kt=t;				   
				//alert($(this).css("background"));	
				$("dl[name=dlchoses]").eq(g).find("dd").css("background","#eee").css("color","#666");	
				$("dl[name=dlchoses]").eq(g).find("dd").eq(t).css("background","#A40000").css("color","#fff");	
				$("dl[name=dlchoses]").eq(g).find("dd").eq(t).find("input").attr("checked",true);
				$("dl[name=dlchoses]").eq(g).find("dd").eq(t).parent("dl").children("dt").css("color","#666");	
				$('#cal_submit').html('<span class=calcula_click onclick="func_calcula_click()" onmouseover="func_calaua_over()" onmouseout="func_calcua_out()"></span>');
				$("#cal_show > dl").hide();
				$('span[class=calcula_click]').css('background','url(../images/products/02.png)');	
			});	

		});	//function(t)				  
	}); //function(g)

	$(".nav_chose >span").each(function(i){
		$(".nav_chose >span").eq(0).css("background","#fff").css("border-top","1px solid #ccc").css("border-left","1px solid #ccc").css("border-right","1px solid #ccc").css("border-bottom","0px");
		$(this).mouseover(function(){
			$(this).css("color","red");					   
		});
		$(this).mouseout(function(){
			$(this).css("color","#000");				  
		});
		$(this).click(function(){
			$(".nav_chose >span").css("background","#eee").css("border","0px");					   
			$(this).css("background","#fff").css("border-top","1px solid #ccc").css("border-left","1px solid #ccc").css("border-right","1px solid #ccc").css("border-bottom","0px");	
			$(".nav_show").hide();
			$(".nav_show").eq(i).show();			
		});
	}); //function(i)

	$("dd[name=question]").each(function(k){
		$(this).mouseover(function(){
			$("dd[name=question]").next("dd").hide();
			$("dd[name=question]").css("border","none");
			$("dd[name=question]").eq(k).next("dd").show();
			$("dd[name=question]").eq(k).css("border","1px solid #eee");
		});
	});
	calc_price=$("input[name=chose_version]").val();
	//notebook begin
	notebook_config();	
	init_price();
	//notebook end
	city_code=remote_ip_info["city"];
	//alert(city_code);
	$("input[name=city_code]").val(city_code);
}); //document.ready

function notebook_config()
{
	notebook_init('cpu');
	notebook_init('memory');
	notebook_init('disk');
	notebook_init('graph');
	notebook_init('size');
   	calc_price==0;
	$("#price").text(0);

	$("input[name=cpusel_t]").val('');
	$("input[name=memorysel_t]").val('');
	$("input[name=disksel_t]").val('');
	$("input[name=graphsel_t]").val('');
	$("input[name=sizesel_t]").val('');
}

function notebook_init(inittype)
{
	var inputname='int'+inittype;
	var imgname='img'+inittype;
	var fatherid2=$("input[name=fatherid2]").val();
//alert(inittype);
  	$.ajax({
	url:'../ajax/auto_brand.php',
	cache: false,
	data: {"fatherid2":fatherid2,
    		"kind":inittype 	//size选择框
	},
	type: "POST",
	success :function(data){
		//先把select的option清空
		$("select[name="+inittype+"]").children("option").remove();
		$("select[name="+inittype+"]").append("<option value='0'></option>");
		for(var i=0;i<data.length;i++){
			var selvalue=data[i][inittype];
			$("select[name="+inittype+"]").append("<option  value="+selvalue+">"+selvalue+"</option>");
		}
	},
	dataType : 'json'	
   	});

   	$("img[id="+imgname+"]").hide();
   	$("input[name="+inputname+"]").val("");
}

function init_price()
{
	var price=0;
	var h_price=0;
	var sz_price=0;
	var kind=0;
	var fatherid=0;
	var goodsid=$("input[name=priductid]").val();
	//alert(goodsid);
	$.ajax({
		url:'../ajax/select_price.php', //静态化时注意路径
		cache: false,
		data: {"goodsid":goodsid
		},
		type: "POST",
		error: function() { alert("Jquery Ajax request error!!"); },
		success :function(data){
			if(data=='noprice'){
				alert("价格查询失败，请刷新页面或联系客服");
			}else{
				//alert(data);
				price=data.productprice;
				h_price=data.h_productprice;
				sz_price=data.sz_productprice;
				kind=data.kind;
				fatherid=data.fatherid;
				//alert(sz_price);
				$("#price").text(price);
				if(kind==5 || kind==23){
					if(fatherid!=134){
						if(price>0){
							$("input[id=china]").val(price);
							//$("#price1").text(price);
						}
						if(h_price>0){
							$("input[id=hongkong]").val(h_price);
						}
						if(sz_price>0){
							$("input[id=othercountry]").val(sz_price);
						}
					}
				}
			}
		},
		dataType : 'json'
	});
}

function fun_price()
{
	if(calc_price==0){
		alert('版本信息选择有误，请重新选择');
		$('body,html').animate({scrollTop:300},100);
		return false;
	}
	if(check_all()=='no'){
		alert('请选择完整的物品描述');
		$('body,html').animate({scrollTop:300},100);
		return false;
	}
	$('#cal_submit').html('<span class=calcula_click onclick="func_calcula_click()" onmouseover="func_calaua_over()" onmouseout="func_calcua_out()"></span>');
	$("#cal_show > dl").hide();
	$('span[class=calcula_click]').css('background','url(../images/products/02.png)');

	var desctext="";
	var descsel="";
	$("select").each(function(y){
		desctext+=$("select").eq(y).find("option:selected").text()+"|";
	})
	$("input:checked").each(function(y){
		desctext+=$("input:checked").eq(y).parent("dd").text()+"|";
		descsel+=$("input:checked").eq(y).attr("lang")+",";
	})	

	$("input[name=desctext]").val(desctext);	//alert(descsel);
	$("input[name=descsel]").val(descsel);

	var price_org=$("#price").text();
	var price_cur=$("#price").text();
	$("input[accept='calc']:checked").each(function(i){
		price_cur-=price_org*$("input[accept='calc']:checked").eq(i).attr("ratio");
	})
	var price_h=(Math.round(price_cur));
	if(price_h<$("input[name=lowestprice]").val()){
		price_h=$("input[name=lowestprice]").val();
	}
	$("input[name=lastprice]").attr("value",price_h);
	$("dd[class=dd_price]").css('font-size','28px').html(price_h);
	$("#submit").show();
}

var pname;
var abanben='no';
var abaoxiu='no';
var amemory='no';
var awebshuo='no';
var haveprice='no';

function fun_apple(apple)
{
	$('#cal_submit').html('<span class=calcula_click onclick="func_calcula_click()" onmouseover="func_calaua_over()" onmouseout="func_calcua_out()"></span>');
	$("#cal_show > dl").hide();
	$('span[class=calcula_click]').css('background','url(../images/products/02.png)');

	pname=$("input[name=pname]").val();
	if($(apple).attr("name")=='abanben')
	{
		abanben=$(apple).children("input").val();
	}
	if($(apple).attr("name")=='abaoxiu')
	{
		abaoxiu=$(apple).children("input").val();
	}
	if($(apple).attr("name")=='amemory')
	{
		amemory=$(apple).children("input").val();
	}
	if($(apple).attr("name")=='awebshuo')
	{
		awebshuo=$(apple).children("input").val();
	}
	if((abanben=='no')|| (abaoxiu=='no') ||(amemory=='no')){
		return;
	}
	calc_price=1;
	$.ajax({
		url:'../tpl/apple_clacu.php',//静态化时注意路径
		cache: false,
		data: {
			"pname":pname,
			"amemory":amemory,
			"ababben":abanben,
			"abaoxiu":abaoxiu,
			"awebshuo":awebshuo
		},
		type: "POST",
		error: function() { alert("Jquery Ajax request error!!!"); },
		success :function(data){
			if(data=='noprice'){
				$("#price").text(0);
                calc_price=0;
				alert("没有您选择的这种配置，请重新选择或详询客服");
			}
			else
			{
				$("#price").text(data);
			}
		}
	});
}

function fun_qudao(qudao)
{
	calc_price=1;
	$("#price").text($(qudao).children("input").val());
}

function check_all()
{
	var checkname="";
	var allcheck="";
	$("input[accept='calc']:checked").each(function(j){
		checkname+=$(this).attr("name")+",";						 				 
	})
	checkname=checkname.substr(0, checkname.length-1); 
	allcheck=checkname.split(",");

	var textslong="";
	var dtid="";
	var alltexts="";
	$(".dtchoses").each(function(){
		dtid=$(this).attr("id");	
		var texts=$.inArray(dtid,allcheck);
		textslong+=texts+",";	
		if(texts == -1){
			$(this).css("color","#FF0000");
		}else{
			$(this).css("color","#666");
		}
	});
	textslong=textslong.substr(0, textslong.length-1);
	alltexts=textslong.split(",");
	var textlog=$.inArray('-1',alltexts);
	if(textlog>=0){
		return 'no';
	}	
}

function check_notebook()
{
	if($(".configinput").eq(0).val()=='' 
		|| $(".configinput").eq(1).val()=='' 
		|| $(".configinput").eq(2).val()=='' 
		|| $(".configinput").eq(3).val()=='' 
		|| $(".configinput").eq(4).val()=='')
	{
		return 'no';
	}
	else{
		calc_price=1;
	}
}

function select_price(sel_obj){
	$('#cal_submit').html('<span class=calcula_click onclick="func_calcula_click()" onmouseover="func_calaua_over()" onmouseout="func_calcua_out()"></span>');
	$("#cal_show > dl").hide();
	$('span[class=calcula_click]').css('background','url(../images/products/02.png)');

	var pzclass=$(sel_obj).attr("name");//配置的类别
	var pzvalue=$(sel_obj).find("option:selected").text();//配置类别的值
		//alert(pzclass+'--'+pzvalue);
	var cputext=new Array();
	var memorytext=new Array();
	var graphtext=new Array();
	var disktext=new Array();
	var sizetext=new Array();
	var productprice=new Array();
	cpusel=$("select[name=cpu]").val();
	memorysel=$("select[name=memory]").val();
	disksel=$("select[name=disk]").val();
	graphsel=$("select[name=graph]").val();
	sizesel=$("select[name=size]").val();
	var allconfig=$("input[name=allconfig]").val();
	var fatherid2=$("input[name=fatherid2]").val();
	var cpusel_t=$("input[name=cpusel_t]").val();
	var memorysel_t=$("input[name=memorysel_t]").val();
	var disksel_t=$("input[name=disksel_t]").val();
	var graphsel_t=$("input[name=graphsel_t]").val();
	var sizesel_t=$("input[name=sizesel_t]").val();

	$.ajax({
		url:'../ajax/notebook_jj.php',
		cache: false,
		data: {	'pzclass':pzclass,
			'cpu':cpusel_t,
			'memory':memorysel_t,
			'disk':disksel_t,
			'graph':graphsel_t,
			'size':sizesel_t,
			'pzvalue':pzvalue,
			'fatherid2':fatherid2
		},
		type: "POST",
		dataType : 'json',
		error: function() { alert('加载失败，请重新刷新页面。'); },
		success :function(data){
			for(var i=0;i<data.length;i++){
				cputext.push(data[i].cpu);
				memorytext.push(data[i].memory);
				graphtext.push(data[i].graph);
				disktext.push(data[i].disk);
				sizetext.push(data[i].size);
				productprice.push(data[i].productprice);
			}
			cputext=cputext.delRepeat();
			memorytext=memorytext.delRepeat();
			graphtext=graphtext.delRepeat();
			disktext=disktext.delRepeat();
			sizetext=sizetext.delRepeat();
			productprice=productprice.delRepeat();
			inputselect(cputext,'cpu');
			inputselect(memorytext,'memory');
			inputselect(graphtext,'graph');
			inputselect(disktext,'disk');
			inputselect(sizetext,'size');

			if(check_notebook()=='no'){
			}else{
				var allconfig=$("input[name=allconfig]").val();
				var fatherid2=$("input[name=fatherid2]").val();
				var cpusel_t=$("input[name=cpusel_t]").val();
				var memorysel_t=$("input[name=memorysel_t]").val();
				var disksel_t=$("input[name=disksel_t]").val();
				var graphsel_t=$("input[name=graphsel_t]").val();
				var sizesel_t=$("input[name=sizesel_t]").val();
				//alert(cpusel_t+'--'+memorysel_t+'--'+disksel_t+'--'+graphsel_t+'--'+sizesel_t+'--'+fatherid2);
				$.ajax({
					url:'../ajax/notebook_price.php',
					cache: false,
					data: {'cpu':cpusel_t,
						'memory':memorysel_t,
						'disk':disksel_t,
						'graph':graphsel_t,
						'size':sizesel_t,
						"fatherid2":fatherid2
					},
					type: "POST",
					error: function() { alert("Jquery Ajax request error!!!"); },
					success :function(data){
						//拿到这个配置的价钱
						//alert(data);
						//$("span[id=price]").html(data);
						$("#price").text(data);
					}

				});	
			}
		}
	});		
}

function inputselect(selarray,selname){
	//alert(selarray.length);
	var inputname='int'+selname;//相对应的input名字少
	var imgname='img'+selname;
	var inputselname=selname+"sel_t";
	var selhtml='';
	var allconfig=$("input[name=allconfig]").val();
	//alert($("input[name="+inputname+"]").val());
	if($("input[name="+inputname+"]").val()==1){//如果该下拉列只有一个值了，则不需要操作该下拉列了
	}else{
		//alert(selarray.length);
		if(selarray.length>1){
			selhtml="<option value=''></option>";
			for(var t=0;t<selarray.length;t++){   
				selhtml+="<option value='"+selarray[t]+"'>"+selarray[t]+"</option>";
			}
		}else if(selarray.length=1){
			selhtml="<option value='"+selarray[0]+"'>"+selarray[0]+"</option>";
			$("input[name="+inputname+"]").val(1);			
			$("img[id="+imgname+"]").show();
			$("input[name="+inputselname+"]").val(selarray[0]);
		}else{
			selhtml="";
		}
		$("select[name="+selname+"]").html(selhtml);
	}
}

Array.prototype.delRepeat = function(){
	var newArray = [];
	var provisionalTable = {};
	for (var i = 0, item; (item = this[i]) != null; i++) {
		if (!provisionalTable[item]) {
			newArray.push(item);
			provisionalTable[item] = true;
		}
	}
	return newArray;
}
function checklogin(){}

function func_calcula_click(){
	res=fun_price();
	if(res!=false){
		$("#cal_show > p").show();
		$("#cal_submit > span").css("background","url(../images/products/02.png)");
		var ct=setTimeout("$('#cal_show > p').hide();$('#cal_show > dl').show();$('#cal_submit').html('<span class=calcula_click></span>');$('span[class=calcula_click]').css('background','url(../images/products/03.png)')",2000);
	}
}
function func_calaua_over(){
	//alert('123');
	$("#cal_submit > span").css("background","url(../images/products/02.png)");
	}	
function func_calcua_out(){
	//alert('456');
	$("#cal_submit > span").css("background","url(../images/products/01.png)");
	}


//一个后门:为减轻本站工作人员劳动量.点击图片时可以把很多的第一项选项给选中
$(document).ready(function(){

	$("#goods_left dl dd img").click(function(){

		$("dl[name='dlchoses']:gt(3)").each(function(){
			$(this).find("dd").eq(0).trigger("click");
		});
	});

});