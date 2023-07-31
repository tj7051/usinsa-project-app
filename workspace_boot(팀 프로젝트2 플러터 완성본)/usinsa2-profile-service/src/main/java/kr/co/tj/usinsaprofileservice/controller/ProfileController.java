package kr.co.tj.usinsaprofileservice.controller;

import java.io.File;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.io.FileUtils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import kr.co.tj.usinsaprofileservice.dto.ProfileDTO;
import kr.co.tj.usinsaprofileservice.dto.ProfileEntity;
import kr.co.tj.usinsaprofileservice.repository.ProfileRepository;
import kr.co.tj.usinsaprofileservice.service.ProfileService;

@Controller
@RequestMapping("/profile-service")
public class ProfileController {

	@Autowired
	private ProfileService fileService;

	@Autowired
	private ProfileRepository fileRepository;


	
	@GetMapping("/image/{username}")
	public ResponseEntity<?> findByUsername(@PathVariable("username") String username) {
		 byte[] fileBytes = fileService.findByUsername(username);
	      if (fileBytes != null) {
	         ByteArrayResource resource = new ByteArrayResource(fileBytes);
	         HttpHeaders headers = new HttpHeaders();
	         headers.setContentType(MediaType.IMAGE_JPEG);

	         return ResponseEntity.ok().headers(headers).contentLength(fileBytes.length).body(resource);
	      } else {
	         return ResponseEntity.notFound().build();
	      }
	   }



	
	@DeleteMapping("/profiledelete")
	public ResponseEntity<?> filedelete(@RequestBody ProfileDTO fileDTO){
		Map<String, Object> map = new HashMap<>();
		
		fileService.delete(fileDTO.getUsername());
		map.put("result", fileDTO);
		return ResponseEntity.ok().body(map);
		
	}
	
	@PostMapping("/profileupload")
	public ResponseEntity<?> fileupload(@RequestParam("file") MultipartFile file,
	                                    @RequestParam("username") String username) {
	    if (file.isEmpty()) {
	        return ResponseEntity.badRequest().body("파일이 비어 있습니다.");
	    }

	    String orgFilename = file.getOriginalFilename();
	    // 파일이 저장될 경로 설정
	    File path = new File("D:" + File.separator + "workspace" + File.separator +
	            "workspace_flutter" + File.separator + "usinsaapp" + File.separator + "asset"
	            + File.separator + "profil");

	    if (!path.exists()) {
	        path.mkdirs();
	    }

	    String datePath = ProfileService.makePath(path.getPath());
	    String savedName = ProfileService.makeFilename(orgFilename);

	    try {
	        byte[] fileBytes = file.getBytes(); // 파일 데이터를 byte 배열로 추출

	        // 파일을 저장하는 코드
	        FileUtils.writeByteArrayToFile(new File(path + datePath, savedName), fileBytes);

	        // 파일 정보를 DB에 저장하는 코드 추가
	        Date date = new Date();

	        System.out.println(savedName);

	        // 파일 정보를 DB에 저장하는 코드 추가
	        ProfileEntity fileEntity = new ProfileEntity();
	        fileEntity.setOriginalName(orgFilename);
	        fileEntity.setSavedName(savedName);
	        fileEntity.setUploadDate(date);
	        fileEntity.setUsername(username);

	        // 파일 데이터를 Base64로 인코딩하여 저장
	        String encodedFileData = Base64.getEncoder().encodeToString(fileBytes);
	        fileEntity.setFileBytes(encodedFileData.getBytes());

	        fileRepository.save(fileEntity); // 파일 정보를 DB에 저장합니다.

	        return ResponseEntity.ok().body("성공");
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return ResponseEntity.badRequest().body("실패");
	}
	

}
