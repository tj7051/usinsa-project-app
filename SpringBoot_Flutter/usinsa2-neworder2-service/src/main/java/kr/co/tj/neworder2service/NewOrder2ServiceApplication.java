package kr.co.tj.neworder2service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class NewOrder2ServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(NewOrder2ServiceApplication.class, args);
	}

}
