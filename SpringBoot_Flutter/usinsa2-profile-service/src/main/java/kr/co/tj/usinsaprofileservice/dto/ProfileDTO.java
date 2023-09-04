package kr.co.tj.usinsaprofileservice.dto;


import java.util.Date;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfileDTO {
	
	private Long id;
	private String originalName;
	private String savedName;
	private Date uploadDate;
	private String username;
	private byte[] filebyte;
	
	public static ProfileDTO toProfileDTO(ProfileEntity profileEntity) {
		// TODO Auto-generated method stub
		return ProfileDTO.builder()
				.id(profileEntity.getId())
				.originalName(profileEntity.getOriginalName())
				.savedName(profileEntity.getSavedName())
				.uploadDate(profileEntity.getUploadDate())
				.username(profileEntity.getUsername())
				.filebyte(profileEntity.getFileBytes())
				.build();
	}


}
