package com.yomul.service;

import java.util.List;

import com.yomul.vo.NearVO;

public interface NearService {
	//내근처 글쓰기
	public int getNearWrite(NearVO vo);
	
	//내 근처 홈 화면 보기
	public List<NearVO> selectNearList();
	
	// 내 근처 게시글 상세보기
	public NearVO getNearInfo(int no);
	
	// 내 근처 게시글 조회수 업데이트
	public boolean updateNearHits(int no);
}
