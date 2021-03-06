package com.benson.graduate.news.service.impl;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import com.benson.graduate.base.pagemodel.DataGrid;
import com.benson.graduate.base.pagemodel.Pager;
import com.benson.graduate.base.service.impl.BaseServiceImpl;
import com.benson.graduate.news.dao.NewsNnDao;
import com.benson.graduate.news.dao.NewsPlateDao;
import com.benson.graduate.news.model.NewsNn;
import com.benson.graduate.news.model.NewsPlate;
import com.benson.graduate.news.pagemodel.PageNewsNn;
import com.benson.graduate.news.service.NewsNnService;
import com.benson.graduate.stu.pagemodel.PageStudentInfo;
import com.benson.graduate.sys.dao.EnumerationValueDao;
import com.benson.graduate.sys.model.EnumerationValue;
import com.benson.graduate.utils.CastUtil;
import com.benson.graduate.utils.StringUtil;

@Service("newsNnService")
public class NewsNnServiceImpl extends BaseServiceImpl implements
		NewsNnService {

	private NewsNnDao newsNnDao;
	@Resource(name="newsNnDao")
	public void setNewsNnDao(NewsNnDao newsNnDao) {
		this.newsNnDao = newsNnDao;
	}
	private NewsPlateDao newsPlateDao;
	@Resource(name="newsPlateDao")
	public void setNewsPlateDao(NewsPlateDao newsPlateDao) {
		this.newsPlateDao = newsPlateDao;
	}
	private EnumerationValueDao enumerationValueDao;
	@Resource(name="enumerationValueDao")
	public void setEnumerationValueDao(EnumerationValueDao enumerationValueDao) {
		this.enumerationValueDao = enumerationValueDao;
	}
	
	@Override
	public DataGrid getDataGrid(Map<String, Object> fieldMap, String sort, String order, int pageNow, int pageRows) {
		
		StringBuffer hql = new StringBuffer();
		List<Object> params = new ArrayList<Object>();
		String createName = CastUtil.castString(fieldMap.get("createName"));
		String title = CastUtil.castString(fieldMap.get("title"));
		String keyWords = CastUtil.castString(fieldMap.get("keyWords"));
		
		//拼接hql和准备参数
		hql.append("from NewsNn nn where 1=1");
		
		if(StringUtil.isNotEmpty(createName)){
			hql.append(" and nn.createName like ?");
			params.add("%" + createName + "%");
		}
		
		if(StringUtil.isNotEmpty(title)){
			hql.append(" and nn.title like ?");
			params.add("%" + title + "%");
		}
		
		if(StringUtil.isNotEmpty(keyWords)){
			hql.append(" and nn.keyWords like ?");
			params.add("%" + keyWords + "%");
		}
		
		if(StringUtil.isNotEmpty(sort)){
			if(StringUtil.isEmpty(order)){
				order = "desc";
			}
			hql.append(" order by "+sort+" "+order);
		}
		System.out.println(hql.toString());
		//查询
		List<NewsNn> newsNnList = getAllNewsNnByPage(hql.toString(), pageNow, pageRows, params);
		List<PageNewsNn> pageNewsList = changeToPageModelList(newsNnList);
		//构造easyui前端所需要的grid数据
		if (pageNewsList != null && pageNewsList.size() > 0) {
			DataGrid data = new DataGrid();
			data.setTotal(getTotals(hql.toString(), params));
			data.setRows(pageNewsList);
			return data;
		} else {
			DataGrid data = new DataGrid();
			data.setRows(new ArrayList<PageStudentInfo>());
			data.setTotal(0L);
			return data;
		}
	}
	
	public List<PageNewsNn> changeToPageModelList(List<NewsNn> newsNnList){
		List<PageNewsNn> pageNewsList = new ArrayList<PageNewsNn>();
		PageNewsNn pageNews = null;
		for(NewsNn nn : newsNnList){
			pageNews = new PageNewsNn();
			BeanUtils.copyProperties(nn, pageNews);
			if(StringUtil.isNotEmpty(nn.getPlateId()+"")){
				NewsPlate plate = newsPlateDao.getEntity(nn.getPlateId());
				if(plate!=null){
					pageNews.setPlateName(plate.getPlateName());
				}else{
					pageNews.setPlateName("");
				}
			}
			if(StringUtil.isNotEmpty(nn.getPlatePid()+"")){
				NewsPlate plate = newsPlateDao.getEntity(nn.getPlatePid());
				if(plate!=null){
					pageNews.setPlatePname(plate.getPlateName());
				}else{
					pageNews.setPlatePname("");
				}
			}
			EnumerationValue enumerationValue =null;
			//转换新闻类型字段
			enumerationValue=enumerationValueDao.getEntity(nn.getNewsType());
			if(enumerationValue!=null){
				pageNews.setNewsTypeStr(enumerationValue.getName());
			}
			pageNewsList.add(pageNews);
		}
		return pageNewsList;
	}
	
	public List<NewsNn> getAllNewsNnByPage(String hql, int pageNow, int pageRows, List<Object> params){
		return newsNnDao.findEntityByHQL(hql, pageNow, pageRows, params.toArray());
	}
	
	public Long getTotals(String hql, List<Object> params){
		hql="select count(*) "+hql;
		return newsNnDao.getNewsNnCount(hql, params.toArray());
	}

	@Override
	public NewsNn findById(int id) {
		return newsNnDao.getEntity(id);
	}
	
	@Override
	public List<NewsNn> findByNewsPlateId(int enVal){
		return newsNnDao.findEntityByHQL("from NewsNn n where n.newsType=?", enVal);
	}

	@Override
	public boolean insertNewsNn(NewsNn newsNn) {
		try {
			newsNnDao.saveEntity(newsNn);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}

	@Override
	public boolean deleteNewsNns(String idList) {
		try {
			newsNnDao.deleteNewsNns(stringToInt(idList));
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	//将逗号隔开的id列表转化为Integer数组
	public List<Integer> stringToInt(String idList){
		String []str_id=idList.split(",");
		List<Integer> ids=new ArrayList<Integer>();
		for(int i=0;i<str_id.length;i++){
			ids.add(Integer.parseInt(str_id[i]));
		}
		return ids;
	}

	@Override
	public boolean updateNewsNn(NewsNn newsNn) {
		try {
			newsNnDao.updateEntity(newsNn);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			return false;
		}
		return true;
	}

	@Override
	public boolean deleteFile(String path) {
		File file = new File(path);
		return file.delete();
	}

	@Override
	public Pager findNewsNnPager(int pageNumber, int pageSize, Map<String, Object> fieldMap) {
		StringBuffer condition = new StringBuffer();
		StringBuffer hqlCondition = new StringBuffer();
		List<Object> params = new ArrayList<Object>();
		
		String sort = CastUtil.castString(fieldMap.get("sort"));
		if(StringUtil.isEmpty(sort)){
			sort = " create_time desc ";
		}else{
			sort += " desc ";
		}
		
		condition.append(" 1 = 1");
		hqlCondition.append(" 1 = 1");
		
		String platePid = CastUtil.castString(fieldMap.get("platePid"));
		if(StringUtil.isNotEmpty(platePid)){
			condition.append(" and plate_pid = ?");
			hqlCondition.append(" and nn.platePid = ?");
			params.add(CastUtil.castInt(platePid));
		}
		
		String newsType = CastUtil.castString(fieldMap.get("newsType"));
		if(StringUtil.isNotEmpty(newsType)){
			condition.append(" and news_type = ?");
			hqlCondition.append(" and nn.newsType = ?");
			params.add(CastUtil.castInt(newsType));
		}
		
		long nnCount = selectCount("select count(*) from NewsNn nn where"+hqlCondition.toString(), params.toArray());
		
		//分页设置
		if(pageSize<1){
			pageSize=10;
		}
		//总页数
		long pageCount= nnCount%pageSize==0? nnCount/pageSize : nnCount/pageSize+1;
		if(pageNumber>pageCount){
			pageNumber=CastUtil.castInt(pageCount);
		}
		//避免查询总数为0的时候，页码也为0
		if (pageNumber <= 0) {
			pageNumber = 1;
		}

		StringBuffer sql = new StringBuffer();
		sql.append("select * from news_nn where");
		sql.append(condition);
		sql.append(" order by ").append(sort);
		sql.append(" limit ").append((pageNumber-1)*pageSize).append(",").append(pageSize);
		
		List<NewsNn> nnList = newsNnDao.findEntityListBySql(sql.toString(), params.toArray());
		return new Pager(pageNumber, pageSize, nnCount, nnList);
	}

	@Override
	public long selectCount(String sql, Object... objects) {
		try {
			return newsNnDao.getNewsNnCount(sql, objects);
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}
}
