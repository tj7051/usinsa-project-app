package kr.co.tj.usinsaprofileservice.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import kr.co.tj.usinsaprofileservice.dto.ProfileEntity;

public interface ProfileRepository extends JpaRepository<ProfileEntity, Long> {

//	FileEntity findByBid(Long bid);

	void deleteById(String id);

	void deleteByUsername(String username);

	Optional<ProfileEntity> findByUsername(String username);


}
