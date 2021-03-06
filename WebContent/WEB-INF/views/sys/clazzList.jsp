<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<div class="easyui-layout" data-options="fit:true,border:false" style="width: 99%; height: auto">
	<div data-options="region:'center',fit:true,border:false,iconCls:'icon-dic'" title="班级列表">
		<div id="clazzToolbar" style="padding: 5px; height: auto">	
				<td>班级名称:</td>
				<td><input class="easyui-validatebox textbox" id="name"
					name="name" 
					style="width: 100px; height: 13px; padding: 5px" />
				</td> 
				&nbsp;
				<td>所属专业:</td>
				<td><s:select cssClass="easyui-combobox" id="majorFieldSelected" editable="false" 
					name="majorFieldSelected" list="#request.majors" listKey="id" listValue="name" headerKey="0" headerValue="---请选择---"  
					cssStyle="width: 140px;height:26px" data-options="panelWidth:'120px', panelHeight:'auto'"></s:select>
				</td>
				&nbsp;
				<button href="#" class="easyui-linkbutton" plain="true" 
					onclick="getClazzsByLimit('#clazzToolbar', '#clazzList')" 
					iconCls="icon-search">查询</button>
		</div>
		<table id="clazzList" class="easyui-datagrid" style="width: auto;"
			pagination="true" url="System_Clazz_getClazzList.action" toolbar="#clazzOperToolbar" 
			rownumbers="true" data-options="pageSize:10,loadMsg:'数据加载中,请稍后...',idField :'id',sortName:'name',sortOrder:'desc'" >
			<thead>
				<tr>
					<th field="id" width="100" align="center" checkbox="true">id</th>
					<th field="name" width="120" align="center" sortable="true">班级名字</th>
					<th field="classQqNumber" width="120" align="center">班级QQ群</th>
					<th field="gradeName" width="60" align="center">所属年级</th>
					<th field="majorFieldName" width="150" align="center">所属专业</th>
				</tr>
			</thead>
		</table>
	</div>
	
    <div id="clazzOperToolbar">
    	<a href="javascript:void(0)" class="easyui-linkbutton" iconCls="icon-add" plain="true" onclick="toAddClazz()">添加</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" iconCls="icon-edit" plain="true" onclick="toEditClazz()">编辑</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" iconCls="icon-clear" plain="true" onclick="toDeleteClazz()">删除</a>
    </div>
</div>
<div id="addClazzDialog" data-options="iconCls:'icon-add'" style="width:600px;height:300px;padding:10px"></div>
<div id="editClazzDialog" data-options="iconCls:'icon-edit'" style="width:600px;height:300px;padding:10px"></div>
<script type="text/javascript">

	function getClazzsByLimit(toolbar,datagrid){
		//解决浏览器不兼容tirm()方法，如ie8以下不兼容trim()，该方法去掉前后空格
		if(!String.prototype.trim) {
			String.prototype.trim = function(){
		    	return this.replace(/^\s+|\s+$/g,'');
		  	};
		}
		
		var name=$(toolbar).find("#name").val().trim();
		var majorFieldSelected=$(toolbar).find('#majorFieldSelected').combobox('getValue');
		
		$('#clazzList').datagrid({
			queryParams: {
				name: name,
				majorFieldSelected: majorFieldSelected
			}
		});
		
		//再次发送请求
		$.post('System_Clazz_getClazzList.action',{
			name: name,
			majorFieldSelected: majorFieldSelected
		},function(data){
			if (data.total){
				$(datagrid).datagrid('loadData', data); 
            }else{
           		$(datagrid).datagrid('loadData', data); 
           	 	$.messager.show({    // show error message
                    title: '提示',
                    msg: '没有任何记录'
                });
            }
		},"json")
	}
	
	//添加
	function toAddClazz(){
		$('#addClazzDialog').dialog({
			title :"	添加班级信息",
		    width: 600,
		    height: 400,
		    cache: false,
		    href: 'System_Clazz_addClazzPage.action',
		    collapsible: true,
		    maximizable: true,
		    resizable: true,
		    modal: true,
		    closed: true
		});
		$('#addClazzDialog').dialog('open');
	}
	
	//编辑
	function toEditClazz(){
		var rows = $('#clazzList').datagrid('getSelections');
   		if (rows.length == 1) {
   			$('#editClazzDialog').dialog({
   				title :"	编辑班级信息",
   			    width: 600,
   			    height: 400,
   			    cache: false,
   			    href: 'System_Clazz_editClazzPage.action?clazzId='+rows[0].id,
   			    collapsible: true,
   			    maximizable: true,
   			    resizable: true,
   			    modal: true,
   			    closed: true
   			});
   			$('#editClazzDialog').dialog('open');
   		} else if (rows.length > 1) {
   			 $.messager.alert('提示', '一次只能编辑一条信息！', 'error');
   		} else {
   			 $.messager.alert('提示', '请勾选要编辑的班级信息！', 'error');
   		}
	}
	
	//删除
	function toDeleteClazz(){
		var rows = $('#clazzList').datagrid('getSelections');
		if(rows.length==0){
			$.messager.alert('提示', '请勾选要删除信息！', 'info');
   			return;
		}else{
			var length=rows.length;
			$.messager.confirm('请确认','您确定删除共'+length+'条专业信息吗?',function(r){
                   if (r){
                   	var params="";
                   	for(i=0;i<rows.length;i++){
                   		params=params+rows[i].id;
                   		if(!(i==rows.length-1)){
                   			params=params+",";
                   		}
                   	}
   					var url="System_Clazz_toDeleteClazz.action";
                   	$.post(url, {idList:params},
                   	function(data){
                    	if (data.success){
                      		$('#clazzList').datagrid('uncheckAll');
                            $.messager.show({    // show error message
                            	title: 'Tips',
                                msg: '删除记录成功'
                            });
                            $('#clazzList').datagrid('reload');    // reload the user data
                        }else {
                        	$.messager.show({    // show error message
                            	title: 'Error',
                           		msg: '删除记录失败'
                           	});
                        }
                    },'json'); 
                 }
            });
		}
	} 
	
</script>
