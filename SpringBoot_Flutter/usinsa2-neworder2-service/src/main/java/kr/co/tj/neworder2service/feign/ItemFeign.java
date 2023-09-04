package kr.co.tj.neworder2service.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

import kr.co.tj.neworder2service.dto.NewOrder2DTO;


@FeignClient(name = "item-service")
public interface ItemFeign {
	
	@PutMapping("/item-service/item/productid3")
	public String updateEaByProductId3(@RequestBody NewOrder2DTO newOrder2DTO);

}
