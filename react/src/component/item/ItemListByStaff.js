import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom';
import { fetchFn } from '../etc/NetworkUtils';
import ItemSearchPageByStaff from './ItemSearchPageByStaff';
import ItemComp from './ItemComp';

function ItemListByStaff() {
    const [pageList, setPageList] = useState([]);
    const username = useParams().username;

    // *** itemListOfStaff 해당 스태프의 리스트 가져오기 (x)
    useEffect(()=>{
        fetchFn("GET", `http://localhost:8000/item-service/list/search?username=${username}&pageNum=0`, null)
        .then((data) =>{
            setPageList(data.result.content);
        })
    },[username])

  return (
    <div style={{ marginTop: '30px', marginBottom: '30px' }}>

    <div style={{ display: 'flex', justifyContent: 'center', flexWrap: 'wrap' }}>
        {
            pageList.length > 0 && pageList.map(item => 
            <div key={item.id}  style={{ flexBasis: '10%', margin: '20px', minWidth: '300px' }}>
                <ItemComp key={item.id} item={item}/>
            </div>
            )
        }
        </div>
    
        <ItemSearchPageByStaff setFn={setPageList}/>
        
        </div>
  );
}

export default ItemListByStaff