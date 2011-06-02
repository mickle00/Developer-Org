window.onload = new function()
{
window.setTimeout(doit,2000);
}

function doit(){
	var u = document.URL;
	if(u.indexOf("https://na3.salesforce.com/5005000000CJdMB") != -1){
		//alert(u);
		if(document.getElementsByName("newEmail")[0]!=null){
			document.getElementsByName("newEmail")[0].style.display = 'none';
		}
	}
	//else
	//{
	//alert(u);
	//}
}
