package kr.co.tj.usinsaprofileservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@EnableFeignClients
@SpringBootApplication
public class UsinsaProfileServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(UsinsaProfileServiceApplication.class, args);
	}

}
