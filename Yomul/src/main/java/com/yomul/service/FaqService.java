package com.yomul.service;


import java.util.ArrayList;

import com.yomul.vo.FaqVO;

public interface FaqService {

	int getAdminFaqWrite(FaqVO faq);
	
	ArrayList<FaqVO> getAdminFaqList();
}
