package kr.co.tj.neworder2service.dto;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@Table(name = "order_items")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemEntity {
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "item_name")
    private String itemName;

    @Column(name = "item_price")
    private Long itemPrice;

    @Column(name = "item_id")
    private Long itemId;

    @Column(name = "item_stock")
    private Long itemStock;

    @Column(name = "item_seller_name")
    private String itemSellerName;

    @Column(name = "item_total_price")
    private Long itemTotalPrice;
    
    @Column(name = "order_id")
    private Long orderId;

}
