package kr.co.tj.usinsaprofileservice.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import kr.co.tj.usinsaprofileservice.dto.ProfileDTO;
import kr.co.tj.usinsaprofileservice.dto.ProfileEntity;
import kr.co.tj.usinsaprofileservice.repository.ProfileRepository;


@Service
public class ProfileService {
	
	@Autowired
	private ProfileRepository fileRepository;


public static int[] getCalendarInfo() {
		
		Calendar c = Calendar.getInstance();
		
		int year = c.get(Calendar.YEAR);
		int month = c.get(Calendar.MONTH)+1;
		int date = c.get(Calendar.DATE);
		
		int[] calendarInfo = {year, month, date};
		
		return calendarInfo;
	}
	
	public static String makePath(String uploadPath) {
		
		int[] calendarInfo = getCalendarInfo();
		
		int year = calendarInfo[0];
		String yearPath = File.separator+year;
		
		int month = calendarInfo[1];
		
		//폴더명이 5가 아닌 05처럼 만들기위해
		String sMonth = month < 10 ? "0"+month : month+"";
		String monthPath = yearPath+File.separator+sMonth;
		
		int date = calendarInfo[2];
		
		String sDate = date < 10 ? "0"+date : date+"";
		String datePath = monthPath+File.separator+sDate;
		
		
		makeDir(uploadPath, yearPath, monthPath, datePath);
		
		return datePath;
	}

	private static void makeDir(String uploadPath, String yearPath, String monthPath, String datePath) {
		
		File yearFile = new File(uploadPath, yearPath);
		
		if(!yearFile.exists()) {
			yearFile.mkdir();
		}
		
		File monthFile = new File(uploadPath, monthPath);
		
		if(!monthFile.exists()) {
			monthFile.mkdir();
		}
		
		File dateFile = new File(uploadPath, datePath);
		
		if(!dateFile.exists()) {
			dateFile.mkdir();
		}
	}
	
	
	public static String makeFilename(String orgFilename) {
		
		String uid = UUID.randomUUID().toString();
		String savedName = uid + "_" + orgFilename;
		
		return savedName;
	}
	
	public static MediaType getMediaType(String filename) {
		int idx = filename.lastIndexOf(".")+1;
		String formatName = filename.substring(idx);
		
		// 확장자의 대소문자 구분하지 않고 전부 소문자로 바꿔준다.
		formatName = formatName.toLowerCase();
		
		Map<String, MediaType> map = new HashMap<>();
		map.put("png", MediaType.IMAGE_PNG);
		map.put("gif", MediaType.IMAGE_GIF);
		map.put("jpg", MediaType.IMAGE_JPEG);
		map.put("jpeg", MediaType.IMAGE_JPEG);
		
		return map.get(formatName);
	}

	@Transactional
	public void delete(String username) {
		// TODO Auto-generated method stub
				
		fileRepository.deleteByUsername(username);

		
	}
	
	
	public byte[] getFileBytesByBId(Long bid) {
	    ProfileEntity fileEntity = fileRepository.findById(bid).orElse(null);
	    if (fileEntity != null) {
	        // Blob 데이터의 byte 배열 가져오기
	        byte[] fileBytes = fileEntity.getFileBytes();

	        return fileBytes;
	    }

	    return new byte[0];
	}
	

	public byte[] findByUsername(String username) {
	    Optional<ProfileEntity> fileEntity = fileRepository.findByUsername(username);
	    if (fileEntity.isPresent()) {
	        ProfileEntity entity = fileEntity.get();
	        String encodedFileData = new String(entity.getFileBytes());
	        return Base64.getDecoder().decode(encodedFileData);
	    }
	    return null;
	}

	
	
}
