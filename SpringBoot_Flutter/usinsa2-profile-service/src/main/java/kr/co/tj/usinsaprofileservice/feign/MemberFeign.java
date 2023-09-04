package kr.co.tj.usinsaprofileservice.feign;

import java.util.List;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

import kr.co.tj.usinsaprofileservice.dto.MemberResponse;

@Component
@FeignClient(name = "member-service")
public interface MemberFeign {

	@GetMapping("/members/username/{username}")
	ResponseEntity<MemberResponse> getMemberById(Long id);

	 @PutMapping("/members/user/username")
	 ResponseEntity<MemberResponse> updateMember(@RequestBody MemberResponse memberResponse);
}
