package com.yomul.service;

import java.util.ArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yomul.dao.ProductDAO;
import com.yomul.vo.CategoryVO;
import com.yomul.vo.MemberVO;
import com.yomul.vo.ProductVO;

@Service("productService")
public class ProductServiceImpl implements ProductService {

	@Autowired
	private ProductDAO productDAO;

	@Override
	public int getDelete(MemberVO member, ProductVO pvo) {
		return productDAO.deleteProduct(member, pvo);
	}

	@Override
	public String getProductSequence() {
		return productDAO.getProductSequence();
	}

	@Override
	public ArrayList<CategoryVO> getProductCategories() {
		return productDAO.getProductCategories();
	}

	@Override
	public int getProductWrite(ProductVO pvo) {
		return productDAO.getProductWrite(pvo) == 1 ? 1 : 0;
	}

	@Override
	public ArrayList<ProductVO> getProductList(ProductVO product, String page) {
		return productDAO.getProductList(product, page);
	}

	@Override
	public ProductVO getProductInfo(String no) {
		return productDAO.getProductInfo(no);
	}

	@Override
	public int getTotalPageCount(String search) {
		return productDAO.getTotalPageCount(search);
	}

	@Override
	public ArrayList<ProductVO> getProductList(int page, String search) {
		return productDAO.getProductList(page, search);
	}

}
