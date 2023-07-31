import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom';
import { InsertFetchFn, fetchFn } from '../etc/NetworkUtils';
import { Col, Container, Row } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';

function OrderInsert() {

  const username = localStorage.getItem("LOGINER");
  const id = useParams().id;
  const productId = useParams().id;
  const [item, setItem] = useState(null);
  const [unitPrice, setUnitPrice] = useState('');

  useEffect(() => {
    fetchFn("GET", `http://localhost:8000/item-service/item/id/${id}`, null)
        .then(data => {
            setItem(data);
        })
}, [id])

useEffect(() => {
  if (item) {
    // item에서 salePrice 값을 가져와서 unitPrice로 설정
    const price = item.price;
    const discount = item.discount;
 
    const salePrice = price-(price*(discount/100));
    setUnitPrice(salePrice);
  }
}, [item]);

  function onSubmitHandler(e){
    e.preventDefault();

    const formData = new FormData(e.target);
    const productId = formData.get('productId');
    const productName = formData.get('productName')
    const unitPrice = formData.get('unitPrice');
    const qty = formData.get('qty');
    const totalPrice = formData.get('totalPrice');

    const dto={
      username,
      productName,
      productId,
      unitPrice,
      qty,
      totalPrice
    }

    InsertFetchFn("order-service", dto, "orders");
  }

  

  const [qty, setQuantity] = useState(1);

  const handleQuantityChange = (event) => {
    const newQuantity = parseInt(event.target.value);
    if (newQuantity > 0) {
      setQuantity(newQuantity);
    } else {
      setQuantity(1);
    }
  };

  const calculateTotalPrice = () => {
    return unitPrice * qty;
  };


  return (
    <div>
        <h2>상품 주문</h2>
        {item !== null &&<>
          <Container>
          <Row className="justify-content-center">
          <Col md={6} className="text-center">
              <Form action='#' onSubmit={onSubmitHandler}>
                <Form.Group className="mb-3" controlId="formBasicEmail1">
                  <Form.Label><strong>아이디</strong></Form.Label>
                  <Col sm={40}>
                    <Form.Control value={username} disabled />
                  </Col>
                </Form.Group>
            <Form.Group className="mb-3" controlId="formBasicEmail7">
                  <Form.Label><strong>상품번호</strong></Form.Label>
                  <Col sm={40} className="d-flex justify-content-center">
                    <Form.Control name='productId' value={productId} readOnly/>
                  </Col>
                </Form.Group>
                <Form.Group className="mb-3" controlId="formBasicEmail7">
                  <Form.Label><strong>상품명</strong></Form.Label>
                  <Col sm={40} className="d-flex justify-content-center">
                    <Form.Control name='productName' value={item.itemName} readOnly/>
                  </Col>
                </Form.Group>
                <Form.Group className="mb-3" controlId="formBasicEmail7">
                  <Form.Label><strong>가격</strong></Form.Label>
                  <Col sm={40} className="d-flex justify-content-center">
                    <Form.Control name='unitPrice' value={unitPrice} readOnly/>
                  </Col>
                </Form.Group>
                <Form.Group className="mb-3" controlId="formBasicEmail7">
                  <Form.Label><strong>수량</strong></Form.Label>
                  <Col sm={40} className="d-flex justify-content-center">
                    <Form.Control type='number' name='qty' value={qty} onChange={handleQuantityChange}/>
                  </Col>
                </Form.Group>        
                <Form.Group className="mb-3" controlId="formBasicEmail7">
                  <Form.Label><strong>총가격</strong></Form.Label>
                  <Col sm={40} className="d-flex justify-content-center">
                    <Form.Control name='totalPrice' value={calculateTotalPrice()} readOnly/>
                  </Col>
                </Form.Group>
            <Button variant="dark" type="submit">
                  구매
                </Button>
        </Form> 
        </Col>
          </Row>
        </Container>
        
        </>}
        
       
    </div>
  )
}

// return (
//   <div>
//       <h2>상품 주문</h2>
//       {item !== null &&<>
//         <form action='#' onSubmit={onSubmitHandler}>
//           주문자: <input name='username' value={username} readOnly/><br/>
//           상품번호: <input name='productId' value={productId} readOnly/><br/>
//           상품이름: <input value={item.itemName} readOnly /><br/>
//           가격: <input name='unitPrice' value={unitPrice} readOnly/><br/>
//           수량: <input type="number" name='qty' value={qty} onChange={handleQuantityChange}/><br/>        
//           총 가격:<input name='totalPrice' value={calculateTotalPrice()} readOnly/>
//           <button>주문 완료</button>
//       </form> 
     
      
//       </>}
      
     
//   </div>
// )
// }

export default OrderInsert
