<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<div class="easyui-panel" style="padding: 30px 70px 50px 70px" align="center">
	<s:form id="addClazzForm" namespace="/" method="post" theme="simple" enctype="multipart/form-data">
		<s:hidden name="id"/>
		<table cellpadding="7">
			<tr>
				<td>学	院：</td>
				<td>
					<s:select list="#request.departments" listKey="id" listValue="name" headerKey="--请选择学院--" headerValue="--请选择学院--"
					cssClass="easyui-combobox" editable="false" 
					id="departmentSelected" name="departmentSelected" style="width: 150px"
					data-options="panelWidth:'130px', panelHeight:'auto'"></s:select>
				</td>
			</tr>
			
			<tr>
				<td>专	业：</td>
				<td>
					<select class="easyui-combobox" editable="false" 
					id="majorFieldSelected" name="majorFieldSelected" style="width: 150px" 
					data-options="panelWidth:'130px', panelHeight:'auto'">
						<option value="0">--请选择专业--</option>
					</select>
				</td>
			</tr>
			
			<tr>
				<td>班别名称：</td>
				<td>
					<s:textfield cssClass="easyui-validatebox textbox" name="name" id="name"  
						data-options="required:true" missingMessage="必须输入项" placeholder="请输入班级名称" 
						style="width: 120px; height: 15px; padding: 5px"/>
					<font color="red" style="padding-left: 5px;">*</font>
				</td>
			</tr>
			
			<tr>
				<td>班别QQ群号：</td>
				<td>
					<s:textfield cssClass="easyui-validatebox textbox" name="classQqNumber" id="classQqNumber" placeholder="请输入班级QQ群" 
						style="width: 120px; height: 15px; padding: 5px"/>
				</td>
			</tr>
			
			<tr>
				<td>所属年级：</td>
				<td>
					<s:select list="%{#request.grades}" listKey="id" listValue="name" headerKey="0" headerValue="--选择--" 
					cssClass="easyui-combobox" editable="false" 
					id="gradeSelected" name="gradeSelected" style="width: 80px" 
					data-options="panelWidth:'60px', panelHeight:'auto'"></s:select>
				</td>
			</tr>
		</table>
	</s:form>
	<br/>
	<div style="text-align: center; padding: 5px;">
		<a href="javascript:void(0)" class="easyui-linkbutton" iconCls="icon-ok" 
			onclick="toAddClazzs('#addClazzForm')">添加</a>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:void(0)" class="easyui-linkbutton" iconCls="icon-no" 
			onclick="exitAddClazzPage()">关闭</a>
	</div>
</div>
<script type="text/javascript">
  	
	//获取专业
	$(function(){
		var tcSelect = $('#departmentSelected');
		tcSelect.combobox({
			onSelect : function() {
				var departmentId = tcSelect.combobox('getValue');
				if(departmentId!="--请选择学院--"&&departmentId!=null){
					$('#addClazzForm').find('#majorFieldSelected').combobox({
						valueField : "id",
						textField : "name",
						url : "StudentInfo_AddNewInfo_toGetMajorField.action?departmentId=" + departmentId,
						editable : false,
						value : "--请选择专业--"
					});		
				}else{
					//清空combobox
					$('#addClazzForm').find('#majorFieldSelected').combobox('loadData', {});
					$('#addClazzForm').find('#majorFieldSelected').combobox('setValue', '--请选择专业--');
				}
			}
		});
	});

	function exitAddClazzPage(){
		$.messager.confirm('请确认','确认关闭添加页面？',function(r){
			if(r){
				$('#addClazzDialog').dialog('close');
			}
		});
	}
	
	//表单提交
	function toAddClazzs(form){
    	//在提交数据之前执行表单验证
		$(form).form('enableValidation').form('validate'); 
    	
    	var majorFieldSelected=$(form).find('#majorFieldSelected').combobox('getValue');
    	var gradeSelected=$(form).find('#gradeSelected').combobox('getValue');
    	
    	//判断表单验证是否通过
		if(!$(form).form('validate')){
			$.messager.alert("错误提示", "注意填写必须填写的信息！","info");  
			return false;
		}else if(gradeSelected=="0"||majorFieldSelected=="--请选择专业--"){
			$.messager.alert("错误提示", "请选择专业或者选择年级！","info");  
			return;
		}
    	
    	//发送异步请求
		$(form).ajaxSubmit({
		     type: 'post',
		     url: "System_Clazz_addClazz.action",
		     success: 
		    	function(data){
		    		var result=eval("("+data+")");
		    		if (result.success){
		    			//关闭添加页面
		    			$('#addClazzDialog').dialog('close');
					   	$.messager.show({
			                title:'操作提示',
			                msg:'添加班级成功',
			                showType:'show'
			            });
					   	//重新加载
					   	$('#clazzList').datagrid('reload');
					} else{
						$.messager.alert("操作提示","添加班级失败" ,"error");
					}
				}
		});     
	}
      
</script>
