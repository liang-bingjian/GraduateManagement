package com.benson.graduate.news.dao;

import java.util.List;

import com.benson.graduate.base.dao.BaseDao;
import com.benson.graduate.news.model.NewsNn;

public interface NewsNnDao extends BaseDao<NewsNn> {
	/**
	 * 获取新闻总数
	 * @param hql
	 * @return
	 */
	public Long getNewsNnCount(String hql, Object...objects);
	
	/**
	 * 批量删除  hql
	 * @param ids
	 */
	void deleteNewsNns(List<Integer> ids) ;
}
